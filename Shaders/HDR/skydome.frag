#version 330 core

layout(location = 0) out vec4 fragColor;

in vec3 ray_dir;
in vec3 ray_dir_view;

uniform bool sun_disk;
uniform sampler2D sky_view_tex;
uniform sampler2D transmittance_tex;

uniform vec3 fg_SunDirection;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_EarthRadius;
uniform vec3 fg_CameraViewUp;

const float ATMOSPHERE_RADIUS = 6471e3;
const float sun_solid_angle = radians(0.545); // ~half a degree
const float sun_cos_solid_angle = cos(sun_solid_angle);

// Limb darkening constants, sampled for
// 630, 560, 490, 430 nanometers
const vec4 u = vec4(1.0);
const vec4 alpha = vec4(0.429, 0.502, 0.575, 0.643);

// math.glsl
float M_PI();
// atmos_spectral.glsl
vec4 get_sun_spectral_irradiance();
vec3 linear_srgb_from_spectral_samples(vec4 L);

void main()
{
    vec3 ray_dir = normalize(ray_dir);
    float azimuth = atan(ray_dir.y, ray_dir.x) / M_PI() * 0.5 + 0.5;
    // Undo the non-linear transformation from the sky-view LUT
    float l = asin(ray_dir.z);
    float elev = sqrt(abs(l) / (M_PI() * 0.5)) * sign(l) * 0.5 + 0.5;

    vec4 sky_radiance = texture(sky_view_tex, vec2(azimuth, elev));
    // When computing the sky texture we assumed an unitary light source.
    // Now multiply by the sun irradiance.
    sky_radiance *= get_sun_spectral_irradiance();

    if (sun_disk) {
        // Render the Sun disk
        vec3 ray_dir_view = normalize(ray_dir_view);
        float cos_theta = dot(ray_dir_view, fg_SunDirection);

        if (cos_theta >= sun_cos_solid_angle) {
            float normalized_altitude =
                (fg_CameraDistanceToEarthCenter - fg_EarthRadius)
                / (ATMOSPHERE_RADIUS - fg_EarthRadius);

            float sun_zenith_cos_theta = dot(-ray_dir_view, fg_CameraViewUp);

            vec2 uv = vec2(sun_zenith_cos_theta * 0.5 + 0.5,
                           clamp(normalized_altitude, 0.0, 1.0));
            vec4 transmittance = texture(transmittance_tex, uv);

            // Limb darkening
            // http://www.physics.hmc.edu/faculty/esin/a101/limbdarkening.pdf
            float center_to_edge = 1.0 - (cos_theta - sun_cos_solid_angle)
                / (1.0 - sun_cos_solid_angle);
            float mu = sqrt(max(1.0 - center_to_edge*center_to_edge, 0.0));
            vec4 factor = vec4(1.0) - u * (vec4(1.0) - pow(vec4(mu), alpha));

            vec4 sun_radiance = get_sun_spectral_irradiance() * transmittance * factor;
            sky_radiance += sun_radiance;
        }
    }

    vec3 sky_color = linear_srgb_from_spectral_samples(sky_radiance);
    fragColor = vec4(sky_color, 1.0);
}
