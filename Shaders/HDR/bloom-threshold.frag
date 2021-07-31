#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D hdr_tex;
uniform sampler2D lum_tex;

uniform float bloom_threshold;

vec3 applyExposure(vec3 color, float avgLuminance, float threshold);

void main()
{
    vec3 hdrColor = texture(hdr_tex, texCoord).rgb;
    float avgLuminance = texelFetch(lum_tex, ivec2(0), 0).r;

    vec3 exposedHdrColor = applyExposure(hdrColor, avgLuminance, bloom_threshold);
    if (dot(exposedHdrColor, vec3(0.333)) <= 0.001)
		fragColor = vec3(0.0);
    else
        fragColor = exposedHdrColor;
}
