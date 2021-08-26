#version 330 core

uniform sampler2D depth_tex; // For Screen Space Shadows
uniform sampler2DShadow shadow_tex;

uniform mat4 fg_LightMatrix_csm0;
uniform mat4 fg_LightMatrix_csm1;
uniform mat4 fg_LightMatrix_csm2;
uniform mat4 fg_LightMatrix_csm3;

const float NORMAL_BIAS = 0.02;
const float BAND_SIZE = 0.1;
const vec2 BAND_BOTTOM_LEFT = vec2(BAND_SIZE);
const vec2 BAND_TOP_RIGHT   = vec2(1.0 - BAND_SIZE);
// Ideally these should be passed as an uniform, but we don't support uniform
// arrays yet
const vec2 uv_shifts[4] = vec2[4](
    vec2(0.0, 0.0), vec2(0.5, 0.0),
    vec2(0.0, 0.5), vec2(0.5, 0.5));
const vec2 uv_factor = vec2(0.5, 0.5);

const float SSS_THICKNESS = 0.1;
const uint SSS_NUM_STEPS = 16u;
const float SSS_MAX_DISTANCE = 0.05;
const vec3 DITHER_MAGIC = vec3(0.06711056, 0.00583715, 52.9829189);

float sampleMap(vec2 coord, vec2 offset, float depth)
{
    return texture(shadow_tex, vec3(coord + offset, depth));
}

// OptimizedPCF from https://github.com/TheRealMJP/Shadows
// Original by Ignacio Castaño for The Witness
// Released under The MIT License
float sampleOptimizedPCF(vec4 pos, vec2 mapSize)
{
    vec2 texelSize = vec2(1.0) / mapSize;

    vec2 offset = vec2(0.5);
    vec2 uv = (pos.xy * mapSize) + offset;
    vec2 base = (floor(uv) - offset) * texelSize;
    vec2 st = fract(uv);

    vec3 uw = vec3(4.0 - 3.0 * st.x, 7.0, 1.0 + 3.0 * st.x);
    vec3 vw = vec3(4.0 - 3.0 * st.y, 7.0, 1.0 + 3.0 * st.y);

    vec3 u = vec3((3.0 - 2.0 * st.x) / uw.x - 2.0, (3.0 + st.x) / uw.y, st.x / uw.z + 2.0);
    vec3 v = vec3((3.0 - 2.0 * st.y) / vw.x - 2.0, (3.0 + st.y) / vw.y, st.y / vw.z + 2.0);

    u *= texelSize.x;
    v *= texelSize.y;

    float depth = pos.z;
    float sum = 0.0;

    sum += uw.x * vw.x * sampleMap(base, vec2(u.x, v.x), depth);
    sum += uw.y * vw.x * sampleMap(base, vec2(u.y, v.x), depth);
    sum += uw.z * vw.x * sampleMap(base, vec2(u.z, v.x), depth);

    sum += uw.x * vw.y * sampleMap(base, vec2(u.x, v.y), depth);
    sum += uw.y * vw.y * sampleMap(base, vec2(u.y, v.y), depth);
    sum += uw.z * vw.y * sampleMap(base, vec2(u.z, v.y), depth);

    sum += uw.x * vw.z * sampleMap(base, vec2(u.x, v.z), depth);
    sum += uw.y * vw.z * sampleMap(base, vec2(u.y, v.z), depth);
    sum += uw.z * vw.z * sampleMap(base, vec2(u.z, v.z), depth);

    return sum / 144.0;
}

float sampleCascade(vec4 p, vec2 shift, vec2 mapSize)
{
    vec4 pos = p;
    pos.xy *= uv_factor;
    pos.xy += shift;
    return sampleOptimizedPCF(pos, mapSize);
}

float getBlendFactor(vec2 uv, vec2 bottomLeft, vec2 topRight)
{
    vec2 s = smoothstep(vec2(0.0), bottomLeft, uv)
        - smoothstep(topRight, vec2(1.0), uv);
    return 1.0 - s.x * s.y;
}

bool checkWithinBounds(vec2 coords, vec2 bottomLeft, vec2 topRight)
{
    vec2 r = step(bottomLeft, coords) - step(topRight, coords);
    return bool(r.x * r.y);
}

bool isInsideCascade(vec4 p)
{
    return checkWithinBounds(p.xy, vec2(0.0), vec2(1.0)) && ((p.z / p.w) <= 1.0);
}

bool isInsideBand(vec4 p)
{
    return !checkWithinBounds(p.xy, BAND_BOTTOM_LEFT, BAND_TOP_RIGHT);
}

/**
 * Get the light space position of point p.
 * Both p and n must be in view space. The light matrix is also assumed to
 * transform from view space to light space.
 */
vec4 getLightSpacePosition(vec3 p, vec3 n, float NdotL, mat4 lightMatrix)
{
    float sinTheta = sqrt(1.0 - NdotL * NdotL);
    vec3 offsetPos = p + n * (sinTheta * NORMAL_BIAS);
    return lightMatrix * vec4(offsetPos, 1.0);
}

/**
 * Screen Space Shadows
 * Implementation mostly from:
 * https://panoskarabelas.com/posts/screen_space_shadows/
 * Marching done in screen space instead of in view space.
 */
float getContactShadow(vec3 p, vec3 l, mat4 viewToClip)
{
    // Ray start and end points in view space
    vec3 viewRayStart = p;
    vec3 viewRayEnd = viewRayStart + l * SSS_MAX_DISTANCE;
    // To clip space
    vec4 clipRayStart = viewToClip * vec4(viewRayStart, 1.0);
    vec4 clipRayEnd   = viewToClip * vec4(viewRayEnd, 1.0);
    // Perspective divide
    vec3 rayStart = clipRayStart.xyz / clipRayStart.w;
    vec3 rayEnd = clipRayEnd.xyz / clipRayEnd.w;
    // From [-1,1] to [0,1] to sample directly from textures
    rayStart = rayStart * 0.5 + 0.5;
    rayEnd   = rayEnd * 0.5 + 0.5;

    vec3 ray = rayEnd - rayStart;

    float dither = fract(DITHER_MAGIC.z * fract(dot(gl_FragCoord.xy, DITHER_MAGIC.xy)));

    float dt = 1.0 / float(SSS_NUM_STEPS);
    float t = dt * dither + dt;

    float shadow = 0.0;

    for (uint i = 0u; i < SSS_NUM_STEPS; ++i) {
        vec3 samplePos = rayStart + ray * t;
        // Reversed depth buffer, invert it
        float sampleDepth = 1.0 - texture(depth_tex, samplePos.xy).r;
        float dz = samplePos.z - sampleDepth;
        if (dz > 0.00001 && dz < SSS_THICKNESS) {
            shadow = 1.0;
            vec2 screenFade = smoothstep(vec2(0.0), vec2(0.07), samplePos.xy)
                - smoothstep(vec2(0.93), vec2(1.0), samplePos.xy);
            shadow *= screenFade.x * screenFade.y;
            break;
        }
        t += dt;
    }

    return 1.0 - shadow;
}

/**
 * Get shadowing factor for a given position. 1.0 corresponds to a fragment
 * being completely lit, and 0.0 to a fragment being completely in shadow.
 * Both p and n must be in view space.
 * viewToClip transforms a point from view space to clip space. Used for SSS.
 */
float getShadowing(vec3 p, vec3 n, vec3 l, mat4 viewToClip)
{
    float NdotL = clamp(dot(n, l), 0.0, 1.0);

    vec4 lightSpacePos[4];
    lightSpacePos[0] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm0);
    lightSpacePos[1] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm1);
    lightSpacePos[2] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm2);
    lightSpacePos[3] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm3);

    vec2 mapSize = vec2(textureSize(shadow_tex, 0));
    float visibility = 1.0;

    for (int i = 0; i < 4; ++i) {
        // Map-based cascade selection
        // We test if we are inside the cascade bounds to find the tightest
        // map that contains the fragment.
        if (isInsideCascade(lightSpacePos[i])) {
            if (isInsideBand(lightSpacePos[i])) {
                // Blend between cascades if the fragment is near the
                // next cascade to avoid abrupt transitions.
                float blend = getBlendFactor(lightSpacePos[i].xy,
                                             BAND_BOTTOM_LEFT,
                                             BAND_TOP_RIGHT);
                float cascade0 = sampleCascade(lightSpacePos[i],
                                               uv_shifts[i],
                                               mapSize);
                float cascade1;
                if (i == 3) {
                    // Handle special case of the last cascade
                    cascade1 = 1.0;
                } else {
                    cascade1 = sampleCascade(lightSpacePos[i+1],
                                             uv_shifts[i+1],
                                             mapSize);
                }
                visibility = mix(cascade0, cascade1, blend);
            } else {
                // We are far away from the borders of the cascade, so
                // we skip the blending to avoid the performance cost
                // of sampling the shadow map twice.
                visibility = sampleCascade(lightSpacePos[i],
                                           uv_shifts[i],
                                           mapSize);
            }
            break;
        }
    }
    visibility = clamp(visibility, 0.0, 1.0);

    if (visibility > 0.0)
        visibility *= getContactShadow(p, l, viewToClip);

    return visibility;
}

vec3 debugShadowColor(vec3 p, vec3 n, vec3 l)
{
    float NdotL = clamp(dot(n, l), 0.0, 1.0);

    vec4 lightSpacePos[4];
    lightSpacePos[0] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm0);
    lightSpacePos[1] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm1);
    lightSpacePos[2] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm2);
    lightSpacePos[3] = getLightSpacePosition(p, n, NdotL, fg_LightMatrix_csm3);

    if (isInsideCascade(lightSpacePos[0]))
        return vec3(1.0, 0.0, 0.0);
    else if (isInsideCascade(lightSpacePos[1]))
        return vec3(0.0, 1.0, 0.0);
    else if (isInsideCascade(lightSpacePos[2]))
        return vec3(0.0, 0.0, 1.0);
    else if (isInsideCascade(lightSpacePos[3]))
        return vec3(1.0, 0.0, 1.0);

    return vec3(0.0);
}
