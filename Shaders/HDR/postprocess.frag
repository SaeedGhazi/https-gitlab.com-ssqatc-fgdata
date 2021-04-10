#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D hdr_tex;
uniform sampler2D lum_tex;
uniform sampler2D bloom_tex;

uniform vec2 fg_BufferSize;

const float BLOOM_INTENSITY = 1.0;
const float EXPOSURE_THRESHOLD = 0.0;

vec3 ACESFilm(vec3 x)
{
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

float log10(float x)
{
    return (1.0 / log(10.0)) * log(x);
}

float autokey(float lum)
{
    return 1.03 - 2.0 / (2.0 + log10(lum + 1.0));
}

void main()
{
    vec3 hdrColor = texture(hdr_tex, texCoord).rgb;

    float avgLuminance = texelFetch(lum_tex, ivec2(0), 0).r;
    avgLuminance = max(avgLuminance, 0.001);

    // Auto-expose
    float linearExposure = autokey(avgLuminance) / avgLuminance;
    float exposure = log2(max(linearExposure, 0.0001));
    exposure -= EXPOSURE_THRESHOLD;
    hdrColor *= exp2(exposure);

    // Tonemap
    vec3 color = ACESFilm(hdrColor);
    // Gamma correction
    color = pow(color, vec3(1.0/2.2));

    // Apply bloom
    vec3 bloom = texture(bloom_tex, texCoord).rgb;
    bloom *= BLOOM_INTENSITY;
    color += bloom;

    fragColor = vec4(color, 1.0);
}
