#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer1_tex;

void main()
{
    fragColor = vec4(texture(gbuffer1_tex, texCoord).rgb, 1.0);
}
