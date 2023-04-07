#version 330 core

in vec3 rawpos;
in vec2 texcoord;
in mat3 TBN;

uniform sampler2D color_tex;
uniform sampler2D normal_tex;
uniform sampler3D noise_tex;

const float NORMAL_MAP_SCALE = 8.0;

// gbuffer_pack.glsl
void gbuffer_pack(vec3 normal, vec3 base_color, float metallic, float roughness,
                  float occlusion, vec3 emissive, uint mat_id);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);

void main()
{
    vec4 texel = texture(color_tex, texcoord);
    vec3 color = eotf_inverse_sRGB(texel.rgb);

    vec3 normal = texture(normal_tex, texcoord * NORMAL_MAP_SCALE).rgb * 2.0 - 1.0;
    vec3 N = normalize(TBN * normal);

    vec3 noise_large = texture(noise_tex, rawpos * 0.0045).rgb;
    vec3 noise_small = texture(noise_tex, rawpos).rgb;

    float mix_factor = noise_large.r * noise_large.g * noise_large.b * 350.0;
    mix_factor = smoothstep(0.0, 1.0, mix_factor);

    color = mix(color, noise_small, 0.15);

    float roughness = mix(0.94, 0.98, mix_factor);

    gbuffer_pack(N, color, 0.0, roughness, 1.0, vec3(0.0), 3u);
}
