#version 330 core

out vec4 fragColor;

in vec3 normalVS;
in vec2 texCoord;
in vec4 materialColor;
in vec3 ecPos;

uniform sampler2D color_tex;

uniform mat4 osg_ViewMatrixInverse;
uniform mat4 osg_ProjectionMatrix;
uniform vec4 fg_Viewport;
uniform vec3 fg_SunDirection;

const float DEFAULT_TRANSPARENT_ROUGHNESS = 0.1;

vec3 decodeSRGB(vec3 screenRGB);
float getShadowing(vec3 p, vec3 n, vec3 l, mat4 viewToClip);
vec3 getF0Reflectance(vec3 baseColor, float metallic);
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
    vec4 baseColorTexel = texture(color_tex, texCoord);
    vec3 baseColor = decodeSRGB(baseColorTexel.rgb) * materialColor.rgb;
    float alpha = materialColor.a * baseColorTexel.a;

    vec3 n = normalize(normalVS);
    vec3 v = normalize(-ecPos);
    vec3 l = fg_SunDirection;

    float NdotL = dot(n, l);
    float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);

    vec3 f0 = getF0Reflectance(baseColor.rgb, 0.0);

    vec3 sunIlluminance = getSunIntensity() * clamp(NdotL, 0.0, 1.0);
    float shadowFactor = getShadowing(ecPos, n, l, osg_ProjectionMatrix);

    vec3 color = evaluateLight(baseColor,
                               0.0,
                               DEFAULT_TRANSPARENT_ROUGHNESS,
                               0.0,
                               0.0,
                               f0,
                               sunIlluminance,
                               shadowFactor,
                               n, l, v,
                               NdotL, NdotV);

    vec3 worldNormal = (osg_ViewMatrixInverse * vec4(n, 0.0)).xyz;
    vec3 worldReflected = (osg_ViewMatrixInverse * vec4(reflect(-v, n), 0.0)).xyz;

    color += evaluateIBL(baseColor,
                         0.0,
                         DEFAULT_TRANSPARENT_ROUGHNESS,
                         f0,
                         1.0,
                         worldNormal,
                         NdotV,
                         worldReflected);

    vec2 coord = (gl_FragCoord.xy - fg_Viewport.xy) / fg_Viewport.zw;
    color = addAerialPerspective(color, coord, length(ecPos));

    fragColor = vec4(color, alpha);
}
