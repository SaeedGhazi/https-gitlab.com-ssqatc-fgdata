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

const float a = 2.51;
const float b = 0.03;
const float c = 2.43;
const float d = 0.59;
const float e = 0.14;
vec3 ACESFilm(vec3 x)
{
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

vec3 encodeSRGB(vec3 linearRGB)
{
    vec3 a = 12.92 * linearRGB;
    vec3 b = 1.055 * pow(linearRGB, vec3(1.0 / 2.4)) - 0.055;
    vec3 c = step(vec3(0.0031308), linearRGB);
    return mix(a, b, c);
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
    vec3 color = ACESFilm(exposedHdrColor);
    // Gamma correction
    color = encodeSRGB(color);

    // Bloom
    vec3 bloom = texture(bloom_tex, texCoord).rgb;
    color += bloom.rgb * bloom_magnitude;

    fragColor = vec4(color, 1.0);
}
