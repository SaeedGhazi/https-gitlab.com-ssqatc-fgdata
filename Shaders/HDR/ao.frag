#version 330 core
#pragma optionNV (unroll all)

out float fragColor;

in vec2 texCoord;

uniform sampler2D depth_tex;
uniform sampler2D normal_tex;

uniform mat4 fg_ProjectionMatrix;

const float RADIUS = 0.04;
const float BIAS = 0.05;
const float SCALE = 3.0;
const float MAX_DISTANCE = 0.08;
const float INTENSITY = 1.5;

const vec2 kernel[4] = vec2[](
    vec2( 0.0,  1.0),  // top
    vec2( 1.0,  0.0),  // right
    vec2( 0.0, -1.0),  // bottom
    vec2(-1.0,  0.0)); // left

vec3 positionFromDepth(vec2 pos, float depth);
vec3 decodeNormal(vec2 enc);

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float sampleAO(vec3 fragPos, vec3 normal, vec2 coords)
{
    float sampleDepth = texture(depth_tex, coords).r;
    vec3 samplePoint = positionFromDepth(coords, sampleDepth);

    vec3 diff = samplePoint - fragPos;
    float l = length(diff);
    vec3 v = diff / l;
    float d = l * SCALE;

    float ao = max(0.0, dot(normal, v) - BIAS) * (1.0 / (1.0 + d));
    ao *= smoothstep(MAX_DISTANCE, MAX_DISTANCE * 0.5, l);
    return ao;
}

void main()
{
    float fragDepth = texture(depth_tex, texCoord).r;
    vec3 fragPos = positionFromDepth(texCoord, fragDepth);

    vec3 normal = normalize(decodeNormal(texture(normal_tex, texCoord).rg));

    vec2 randomVec = normalize(vec2(rand(texCoord) * 2.0 - 1.0,
                                    rand(texCoord+1.0) * 2.0 - 1.0));

    const float sin45 = 0.707107;

    float occlusion = 0.0;
    for (int i = 0; i < 4; ++i) {
        vec2 k1 = reflect(kernel[i], randomVec) * RADIUS;
        vec2 k2 = vec2(k1.x * sin45 - k1.y * sin45, k1.x * sin45 + k1.y * sin45);
        occlusion += sampleAO(fragPos, normal, texCoord + k1);
        occlusion += sampleAO(fragPos, normal, texCoord + k2 * 0.75);
        occlusion += sampleAO(fragPos, normal, texCoord + k1 * 0.5);
        occlusion += sampleAO(fragPos, normal, texCoord + k2 * 0.25);
    }
    occlusion /= 16.0;

    fragColor = clamp(1.0 - occlusion * INTENSITY, 0.0, 1.0);
}
