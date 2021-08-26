#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec2 texCoord;
in mat3 TBN;

uniform sampler2D base_color_tex;
uniform sampler2D normal_tex;
uniform sampler2D orm_tex;
uniform sampler2D emissive_tex;
uniform vec4 base_color_factor;
uniform float metallic_factor;
uniform float roughness_factor;
uniform vec3 emissive_factor;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec3 baseColorTexel = texture(base_color_tex, texCoord).rgb; // Ignore alpha
    vec3 baseColor = decodeSRGB(baseColorTexel.rgb) * base_color_factor.rgb;

    vec3 normal = texture(normal_tex, texCoord).rgb * 2.0 - 1.0;
    normal = normalize(TBN * normal);

    vec3 orm = texture(orm_tex, texCoord).rgb;
    float occlusion = orm.r;
    float roughness = orm.g * roughness_factor;
    float metallic = orm.b * metallic_factor;

    vec3 emissive = texture(emissive_tex, texCoord).rgb * emissive_factor;

    outGBuffer0.rg  = encodeNormal(normal);
    outGBuffer0.b   = roughness;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = baseColor;
    outGBuffer1.a   = metallic;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = occlusion;
}
