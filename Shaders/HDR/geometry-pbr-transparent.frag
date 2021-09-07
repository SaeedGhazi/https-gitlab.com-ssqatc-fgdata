#version 330 core

out vec4 fragColor;

in vec2 texCoord;
in mat3 TBN;
in vec3 ecPos;

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
uniform vec3 fg_SunDirection;

vec3 decodeSRGB(vec3 screenRGB);
float getShadowing(vec3 p, vec3 n, vec3 l, mat4 viewToClip);
vec3 getF0Reflectance(vec3 baseColor, float metallic);
vec3 evaluateLight(
    vec3 baseColor,
    float metallic,
    float roughness,
    vec3 f0,
    vec3 intensity,
    float visibility,
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
    float visibility,
    vec3 nWorldSpace,
    float NdotV,
    vec3 reflected);
vec3 addAerialPerspective(vec3 color, vec2 coord, float depth);
vec3 getSunIntensity();

void main()
{
    vec4 baseColorTexel = texture(base_color_tex, texCoord);
    vec4 baseColor = vec4(decodeSRGB(baseColorTexel.rgb), baseColorTexel.a)
        * base_color_factor;
    if (baseColor.a < alpha_cutoff)
        discard;

    vec3 n = texture(normal_tex, texCoord).rgb * 2.0 - 1.0;
    n = normalize(TBN * n);

    vec3 orm = texture(orm_tex, texCoord).rgb;
    float occlusion = orm.r;
    float roughness = orm.g * roughness_factor;
    float metallic = orm.b * metallic_factor;

    vec3 emissive = texture(emissive_tex, texCoord).rgb * emissive_factor;

    vec3 v = normalize(-ecPos);
    vec3 l = fg_SunDirection;

    float NdotL = dot(n, l);
    float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);

    vec3 f0 = getF0Reflectance(baseColor.rgb, metallic);

    vec3 sunIlluminance = getSunIntensity() * clamp(NdotL, 0.0, 1.0);
    float shadowFactor = getShadowing(ecPos, n, l, osg_ProjectionMatrix);

    vec3 color = evaluateLight(baseColor.rgb,
                               metallic,
                               roughness,
                               f0,
                               sunIlluminance,
                               shadowFactor,
                               n, l, v,
                               NdotL, NdotV);

    vec3 worldNormal = (osg_ViewMatrixInverse * vec4(n, 0.0)).xyz;
    vec3 worldReflected = (osg_ViewMatrixInverse * vec4(reflect(-v, n), 0.0)).xyz;

    color += evaluateIBL(baseColor.rgb,
                         metallic,
                         roughness,
                         f0,
                         occlusion,
                         worldNormal,
                         NdotV,
                         worldReflected);

    vec2 coord = (gl_FragCoord.xy - fg_Viewport.xy) / fg_Viewport.zw;
    color = addAerialPerspective(color, coord, length(ecPos));

    fragColor = vec4(color, baseColor.a);
}
