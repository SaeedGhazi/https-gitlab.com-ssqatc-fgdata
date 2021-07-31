#version 330 core

out float luminance;

in vec2 texCoord;

uniform sampler2D hdr_tex;

void main()
{
    vec3 hdrColor = texture(hdr_tex, texCoord).rgb;
    luminance = log(max(dot(hdrColor, vec3(0.299, 0.587, 0.114)), 0.0001));
}
