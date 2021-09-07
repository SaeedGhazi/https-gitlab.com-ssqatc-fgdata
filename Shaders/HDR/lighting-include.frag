#version 330 core

uniform sampler2D dfg_lut;
uniform samplerCube prefiltered_envmap;

const float PI = 3.14159265359;
const float RECIPROCAL_PI = 0.31830988618;
const float DIELECTRIC_SPECULAR = 0.04;
const float MAX_PREFILTERED_LOD = 4.0;

//------------------------------------------------------------------------------
// BRDF utility functions

/**
 * Fresnel term with included roughness to get a pleasant visual result.
 * See https://seblagarde.wordpress.com/2011/08/17/hello-world/
 */
vec3 F_SchlickRoughness(float NdotV, vec3 F0, float r)
{
    return F0 + (max(vec3(1.0 - r), F0) - F0) * pow(max(1.0 - NdotV, 0.0), 5.0);
}

/**
 * Fresnel (specular F)
 * Schlick's approximation for the Cook-Torrance BRDF.
 */
vec3 F_Schlick(float VdotH, vec3 F0)
{
    return F0 + (vec3(1.0) - F0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);
}

float F_Schlick(float VdotH, float F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);
}

/**
 * Normal distribution function (NDF) (specular D)
 * Trowbridge-Reitz/GGX microfacet distribution. Includes Disney's
 * reparametrization of a=roughness*roughness
 */
float D_GGX(float NdotH, float a2)
{
    float f = (NdotH * a2 - NdotH) * NdotH + 1.0;
    return a2 / (PI * f * f);
}

/**
 * Geometric attenuation (specular G)
 * Smith-GGX formulation.
 */
float G_SmithGGX(float NdotV, float NdotL, float a2)
{
    float attV = 2.0 * NdotV / (NdotV + sqrt(a2 + (1.0 - a2) * (NdotV * NdotV)));
    float attL = 2.0 * NdotL / (NdotL + sqrt(a2 + (1.0 - a2) * (NdotL * NdotL)));
    return attV * attL;
}

/**
 * Basic Lambertian diffuse BRDF
 */
vec3 Fd_Lambert(vec3 c_diff)
{
    return c_diff * RECIPROCAL_PI;
}

/**
 * Get the fresnel reflectance at 0 degrees (light hitting the surface
 * perpendicularly).
 */
vec3 getF0Reflectance(vec3 baseColor, float metallic)
{
    return mix(vec3(DIELECTRIC_SPECULAR), baseColor, metallic);
}

//------------------------------------------------------------------------------
// IBL evaluation

/**
 * Indirect diffuse irradiance
 * To get better results we should be precomputing the irradiance into a cubemap
 * or calculating spherical harmonics coefficients on the CPU.
 * Sampling the roughness=1 mipmap level of the prefiltered specular map
 * works too. :)
 */
vec3 evaluateDiffuseIrradianceIBL(vec3 n)
{
    int roughnessOneLevel = int(MAX_PREFILTERED_LOD);
    ivec2 s = textureSize(prefiltered_envmap, roughnessOneLevel);
    float du = 1.0 / float(s.x);
    float dv = 1.0 / float(s.y);
    vec3 m0 = normalize(cross(n, vec3(0.0, 1.0, 0.0)));
    vec3 m1 = cross(m0, n);
    vec3 m0du = m0 * du;
    vec3 m1dv = m1 * dv;

    vec3 c;
    c  = textureLod(prefiltered_envmap, n - m0du - m1dv, roughnessOneLevel).rgb;
    c += textureLod(prefiltered_envmap, n + m0du - m1dv, roughnessOneLevel).rgb;
    c += textureLod(prefiltered_envmap, n + m0du + m1dv, roughnessOneLevel).rgb;
    c += textureLod(prefiltered_envmap, n - m0du + m1dv, roughnessOneLevel).rgb;
    return c * 0.25;
}

/**
 * Indirect specular (ambient specular)
 * Sample from the prefiltered environment map.
 */
vec3 evaluateSpecularIBL(float NdotV, vec3 reflected, float roughness, vec3 f)
{
    vec3 prefilteredColor = textureLod(prefiltered_envmap,
                                       reflected,
                                       roughness * MAX_PREFILTERED_LOD).rgb;
    vec2 envBRDF = texture(dfg_lut, vec2(NdotV, roughness)).rg;
    return prefilteredColor * (f * envBRDF.x + envBRDF.y);
}

vec3 evaluateIBL(
    vec3 baseColor,
    float metallic,
    float roughness,
    vec3 f0,                  // Use getF0Reflectance() to obtain this
    float visibility,
    vec3 nWorldSpace,         // Normal in world space
    float NdotV,              // Must be positive and non-zero
    vec3 reflected            // Reflected vector in world space: reflect(-v, n)
    )
{
    vec3 f = F_SchlickRoughness(NdotV, f0, roughness);

    vec3 specular = evaluateSpecularIBL(NdotV, reflected, roughness, f);
    vec3 diffuse = evaluateDiffuseIrradianceIBL(nWorldSpace) * baseColor
        * (vec3(1.0) - f) * (1.0 - metallic);

    return (diffuse + specular) * visibility;
}

//------------------------------------------------------------------------------
// Analytical light source evaluation

vec3 evaluateLight(
    vec3 baseColor,
    float metallic,
    float roughness,
    vec3 f0,                  // Use getF0Reflectance() to obtain this
    vec3 intensity,
    float visibility,
    vec3 n,
    vec3 l,
    vec3 v,
    float NdotL,              // Must not be clamped to [0,1]
    float NdotV               // Must be positive and non-zero
    )
{
    // Skip fragments that are completely occluded or that are not facing the light
    if (visibility <= 0.0 || NdotL <= 0.0)
        return vec3(0.0);

    NdotL = clamp(NdotL, 0.001, 1.0);

    vec3 h = normalize(v + l);
    float NdotH = clamp(dot(n, h), 0.0, 1.0);
    float VdotH = clamp(dot(v, h), 0.0, 1.0);

    vec3 c_diff = mix(baseColor * (1.0 - DIELECTRIC_SPECULAR), vec3(0.0), metallic);

    // Avoid blown out lighting by capping the roughness to a non-zero value
    float a = max(roughness * roughness, 0.001);
    float a2 = a * a;

    vec3 F = F_Schlick(VdotH, f0);
    float D = D_GGX(NdotH, a2);
    float G = G_SmithGGX(NdotV, NdotL, a2);

    // Diffuse term: Lambertian diffuse model
    vec3 f_diffuse = (vec3(1.0) - F) * Fd_Lambert(c_diff);

    // Specular term: Cook-Torrance specular microfacet model
    vec3 f_specular = ((D * G) * F) / (4.0 * NdotV * NdotL);

    vec3 material = f_diffuse + f_specular;

    vec3 color = material * intensity * visibility;
    return color;
}
