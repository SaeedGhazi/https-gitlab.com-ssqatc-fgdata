#version 330 core

layout(location = 0) out vec4 gbuffer0;
layout(location = 1) out vec2 gbuffer1;
layout(location = 2) out vec4 gbuffer2;

in vec3 normalVS;

vec2 encodeNormal(vec3 n);

void main()
{
    gbuffer0 = vec4(1.0);
    gbuffer1 = encodeNormal(normalVS);
    gbuffer2 = vec4(1.0, 0.1, 0.0, 0.0);
}
