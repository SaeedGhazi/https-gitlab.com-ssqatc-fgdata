#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D tex;

float linearizeDepth(float depth);

void main()
{
    fragColor = vec4(linearizeDepth(texture(tex, texCoord).r));
}
