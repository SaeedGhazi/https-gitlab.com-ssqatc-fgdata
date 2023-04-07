#version 330 core

layout(location = 0) out vec3 fragColor;

in vec2 texcoord;

uniform sampler2D hdr_tex;
uniform sampler2D lum_tex;

uniform float bloom_threshold;

// exposure.glsl
vec3 apply_exposure(vec3 color, float avg_lum, float threshold);

void main()
{
    vec3 hdr_color = texture(hdr_tex, texcoord).rgb;
    float avg_lum = texelFetch(lum_tex, ivec2(0), 0).r;

    vec3 exposed_hdr_color = apply_exposure(hdr_color, avg_lum, bloom_threshold);
    if (dot(exposed_hdr_color, vec3(0.333)) <= 0.001)
        fragColor = vec3(0.0);
    else
        fragColor = exposed_hdr_color;
}
