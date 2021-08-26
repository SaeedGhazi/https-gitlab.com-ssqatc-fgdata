#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D gbuffer1_tex;
uniform sampler2D gbuffer2_tex;

void main()
{
    fragColor = vec4(texture(gbuffer2_tex, texCoord).a,
                     texture(gbuffer0_tex, texCoord).b,
                     texture(gbuffer1_tex, texCoord).a,
                     1.0);
}
