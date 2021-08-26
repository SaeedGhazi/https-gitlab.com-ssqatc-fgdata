#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 normalVS;
in vec2 texCoord;
in vec4 materialColor;

uniform sampler2D color_tex;

const float DEFAULT_METALNESS = 0.0;
const float DEFAULT_ROUGHNESS = 0.5;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec3 texel = texture(color_tex, texCoord).rgb;
    vec3 color = decodeSRGB(texel) * materialColor.rgb; // Ignore transparency

    outGBuffer0.rg  = encodeNormal(normalVS);
    outGBuffer0.b   = DEFAULT_ROUGHNESS;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = color;
    outGBuffer1.a   = DEFAULT_METALNESS;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
