// An implementation of Sébastien Hillaire's "A Scalable and Production Ready
// Sky and Atmosphere Rendering Technique".
//
// This shader generates the transmittance LUT. It stores the transmittance to
// the Sun through the atmosphere for a given Sun zenith angle and a height
// inside the atmosphere (0 being the ground).

#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform float fg_EarthRadius;

const float ATMOSPHERE_RADIUS = 6471e3;
const int TRANSMITTANCE_STEPS = 40;

float raySphereIntersection(vec3 ro, vec3 rd, float radius);
vec3 sampleMedium(in float height,
                  out float mieScattering, out float mieAbsorption,
                  out vec3 rayleighScattering, out vec3 ozoneAbsorption);

void main()
{
    float sunCosTheta = texCoord.x * 2.0 - 1.0;
    vec3 sunDir = vec3(-sqrt(1.0 - sunCosTheta*sunCosTheta), 0.0, sunCosTheta);

    float altitude = mix(fg_EarthRadius, ATMOSPHERE_RADIUS, texCoord.y);
    vec3 rayOrigin = vec3(0.0, 0.0, altitude);

    float dist = raySphereIntersection(rayOrigin, sunDir, ATMOSPHERE_RADIUS);
    float t = 0.0;
    vec3 transmittance = vec3(1.0);

    for (int i = 0; i < TRANSMITTANCE_STEPS; ++i) {
        float newT = ((float(i) + 0.3) / TRANSMITTANCE_STEPS) * dist;
        float dt = newT - t;
        t = newT;

        vec3 samplePos = rayOrigin + sunDir * t;
        float height = length(samplePos) - fg_EarthRadius;

        float mieScattering, mieAbsorption;
        vec3 rayleighScattering, ozoneAbsorption;
        vec3 extinction = sampleMedium(height, mieScattering, mieAbsorption,
                                       rayleighScattering, ozoneAbsorption);

        transmittance *= exp(-dt * extinction);
    }

    fragColor = transmittance;
}
