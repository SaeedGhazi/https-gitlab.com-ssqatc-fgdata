// An implementation of Sébastien Hillaire's "A Scalable and Production Ready
// Sky and Atmosphere Rendering Technique".
//
// This shader generates the sky-view texture. Since the sky generally has low
// frequency detail, it's possible to pre-compute it on a small texture and
// sample it later when rendering the skydome. This effectively bypasses the
// need for raymarching on screen-sized textures, which is specially costly on
// larger resolutions like 4K.

#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D transmittance_lut;
uniform sampler2D multiscattering_lut;

uniform float fg_SunZenithCosTheta;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_EarthRadius;

const float PI = 3.141592653;

const float ATMOSPHERE_RADIUS = 6471e3;
const int SCATTERING_SAMPLES = 32;

float raySphereIntersection(vec3 ro, vec3 rd, float radius);
vec3 sampleMedium(in float height,
                  out float mieScattering, out float mieAbsorption,
                  out vec3 rayleighScattering, out vec3 ozoneAbsorption);
float miePhaseFunction(float cosTheta);
float rayleighPhaseFunction(float cosTheta);
vec3 getValueFromLUT(sampler2D lut, float sunCosTheta, float normalizedHeight);

void main()
{
    // Always leave the sun right in the middle of the texture as the skydome
    // model is already being rotated.
    vec3 sunDir = vec3(-sqrt(1.0 - fg_SunZenithCosTheta*fg_SunZenithCosTheta),
                       0.0,
                       fg_SunZenithCosTheta);

    float azimuth = 2.0 * PI * texCoord.x; // [0, 2pi]
    // Apply a non-linear transformation to the elevation to dedicate more
    // texels to the horizon, which is where having more detail matters.
    float l = texCoord.y * 2.0 - 1.0;
    float elev = l*l * sign(l) * PI * 0.5; // [-pi/2, pi/2]
    vec3 rayDir = vec3(cos(elev) * cos(azimuth), cos(elev) * sin(azimuth), sin(elev));

    vec3 rayOrigin = vec3(0.0, 0.0, fg_CameraDistanceToEarthCenter);

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
        fragColor = vec3(0.0);
        return;
    }

    float cosTheta = dot(rayDir, sunDir);
    float miePhase = miePhaseFunction(cosTheta);
    float rayleighPhase = rayleighPhaseFunction(-cosTheta);

    vec3 L = vec3(0.0);
    vec3 throughput = vec3(1.0);
    float t = 0.0;

    for (int i = 0; i < SCATTERING_SAMPLES; ++i) {
        float newT = ((float(i) + 0.3) / SCATTERING_SAMPLES) * tmax;
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

    fragColor = L;
}
