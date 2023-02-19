#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 normalVS;
in vec2 texCoord;

uniform sampler2D color_tex;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec4 texel = texture(color_tex, texCoord);
    if (texel.a < 0.5)
        discard;

    vec3 color = decodeSRGB(texel.rgb);

    outGBuffer0.rg  = encodeNormal(normalVS);
    outGBuffer0.b   = 0.9;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = color;
    outGBuffer1.a   = 0.0;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
