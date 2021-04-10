#version 330 core

layout(location = 0) out vec4 gbuffer0;
layout(location = 1) out vec2 gbuffer1;
layout(location = 2) out vec4 gbuffer2;

in vec3 normalVS;
in vec2 texCoord;

uniform sampler2D color_tex;

const float DEFAULT_METALNESS = 0.0;
const float DEFAULT_ROUGHNESS = 0.8;

vec2 encodeNormal(vec3 n);

void main()
{
    gbuffer0.rgb = pow(texture(color_tex, texCoord).rgb, vec3(2.2)); // Gamma correction
    gbuffer0.a = 1.0;
    gbuffer1 = encodeNormal(normalVS);
    gbuffer2 = vec4(DEFAULT_METALNESS,
                    DEFAULT_ROUGHNESS,
                    0.0,
                    0.0);
}
