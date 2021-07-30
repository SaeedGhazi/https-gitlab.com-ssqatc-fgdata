#version 330 core

out vec3 fragHdrColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D gbuffer1_tex;
uniform sampler2D gbuffer2_tex;
uniform sampler2D depth_tex;
uniform sampler2D ao_tex;
uniform samplerCube prefiltered_envmap;
uniform sampler2DShadow shadow_tex;
uniform sampler2D dfg_lut;
uniform sampler2D aerial_perspective_lut;
uniform sampler2D transmittance_lut;

uniform mat4 fg_ViewMatrix;
uniform mat4 fg_ViewMatrixInverse;
uniform vec3 fg_SunDirection;
uniform vec3 fg_SunDirectionWorld;
uniform vec3 fg_CameraPositionCart;
uniform vec3 fg_CameraPositionGeod;

uniform mat4 fg_LightMatrix_csm0;
uniform mat4 fg_LightMatrix_csm1;
uniform mat4 fg_LightMatrix_csm2;
uniform mat4 fg_LightMatrix_csm3;

const float PI = 3.14159265359;
const float RECIPROCAL_PI = 0.31830988618;

const int sun_atlas_size = 8192;

const float DEPTH_BIAS = 2.0;
const float BAND_SIZE = 0.1;
const vec2 BAND_BOTTOM_LEFT = vec2(BAND_SIZE);
const vec2 BAND_TOP_RIGHT   = vec2(1.0 - BAND_SIZE);

// Ideally these should be passed as an uniform, but we don't support uniform
// arrays yet
const vec2 uv_shifts[4] = vec2[4](
    vec2(0.0, 0.0), vec2(0.5, 0.0),
    vec2(0.0, 0.5), vec2(0.5, 0.5));
const vec2 uv_factor = vec2(0.5, 0.5);

const float AERIAL_SLICES = 16.0;
const float AERIAL_LUT_TILE_SIZE = 1.0 / AERIAL_SLICES;
const float AERIAL_LUT_TEXEL_SIZE = 1.0 / 512.0;
const float AERIAL_MAX_DEPTH = 32000.0;

const float MAX_PREFILTERED_LOD = 4.0;

const float ATMOSPHERE_RADIUS = 6471e3;
const vec3 EXTRATERRESTRIAL_SOLAR_ILLUMINANCE = vec3(128.0);

vec3 decodeNormal(vec2 enc);
vec3 positionFromDepth(vec2 pos, float depth);

//------------------------------------------------------------------------------
// Shadow mapping related stuff

float sampleOffset(vec4 pos, vec2 offset, vec2 invTexelSize)
{
    return texture(
        shadow_tex, vec3(
            pos.xy + offset * invTexelSize,
            pos.z - DEPTH_BIAS * invTexelSize));
}

// OptimizedPCF from https://github.com/TheRealMJP/Shadows
// Original by Ignacio Castaño for The Witness
// Released under The MIT License
float sampleOptimizedPCF(vec4 pos)
{
    vec2 invTexSize = vec2(1.0 / float(sun_atlas_size));

    vec2 uv = pos.xy * sun_atlas_size;
    vec2 base_uv = floor(uv + 0.5);
    float s = (uv.x + 0.5 - base_uv.x);
    float t = (uv.y + 0.5 - base_uv.y);
    base_uv -= vec2(0.5);
    base_uv *= invTexSize;
    pos.xy = base_uv.xy;

    float sum = 0.0;

    float uw0 = (4.0 - 3.0 * s);
    float uw1 = 7.0;
    float uw2 = (1.0 + 3.0 * s);

    float u0 = (3.0 - 2.0 * s) / uw0 - 2.0;
    float u1 = (3.0 + s) / uw1;
    float u2 = s / uw2 + 2.0;

    float vw0 = (4.0 - 3.0 * t);
    float vw1 = 7.0;
    float vw2 = (1.0 + 3.0 * t);

    float v0 = (3.0 - 2.0 * t) / vw0 - 2.0;
    float v1 = (3.0 + t) / vw1;
    float v2 = t / vw2 + 2.0;

    sum += uw0 * vw0 * sampleOffset(pos, vec2(u0, v0), invTexSize);
    sum += uw1 * vw0 * sampleOffset(pos, vec2(u1, v0), invTexSize);
    sum += uw2 * vw0 * sampleOffset(pos, vec2(u2, v0), invTexSize);

    sum += uw0 * vw1 * sampleOffset(pos, vec2(u0, v1), invTexSize);
    sum += uw1 * vw1 * sampleOffset(pos, vec2(u1, v1), invTexSize);
    sum += uw2 * vw1 * sampleOffset(pos, vec2(u2, v1), invTexSize);

    sum += uw0 * vw2 * sampleOffset(pos, vec2(u0, v2), invTexSize);
    sum += uw1 * vw2 * sampleOffset(pos, vec2(u1, v2), invTexSize);
    sum += uw2 * vw2 * sampleOffset(pos, vec2(u2, v2), invTexSize);

    return sum / 144.0;
}

float sampleCascade(vec4 p, vec2 shift)
{
    vec4 pos = p;
    pos.xy *= uv_factor;
    pos.xy += shift;
    return sampleOptimizedPCF(pos);
}

float sampleAndBlendBand(vec4 p1, vec4 p2, vec2 s1, vec2 s2)
{
    vec2 s = smoothstep(vec2(0.0), BAND_BOTTOM_LEFT, p1.xy)
        - smoothstep(BAND_TOP_RIGHT, vec2(1.0), p1.xy);
    float blend = 1.0 - s.x * s.y;
    return mix(sampleCascade(p1, s1),
               sampleCascade(p2, s2),
               blend);
}

bool checkWithinBounds(vec2 coords, vec2 bottomLeft, vec2 topRight)
{
    vec2 r = step(bottomLeft, coords) - step(topRight, coords);
    return bool(r.x * r.y);
}

bool isInsideCascade(vec4 p)
{
    return checkWithinBounds(p.xy, vec2(0.0), vec2(1.0)) && ((p.z / p.w) <= 1.0);
}

bool isInsideBand(vec4 p)
{
    return !checkWithinBounds(p.xy, BAND_BOTTOM_LEFT, BAND_TOP_RIGHT);
}

/**
 * Get the light space position of point p.
 * Both p and n must be in view space. The light matrix is also assumed to
 * transform from view space to light space.
 */
vec4 getLightSpacePosition(vec3 p, vec3 n, float NdotL, float bias,
                           mat4 lightMatrix)
{
    float sinTheta = sqrt(1.0 - NdotL * NdotL);
    vec3 offset = p + n * (sinTheta * bias);
    return lightMatrix * vec4(offset, 1.0);
}

/**
 * Get shadowing factor for a given position. 1.0 corresponds to a fragment
 * being completely lit, and 0.0 to a fragment being completely in shadow.
 * Both p and n must be in view space.
 */
float getShadowing(vec3 p, vec3 n, float NdotL)
{
    float shadow = 1.0;

    vec4 lightSpacePos[4];
    lightSpacePos[0] = getLightSpacePosition(p, n, NdotL, 0.05, fg_LightMatrix_csm0);
    lightSpacePos[1] = getLightSpacePosition(p, n, NdotL, 0.2, fg_LightMatrix_csm1);
    lightSpacePos[2] = getLightSpacePosition(p, n, NdotL, 1.0, fg_LightMatrix_csm2);
    lightSpacePos[3] = getLightSpacePosition(p, n, NdotL, 5.0, fg_LightMatrix_csm3);

    for (int i = 0; i < 4; ++i) {
        // Map-based cascade selection
        // We test if we are inside the cascade bounds to find the tightest
        // map that contains the fragment.
        if (isInsideCascade(lightSpacePos[i])) {
            if (isInsideBand(lightSpacePos[i]) && ((i+1) < 4)) {
                // Blend between cascades if the fragment is near the
                // next cascade to avoid abrupt transitions.
                shadow = clamp(sampleAndBlendBand(lightSpacePos[i],
                                                  lightSpacePos[i+1],
                                                  uv_shifts[i],
                                                  uv_shifts[i+1]),
                               0.0, 1.0);
            } else {
                // We are far away from the borders of the cascade, so
                // we skip the blending to avoid the performance cost
                // of sampling the shadow map twice.
                shadow = clamp(sampleCascade(lightSpacePos[i], uv_shifts[i]),
                               0.0, 1.0);
            }
            break;
        }
    }

    return shadow;
}

//------------------------------------------------------------------------------
// BRDF related stuff

/**
 * Indirect diffuse irradiance
 * To get better results we should be precomputing the irradiance into a cubemap
 * or calculating spherical harmonics coefficients on the CPU.
 * Sampling the roughness=1 mipmap level of the prefiltered specular map
 * works too. :)
 */
vec3 IBL_DiffuseIrradiance(vec3 n)
{
    vec4 worldSpaceNormal = fg_ViewMatrixInverse * vec4(n, 0.0);
    vec3 coord = worldSpaceNormal.xyz;

    int roughnessOneLevel = int(MAX_PREFILTERED_LOD);
    ivec2 s = textureSize(prefiltered_envmap, roughnessOneLevel);
    float du = 1.0 / float(s.x);
    float dv = 1.0 / float(s.y);
    vec3 m0 = normalize(cross(n, vec3(0.0, 1.0, 0.0)));
    vec3 m1 = cross(m0, n);
    vec3 m0du = m0 * du;
    vec3 m1dv = m1 * dv;

    vec3 c;
    c  = textureLod(prefiltered_envmap, coord - m0du - m1dv, roughnessOneLevel).rgb;
    c += textureLod(prefiltered_envmap, coord + m0du - m1dv, roughnessOneLevel).rgb;
    c += textureLod(prefiltered_envmap, coord + m0du + m1dv, roughnessOneLevel).rgb;
    c += textureLod(prefiltered_envmap, coord - m0du + m1dv, roughnessOneLevel).rgb;
    return c * 0.25;
}

/**
 * Indirect specular (ambient specular)
 * Sample from the prefiltered environment map.
 */
vec3 IBL_Specular(vec3 n, vec3 v, float NdotV, float roughness, vec3 F)
{
    vec4 reflectVec = vec4(reflect(-v, n), 0.0);
    vec4 worldReflectVec = fg_ViewMatrixInverse * reflectVec;

    vec3 prefilteredColor = textureLod(prefiltered_envmap,
                                       worldReflectVec.xyz,
                                       roughness * MAX_PREFILTERED_LOD).rgb;

    vec2 envBRDF = texture(dfg_lut, vec2(NdotV, roughness)).rg;

    return prefilteredColor * (F * envBRDF.x + envBRDF.y);
}

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
vec3 BRDF_Diffuse_Lambert(vec3 c_diff)
{
    return c_diff * RECIPROCAL_PI;
}

vec3 BRDF(in vec3 albedo, in float metalness, in float roughness,
          in float clearcoat, in float clearcoatRoughness,
          in float NdotL, in float NdotV, in float NdotH, in float VdotH,
          out vec3 f0)
{
    const float dielectricSpecular = 0.04;
    vec3 c_diff = mix(albedo * (1.0 - dielectricSpecular), vec3(0.0), metalness);
    f0 = mix(vec3(dielectricSpecular), albedo, metalness);

    float a = roughness * roughness;
    float a2 = a * a;

    vec3 F = F_Schlick(VdotH, f0);
    float D = D_GGX(NdotH, a2);
    float G = G_SmithGGX(NdotV, NdotL, a2);

    // Diffuse term
    // Lambertian diffuse model
    vec3 f_diffuse = (vec3(1.0) - F) * BRDF_Diffuse_Lambert(c_diff);

    // Specular term
    // Cook-Torrance specular microfacet model
    vec3 f_specular = F * D * G / (4.0 * NdotV * NdotL);

    return f_diffuse + f_specular;
}

//------------------------------------------------------------------------------
// Atmospheric scattering

vec4 sampleAerialPerspectiveSlice(int slice)
{
    // Sample at the pixel center
    float offset = slice * AERIAL_LUT_TILE_SIZE + AERIAL_LUT_TEXEL_SIZE * 0.5;
    float x = texCoord.x * (AERIAL_LUT_TILE_SIZE - AERIAL_LUT_TEXEL_SIZE) + offset;
    return texture(aerial_perspective_lut, vec2(x, texCoord.y));
}

vec4 sampleAerialPerspective(float depth)
{
    vec4 color;
    // Map to [0,1]
    float w = depth / AERIAL_MAX_DEPTH;
    // Squared distribution
    w = sqrt(clamp(w, 0.0, 1.0));
    // Remap to [0,16] to sample the right tile
    w *= AERIAL_SLICES;
    if (w <= 1.0) {
        // Handle special case of fragments behind the first slice
        color = mix(vec4(0.0, 0.0, 0.0, 1.0), sampleAerialPerspectiveSlice(0), w);
    } else {
        w -= 1.0; // [0,15]
        // Manually linearly interpolate between slices
        color = mix(sampleAerialPerspectiveSlice(int(floor(w))),
                    sampleAerialPerspectiveSlice(int(ceil(w))),
                    fract(w));
    }
    return color;
}

vec3 getSunIlluminance()
{
    float cameraHeight = length(fg_CameraPositionCart);
    vec3 up = fg_CameraPositionCart / cameraHeight;
    float cosTheta = dot(fg_SunDirectionWorld, up);

    float earthRadius = cameraHeight - max(fg_CameraPositionGeod.z, 0.0);
    float normalizedHeight = (cameraHeight - earthRadius)
        / (ATMOSPHERE_RADIUS - earthRadius);

    vec2 coords = vec2(cosTheta * 0.5 + 0.5, clamp(normalizedHeight, 0.0, 1.0));
    vec3 transmittance = texture(transmittance_lut, coords).rgb;

    return EXTRATERRESTRIAL_SOLAR_ILLUMINANCE * transmittance;
}

//------------------------------------------------------------------------------

void main()
{
    float depth = texture(depth_tex, texCoord).r;
    if (depth == 1.0) {
        fragHdrColor = vec3(0.0);
        return;
    }

    vec4 gbuffer0 = texture(gbuffer0_tex, texCoord);
    vec2 gbuffer1 = texture(gbuffer1_tex, texCoord).rg;
    vec4 gbuffer2 = texture(gbuffer2_tex, texCoord);
    float ao = texture(ao_tex, texCoord).r;

    vec3 pos = positionFromDepth(texCoord * 2.0 - 1.0, depth * 2.0 - 1.0);
    vec3 v = normalize(-pos);
    vec3 n = decodeNormal(gbuffer1);

    vec3 albedo = gbuffer0.rgb;
    float cavity = gbuffer0.a;
    float metalness = gbuffer2.r;
    float roughness = gbuffer2.g;
    float clearcoat = gbuffer2.b;
    float clearcoatRoughness = gbuffer2.a;

    vec3 l = fg_SunDirection;
    vec3 h = normalize(v + l);

    float NdotL = clamp(dot(n, l), 0.001, 1.0);
    float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);
    float NdotH = clamp(dot(n, h), 0.0, 1.0);
    float VdotH = clamp(dot(v, h), 0.0, 1.0);

    vec3 f0;
    vec3 brdf = BRDF(albedo, metalness, roughness,
                     clearcoat, clearcoatRoughness,
                     NdotL, NdotV, NdotH, VdotH,
                     f0);

    vec3 sunIlluminance = getSunIlluminance() * NdotL;

    vec3 f = F_SchlickRoughness(NdotV, f0, roughness);
    vec3 indirectSpecular = IBL_Specular(n, v, NdotV, roughness, f);
    vec3 indirectDiffuse = IBL_DiffuseIrradiance(n) * albedo
        * (vec3(1.0) - f) * (1.0 - metalness);

    vec3 ambient = (indirectDiffuse + indirectSpecular) * ao * cavity;
    float shadowFactor = getShadowing(pos, n, NdotL);
    vec3 color = ambient + brdf * sunIlluminance * shadowFactor;

    vec4 aerialPerspective = sampleAerialPerspective(length(pos));
    color = color * aerialPerspective.a + aerialPerspective.rgb
        * EXTRATERRESTRIAL_SOLAR_ILLUMINANCE;

    fragHdrColor = color;
}
