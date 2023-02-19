// Render the aerial perspective LUT, similar to
// "A Scalable and Production Ready Sky and Atmosphere Rendering Technique"
//     by Sébastien Hillaire (2020).
//
// Unlike the paper, we are using a tiled 2D texture instead of a true 3D
// texture. For some reason the overhead of rendering to a texture many times
// (the depth of the 3D texture) seems to be too high, probably because OSG is
// not sharing state between those passes.

#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D transmittance_lut;

uniform mat4 fg_ViewMatrixInverse;
uniform vec3 fg_CameraPositionCart;
uniform vec3 fg_SunDirectionWorld;

const float AP_SLICE_COUNT = 32.0;
const float AP_MAX_DEPTH = 128000.0;
const int AERIAL_PERSPECTIVE_STEPS = 20;

// gbuffer-include.frag
vec3 positionFromDepth(vec2 pos, float depth);

// atmos-include.frag
vec4 compute_inscattering(in vec3 ray_origin,
                          in vec3 ray_dir,
                          in float t_max,
                          in vec3 sun_dir,
                          in int steps,
                          in sampler2D transmittance_lut,
                          out vec4 transmittance);

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


void main()
{
    // Account for the depth slice we are currently in. Depth goes from 0 to
    // DEPTH_RANGE in a squared distribution. The first slice is not 0 since
    // that would waste a slice.
    float x = texCoord.x * AP_SLICE_COUNT;
    float slice = ceil(x);
    float w = slice / AP_SLICE_COUNT; // [0,1]
    float depth = w*w * AP_MAX_DEPTH;

    vec2 coord = vec2(fract(x), texCoord.y);

    vec3 frag_pos = positionFromDepth(coord, 1.0);
    vec3 ray_dir = vec4(fg_ViewMatrixInverse * vec4(normalize(frag_pos), 0.0)).xyz;

    vec4 transmittance;
    vec4 L = compute_inscattering(fg_CameraPositionCart,
                                  ray_dir,
                                  depth,
                                  fg_SunDirectionWorld,
                                  AERIAL_PERSPECTIVE_STEPS,
                                  transmittance_lut,
                                  transmittance);
    // In-scattering
    fragColor.rgb = linear_srgb_from_spectral_samples(L * sun_spectral_irradiance);
    // Transmittance
    fragColor.a = dot(transmittance, vec4(0.25));
}
