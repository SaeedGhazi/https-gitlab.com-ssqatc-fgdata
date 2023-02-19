#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D gbuffer0_tex;
uniform sampler2D gbuffer1_tex;
uniform sampler2D gbuffer2_tex;
uniform sampler2D depth_tex;
uniform sampler2D ao_tex;

uniform bool ambient_occlusion_enabled;
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
vec3 add_aerial_perspective(vec3 color, vec2 coord, float depth);
vec3 get_sun_radiance(vec3 p);

vec3 get_contribution_from_scene_lights(
    vec3 p,
    vec3 base_color,
    float metallic,
    float roughness,
    vec3 f0,
    vec3 n,
    vec3 v);

float GTAOMultiBounce(float x, vec3 albedo)
{
    // Use luminance instead of albedo because colored multibounce looks bad
    // Idea borrowed from Blender Eevee
    float lum = dot(albedo, vec3(0.333));
    float a =  2.0404 * lum - 0.3324;
    float b = -4.7951 * lum + 0.6417;
    float c =  2.7552 * lum + 0.6903;
    return max(x, ((x * a + b) * x + c) * x);
}

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

    vec3 f0 = getF0Reflectance(baseColor, metallic);

    vec3 pos_world = (fg_ViewMatrixInverse * vec4(pos, 1.0)).xyz;
    vec3 sun_radiance = get_sun_radiance(pos_world);

    float shadowFactor = getShadowing(pos, n, l, fg_ProjectionMatrix);

    vec3 color = evaluateLight(baseColor,
                               metallic,
                               roughness,
                               f0,
                               sun_radiance,
                               shadowFactor,
                               n, l, v,
                               NdotL, NdotV);

    color += get_contribution_from_scene_lights(pos,
                                                baseColor,
                                                metallic,
                                                roughness,
                                                f0, n, v);

    float ao = occlusion;
    if (ambient_occlusion_enabled) {
        ao *= GTAOMultiBounce(texture(ao_tex, texCoord).r, baseColor);
    }

    vec3 worldNormal = (fg_ViewMatrixInverse * vec4(n, 0.0)).xyz;
    vec3 worldReflected = (fg_ViewMatrixInverse * vec4(reflect(-v, n), 0.0)).xyz;

    color += evaluateIBL(baseColor,
                         metallic,
                         roughness,
                         f0,
                         ao,
                         worldNormal,
                         NdotV,
                         worldNormal);

    color = add_aerial_perspective(color, texCoord, length(pos));

    if (debug_shadow_cascades)
        color *= debugShadowColor(pos, n, l);

    fragColor = color;
}
