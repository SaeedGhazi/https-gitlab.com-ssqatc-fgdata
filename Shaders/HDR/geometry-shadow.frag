#version 330 core

layout(location = 0) out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D color_tex;

const float ALPHA_THRESHOLD = 0.5;

void main()
{
    fragColor = vec4(1.0);
    float alpha = texture(color_tex, texCoord).a;
    if (alpha <= ALPHA_THRESHOLD)
        discard;
}
