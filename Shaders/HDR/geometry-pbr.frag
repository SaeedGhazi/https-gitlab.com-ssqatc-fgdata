#version 330 core

layout(location = 0) out vec4 gbuffer0;
layout(location = 1) out vec2 gbuffer1;
layout(location = 2) out vec4 gbuffer2;

in vec2 texCoord;
in mat3 TBN;

uniform sampler2D albedo_tex;
uniform sampler2D normal_tex;
uniform sampler2D metalness_tex;
uniform sampler2D roughness_tex;
uniform sampler2D cavity_tex;

vec2 encodeNormal(vec3 n);

void main()
{
    gbuffer0.rgb = pow(texture(albedo_tex, texCoord).rgb, vec3(2.2)); // Gamma correction
    gbuffer0.a = texture(cavity_tex, texCoord).r;

    vec3 normal = texture(normal_tex, texCoord).rgb * 2.0 - 1.0;
    normal = normalize(TBN * normal);
    gbuffer1 = encodeNormal(normal);

    float metalness = texture(metalness_tex, texCoord).r;
    float roughness = texture(roughness_tex, texCoord).r;

    gbuffer2 = vec4(metalness, roughness, 0.0, 0.0);
}
