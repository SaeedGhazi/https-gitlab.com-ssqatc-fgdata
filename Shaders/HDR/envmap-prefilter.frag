#version 330 core

out vec3 fragColor;

in vec3 cubemapCoord;

uniform samplerCube envmap;
uniform float roughness;

uniform int fg_CubemapFace;

const float PI = 3.14159265359;

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

vec3 ImportanceSampleGGX(vec2 Xi, vec3 n, float r)
{
    float a = r*r;

    float phi = 2.0 * PI * Xi.x;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a*a - 1.0) * Xi.y));
    float sinTheta = sqrt(1.0 - cosTheta*cosTheta);

    vec3 h;
    h.x = sinTheta * cos(phi);
    h.y = sinTheta * sin(phi);
    h.z = cosTheta;

    vec3 up        = abs(n.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
    vec3 tangent   = normalize(cross(up, n));
    vec3 bitangent = cross(n, tangent);

    vec3 sampleVec = tangent * h.x + bitangent * h.y + n * h.z;
    return normalize(sampleVec);
}

void main()
{
    vec3 n = normalize(cubemapCoord);
    vec3 v = n; // n = v simplification

    vec3 prefilteredColor = vec3(0.0);
    float totalWeight = 0.0;
    const uint NUM_SAMPLES = 1024u;

    for (uint i = 0u; i < NUM_SAMPLES; ++i) {
        vec2 Xi = Hammersley(i, NUM_SAMPLES);
        vec3 h = ImportanceSampleGGX(Xi, n, roughness);
        vec3 l = normalize(2.0 * dot(v, h) * h - v);

        float NdotL = max(dot(n, l), 0.0);
        if (NdotL > 0.0) {
            prefilteredColor += textureLod(envmap, l, 0.0).rgb * NdotL;
            totalWeight += NdotL;
        }
    }

    prefilteredColor /= totalWeight;

    fragColor = prefilteredColor;
}
