#version 330 core

in VS_OUT {
    vec2 texcoord;
    vec3 vertex_normal;
    vec3 view_vector;
} fs_in;

uniform sampler2D color_tex;

uniform int normalmap_enabled;
uniform float normalmap_tiling;

const float COMBINED_METALLIC  = 0.0;
const float COMBINED_ROUGHNESS = 0.1;

// gbuffer_pack.glsl
void gbuffer_pack(vec3 normal, vec3 base_color, float metallic, float roughness,
                  float occlusion, vec3 emissive, uint mat_id);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);
// normalmap.glsl
vec3 perturb_normal(vec3 N, vec3 V, vec2 texcoord);

void main()
{
    vec3 texel = texture(color_tex, fs_in.texcoord).rgb;
    vec3 color = eotf_inverse_sRGB(texel);

    vec3 N = normalize(fs_in.vertex_normal);
    if (normalmap_enabled > 0) {
        N = perturb_normal(N, fs_in.view_vector, fs_in.texcoord * normalmap_tiling);
    }

    gbuffer_pack(N, color, COMBINED_METALLIC, COMBINED_ROUGHNESS, 1.0, vec3(0.0), 3u);
}
