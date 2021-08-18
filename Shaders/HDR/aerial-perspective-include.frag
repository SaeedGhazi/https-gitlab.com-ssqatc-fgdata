#version 330 core

uniform sampler2D aerial_perspective_lut;
uniform sampler2D transmittance_lut;

uniform float fg_SunZenithCosTheta;
uniform float fg_CameraDistanceToEarthCenter;
uniform float fg_EarthRadius;

const float AERIAL_SLICES = 32.0;
const float AERIAL_LUT_TILE_SIZE = 1.0 / AERIAL_SLICES;
const float AERIAL_LUT_TEXEL_SIZE = 1.0 / 1024.0;
const float AERIAL_MAX_DEPTH = 128000.0;
const vec3 EXTRATERRESTRIAL_SOLAR_ILLUMINANCE = vec3(128.0);

const float ATMOSPHERE_RADIUS = 6471e3;

vec4 sampleAerialPerspectiveSlice(vec2 coord, int slice)
{
    // Sample at the pixel center
    float offset = slice * AERIAL_LUT_TILE_SIZE + AERIAL_LUT_TEXEL_SIZE * 0.5;
    float x = coord.x * (AERIAL_LUT_TILE_SIZE - AERIAL_LUT_TEXEL_SIZE) + offset;
    return texture(aerial_perspective_lut, vec2(x, coord.y));
}

vec4 sampleAerialPerspective(vec2 coord, float depth)
{
    vec4 color;
    // Map to [0,1]
    float w = depth / AERIAL_MAX_DEPTH;
    // Squared distribution
    w = sqrt(clamp(w, 0.0, 1.0));
    w *= AERIAL_SLICES;
    if (w <= 1.0) {
        // Handle special case of fragments behind the first slice
        color = mix(vec4(0.0, 0.0, 0.0, 1.0),
                    sampleAerialPerspectiveSlice(coord, 0),
                    w);
    } else {
        w -= 1.0;
        // Manually interpolate between slices
        color = mix(sampleAerialPerspectiveSlice(coord, int(floor(w))),
                    sampleAerialPerspectiveSlice(coord, int(ceil(w))),
                    sqrt(fract(w)));
    }
    return color;
}

vec3 addAerialPerspective(vec3 color, vec2 coord, float depth)
{
    vec4 aerialPerspective = sampleAerialPerspective(coord, depth);
    return color * aerialPerspective.a + aerialPerspective.rgb
        * EXTRATERRESTRIAL_SOLAR_ILLUMINANCE;
}

/**
 * Get the illuminance of the Sun for a surface perpendicular to the Sun
 * direction. The illuminance is calculated at the altitude of the viewer,
 * which might or might not be correct in certain circumstances. If the object
 * being illuminated is not too far from the viewer it's a good enough
 * approximation.
 */
vec3 getSunIntensity()
{
    float normalizedHeight = (fg_CameraDistanceToEarthCenter - fg_EarthRadius)
        / (ATMOSPHERE_RADIUS - fg_EarthRadius);

    vec2 coord = vec2(fg_SunZenithCosTheta * 0.5 + 0.5,
                       clamp(normalizedHeight, 0.0, 1.0));
    vec3 transmittance = texture(transmittance_lut, coord).rgb;

    return EXTRATERRESTRIAL_SOLAR_ILLUMINANCE * transmittance;
}
