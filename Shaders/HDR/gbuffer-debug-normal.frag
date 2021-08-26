#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;

void main()
{
    fragColor = vec4(texture(gbuffer0_tex, texCoord).rg, 0.0, 1.0);
}
