#version 330 core

out vec4 fragColor;

in vec3 v_ray_dir;
in vec3 v_ray_dir_view;

uniform bool sun_disk;
uniform sampler2D sky_view_lut;
uniform sampler2D transmittance_lut;

uniform vec3 fg_SunDirection;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_EarthRadius;
uniform vec3 fg_CameraViewUp;

const float PI = 3.14159265358979323846;
const float ATMOSPHERE_RADIUS = 6471e3;
const float sun_solid_angle = radians(0.545); // ~half a degree
const float sun_cos_solid_angle = cos(sun_solid_angle);
// Limb darkening constants, sampled for
// 630, 560, 490, 430 nanometers
const vec4 u = vec4(1.0);
const vec4 alpha = vec4(0.429, 0.502, 0.575, 0.643);

//-- BEGIN spectral include
// Extraterrestial Solar Irradiance Spectra, units W * m^-2 * nm^-1
// https://www.nrel.gov/grid/solar-resource/spectra.html
const vec4 sun_spectral_irradiance = vec4(1.679, 1.828, 1.986, 1.307);

const mat4x3 M = mat4x3(
    137.672389239975, -8.632904716299537, -1.7181567391931372,
    32.549094028629234, 91.29801417199785, -12.005406444382531,
    -38.91428392614275, 34.31665471469816, 29.89044807197628,
    8.572844237945445, -11.103384660054624, 117.47585277566478);

vec3 linear_srgb_from_spectral_samples(vec4 L)
{
    return M * L;
}
//-- END spectral include

void main()
{
    vec3 ray_dir = normalize(v_ray_dir);
    float azimuth = atan(ray_dir.y, ray_dir.x) / PI * 0.5 + 0.5;
    // Undo the non-linear transformation from the sky-view LUT
    float l = asin(ray_dir.z);
    float elev = sqrt(abs(l) / (PI * 0.5)) * sign(l) * 0.5 + 0.5;

    vec4 sky_radiance = texture(sky_view_lut, vec2(azimuth, elev));
    // When computing the sky texture we assumed an unitary light source.
    // Now multiply by the sun irradiance.
    sky_radiance *= sun_spectral_irradiance;

    if (sun_disk) {
        // Render the Sun disk
        vec3 ray_dir_view = normalize(v_ray_dir_view);
        float cos_theta = dot(ray_dir_view, fg_SunDirection);

        if (cos_theta >= sun_cos_solid_angle) {
            float normalized_altitude =
                (fg_CameraDistanceToEarthCenter - fg_EarthRadius)
                / (ATMOSPHERE_RADIUS - fg_EarthRadius);

            float sun_zenith_cos_theta = dot(-ray_dir_view, fg_CameraViewUp);

            vec2 uv = vec2(sun_zenith_cos_theta * 0.5 + 0.5,
                           clamp(normalized_altitude, 0.0, 1.0));
            vec4 transmittance = texture(transmittance_lut, uv);

            // Limb darkening
            // http://www.physics.hmc.edu/faculty/esin/a101/limbdarkening.pdf
            float center_to_edge = 1.0 - (cos_theta - sun_cos_solid_angle)
                / (1.0 - sun_cos_solid_angle);
            float mu = sqrt(max(1.0 - center_to_edge*center_to_edge, 0.0));
            vec4 factor = vec4(1.0) - u * (vec4(1.0) - pow(vec4(mu), alpha));

            vec4 sun_radiance = sun_spectral_irradiance * transmittance * factor;
            sky_radiance += sun_radiance;
        }
    }

    vec3 sky_color = linear_srgb_from_spectral_samples(sky_radiance);
    fragColor = vec4(sky_color, 1.0);
}
