#version 330 core

uniform sampler3D fg_Clusters;
uniform sampler2D fg_ClusteredIndices;
uniform sampler2D fg_ClusteredPointLights;
uniform sampler2D fg_ClusteredSpotLights;

uniform int fg_ClusteredMaxPointLights;
uniform int fg_ClusteredMaxSpotLights;
uniform int fg_ClusteredMaxLightIndices;
uniform int fg_ClusteredTileSize;
uniform int fg_ClusteredDepthSlices;
uniform float fg_ClusteredSliceScale;
uniform float fg_ClusteredSliceBias;
uniform int fg_ClusteredHorizontalTiles;
uniform int fg_ClusteredVerticalTiles;

// lighting-include.frag
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

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
    float range;
};

struct SpotLight {
    vec3 position;
    vec3 direction;
    vec3 color;
    float intensity;
    float range;
    float cos_cutoff;
    float exponent;
};

PointLight unpackPointLight(int index)
{
    float v = (float(index) + 0.5) / float(fg_ClusteredMaxPointLights);
    PointLight light;
    vec4 block;
    block = texture(fg_ClusteredPointLights, vec2(0.25, v));
    light.position    = block.xyz;
    light.range       = block.w;
    block = texture(fg_ClusteredPointLights, vec2(0.75, v));
    light.color       = block.xyz;
    light.intensity   = block.w;
    return light;
}

SpotLight unpackSpotLight(int index)
{
    float v = (float(index) + 0.5) / float(fg_ClusteredMaxSpotLights);
    SpotLight light;
    vec4 block;
    block = texture(fg_ClusteredSpotLights, vec2(0.125, v));
    light.position    = block.xyz;
    light.range       = block.w;
    block = texture(fg_ClusteredSpotLights, vec2(0.375, v));
    light.direction   = block.xyz;
    light.cos_cutoff  = block.w;
    block = texture(fg_ClusteredSpotLights, vec2(0.625, v));
    light.color       = block.xyz;
    light.intensity   = block.w;
    block = texture(fg_ClusteredSpotLights, vec2(0.875, v));
    light.exponent    = block.x;
    return light;
}

int getIndex(int counter)
{
    vec2 coords = vec2(mod(float(counter), float(fg_ClusteredMaxLightIndices)) + 0.5,
                       float(counter / fg_ClusteredMaxLightIndices) + 0.5);
    // Normalize
    coords /= vec2(fg_ClusteredMaxLightIndices);
    return int(texture(fg_ClusteredIndices, coords).r);
}

float get_square_falloff_attenuation(vec3 to_light, float inv_range)
{
    float dd = dot(to_light, to_light);
    float factor = dd * inv_range * inv_range;
    float smooth_factor = max(1.0 - factor * factor, 0.0);
    return (smooth_factor * smooth_factor) / max(dd, 0.0001);
}

float get_spot_angle_attenuation(vec3 l, vec3 light_dir,
                                 float cos_cutoff, float exponent)
{
    float cd = dot(-l, light_dir);
    if (cd < cos_cutoff)
        return 0.0;
    return pow(cd, exponent);
}

vec3 get_contribution_from_scene_lights(
    vec3 p,
    vec3 base_color,
    float metallic,
    float roughness,
    vec3 f0,
    vec3 n,
    vec3 v)
{
    int slice = int(max(log2(-p.z) * fg_ClusteredSliceScale
                        + fg_ClusteredSliceBias, 0.0));
    vec3 clusterCoords = vec3(floor(gl_FragCoord.xy / fg_ClusteredTileSize),
                              slice) + vec3(0.5); // Pixel center
    // Normalize
    clusterCoords /= vec3(fg_ClusteredHorizontalTiles,
                          fg_ClusteredVerticalTiles,
                          fg_ClusteredDepthSlices);

    vec3 cluster = texture(fg_Clusters, clusterCoords).rgb;
    int lightIndex = int(cluster.r);
    int pointCount = int(cluster.g);
    int spotCount  = int(cluster.b);

    vec3 color = vec3(0.0);

    for (int i = 0; i < pointCount; ++i) {
        int index = getIndex(lightIndex++);
        PointLight light = unpackPointLight(index);

        vec3 to_light = light.position - p;
        vec3 l = normalize(to_light);

        float attenuation = get_square_falloff_attenuation(
            to_light, 1.0 / light.range);
        if (attenuation <= 0.0)
            continue;

        vec3 intensity = light.color * light.intensity * attenuation;

        float NdotL = max(dot(n, l), 0.0);
        float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);

        color += evaluateLight(base_color,
                               metallic,
                               roughness,
                               f0,
                               intensity,
                               1.0,
                               n, l, v,
                               NdotL, NdotV);
    }

    for (int i = 0; i < spotCount; ++i) {
        int index = getIndex(lightIndex++);
        SpotLight light = unpackSpotLight(index);

        vec3 to_light = light.position - p;
        vec3 l = normalize(to_light);

        float attenuation = get_square_falloff_attenuation(
            to_light, 1.0 / light.range);
        attenuation *= get_spot_angle_attenuation(
            l, light.direction, light.cos_cutoff, light.exponent);
        if (attenuation <= 0.0)
            continue;

        vec3 intensity = light.color * light.intensity * attenuation;

        float NdotL = max(dot(n, l), 0.0);
        float NdotV = clamp(abs(dot(n, v)), 0.001, 1.0);

        color += evaluateLight(base_color,
                               metallic,
                               roughness,
                               f0,
                               intensity,
                               1.0,
                               n, l, v,
                               NdotL, NdotV);
    }

    return color;
}
