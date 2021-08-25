#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D gbuffer1_tex;
uniform sampler2D depth_tex;
uniform samplerCube prefiltered_envmap;
uniform sampler2D transmittance_lut;

uniform mat4 fg_ViewMatrixInverse;
uniform vec3 fg_SunDirection;
uniform float fg_SunZenithCosTheta;

const float PI = 3.14159265359;
const float RECIPROCAL_PI = 0.31830988618;
const float MAX_PREFILTERED_LOD = 4.0;
const vec3 EXTRATERRESTRIAL_SOLAR_ILLUMINANCE = vec3(128.0);

vec3 decodeNormal(vec2 enc);
vec3 positionFromDepth(vec2 pos, float depth);
vec3 addAerialPerspective(vec3 color, vec2 coord, float depth);

float F_Schlick(float VdotH, float F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0);
}

float D_GGX(float NdotH, float a2)
{
    float f = (NdotH * a2 - NdotH) * NdotH + 1.0;
    return a2 / (PI * f * f);
}

void main()
{
    float depth = texture(depth_tex, texCoord).r;
    vec3 pos = positionFromDepth(texCoord, depth);

    vec3 v = normalize(-pos);
    vec3 n = decodeNormal(texture(gbuffer1_tex, texCoord).rg);
    vec3 l = fg_SunDirection;

    vec3 reflected = reflect(-v, n);
    vec3 worldNormal = (fg_ViewMatrixInverse * vec4(n, 0.0)).xyz;
    vec3 worldReflected = (fg_ViewMatrixInverse * vec4(reflected, 0.0)).xyz;

    float NdotL = clamp(dot(n, l), 0.0, 1.0);
    float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);
    vec3 h = normalize(v + l);
    float NdotH = clamp(dot(n, h), 0.0, 1.0);

    // Get transmittance from Sun to the sea surface (assume the water is
    // always at sea level, i.e. normalizedAltitude = 0)
    vec3 transmittance = texture(transmittance_lut,
                                 vec2(fg_SunZenithCosTheta * 0.5 + 0.5, 0.0)).rgb;
    vec3 sunIntensity = EXTRATERRESTRIAL_SOLAR_ILLUMINANCE * transmittance;

    const float f0 = 0.02; // For IOR=1.33
    float fresnel = F_Schlick(NdotV, f0);

    // Refracted light
    vec3 seaColor = texture(gbuffer0_tex, texCoord).rgb;
    vec3 Esky = textureLod(prefiltered_envmap, worldNormal, MAX_PREFILTERED_LOD).rgb;
    vec3 refracted = seaColor * Esky * RECIPROCAL_PI;

    // Reflected sky light
    vec3 reflection = textureLod(prefiltered_envmap, worldReflected, 1.0).rgb;

    vec3 color = mix(refracted, reflection, fresnel);

    // Add reflected Sun light
    color += RECIPROCAL_PI * fresnel * D_GGX(NdotH, 0.001) * sunIntensity * NdotL;

    color = addAerialPerspective(color, texCoord, length(pos));

    fragColor = color;
}
