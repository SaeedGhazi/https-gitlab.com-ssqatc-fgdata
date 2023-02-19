#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D hdr_tex;
uniform sampler2D lum_tex;
uniform sampler2D bloom_tex;

uniform vec2 fg_BufferSize;

uniform float bloom_magnitude;
uniform bool debug_ev100;

vec3 applyExposure(vec3 color, float avgLuminance, float threshold);

/**
 * ACES tone mapping
 * From 'Baking Lab' by MJP and David Neubelt
 * Original by Stephen Hill
 * https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl
 * Licensed under the MIT license
 */
// sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
const mat3 ACESInputMat = mat3(
    0.59719, 0.07600, 0.02840,
    0.35458, 0.90834, 0.13383,
    0.04823, 0.01566, 0.83777);
// ODT_SAT => XYZ => D60_2_D65 => sRGB
const mat3 ACESOutputMat = mat3(
     1.60475, -0.10208, -0.00327,
    -0.53108,  1.10813, -0.07276,
    -0.07367, -0.00605,  1.07602);

vec3 ACESFitted(vec3 color)
{
    vec3 v = ACESInputMat * color;
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return clamp(ACESOutputMat * (a / b), 0.0, 1.0);
}

vec3 getDebugColor(float value)
{
    float level = value*3.14159265/2.0;
    vec3 col;
    col.r = sin(level);
    col.g = sin(level*2.0);
    col.b = cos(level);
    return col;
}

vec3 debugEV100(vec3 hdr, float avgLuminance)
{
    float level;
    if (texCoord.y < 0.05) {
        const float w = 0.001;
        if (texCoord.x >= (0.5 - w) && texCoord.x <= (0.5 + w))
            return vec3(1.0);
        return getDebugColor(texCoord.x);
    }
    float luminance = max(dot(hdr, vec3(0.299, 0.587, 0.114)), 0.0001);
    float ev100 = log2(luminance * 8.0);
    float norm = ev100 / 12.0 + 0.5;
    return getDebugColor(norm);
}

vec3 encodeSRGB(vec3 linearRGB)
{
    vec3 a = 12.92 * linearRGB;
    vec3 b = 1.055 * pow(linearRGB, vec3(1.0 / 2.4)) - 0.055;
    vec3 c = step(vec3(0.0031308), linearRGB);
    return mix(a, b, c);
}

float rand2D(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec3 hdrColor = texture(hdr_tex, texCoord).rgb;
    float avgLuminance = texelFetch(lum_tex, ivec2(0), 0).r;

    // Exposure
    vec3 exposedHdrColor = applyExposure(hdrColor, avgLuminance, 0.0);
    if (debug_ev100) {
        fragColor = vec4(debugEV100(exposedHdrColor, avgLuminance), 1.0);
        return;
    }

    // Tonemap
    vec3 color = ACESFitted(exposedHdrColor);
    // Gamma correction
    color = encodeSRGB(color);

    // Bloom
    vec3 bloom = texture(bloom_tex, texCoord).rgb;
    color += bloom.rgb * bloom_magnitude;

    // Dithering
    color += mix(-0.5/255.0, 0.5/255.0, rand2D(texCoord));

    fragColor = vec4(color, 1.0);
}
