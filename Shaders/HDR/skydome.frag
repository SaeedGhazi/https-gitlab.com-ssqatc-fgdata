#version 330 core

out vec4 fragColor;

in vec3 vRayDir;
in vec3 vRayDirView;

uniform bool sun_disk;
uniform sampler2D sky_view_lut;
uniform sampler2D transmittance_lut;

uniform vec3 fg_SunDirection;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_EarthRadius;
uniform vec3 fg_CameraViewUp;

const float PI = 3.141592653;
const vec3 EXTRATERRESTRIAL_SOLAR_ILLUMINANCE = vec3(128.0);
const float ATMOSPHERE_RADIUS = 6471e3;

const float sun_solid_angle = 0.545*PI/180.0; // ~half a degree
const float sun_cos_solid_angle = cos(sun_solid_angle);

void main()
{
    vec3 rayDir = normalize(vRayDir);
    float azimuth = atan(rayDir.y, rayDir.x) / PI * 0.5 + 0.5;
    // Undo the non-linear transformation from the sky-view LUT
    float l = asin(rayDir.z);
    float elev = sqrt(abs(l) / (PI * 0.5)) * sign(l) * 0.5 + 0.5;

    vec3 color = texture(sky_view_lut, vec2(azimuth, elev)).rgb;
    color *= EXTRATERRESTRIAL_SOLAR_ILLUMINANCE;

    if (sun_disk) {
        // Render the Sun disk
        vec3 rayDirView = normalize(vRayDirView);
        float cosTheta = dot(rayDirView, fg_SunDirection);

        if (cosTheta >= sun_cos_solid_angle) {
            float normalizedHeight = (fg_CameraDistanceToEarthCenter - fg_EarthRadius)
                / (ATMOSPHERE_RADIUS - fg_EarthRadius);

            float sunZenithCosTheta = dot(-rayDirView, fg_CameraViewUp);

            vec2 coords = vec2(sunZenithCosTheta * 0.5 + 0.5,
                               clamp(normalizedHeight, 0.0, 1.0));
            vec3 transmittance = texture(transmittance_lut, coords).rgb;

            // Limb darkening
            // http://www.physics.hmc.edu/faculty/esin/a101/limbdarkening.pdf
            vec3 u = vec3(1.0);
            vec3 a = vec3(0.397, 0.503, 0.652);
            float centerToEdge = 1.0 - (cosTheta - sun_cos_solid_angle)
                / (1.0 - sun_cos_solid_angle);
            float mu = sqrt(max(1.0 - centerToEdge * centerToEdge, 0.0));
            vec3 factor = vec3(1.0) - u * (vec3(1.0) - pow(vec3(mu), a));

            color += EXTRATERRESTRIAL_SOLAR_ILLUMINANCE * transmittance * factor;
        }
    }

    fragColor = vec4(color, 1.0);
}
