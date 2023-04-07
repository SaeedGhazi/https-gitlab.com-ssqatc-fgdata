#version 330 core

in vec2 texcoord;
in mat3 TBN;

uniform sampler2D color_tex;
uniform sampler2D normal_tex;
uniform int normalmap_enabled;
uniform int normalmap_dds;
uniform float normalmap_tiling;

const float COMBINED_METALLIC  = 0.0;
const float COMBINED_ROUGHNESS = 0.1;

// gbuffer_pack.glsl
void gbuffer_pack(vec3 normal, vec3 base_color, float metallic, float roughness,
                  float occlusion, vec3 emissive, uint mat_id);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);

void main()
{
    vec3 texel = texture(color_tex, texcoord).rgb;
    vec3 color = eotf_inverse_sRGB(texel);

    vec3 normal = vec3(0.0, 0.0, 1.0);
    if (normalmap_enabled > 0) {
        normal = texture(normal_tex, texcoord * normalmap_tiling).rgb * 2.0 - 1.0;
        // DDS has flipped normals
        if (normalmap_dds > 0)
            normal = -normal;
    }
    vec3 N = normalize(TBN * normal);

    gbuffer_pack(N, color, COMBINED_METALLIC, COMBINED_ROUGHNESS, 1.0, vec3(0.0), 3u);
}
