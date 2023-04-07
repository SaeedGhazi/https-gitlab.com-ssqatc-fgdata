#version 330 core

in vec3 vN;
in vec2 texcoord;

uniform sampler2D color_tex;

// gbuffer_pack.glsl
void gbuffer_pack(vec3 normal, vec3 base_color, float metallic, float roughness,
                  float occlusion, vec3 emissive, uint mat_id);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);

void main()
{
    vec4 texel = texture(color_tex, texcoord);
    if (texel.a < 0.5)
        discard;

    vec3 color = eotf_inverse_sRGB(texel.rgb);

    gbuffer_pack(vN, color, 0.0, 0.9, 1.0, vec3(0.0), 3u);
}
