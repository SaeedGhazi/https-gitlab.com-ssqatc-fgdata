#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D depth_tex;

float linearizeDepth(float depth);

void main()
{
    float depth = texture(depth_tex, texCoord).r;
    fragColor = vec4(vec3(linearizeDepth(depth)), 1.0);
}
