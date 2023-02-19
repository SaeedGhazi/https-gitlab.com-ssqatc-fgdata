#version 330 core

uniform sampler2D aerial_perspective_lut;
uniform sampler2D transmittance_lut;

uniform vec3 fg_SunDirectionWorld;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_SunZenithCosTheta;
uniform float fg_EarthRadius;

const float AP_SLICE_COUNT = 32.0;
const float AP_MAX_DEPTH = 128000.0;
const float AP_SLICE_WIDTH_PIXELS = 32.0;
const float AP_SLICE_SIZE = 1.0 / AP_SLICE_COUNT;
const float AP_TEXEL_WIDTH = 1.0 / (AP_SLICE_COUNT * AP_SLICE_WIDTH_PIXELS);

const float ATMOSPHERE_RADIUS = 6471e3;

//-- BEGIN spectral include

// Extraterrestial Solar Irradiance Spectra, units W * m^-2 * nm^-1
// https://www.nrel.gov/grid/solar-resource/spectra.html
const vec4 sun_spectral_irradiance = vec4(1.679, 1.828, 1.986, 1.307);

const mat4x3 M = mat4x3(
    137.672389239975, -8.632904716299537, -1.7181567391931372,
    32.549094028629234, 91.29801417199785, -12.005406444382531,
    -38.91428392614275, 34.31665471469816, 29.89044807197628,
    8.572844237945445, -11.103384660054624, 117.47585277566478
    );

vec3 linear_srgb_from_spectral_samples(vec4 L)
{
    return M * L;
}

//-- END spectral include

vec4 sample_aerial_perspective_slice(sampler2D lut, vec2 coord, float slice)
{
    // Sample at the pixel center
    float offset = slice * AP_SLICE_SIZE + AP_TEXEL_WIDTH * 0.5;
    float x = coord.x * (AP_SLICE_SIZE - AP_TEXEL_WIDTH) + offset;
    return texture(lut, vec2(x, coord.y));
}

vec4 sample_aerial_perspective(sampler2D lut, vec2 coord, float depth)
{
    vec4 color;
    float w = sqrt(clamp(depth / AP_MAX_DEPTH, 0.0, 1.0));
    float x = w * AP_SLICE_COUNT;
    if (x <= 1.0) {
        // Handle special case of fragments behind the first slice
        color = mix(vec4(0.0, 0.0, 0.0, 1.0),
                    sample_aerial_perspective_slice(lut, coord, 0),
                    x);
    } else {
        // Manually interpolate between slices
        x -= 1.0;
        color = mix(sample_aerial_perspective_slice(lut, coord, floor(x)),
                    sample_aerial_perspective_slice(lut, coord, ceil(x)),
                    fract(x));
    }
    return color;
}

vec3 add_aerial_perspective(vec3 color, vec2 coord, float depth)
{
    vec4 ap = sample_aerial_perspective(aerial_perspective_lut, coord, depth);
    return color * ap.a + ap.rgb;
}

/*
 * Get the Sun radiance at a point 'p' in world space.
 * We cannot use the Sun extraterrestial irradiance directly because it will be
 * attenuated by the transmittance of the atmospheric medium.
 */
vec3 get_sun_radiance(vec3 p)
{
    float distance_to_earth_center = length(p);
    float normalized_altitude = (distance_to_earth_center - fg_EarthRadius)
        / (ATMOSPHERE_RADIUS - fg_EarthRadius);

    vec3 zenith_dir = p / distance_to_earth_center;
    float sun_cos_theta = dot(zenith_dir, fg_SunDirectionWorld);

    float u = sun_cos_theta * 0.5 + 0.5;
    float v = clamp(normalized_altitude, 0.0, 1.0);
    vec4 transmittance = texture(transmittance_lut, vec2(u, v));

    vec4 L = sun_spectral_irradiance * transmittance;
    return linear_srgb_from_spectral_samples(L);
}
