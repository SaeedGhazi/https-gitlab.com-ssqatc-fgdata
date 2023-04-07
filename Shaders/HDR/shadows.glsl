#version 330 core

uniform sampler2DShadow shadow_tex;
uniform sampler2D depth_tex; // For Screen Space Shadows

uniform bool debug_shadow_cascades;

uniform mat4 fg_LightMatrix_csm0;
uniform mat4 fg_LightMatrix_csm1;
uniform mat4 fg_LightMatrix_csm2;
uniform mat4 fg_LightMatrix_csm3;

const float NORMAL_BIAS      = 0.02;
const float BAND_SIZE        = 0.1;
const vec2  BAND_BOTTOM_LEFT = vec2(BAND_SIZE);
const vec2  BAND_TOP_RIGHT   = vec2(1.0 - BAND_SIZE);

// Ideally these should be passed as an uniform, but we don't support uniform
// arrays yet
const vec2 uv_shifts[4] = vec2[4](
    vec2(0.0, 0.0), vec2(0.5, 0.0),
    vec2(0.0, 0.5), vec2(0.5, 0.5));
const vec2 uv_factor = vec2(0.5, 0.5);

// Screen Space Shadows parameters
const float SSS_THICKNESS = 0.1;
const uint  SSS_NUM_STEPS = 16u;
const float SSS_MAX_DISTANCE = 0.05;
const vec3  DITHER_MAGIC = vec3(0.06711056, 0.00583715, 52.9829189);

float sample_shadow_map(vec2 coord, vec2 offset, float depth)
{
    return texture(shadow_tex, vec3(coord + offset, depth));
}

/*
 * OptimizedPCF from https://github.com/TheRealMJP/Shadows
 * Original by Ignacio Castaño for The Witness
 * Released under The MIT License
 */
float sample_optimized_PCF(vec4 pos, vec2 map_size)
{
    vec2 texel_size = vec2(1.0) / map_size;

    vec2 offset = vec2(0.5);
    vec2 uv = (pos.xy * map_size) + offset;
    vec2 base = (floor(uv) - offset) * texel_size;
    vec2 st = fract(uv);

    vec3 uw = vec3(4.0 - 3.0 * st.x, 7.0, 1.0 + 3.0 * st.x);
    vec3 vw = vec3(4.0 - 3.0 * st.y, 7.0, 1.0 + 3.0 * st.y);

    vec3 u = vec3((3.0 - 2.0 * st.x) / uw.x - 2.0, (3.0 + st.x) / uw.y, st.x / uw.z + 2.0);
    vec3 v = vec3((3.0 - 2.0 * st.y) / vw.x - 2.0, (3.0 + st.y) / vw.y, st.y / vw.z + 2.0);

    u *= texel_size.x;
    v *= texel_size.y;

    float depth = pos.z;
    float sum = 0.0;

    sum += uw.x * vw.x * sample_shadow_map(base, vec2(u.x, v.x), depth);
    sum += uw.y * vw.x * sample_shadow_map(base, vec2(u.y, v.x), depth);
    sum += uw.z * vw.x * sample_shadow_map(base, vec2(u.z, v.x), depth);

    sum += uw.x * vw.y * sample_shadow_map(base, vec2(u.x, v.y), depth);
    sum += uw.y * vw.y * sample_shadow_map(base, vec2(u.y, v.y), depth);
    sum += uw.z * vw.y * sample_shadow_map(base, vec2(u.z, v.y), depth);

    sum += uw.x * vw.z * sample_shadow_map(base, vec2(u.x, v.z), depth);
    sum += uw.y * vw.z * sample_shadow_map(base, vec2(u.y, v.z), depth);
    sum += uw.z * vw.z * sample_shadow_map(base, vec2(u.z, v.z), depth);

    return sum / 144.0;
}

float sample_cascade(vec4 P, vec2 shift, vec2 map_size)
{
    vec4 pos = P;
    pos.xy *= uv_factor;
    pos.xy += shift;
    return sample_optimized_PCF(pos, map_size);
}

float get_blend_factor(vec2 uv, vec2 bottom_left, vec2 top_right)
{
    vec2 s = smoothstep(vec2(0.0), bottom_left, uv)
        - smoothstep(top_right, vec2(1.0), uv);
    return 1.0 - s.x * s.y;
}

bool check_within_bounds(vec2 uv, vec2 bottom_left, vec2 top_right)
{
    vec2 r = step(bottom_left, uv) - step(top_right, uv);
    return bool(r.x * r.y);
}

bool is_inside_cascade(vec4 P)
{
    return check_within_bounds(P.xy, vec2(0.0), vec2(1.0)) && ((P.z / P.w) <= 1.0);
}

bool is_inside_band(vec4 P)
{
    return !check_within_bounds(P.xy, BAND_BOTTOM_LEFT, BAND_TOP_RIGHT);
}

/*
 * Get the light space position of point P.
 * Both P and N must be in view space. The light matrix is also assumed to
 * transform from view space to light space.
 */
vec4 get_light_space_position(vec3 P, vec3 N, float NdotL, mat4 light_matrix)
{
    float sin_theta = sqrt(1.0 - NdotL * NdotL);
    vec3 offset_pos = P + N * (sin_theta * NORMAL_BIAS);
    return light_matrix * vec4(offset_pos, 1.0);
}

/*
 * Screen Space Shadows
 * Implementation mostly based on:
 * https://panoskarabelas.com/posts/screen_space_shadows/
 * Marching done in screen space instead of in view space.
 */
float get_contact_shadow(vec3 P, vec3 L, mat4 projection_matrix)
{
    // Ray start and end points in view space
    vec3 vs_ray_start = P;
    vec3 vs_ray_end   = vs_ray_start + L * SSS_MAX_DISTANCE;
    // To clip space
    vec4 cs_ray_start = projection_matrix * vec4(vs_ray_start, 1.0);
    vec4 cs_ray_end   = projection_matrix * vec4(vs_ray_end, 1.0);
    // Perspective divide
    vec3 ray_start = cs_ray_start.xyz / cs_ray_start.w;
    vec3 ray_end   = cs_ray_end.xyz / cs_ray_end.w;
    // From [-1,1] to [0,1] to sample directly from textures
    ray_start = ray_start * 0.5 + 0.5;
    ray_end   = ray_end * 0.5 + 0.5;

    vec3 ray_dir = ray_end - ray_start;

    float dither = fract(DITHER_MAGIC.z * fract(dot(gl_FragCoord.xy, DITHER_MAGIC.xy)));

    float dt = 1.0 / float(SSS_NUM_STEPS);
    float t = dt * dither + dt;

    float shadow = 0.0;

    for (uint i = 0u; i < SSS_NUM_STEPS; ++i) {
        vec3 sample_pos = ray_start + ray_dir * t;
        // Reversed depth buffer, invert it
        float sample_depth = 1.0 - texture(depth_tex, sample_pos.xy).r;
        float dz = sample_pos.z - sample_depth;
        if (dz > 0.00001 && dz < SSS_THICKNESS) {
            shadow = 1.0;
            vec2 screen_fade = smoothstep(vec2(0.0), vec2(0.07), sample_pos.xy)
                - smoothstep(vec2(0.93), vec2(1.0), sample_pos.xy);
            shadow *= screen_fade.x * screen_fade.y;
            break;
        }
        t += dt;
    }

    return 1.0 - shadow;
}

/*
 * Get the shadowing factor for a given position. 1.0 corresponds to a fragment
 * being completely lit, and 0.0 to a fragment being completely in shadow.
 * Both P and N must be in view space.
 */
float get_shadowing(vec3 P, vec3 N, vec3 L)
{
    float NdotL = clamp(dot(N, L), 0.0, 1.0);

    vec4 ls_P[4];
    ls_P[0] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm0);
    ls_P[1] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm1);
    ls_P[2] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm2);
    ls_P[3] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm3);

    vec2 map_size = vec2(textureSize(shadow_tex, 0));
    float visibility = 1.0;

    for (int i = 0; i < 4; ++i) {
        // Map-based cascade selection
        // We test if we are inside the cascade bounds to find the tightest
        // map that contains the fragment.
        if (is_inside_cascade(ls_P[i])) {
            if (is_inside_band(ls_P[i])) {
                // Blend between cascades if the fragment is near the
                // next cascade to avoid abrupt transitions.
                float blend = get_blend_factor(ls_P[i].xy,
                                               BAND_BOTTOM_LEFT,
                                               BAND_TOP_RIGHT);
                float cascade0 = sample_cascade(ls_P[i],
                                                uv_shifts[i],
                                                map_size);
                float cascade1;
                if (i == 3) {
                    // Handle special case of the last cascade
                    cascade1 = 1.0;
                } else {
                    cascade1 = sample_cascade(ls_P[i+1],
                                              uv_shifts[i+1],
                                              map_size);
                }
                visibility = mix(cascade0, cascade1, blend);
            } else {
                // We are far away from the borders of the cascade, so
                // we skip the blending to avoid the performance cost
                // of sampling the shadow map twice.
                visibility = sample_cascade(ls_P[i],
                                            uv_shifts[i],
                                            map_size);
            }
            break;
        }
    }
    visibility = clamp(visibility, 0.0, 1.0);

    return visibility;
}

vec3 debug_shadow_color(vec3 color, vec3 P, vec3 N, vec3 L)
{
    if (!debug_shadow_cascades)
        return color;

    float NdotL = clamp(dot(N, L), 0.0, 1.0);

    vec4 ls_P[4];
    ls_P[0] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm0);
    ls_P[1] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm1);
    ls_P[2] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm2);
    ls_P[3] = get_light_space_position(P, N, NdotL, fg_LightMatrix_csm3);

    vec3 debug_color;
    if (is_inside_cascade(ls_P[0]))
        debug_color = vec3(1.0, 0.0, 0.0);
    else if (is_inside_cascade(ls_P[1]))
        debug_color = vec3(0.0, 1.0, 0.0);
    else if (is_inside_cascade(ls_P[2]))
        debug_color = vec3(0.0, 0.0, 1.0);
    else if (is_inside_cascade(ls_P[3]))
        debug_color = vec3(1.0, 0.0, 1.0);
    else
        debug_color = vec3(0.0);

    return color * debug_color;
}
