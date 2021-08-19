// An implementation of Sébastien Hillaire's "A Scalable and Production Ready
// Sky and Atmosphere Rendering Technique".
//
// This shader generates the multiple scattering LUT.

#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D transmittance_lut;

uniform float fg_EarthRadius;

const float PI = 3.141592653;
const float ATMOSPHERE_RADIUS = 6471e3;
const int SQRT_SAMPLES = 4;
const float INV_SAMPLES = 1.0 / float(SQRT_SAMPLES*SQRT_SAMPLES);
const int MULTIPLE_SCATTERING_SAMPLES = 20;

const vec3 ground_albedo = vec3(0.3);

float raySphereIntersection(vec3 ro, vec3 rd, float radius);
vec3 sampleMedium(in float height,
                  out float mieScattering, out float mieAbsorption,
                  out vec3 rayleighScattering, out vec3 ozoneAbsorption);
float miePhaseFunction(float cosTheta);
float rayleighPhaseFunction(float cosTheta);
vec3 getValueFromLUT(sampler2D lut, float sunCosTheta, float normalizedHeight);

vec3 generateRayDir(float theta, float phi)
{
    float cosPhi = cos(phi);
    float sinPhi = sin(phi);
    float cosTheta = cos(theta);
    float sinTheta = sin(theta);
    return vec3(cosTheta * sinPhi, sinTheta * sinPhi, cosPhi);
}

void main()
{
    float sunCosTheta = texCoord.x * 2.0 - 1.0;
    vec3 sunDir = vec3(-sqrt(1.0 - sunCosTheta*sunCosTheta), 0.0, sunCosTheta);

    float altitude = mix(fg_EarthRadius, ATMOSPHERE_RADIUS, texCoord.y);
    vec3 rayOrigin = vec3(0.0, 0.0, altitude);

    vec3 Ltotal = vec3(0.0);
    vec3 LMStotal = vec3(0.0);

    for (int i = 0; i < SQRT_SAMPLES; ++i) {
        for (int j = 0; j < SQRT_SAMPLES; ++j) {
            float theta = 2.0 * PI * (float(i) + 0.5) / float(SQRT_SAMPLES);
            float phi = PI * (float(j) + 0.5) / float(SQRT_SAMPLES);
            vec3 rayDir = generateRayDir(theta, phi);

            float atmosDist = raySphereIntersection(rayOrigin, rayDir, ATMOSPHERE_RADIUS);
            float groundDist = raySphereIntersection(rayOrigin, rayDir, fg_EarthRadius);

            float tmax;
            if (groundDist < 0.0) {
                // No ground collision, use the distance to the outer atmosphere
                tmax = atmosDist;
            } else {
                // Use the distance to the ground
                tmax = groundDist;
            }

            float cosTheta = dot(rayDir, sunDir);
            float miePhase = miePhaseFunction(cosTheta);
            float rayleighPhase = rayleighPhaseFunction(-cosTheta);

            vec3 L = vec3(0.0);
            vec3 LMS = vec3(0.0);
            vec3 throughput = vec3(1.0);
            float t = 0.0;

            for (int k = 0; k < MULTIPLE_SCATTERING_SAMPLES; ++k) {
                float newT = ((float(k) + 0.3) / MULTIPLE_SCATTERING_SAMPLES) * tmax;
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
                    transmittance_lut, sunCosTheta, normalizedHeight);

                vec3 S = (rayleighScattering * rayleighPhase +
                          mieScattering * miePhase) * sunTransmittance;

                // Not using the power serie
                vec3 MS = mieScattering + rayleighScattering;
                vec3 MSint = (MS - MS * sampleTransmittance) / extinction;
                LMS += throughput * MSint;

                vec3 Sint = (S - S * sampleTransmittance) / extinction;
                L += throughput * Sint;
                throughput *= sampleTransmittance;
            }

            if (groundDist >= 0.0) {
                // Account for bounced light off the Earth
                vec3 p = rayOrigin + rayDir * groundDist;
                float pHeight = length(p);
                vec3 up = p / pHeight;

                float normHeight = (pHeight - fg_EarthRadius)
                    / (ATMOSPHERE_RADIUS - fg_EarthRadius);
                float sunZenithCosTheta = dot(sunDir, up);

                vec3 transmittanceFromGround = getValueFromLUT(
                    transmittance_lut, sunZenithCosTheta, normHeight);
                L += transmittanceFromGround * throughput
                    * clamp(sunZenithCosTheta, 0.0, 1.0) * ground_albedo / PI;
            }

            Ltotal += L * INV_SAMPLES;
            LMStotal += LMS * INV_SAMPLES;
        }
    }

    fragColor = Ltotal / (1.0 - LMStotal);
}
