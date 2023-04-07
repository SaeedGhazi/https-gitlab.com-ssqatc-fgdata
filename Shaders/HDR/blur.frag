#version 330 core

layout(location = 0) out vec4 fragColor;

in vec2 texcoord;

uniform sampler2D tex;
uniform sampler2D prev_pass_tex;

uniform bool vertical = false;

void main()
{
    vec2 offset = 1.0 / textureSize(tex, 0);
    if (vertical) offset.x = 0.0;
    else offset.y = 0.0;

    vec4 sum = texture(prev_pass_tex, texcoord);

    sum += texture(tex, texcoord - 4.0 * offset) * 0.0162162162;
    sum += texture(tex, texcoord - 3.0 * offset) * 0.0540540541;
    sum += texture(tex, texcoord - 2.0 * offset) * 0.1216216216;
    sum += texture(tex, texcoord - 1.0 * offset) * 0.1945945946;

    sum += texture(tex, texcoord) * 0.2270270270;

    sum += texture(tex, texcoord + 1.0 * offset) * 0.1945945946;
    sum += texture(tex, texcoord + 2.0 * offset) * 0.1216216216;
    sum += texture(tex, texcoord + 3.0 * offset) * 0.0540540541;
    sum += texture(tex, texcoord + 4.0 * offset) * 0.0162162162;

    fragColor = sum;
}
