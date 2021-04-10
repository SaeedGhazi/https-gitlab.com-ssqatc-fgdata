#version 330 core

layout(location = 0) out vec4 fragColor;

in vec3 normalVS;
in vec2 texCoord;

uniform sampler2D color_tex;

void main()
{
    fragColor = texture(color_tex, texCoord);
}
