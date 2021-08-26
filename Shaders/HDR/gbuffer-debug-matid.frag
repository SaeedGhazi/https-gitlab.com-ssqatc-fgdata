#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;

void main()
{
    fragColor = vec4(vec3(texture(gbuffer0_tex, texCoord).a), 1.0);
}
