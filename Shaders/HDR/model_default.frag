#version 330 core

in vec3 vN;
in vec2 texcoord;
in vec4 material_color;

uniform sampler2D color_tex;

const float DEFAULT_METALLIC  = 0.0;
const float DEFAULT_ROUGHNESS = 0.5;

// gbuffer_pack.glsl
void gbuffer_pack(vec3 normal, vec3 base_color, float metallic, float roughness,
                  float occlusion, vec3 emissive, uint mat_id);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);

void main()
{
    vec3 texel = texture(color_tex, texcoord).rgb;
    vec3 color = eotf_inverse_sRGB(texel) * material_color.rgb;

    gbuffer_pack(vN, color, DEFAULT_METALLIC, DEFAULT_ROUGHNESS, 1.0, vec3(0.0), 3u);
}
