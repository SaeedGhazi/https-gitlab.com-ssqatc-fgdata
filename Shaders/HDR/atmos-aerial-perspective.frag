#version 330 core

layout(location = 0) out vec3 out_inscatter;
layout(location = 1) out vec3 out_transmittance;

in vec2 texCoord;

uniform mat4 fg_ViewMatrixInverse;
uniform vec3 fg_CameraPositionCart;
uniform vec3 fg_CameraPositionGeod;
uniform vec3 fg_SunDirectionWorld;
uniform vec2 fg_NearFar;

const float TOTAL_SLICES = 16.0;
const float DEPTH_RANGE = 32000.0;

vec3 positionFromDepth(vec2 pos, float depth);
void calculateScattering(in vec3 rayOrigin,
                         in vec3 rayDir,
                         in float tmax,
                         in vec3 lightDir,
                         in float earthRadius,
                         out vec3 inscatter,
                         out vec3 transmittance);

void main()
{
    float x = texCoord.x * TOTAL_SLICES;
    vec2 coord = vec2(fract(x), texCoord.y);

    float depth = mix(fg_NearFar.x, DEPTH_RANGE, ceil(x) / TOTAL_SLICES);

    vec3 fragPos = positionFromDepth(coord * 2.0 - 1.0, 0.0);
    vec3 rayDir = vec4(fg_ViewMatrixInverse * vec4(normalize(fragPos), 0.0)).xyz;

    float earthRadius = length(fg_CameraPositionCart) - fg_CameraPositionGeod.z;

    vec3 inscatter, transmittance;
    calculateScattering(fg_CameraPositionCart,
                        rayDir,
                        depth,
                        fg_SunDirectionWorld,
                        earthRadius,
                        inscatter, transmittance);
    out_inscatter = inscatter;
    out_transmittance = transmittance;
}
