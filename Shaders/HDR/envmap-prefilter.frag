// Mostly based on 'Moving Frostbite to Physically Based Rendering'
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf

#version 330 core

layout(location = 0) out vec3 fragColor0;
layout(location = 1) out vec3 fragColor1;
layout(location = 2) out vec3 fragColor2;
layout(location = 3) out vec3 fragColor3;
layout(location = 4) out vec3 fragColor4;
layout(location = 5) out vec3 fragColor5;

in vec3 cubemapCoord0;
in vec3 cubemapCoord1;
in vec3 cubemapCoord2;
in vec3 cubemapCoord3;
in vec3 cubemapCoord4;
in vec3 cubemapCoord5;

uniform samplerCube envmap;
uniform float roughness;
uniform int num_samples;

const float PI = 3.14159265359;
const float ENVMAP_SIZE = 128.0;
const float ENVMAP_MIP_COUNT = 4.0;

float RadicalInverse_VdC(uint bits)
{
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
    bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
    bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
    bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
    return float(bits) * 2.3283064365386963e-10; // / 0x100000000
}

vec2 Hammersley(uint i, uint N)
{
    return vec2(float(i)/float(N), RadicalInverse_VdC(i));
}

vec3 ImportanceSampleGGX(vec2 Xi, vec3 n, float a)
{
    float phi = 2.0 * PI * Xi.x;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a*a - 1.0) * Xi.y));
    float sinTheta = sqrt(1.0 - cosTheta*cosTheta);
    vec3 h;
    h.x = sinTheta * cos(phi);
    h.y = sinTheta * sin(phi);
    h.z = cosTheta;
    return h;
}

float D_GGX(float NdotH, float a2)
{
    float f = (NdotH * a2 - NdotH) * NdotH + 1.0;
    return a2 / (PI * f * f);
}

vec3 prefilter(vec3 n)
{
    vec3 v = n; // n = v simplification
    float a = roughness*roughness;

    vec3 prefilteredColor = vec3(0.0);
    float totalWeight = 0.0;

    vec3 up = abs(n.z) < 0.999f ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
    vec3 tangent = normalize(cross(up, n));
    vec3 bitangent = cross(n, tangent);
    mat3 tangentToWorld = mat3(tangent, bitangent, n);

    uint sample_count = uint(num_samples);
    for (uint i = 0u; i < sample_count; ++i) {
        vec2 Xi = Hammersley(i, sample_count);
        vec3 h = tangentToWorld * ImportanceSampleGGX(Xi, n, a);
        vec3 l = normalize(2.0 * dot(v, h) * h - v);

        float NdotL = max(dot(n, l), 0.0);
        if (NdotL > 0.0) {
            float NdotH = clamp(dot(n, h), 0.0, 1.0);
            float VdotH = clamp(dot(v, h), 0.0, 1.0);

            float pdf = D_GGX(NdotH, a) * NdotH / (4.0 * VdotH);
            float omegaS = 1.0 / (float(sample_count) * pdf);
            float omegaP = 4.0 * PI / (6.0 * ENVMAP_SIZE * ENVMAP_SIZE);
            float mipLevel = clamp(0.5 * log2(omegaS / omegaP) + 1.0,
                                   0.0, ENVMAP_MIP_COUNT);

            prefilteredColor += textureLod(envmap, l, mipLevel).rgb * NdotL;
            totalWeight += NdotL;
        }
    }

    return prefilteredColor / totalWeight;
}

void main()
{
    fragColor0 = prefilter(normalize(cubemapCoord0));
    fragColor1 = prefilter(normalize(cubemapCoord1));
    fragColor2 = prefilter(normalize(cubemapCoord2));
    fragColor3 = prefilter(normalize(cubemapCoord3));
    fragColor4 = prefilter(normalize(cubemapCoord4));
    fragColor5 = prefilter(normalize(cubemapCoord5));
}
