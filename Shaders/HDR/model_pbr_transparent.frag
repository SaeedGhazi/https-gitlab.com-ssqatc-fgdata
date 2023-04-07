#version 330 core

layout(location = 0) out vec4 fragColor;

in vec3 vP;
in vec2 texcoord;
in mat3 TBN;
in vec4 ap_color;

uniform sampler2D base_color_tex;
uniform sampler2D normal_tex;
uniform sampler2D orm_tex;
uniform sampler2D emissive_tex;

uniform vec4 base_color_factor;
uniform float metallic_factor;
uniform float roughness_factor;
uniform vec3 emissive_factor;
uniform float alpha_cutoff;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ProjectionMatrix;
uniform vec4 fg_Viewport;

// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);
// shading_transparent.glsl
vec3 eval_lights_transparent(
    vec3 base_color, float metallic, float roughness, float occlusion,
    vec3 P, vec3 N, vec3 V, vec2 uv, vec4 ap,
    mat4 view_matrix_inverse);

void main()
{
    vec4 base_color_texel = texture(base_color_tex, texcoord);
    vec4 base_color = vec4(eotf_inverse_sRGB(base_color_texel.rgb), base_color_texel.a)
        * base_color_factor;
    if (base_color.a < alpha_cutoff)
        discard;

    vec3 normal = texture(normal_tex, texcoord).rgb * 2.0 - 1.0;
    vec3 N = normalize(TBN * normal);

    vec3 orm = texture(orm_tex, texcoord).rgb;
    float occlusion = orm.r;
    float roughness = orm.g * roughness_factor;
    float metallic = orm.b * metallic_factor;
    vec3 emissive = texture(emissive_tex, texcoord).rgb * emissive_factor;

    vec3 V = normalize(-vP);
    vec2 uv = (gl_FragCoord.xy - fg_Viewport.xy) / fg_Viewport.zw;

    vec3 color = eval_lights_transparent(
        base_color.rgb, metallic, roughness, occlusion,
        vP, N, V, uv, ap_color, osg_ViewMatrixInverse);

    fragColor = vec4(color, baseColor.a);
}
