// An implementation of Sébastien Hillaire's "A Scalable and Production Ready
// Sky and Atmosphere Rendering Technique".
//
// This shader generates the aerial perspective LUT. This LUT is used by opaque
// and transparent objects to apply atmospheric scattering. In-scattering is
// stored in the RGB channels, while transmittance is stored in the alpha
// channel.
// Unlike the paper, we are using a tiled 2D texture instead of a true 3D
// texture. For some reason the overhead of rendering to a texture a lot of
// times (the depth of the 3D texture) seems to be too high, probably because
// OSG is not sharing state between those passes.

#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D transmittance_lut;
uniform sampler2D multiscattering_lut;

uniform mat4 fg_ViewMatrixInverse;
uniform vec3 fg_CameraPositionCart;
uniform vec3 fg_SunDirectionWorld;
uniform float fg_SunZenithCosTheta;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_EarthRadius;

const float PI = 3.141592653;
const float ATMOSPHERE_RADIUS = 6471e3;
const float TOTAL_SLICES = 32.0;
const float DEPTH_RANGE = 128000.0;
const int AERIAL_PERSPECTIVE_SAMPLES = 20;
const vec3 ONE_OVER_THREE = vec3(1.0 / 3.0);

vec3 positionFromDepth(vec2 pos, float depth);

float raySphereIntersection(vec3 ro, vec3 rd, float radius);
vec3 sampleMedium(in float height,
                  out float mieScattering, out float mieAbsorption,
                  out vec3 rayleighScattering, out vec3 ozoneAbsorption);
float miePhaseFunction(float cosTheta);
float rayleighPhaseFunction(float cosTheta);
vec3 getValueFromLUT(sampler2D lut, float sunCosTheta, float normalizedHeight);

void main()
{
    // Account for the depth layer we are currently in
    float x = texCoord.x * TOTAL_SLICES;
    vec2 coord = vec2(fract(x), texCoord.y);
    // Depth goes from the 0 to DEPTH_RANGE in a squared distribution.
    // The first slice is not at 0 since that would waste a slice.
    float w = ceil(x) / TOTAL_SLICES;
    w *= w;
    float depth = w * DEPTH_RANGE;

    vec3 fragPos = positionFromDepth(coord, 1.0);
    vec3 rayDir = vec4(fg_ViewMatrixInverse * vec4(normalize(fragPos), 0.0)).xyz;

    vec3 rayOrigin = fg_CameraPositionCart;

    // Handle the camera being underground
    float earthRadius = min(fg_EarthRadius, fg_CameraDistanceToEarthCenter);

    float atmosDist = raySphereIntersection(rayOrigin, rayDir, ATMOSPHERE_RADIUS);
    float groundDist = raySphereIntersection(rayOrigin, rayDir, earthRadius);

    float tmax;
    if (fg_CameraDistanceToEarthCenter < ATMOSPHERE_RADIUS) {
        // We are inside the atmosphere
        if (groundDist < 0.0) {
            // No ground collision, use the distance to the outer atmosphere
            tmax = atmosDist;
        } else {
            // Use the distance to the ground
            tmax = groundDist;
        }
    } else {
        // We are in outer space, skip
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    // Clip the max distance to the depth of this slice
    tmax = min(tmax, depth);

    float cosTheta = dot(rayDir, fg_SunDirectionWorld);
    float miePhase = miePhaseFunction(cosTheta);
    float rayleighPhase = rayleighPhaseFunction(cosTheta);

    vec3 L = vec3(0.0);
    vec3 throughput = vec3(1.0);
    float t = 0.0;

    for (int i = 0; i < AERIAL_PERSPECTIVE_SAMPLES; ++i) {
        float newT = ((float(i) + 0.3) / AERIAL_PERSPECTIVE_SAMPLES) * tmax;
        float dt = newT - t;
        t = newT;

        vec3 samplePos = rayOrigin + rayDir * t;
        float height = length(samplePos) - fg_EarthRadius;
        float normalizedHeight = height / (ATMOSPHERE_RADIUS - fg_EarthRadius);

        float mieScattering, mieAbsorption;
        vec3 rayleighScattering, ozoneAbsorption;
        vec3 extinction = sampleMedium(height, mieScattering, mieAbsorption,
                                       rayleighScattering, ozoneAbsorption);

        vec3 sampleTransmittance = exp(-dt*extinction);

        vec3 sunTransmittance = getValueFromLUT(
            transmittance_lut, fg_SunZenithCosTheta, normalizedHeight);
        vec3 multiscattering = getValueFromLUT(
            multiscattering_lut, fg_SunZenithCosTheta, normalizedHeight);

        vec3 S =
            rayleighScattering * (rayleighPhase * sunTransmittance + multiscattering) +
            mieScattering * (miePhase * sunTransmittance + multiscattering);

        vec3 Sint = (S - S * sampleTransmittance) / extinction;
        L += throughput * Sint;
        throughput *= sampleTransmittance;
    }

    // Instead of storing an entire vec3, store the mean of its components
    float transmittance = dot(throughput, ONE_OVER_THREE);

    fragColor = vec4(L, transmittance);
}
