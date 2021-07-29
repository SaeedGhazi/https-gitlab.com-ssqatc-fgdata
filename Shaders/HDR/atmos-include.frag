// An implementation of Sébastien Hillaire's "A Scalable and Production Ready
// Sky and Atmosphere Rendering Technique".

#version 330 core

const float PI = 3.141592653;

// Atmosphere parameters
// Section 2.1 of [Bruneton08], units are inverse meters
const float mie_density_height_scale = 8.33333e-4;   // Hm=1.2km
const float rayleigh_density_height_scale = 1.25e-4; // Hr=8km
const float mie_scattering = 3.996e-6;
const float mie_absorption = 4.4e-6;
const vec3 rayleigh_scattering = vec3(5.802, 13.558, 33.1) * vec3(1e-6);
const vec3 ozone_absorption = vec3(0.650, 1.881, 0.085) * vec3(1e-6);

const float g = 0.8;
const float gg = g*g;
const float mie_phase_scale = 3.0/(8.0*PI);
const float rayleigh_phase_scale = 3.0/(16.0*PI);

// Returns the distance between ro and the first intersection with the sphere
// or -1.0 if there is no intersection.
// -1.0 is also returned if the ray is pointing away from the sphere.
float raySphereIntersection(vec3 ro, vec3 rd, float radius)
{
    float b = dot(ro, rd);
    float c = dot(ro, ro) - radius*radius;
    if (c > 0.0 && b > 0.0) return -1.0;
    float d = b*b - c;
    if (d < 0.0) return -1.0;
    if (d > b*b) return (-b+sqrt(d));
    return (-b-sqrt(d));
}

// Sample the sky medium properties at a height in meters, 0 being the ground
// and ~100km being the top of the atmosphere.
// Returns the total atmospheric extinction.
vec3 sampleMedium(in float height,
                  out float mieScattering, out float mieAbsorption,
                  out vec3 rayleighScattering, out vec3 ozoneAbsorption)
{
    float densityMie = exp(-mie_density_height_scale * height);
    float densityRayleigh = exp(-rayleigh_density_height_scale * height);
    float densityOzone = max(0.0, 1.0 - abs(height-25.0e3)/15.0e3);

    mieScattering = mie_scattering * densityMie;
    mieAbsorption = mie_absorption * densityMie;

    rayleighScattering = rayleigh_scattering * densityRayleigh;

    ozoneAbsorption = ozone_absorption * densityOzone;

    return mieScattering + mieAbsorption + rayleighScattering + ozoneAbsorption;
}

// Approximation of the Mie phase function with the Cornette-Shanks phase function
float miePhaseFunction(float cosTheta)
{
    float num = (1.0 - gg) * (1.0 + cosTheta*cosTheta);
    float den = (2.0 + gg) * pow((1.0 + gg - 2.0 * g * cosTheta), 1.5);
    return mie_phase_scale * num / den;
}

float rayleighPhaseFunction(float cosTheta)
{
    return rayleigh_phase_scale * (1.0 + cosTheta*cosTheta);
}

// Sample one of the LUTs (transmittance or multiple scattering) for a given
// normalized height inside the atmosphere [0,1] and the cosine of the Sun
// zenith angle.
vec3 getValueFromLUT(sampler2D lut, float sunCosTheta, float normHeight)
{
    float x = clamp(sunCosTheta * 0.5 + 0.5, 0.0, 1.0);
    float y = clamp(normHeight, 0.0, 1.0);
    return texture(lut, vec2(x, y)).rgb;
}
