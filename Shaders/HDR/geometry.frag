#version 330 core

layout(location = 0) out vec4 gbuffer0;
layout(location = 1) out vec2 gbuffer1;
layout(location = 2) out vec4 gbuffer2;

in vec3 normalVS;
in vec2 texCoord;
in vec4 materialColor;

uniform sampler2D color_tex;

const float DEFAULT_METALNESS = 0.0;
const float DEFAULT_ROUGHNESS = 0.8;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec3 texel = texture(color_tex, texCoord).rgb;
    vec3 color = decodeSRGB(texel) * materialColor.rgb; // Ignore transparency
    gbuffer0.rgb = color;
    gbuffer0.a = 1.0;
    gbuffer1 = encodeNormal(normalVS);
    gbuffer2 = vec4(DEFAULT_METALNESS,
                    DEFAULT_ROUGHNESS,
                    0.0,
                    0.0);
}
