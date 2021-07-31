#version 330 core

layout(location = 0) out vec4 gbuffer0;
layout(location = 1) out vec2 gbuffer1;
layout(location = 2) out vec4 gbuffer2;

in vec2 texCoord;
in mat3 TBN;

uniform sampler2D base_color_tex;
uniform sampler2D normal_tex;
uniform sampler2D metallic_tex;
uniform sampler2D roughness_tex;
uniform sampler2D occlusion_tex;
uniform sampler2D emissive_tex;
uniform vec4 base_color_factor;
uniform float metallic_factor;
uniform float roughness_factor;
uniform vec3 emissive_factor;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec4 base_color_texel = texture(base_color_tex, texCoord);
    gbuffer0.rgb = decodeSRGB(base_color_texel.rgb); // Ignore alpha
    float occlusion = texture(occlusion_tex, texCoord).r;
    gbuffer0.a = occlusion;

    vec3 normal = texture(normal_tex, texCoord).rgb * 2.0 - 1.0;
    normal = normalize(TBN * normal);
    gbuffer1 = encodeNormal(normal);

    float metallic = texture(metallic_tex, texCoord).r * metallic_factor;
    float roughness = texture(roughness_tex, texCoord).r * roughness_factor;
    gbuffer2 = vec4(metallic, roughness, 0.0, 0.0);

    vec3 emissive = texture(emissive_tex, texCoord).rgb * emissive_factor;
}
