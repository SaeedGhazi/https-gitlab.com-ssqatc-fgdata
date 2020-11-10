#version 120

uniform sampler3D fg_Clusters;
uniform sampler2D fg_ClusteredPointLights;
uniform sampler2D fg_ClusteredSpotLights;

uniform int fg_ClusteredTileSize;
uniform float fg_ClusteredSliceScale;
uniform float fg_ClusteredSliceBias;
uniform int fg_ClusteredHorizontalTiles;
uniform int fg_ClusteredVerticalTiles;

const int MAX_POINTLIGHTS = 1024;
const int MAX_SPOTLIGHTS = 1024;
const int MAX_LIGHT_GROUPS_PER_CLUSTER = 255;

struct PointLight {
    vec4 position;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    vec4 attenuation;
};

struct SpotLight {
    vec4 position;
    vec4 direction;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    vec4 attenuation;
    float cos_cutoff;
    float exponent;
};


PointLight unpackPointLight(int index)
{
    PointLight light;
    float v = (float(index) + 0.5) / float(MAX_POINTLIGHTS);
    light.position    = texture2D(fg_ClusteredPointLights, vec2(0.1, v));
    light.ambient     = texture2D(fg_ClusteredPointLights, vec2(0.3, v));
    light.diffuse     = texture2D(fg_ClusteredPointLights, vec2(0.5, v));
    light.specular    = texture2D(fg_ClusteredPointLights, vec2(0.7, v));
    light.attenuation = texture2D(fg_ClusteredPointLights, vec2(0.9, v));
    return light;
}

SpotLight unpackSpotLight(int index)
{
    SpotLight light;
    float v = (float(index) + 0.5) / float(MAX_SPOTLIGHTS);
    light.position    = texture2D(fg_ClusteredSpotLights, vec2(0.0714, v));
    light.direction   = texture2D(fg_ClusteredSpotLights, vec2(0.2143, v));
    light.ambient     = texture2D(fg_ClusteredSpotLights, vec2(0.3571, v));
    light.diffuse     = texture2D(fg_ClusteredSpotLights, vec2(0.5,    v));
    light.specular    = texture2D(fg_ClusteredSpotLights, vec2(0.6429, v));
    light.attenuation = texture2D(fg_ClusteredSpotLights, vec2(0.7857, v));
    vec2 reminder     = texture2D(fg_ClusteredSpotLights, vec2(0.9286, v)).xy;
    light.cos_cutoff  = reminder.x;
    light.exponent    = reminder.y;
    return light;
}

// @param p Fragment position in view space.
// @param n Fragment normal in view space.
vec3 getClusteredLightsContribution(vec3 p, vec3 n, vec3 texel)
{
    int zSlice = int(max(log2(-p.z) * fg_ClusteredSliceScale
                         + fg_ClusteredSliceBias, 0.0));
    int ySlice = int(gl_FragCoord.y) / fg_ClusteredTileSize * zSlice;
    int xSlice = int(gl_FragCoord.x) / fg_ClusteredTileSize;

    vec2 clusterCoords = vec2(
        (float(xSlice) + 0.5) / fg_ClusteredHorizontalTiles,
        (float(ySlice) * float(zSlice) + 0.5) / fg_ClusteredVerticalTiles);

    int pointCount = int(texture3D(fg_Clusters, vec3(clusterCoords, 0.0)).r);
    int spotCount = int(texture3D(fg_Clusters, vec3(clusterCoords, 0.0)).g);

    int lightGroupCount = int(ceil(float(pointCount + spotCount) / 4.0));

    vec3 color = vec3(0.0);

    for (int i = 0; i < lightGroupCount; ++i) {
        float r = (float(i + 1) + 0.5) / float(MAX_LIGHT_GROUPS_PER_CLUSTER + 1);
        vec4 packedIndices = texture3D(fg_Clusters, vec3(clusterCoords, r));

        for (int j = 0; j < 4; ++j) {
            int index;
            if (j == 0)      index = int(packedIndices.x);
            else if (j == 1) index = int(packedIndices.y);
            else if (j == 2) index = int(packedIndices.z);
            else if (j == 3) index = int(packedIndices.w);
            else break;

            int currentLight = i * 4 + j;
            if (currentLight < pointCount) {
                // This is a point light
                PointLight light = unpackPointLight(index);

                float range = light.attenuation.w;
                vec3 toLight = light.position.xyz - p;
                // Ignore fragments outside the light volume
                if (dot(toLight, toLight) > (range * range))
                    continue;

                float d = length(toLight);
                float att = 1.0 / (light.attenuation.x             // constant
                                   + light.attenuation.y * d       // linear
                                   + light.attenuation.z * d * d); // quadratic
                vec3 lightDir = normalize(toLight);
                float NdotL = max(dot(n, lightDir), 0.0);

                vec3 Iamb  = light.ambient.rgb;
                vec3 Idiff = gl_FrontMaterial.diffuse.rgb * light.diffuse.rgb * NdotL;
                vec3 Ispec = vec3(0.0);

                if (NdotL > 0.0) {
                    vec3 halfVector = normalize(lightDir + normalize(-p));
                    float NdotHV = max(dot(n, halfVector), 0.0);
                    Ispec = gl_FrontMaterial.specular.rgb
                        * light.specular.rgb
                        * pow(NdotHV, gl_FrontMaterial.shininess);
                }

                color += ((Iamb + Idiff) * texel + Ispec) * att;
            } else if (currentLight < (pointCount + spotCount)) {
                // This is a spot light
                SpotLight light = unpackSpotLight(index);

                vec3 toLight = light.position.xyz - p;

                float d = length(toLight);
                float att = 1.0 / (light.attenuation.x             // constant
                                   + light.attenuation.y * d       // linear
                                   + light.attenuation.z * d * d); // quadratic

                vec3 lightDir = normalize(toLight);

                float spotDot = dot(-lightDir, light.direction.xyz);
                if (spotDot < light.cos_cutoff)
                    continue;

                att *= pow(spotDot, light.exponent);

                float NdotL = max(dot(n, lightDir), 0.0);

                vec3 Iamb  = light.ambient.rgb;
                vec3 Idiff = gl_FrontMaterial.diffuse.rgb * light.diffuse.rgb * NdotL;
                vec3 Ispec = vec3(0.0);

                if (NdotL > 0.0) {
                    vec3 halfVector = normalize(lightDir + normalize(-p));
                    float NdotHV = max(dot(n, halfVector), 0.0);
                    Ispec = gl_FrontMaterial.specular.rgb
                        * light.specular.rgb
                        * pow(NdotHV, gl_FrontMaterial.shininess);
                }

                color += ((Iamb + Idiff) * texel + Ispec) * att;
            } else {
                break;
            }
        }
    }

    return clamp(color, 0.0, 1.0);

    // for (int i = 0; i < pointCount; ++i) {
    //     vec3 lightCoords = clusterCoords;

    //     int pointCount = int(texture2D(fg_Clusters, clusterCoords).r);
    //     PointLight light = pointLights[lightListIndex];

    //     float range = light.attenuation.w;
    //     vec3 toLight = light.position.xyz - p;
    //     // Ignore fragments outside the light volume
    //     if (dot(toLight, toLight) > (range * range))
    //         continue;

    //     ////////////////////////////////////////////////////////////////////////
    //     // Actual lighting

    //     float d = length(toLight);
    //     float att = 1.0 / (light.attenuation.x             // constant
    //                        + light.attenuation.y * d       // linear
    //                        + light.attenuation.z * d * d); // quadratic
    //     vec3 lightDir = normalize(toLight);
    //     float NdotL = max(dot(n, lightDir), 0.0);

    //     vec3 Iamb  = light.ambient.rgb;
    //     vec3 Idiff = light.diffuse.rgb * NdotL;
    //     vec3 Ispec = vec3(0.0);

    //     if (NdotL > 0.0) {
    //         vec3 halfVector = normalize(lightDir + normalize(-p));
    //         float NdotHV = max(dot(n, halfVector), 0.0);
    //         Ispec = light.specular.rgb * att * pow(NdotHV, shininess);
    //     }

    //     color += addColors(color, (Iamb + Idiff + Ispec) * att);
    // }

    // for (uint i = uint(0); i < spotCount; ++i) {
    //     uint lightListIndex = texelFetch(fg_ClusteredLightIndices,
    //                                      int(startIndex + i)).r;
    //     SpotLight light = spotLights[lightListIndex];

    //     vec3 toLight = light.position.xyz - p;

    //     ////////////////////////////////////////////////////////////////////////
    //     // Actual lighting

    //     float d = length(toLight);
    //     float att = 1.0 / (light.attenuation.x             // constant
    //                        + light.attenuation.y * d       // linear
    //                        + light.attenuation.z * d * d); // quadratic

    //     vec3 lightDir = normalize(toLight);

    //     float spotDot = dot(-lightDir, light.direction.xyz);
    //     if (spotDot < light.cos_cutoff)
    //         continue;

    //     att *= pow(spotDot, light.exponent);

    //     float NdotL = max(dot(n, lightDir), 0.0);

    //     vec3 Iamb  = light.ambient.rgb;
    //     vec3 Idiff = light.diffuse.rgb * NdotL;
    //     vec3 Ispec = vec3(0.0);

    //     if (NdotL > 0.0) {
    //         vec3 halfVector = normalize(lightDir + normalize(-p));
    //         float NdotHV = max(dot(n, halfVector), 0.0);
    //         Ispec = light.specular.rgb * att * pow(NdotHV, shininess);
    //     }

    //     color += (Iamb + Idiff + Ispec) * att;
    // }

}
