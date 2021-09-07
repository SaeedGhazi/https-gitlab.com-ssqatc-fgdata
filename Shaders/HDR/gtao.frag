/**
 * An implementation of GTAO (Ground Truth Ambient Occlusion)
 * Based on 'Practical Real-Time Strategies for Accurate Indirect Occlusion' by
 * Jorge Jimenez et al.
 * https://www.activision.com/cdn/research/Practical_Real_Time_Strategies_for_Accurate_Indirect_Occlusion_NEW%20VERSION_COLOR.pdf
 * https://blog.selfshadow.com/publications/s2016-shading-course/activision/s2016_pbs_activision_occlusion.pdf
 * Most of the shader is based on Algorithm 1 of the paper.
 */

#version 330 core

out float fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D depth_tex;

uniform float world_radius;

uniform vec4 fg_Viewport;
uniform vec2 fg_PixelSize;
uniform mat4 fg_ProjectionMatrix;

const float PI = 3.141592653;
const float PI_HALF = PI * 0.5;
const float SLICE_COUNT = 3.0;
const float DIRECTION_SAMPLE_COUNT = 4.0;

vec3 decodeNormal(vec2 f);
vec3 positionFromDepth(vec2 pos, float depth);

void main()
{
    float depth = textureLod(depth_tex, texCoord, 0.0).r;
    // Ignore the background
    if (depth == 0.0) {
        fragColor = 0.0;
        discard;
    }
    // Slightly push the depth towards the camera to avoid imprecision artifacts
    depth = clamp(depth * 1.00001, 0.0, 1.0);

    // View space normal
    vec3 normal = decodeNormal(texture(gbuffer0_tex, texCoord).rg);
    // Fragment position in view space
    vec3 pos = positionFromDepth(texCoord, depth);
    // View vector in view space
    vec3 v = normalize(-pos);

    float noiseDirection = 0.0625 * float(
        ((int(gl_FragCoord.x) + int(gl_FragCoord.y) & 3) << 2) +
        (int(gl_FragCoord.x) & 3));

    float noiseOffset = 0.25 * float(int(gl_FragCoord.x) + int(gl_FragCoord.y) & 3);

    // Transform the world space hemisphere radius to screen space pixels with
    // the following formula:
    //      radius * 1 / [ tan(fovy / 2) * z_distance ] * (screen_size.y / 2)
    // In our case, the (1,1) element of the projection matrix contains
    // 1 / tan(fovy / 2), so we can use that directly.
    // z_distance is the distance from the camera to the fragment, which is
    // just the positive z component of the view space fragment position.
	float radiusPixels = world_radius * (fg_ProjectionMatrix[1][1] / abs(pos.z))
        * fg_Viewport.w * 0.5;

    float visibility = 0.0;

    for (float i = 0.0; i < SLICE_COUNT; ++i) {
        float phi = ((i + noiseDirection) / SLICE_COUNT) * PI;
        float cosPhi = cos(phi);
        float sinPhi = sin(phi);
        vec2 omega = vec2(cosPhi, sinPhi);

        vec3 dir = vec3(omega, 0.0);
        vec3 orthoDirection = dir - dot(dir, v) * v;
        vec3 axis = normalize(cross(dir, v));
        vec3 projNormal = normal - axis * dot(normal, axis);
        float projNormalLength = max(1e-5, length(projNormal));

        float sgnN = sign(dot(orthoDirection, projNormal));
        float cosN = clamp(dot(projNormal, v) / projNormalLength, 0.0, 1.0);
        float n = sgnN * acos(cosN);

        float hcos1 = -1.0, hcos2 = -1.0;

        for (float j = 0.0; j < DIRECTION_SAMPLE_COUNT; ++j) {
            float s = (j + noiseOffset) / DIRECTION_SAMPLE_COUNT;
            s += 1.2 / radiusPixels;
            vec2 sOffset = s * radiusPixels * omega;
            sOffset = round(sOffset) * fg_PixelSize;

            vec2 sTexCoord1 = texCoord - sOffset;
            float sDepth1 = textureLod(depth_tex, sTexCoord1, 0.0).r;
            if (sDepth1 == 0.0) {
                // Skip background
                continue;
            }
            vec3 sPos1 = positionFromDepth(sTexCoord1, sDepth1);

            vec2 sTexCoord2 = texCoord + sOffset;
            float sDepth2 = textureLod(depth_tex, sTexCoord2, 0.0).r;
            if (sDepth2 == 0.0) {
                // Skip background
                continue;
            }
            vec3 sPos2 = positionFromDepth(sTexCoord2, sDepth2);

            vec3 sHorizon1 = sPos1 - pos;
            vec3 sHorizon2 = sPos2 - pos;
            float sHorizonLength1 = length(sHorizon1);
            float sHorizonLength2 = length(sHorizon2);

            float shcos1 = dot(sHorizon1 / sHorizonLength1, v);
            float shcos2 = dot(sHorizon2 / sHorizonLength2, v);

            // Section 4.3: Bounding the sampling area
            // Attenuate samples that are further away
            float weight1 = clamp((1.0 - sHorizonLength1 / world_radius) * 2.0, 0.0, 1.0);
            float weight2 = clamp((1.0 - sHorizonLength2 / world_radius) * 2.0, 0.0, 1.0);
            shcos1 = mix(-1.0, shcos1, weight1);
            shcos2 = mix(-1.0, shcos2, weight2);

            hcos1 = max(hcos1, shcos1);
            hcos2 = max(hcos2, shcos2);
        }

        float h1 = n + max(-acos(hcos1) - n, -PI_HALF);
        float h2 = n + min( acos(hcos2) - n,  PI_HALF);

        float sinN = sin(n);
        float h1_2 = 2.0 * h1;
        float h2_2 = 2.0 * h2;
        float vd = 0.25 * ((cosN + h1_2 * sinN - cos(h1_2 - n)) +
                           (cosN + h2_2 * sinN - cos(h2_2 - n)));
        visibility += projNormalLength * vd;
    }
    visibility /= float(SLICE_COUNT);

    fragColor = clamp(visibility, 0.0, 1.0);
}
