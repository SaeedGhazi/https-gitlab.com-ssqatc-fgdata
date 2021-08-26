#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D gbuffer1_tex;
uniform sampler2D gbuffer2_tex;
uniform sampler2D depth_tex;
uniform sampler2D ao_tex;

uniform bool debug_shadow_cascades;

uniform mat4 fg_ViewMatrixInverse;
uniform mat4 fg_ProjectionMatrix;
uniform vec3 fg_SunDirection;

vec3 decodeNormal(vec2 f);
vec3 positionFromDepth(vec2 pos, float depth);
float getShadowing(vec3 p, vec3 n, vec3 l, mat4 viewToClip);
vec3 debugShadowColor(vec3 p, vec3 n, vec3 l);
vec3 getF0Reflectance(vec3 baseColor, float metallic);
vec3 evaluateLight(
    vec3 baseColor,
    float metallic,
    float roughness,
    vec3 f0,
    vec3 intensity,
    float occlusion,
    vec3 n,
    vec3 l,
    vec3 v,
    float NdotL,
    float NdotV);
vec3 evaluateIBL(
    vec3 baseColor,
    float metallic,
    float roughness,
    vec3 f0,
    float occlusion,
    vec3 nWorldSpace,
    float NdotV,
    vec3 reflected);
vec3 addAerialPerspective(vec3 color, vec2 coord, float depth);
vec3 getSunIntensity();

void main()
{
    vec4 gbuffer0 = texture(gbuffer0_tex, texCoord);
    vec4 gbuffer1 = texture(gbuffer1_tex, texCoord);
    vec4 gbuffer2 = texture(gbuffer2_tex, texCoord);
    float depth   = texture(depth_tex, texCoord).r;

    // Unpack G-Buffer
    vec3 n          = decodeNormal(gbuffer0.rg);
    float roughness = gbuffer0.b;
    uint matId      = uint(gbuffer0.a * 4.0);
    vec3 baseColor  = gbuffer1.rgb;
    float metallic  = gbuffer1.a;
    float occlusion = gbuffer2.a;

    vec3 pos = positionFromDepth(texCoord, depth);
    vec3 v = normalize(-pos);
    vec3 l = fg_SunDirection;

    float NdotL = dot(n, l);
    float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);

    float ao = texture(ao_tex, texCoord).r;

    vec3 f0 = getF0Reflectance(baseColor, metallic);

    vec3 sunIlluminance = getSunIntensity() * clamp(NdotL, 0.0, 1.0);
    float shadowFactor = getShadowing(pos, n, l, fg_ProjectionMatrix);

    vec3 color = evaluateLight(baseColor,
                               metallic,
                               roughness,
                               f0,
                               sunIlluminance,
                               shadowFactor,
                               n, l, v,
                               NdotL, NdotV);

    float ambientOcclusion = ao * occlusion;
    vec3 worldNormal = (fg_ViewMatrixInverse * vec4(n, 0.0)).xyz;
    vec3 worldReflected = (fg_ViewMatrixInverse * vec4(reflect(-v, n), 0.0)).xyz;

    color += evaluateIBL(baseColor,
                         metallic,
                         roughness,
                         f0,
                         ambientOcclusion,
                         worldNormal,
                         NdotV,
                         worldNormal);

    color = addAerialPerspective(color, texCoord, length(pos));

    if (debug_shadow_cascades)
        color *= debugShadowColor(pos, n, l);

    fragColor = color;
}
