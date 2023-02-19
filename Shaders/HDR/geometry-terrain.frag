#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 normalVS;
in vec2 texCoord;
in vec2 orthophoto_texCoord;

uniform sampler2D color_tex;
uniform sampler2D orthophoto_tex;

uniform bool orthophotoAvailable;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec3 texel = texture(color_tex, texCoord).rgb;
    if (orthophotoAvailable) {
        vec4 sat_texel = texture(orthophoto_tex, orthophoto_texCoord);
        if (sat_texel.a > 0.0) {
            texel.rgb = sat_texel.rgb;
        }
    }

    vec3 color = decodeSRGB(texel);

    outGBuffer0.rg  = encodeNormal(normalVS);
    outGBuffer0.b   = 0.95;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = color;
    outGBuffer1.a   = 0.0;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
