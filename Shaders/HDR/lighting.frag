#version 330 core

out vec3 fragHdrColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D gbuffer1_tex;
uniform sampler2D gbuffer2_tex;
uniform sampler2D depth_tex;
uniform sampler2D ao_tex;

uniform mat4 fg_ViewMatrixInverse;
uniform vec3 fg_SunDirection;

vec3 decodeNormal(vec2 enc);
vec3 positionFromDepth(vec2 pos, float depth);
vec3 getF0Reflectance(vec3 baseColor, float metallic);
float getShadowing(vec3 p, vec3 n, float NdotL);
vec3 evaluateLight(
    vec3 baseColor,
    float metallic,
    float roughness,
    float clearcoat,
    float clearcoatRoughness,
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
    float depth = texture(depth_tex, texCoord).r;
    vec4 gbuffer0 = texture(gbuffer0_tex, texCoord);
    vec2 gbuffer1 = texture(gbuffer1_tex, texCoord).rg;
    vec4 gbuffer2 = texture(gbuffer2_tex, texCoord);
    float ao = texture(ao_tex, texCoord).r;

    vec3 pos = positionFromDepth(texCoord, depth);
    vec3 v = normalize(-pos);
    vec3 n = decodeNormal(gbuffer1);
    vec3 l = fg_SunDirection;

    float NdotL = dot(n, l);
    float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);

    vec3 baseColor = gbuffer0.rgb;
    float cavity = gbuffer0.a;
    float metallic = gbuffer2.r;
    float roughness = gbuffer2.g;
    float clearcoat = gbuffer2.b;
    float clearcoatRoughness = gbuffer2.a;

    vec3 f0 = getF0Reflectance(baseColor, metallic);

    vec3 sunIlluminance = getSunIntensity() * clamp(NdotL, 0.0, 1.0);
    float shadowFactor = getShadowing(pos, n, NdotL);

    vec3 color = evaluateLight(baseColor,
                               metallic,
                               roughness,
                               clearcoat,
                               clearcoatRoughness,
                               f0,
                               sunIlluminance,
                               shadowFactor,
                               n, l, v,
                               NdotL, NdotV);

    float ambientOcclusion = ao * cavity;
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

    fragHdrColor = color;
}
