#version 330 core

in vec3 vN;
in vec2 texcoord;
in vec2 orthophoto_texcoord;

uniform sampler2D color_tex;
uniform sampler2D orthophoto_tex;

uniform bool orthophotoAvailable;

const float TERRAIN_METALLIC  = 0.0;
const float TERRAIN_ROUGHNESS = 0.95;

// gbuffer_pack.glsl
void gbuffer_pack(vec3 normal, vec3 base_color, float metallic, float roughness,
                  float occlusion, vec3 emissive, uint mat_id);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);

void main()
{
    vec3 texel = texture(color_tex, texcoord).rgb;
    if (orthophotoAvailable) {
        vec4 sat_texel = texture(orthophoto_tex, orthophoto_texcoord);
        if (sat_texel.a > 0.0) {
            texel.rgb = sat_texel.rgb;
        }
    }

    vec3 color = eotf_inverse_sRGB(texel);

    gbuffer_pack(vN, color, TERRAIN_METALLIC, TERRAIN_ROUGHNESS, 1.0, vec3(0.0), 3u);
}
