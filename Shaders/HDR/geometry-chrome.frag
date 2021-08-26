#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 normalVS;

const float CHROME_METALNESS = 1.0;
const float CHROME_ROUGHNESS = 0.1;

vec2 encodeNormal(vec3 n);

void main()
{
    outGBuffer0.rg  = encodeNormal(normalVS);
    outGBuffer0.b   = CHROME_ROUGHNESS;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = vec3(1.0);
    outGBuffer1.a   = CHROME_METALNESS;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
