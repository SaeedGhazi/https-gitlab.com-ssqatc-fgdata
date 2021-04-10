#version 330 core

uniform bool  sun_disk               = true;
uniform vec3  beta_rayleigh          = vec3(5.5e-6, 13.0e-6, 22.4e-6);
uniform float beta_mie               = 21e-6;
uniform vec3  beta_absortion         = vec3(2.04e-5, 4.97e-5, 1.95e-6);
uniform float beta_ambient           = 0.0;
uniform float rayleigh_scale_height  = 8e3;
uniform float mie_scale_height       = 1.2e3;
uniform float absortion_scale_height = 30e3;
uniform float absortion_falloff      = 3e3;
uniform int   num_samples            = 64;
uniform int   num_light_samples      = 4;

const float PI                       = 3.141592653;
const float ATMOSPHERE_RADIUS        = 6471e3;
const vec3  SUN_INTENSITY            = vec3(20.0);
const float COS_SUN_ANGULAR_DIAMETER = 0.999956676946448443553574619906976478926848692873900859324;

vec2 raySphereIntersection(vec3 r0, vec3 rd, float radius)
{
    float a = dot(rd, rd);
    float b = 2.0 * dot(rd, r0);
    float c = dot(r0, r0) - (radius * radius);
    float d = (b*b) - 4.0*a*c;
    if (d < 0.0) return vec2(1e5, -1e5);
    return vec2((-b - sqrt(d))/(2.0*a), (-b + sqrt(d))/(2.0*a));
}

vec3 calculateScattering(vec3 rayOrigin,
                         vec3 rayDir,
                         vec3 sceneColor,
                         float depth,
                         float maxDist,
                         float earthRadius,
                         vec3 lightDir)
{
    vec2 hit = raySphereIntersection(rayOrigin, rayDir, ATMOSPHERE_RADIUS);
    if (hit.x > hit.y) {
        // The ray did not hit the atmosphere, we are in outer space
        return sceneColor;
    }
    hit.x = max(hit.x, 0.0); // Do not sample behind the camera
    // Avoid clamping the ray to the far plane when there is no geometry in
    // front of the sky
    if (depth < 1.0) {
        // Stop the ray at the geometry
        hit.y = min(hit.y, maxDist);
    } else {
        // If there is no geometry, simulate a collision with the Earth at sea
        // level. This only happens when FG hasn't loaded any terrain
        vec2 hitEarth = raySphereIntersection(
            rayOrigin, rayDir, earthRadius - 1.0);
        if (hitEarth.x < hitEarth.y && hitEarth.x > 0.0) {
            hit.y = min(hit.y, hitEarth.x);
        }
    }

    float stepSize = (hit.y - hit.x) / float(num_samples);

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

    float primaryTime = hit.x;

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

        for (int j = 0; j < num_light_samples; ++j) {
            vec3 samplePointLight = samplePoint + lightDir *
                (secondaryTime + stepSizeLight * 0.5);

            float altitudeLight = length(samplePointLight) - earthRadius;

            float densityLightRayleigh  = exp(-altitudeLight / rayleigh_scale_height);
            float densityLightMie       = exp(-altitudeLight / mie_scale_height);
            float densityLightAbsortion = clamp((1.0 / cosh((absortion_scale_height - altitudeLight) / absortion_falloff)) * densityLightRayleigh, 0.0, 1.0);
            opticalDepthLightRayleigh  += densityLightRayleigh  * stepSizeLight;
            opticalDepthLightMie       += densityLightMie       * stepSizeLight;
            opticalDepthLightAbsortion += densityLightAbsortion * stepSizeLight;

            secondaryTime += stepSizeLight;
        }

        vec3 tau =
            beta_rayleigh * (opticalDepthRayleigh + opticalDepthLightRayleigh) +
            beta_mie * (opticalDepthMie + opticalDepthLightMie) +
            beta_absortion * (opticalDepthAbsortion + opticalDepthLightAbsortion);
        vec3 attenuation = exp(-tau);

        extinctionFactor += attenuation;

        totalRayleigh += stepOpticalDepthRayleigh * attenuation;
        totalMie      += stepOpticalDepthMie      * attenuation;

        primaryTime += stepSize;
    }

    vec3 opacity = exp(-(beta_rayleigh  * opticalDepthRayleigh +
                         beta_mie       * opticalDepthMie +
                         beta_absortion * opticalDepthAbsortion));

    vec3 color = SUN_INTENSITY *
        (totalRayleigh * beta_rayleigh * phaseRayleigh +
         totalMie * beta_mie * phaseMie +
         opticalDepthRayleigh * beta_ambient)
        + sceneColor * opacity;

    if (sun_disk && (depth >= 1.0)) {
        float costheta = dot(rayDir, lightDir);
        float sundisk = smoothstep(COS_SUN_ANGULAR_DIAMETER,
                                   COS_SUN_ANGULAR_DIAMETER + 0.00002,
                                   costheta);
        color += SUN_INTENSITY * extinctionFactor * sundisk;
    }

    return color;
}
