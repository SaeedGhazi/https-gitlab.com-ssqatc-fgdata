$FG_GLSL_VERSION

in VS_OUT {
    float flogz;
    vec2 texcoord;
    vec3 vertex_normal;
    vec3 view_vector;
} fs_in;

uniform sampler2D base_color_tex;
uniform sampler2D normal_tex;
uniform sampler2D orm_tex;
uniform sampler2D emissive_tex;

uniform vec4 base_color_factor;
uniform float metallic_factor;
uniform float roughness_factor;
uniform vec3 emissive_factor;

// G-buffer inputs
uniform sampler2D gbuffer0;
uniform sampler2D gbuffer1;
uniform sampler2D gbuffer2;
uniform sampler2D gbuffer3;
uniform sampler2D depthTex;

// gbuffer_pack.glsl
void gbuffer_pack_pbr_opaque(vec3 normal,
                             vec3 base_color,
                             float metallic,
                             float roughness,
                             float occlusion,
                             vec3 emissive);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);
// normalmap.glsl
vec3 perturb_normal(vec3 N, vec3 V, vec2 texcoord, sampler2D tex);

// pos_from_depth.glsl
vec3 get_view_space_from_depth(vec2 uv, float depth);

// logarithmic_depth.glsl
float logdepth_encode(float z);
// normal_encoding.glsl
vec3 decode_normal(vec2 f);

uniform mat4 fg_ProjectionMatrixInverse;
uniform vec4 fg_Viewport;
uniform mat4 fg_ViewMatrixInverse;

void main()
{
    // Pixel position in screen space [0, 1]
    vec2 screenCoord = (gl_FragCoord.xy - fg_Viewport.xy) / fg_Viewport.zw;

    // Get the world position
    float depth = texture2D(depthTex, screenCoord).r;
    vec3 worldPos = get_view_space_from_depth(screenCoord, depth);

    // Early out if outside decal bounds
    //if (abs(worldPos.x) > 1.0 || abs(worldPos.y) > 1.0 || abs(worldPos.z) > 0.01) {
     //   discard;
    //}

    // Calculate decal projection coordinates
    vec2 decalCoord = worldPos.xy;   // * decalScale;

    // Sample current G-buffer values
    vec4 gb0 = texture2D(gbuffer0, screenCoord);
    vec4 gb1 = texture2D(gbuffer1, screenCoord);
    vec4 gb2 = texture2D(gbuffer2, screenCoord);
    vec4 gb3 = texture2D(gbuffer3, screenCoord);    

    // Unpack the G-Buffer
    vec3  N          = decode_normal(gb0.rg);
    float roughness  = gb0.b;
    //vec3  base_color = gb1.rgb;
    float metallic   = gb2.b;
    float occlusion  = gb2.a;
    vec3  emissive   = gb3.rgb;

    vec2 decalUV = decalCoord * 0.5 + 0.5;

    vec4 base_color_texel = texture(base_color_tex, decalUV);
    vec3 base_color = eotf_inverse_sRGB(base_color_texel.rgb) * base_color_factor.rgb;    
    // Ignore alpha in base color. We assume this is a completely opaque object

    //vec3 orm = texture(orm_tex, fs_in.texcoord).rgb;
    //float occlusion = orm.r;
    //float roughness = orm.g * roughness_factor;
    //float metallic = orm.b * metallic_factor;

    //vec3 emissive_texel = texture(emissive_tex, fs_in.texcoord).rgb;
    //vec3 emissive = eotf_inverse_sRGB(emissive_texel) * emissive_factor;

    //vec3 N = normalize(fs_in.vertex_normal);
    //N = perturb_normal(N, fs_in.view_vector, fs_in.texcoord, normal_tex);

    base_color = vec3(worldPos.x, worldPos.y, 0.0);
    
    gbuffer_pack_pbr_opaque(N, base_color, metallic, roughness, occlusion, emissive);
    gl_FragDepth = logdepth_encode(fs_in.flogz);
}
