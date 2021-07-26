#version 330 core

uniform vec3  beta_rayleigh          = vec3(5.5e-6, 13.0e-6, 22.4e-6);
uniform float beta_mie               = 21e-6;
uniform vec3  beta_absortion         = vec3(2.04e-5, 4.97e-5, 1.95e-6);
uniform float beta_ambient           = 0.0;
uniform float rayleigh_scale_height  = 8e3;
uniform float mie_scale_height       = 1.2e3;
uniform float absortion_scale_height = 30e3;
uniform float absortion_falloff      = 3e3;
uniform int   num_samples            = 32;
uniform int   num_light_samples      = 4;

const float PI                       = 3.141592653;
const float ATMOSPHERE_RADIUS        = 6471e3;
const vec3  SUN_INTENSITY            = vec3(20.0);

vec2 raySphereIntersection(vec3 ro, vec3 rd, float radius)
{
    vec3 tc = -ro;
    float b = dot(tc, rd);
    float d = b*b - dot(tc, tc) + radius*radius;
    if (d < 0.0) return vec2(-1.0);
    float s = sqrt(d);
    return vec2(b-s, b+s);
}

void calculateScattering(in vec3 rayOrigin,
                         in vec3 rayDir,
                         in float tmax,
                         in vec3 lightDir,
                         in float earthRadius,
                         out vec3 inscatter,
                         out vec3 transmittance)
{
    vec2 hit = raySphereIntersection(rayOrigin, rayDir, ATMOSPHERE_RADIUS);
    vec2 hitEarth = raySphereIntersection(rayOrigin, rayDir, earthRadius - 1.0);
    if (hitEarth.y > 0.0)
        tmax = max(0.0, hitEarth.x);

    float tmin = max(hit.x, 0.0);
    tmax = min(hit.y, tmax);
    if (tmax < 0.0)
        discard;

    float stepSize = (tmax - tmin) / float(num_samples);

    const float g = 0.758; // Mie scattering direction
    const float gg = g*g;
    float mu = dot(rayDir, lightDir);
    float mumu = mu*mu;
    float phaseRayleigh = 3.0 / (50.2654824574 /* 16*PI */) * (1.0 + mumu);
    float phaseMie = 3.0 / (25.1327412287 /* 8*PI */) * ((1.0 - gg) * (mumu + 1.0)) /
        (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

    float opticalDepthRayleigh = 0.0;
    float opticalDepthMie = 0.0;
    float opticalDepthAbsortion = 0.0;

    float primaryTime = tmin;

    vec3 extinctionFactor = vec3(0.0);
    vec3 totalRayleigh = vec3(0.0);
    vec3 totalMie = vec3(0.0);

    for (int i = 0; i < num_samples; ++i) {
        vec3 samplePoint = rayOrigin + rayDir * (primaryTime + stepSize * 0.5);

        float altitude = length(samplePoint) - earthRadius;

        float densityRayleigh  = exp(-altitude / rayleigh_scale_height);
        float densityMie       = exp(-altitude / mie_scale_height);
        float densityAbsortion = clamp((1.0 / cosh((absortion_scale_height - altitude) / absortion_falloff)) * densityRayleigh, 0.0, 1.0);
        float stepOpticalDepthRayleigh  = densityRayleigh  * stepSize;
        float stepOpticalDepthMie       = densityMie       * stepSize;
        float stepOpticalDepthAbsortion = densityAbsortion * stepSize;
        opticalDepthRayleigh  += stepOpticalDepthRayleigh;
        opticalDepthMie       += stepOpticalDepthMie;
        opticalDepthAbsortion += stepOpticalDepthAbsortion;

        vec2 pl = raySphereIntersection(samplePoint, lightDir, ATMOSPHERE_RADIUS);
        float stepSizeLight = pl.y / float(num_light_samples);

        float opticalDepthLightRayleigh = 0.0;
        float opticalDepthLightMie = 0.0;
        float opticalDepthLightAbsortion = 0.0;

        float secondaryTime = 0.0;

        int j;
        for (j = 0; j < num_light_samples; ++j) {
            vec3 samplePointLight = samplePoint + lightDir *
                (secondaryTime + stepSizeLight * 0.5);

            float altitudeLight = length(samplePointLight) - earthRadius;
            if (altitudeLight < 0.0)
                break;

            float densityLightRayleigh  = exp(-altitudeLight / rayleigh_scale_height);
            float densityLightMie       = exp(-altitudeLight / mie_scale_height);
            float densityLightAbsortion = clamp((1.0 / cosh((absortion_scale_height - altitudeLight) / absortion_falloff)) * densityLightRayleigh, 0.0, 1.0);
            opticalDepthLightRayleigh  += densityLightRayleigh  * stepSizeLight;
            opticalDepthLightMie       += densityLightMie       * stepSizeLight;
            opticalDepthLightAbsortion += densityLightAbsortion * stepSizeLight;

            secondaryTime += stepSizeLight;
        }

        if (j == num_light_samples) {
            vec3 tau =
                beta_rayleigh * (opticalDepthRayleigh + opticalDepthLightRayleigh) +
                beta_mie * (opticalDepthMie + opticalDepthLightMie) +
                beta_absortion * (opticalDepthAbsortion + opticalDepthLightAbsortion);
            vec3 attenuation = exp(-tau);

            extinctionFactor += attenuation;

            totalRayleigh += stepOpticalDepthRayleigh * attenuation;
            totalMie      += stepOpticalDepthMie      * attenuation;
        }

        primaryTime += stepSize;
    }

    transmittance = exp(-(beta_rayleigh  * opticalDepthRayleigh +
                          beta_mie       * opticalDepthMie +
                          beta_absortion * opticalDepthAbsortion));

    inscatter = SUN_INTENSITY *
        (totalRayleigh * beta_rayleigh * phaseRayleigh +
         totalMie * beta_mie * phaseMie +
         opticalDepthRayleigh * beta_ambient);
}
