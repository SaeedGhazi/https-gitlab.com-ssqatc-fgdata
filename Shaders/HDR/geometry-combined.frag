#version 330 core

layout(location = 0) out vec4 gbuffer0;
layout(location = 1) out vec2 gbuffer1;
layout(location = 2) out vec4 gbuffer2;

in vec2 texCoord;
in mat3 TBN;

uniform sampler2D color_tex;
uniform sampler2D normal_tex;
uniform int normalmap_enabled;
uniform int normalmap_dds;
uniform float normalmap_tiling;

const float DEFAULT_COMBINED_METALNESS = 0.0;
const float DEFAULT_COMBINED_ROUGHNESS = 0.1;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    gbuffer0.rgb = decodeSRGB(texture(color_tex, texCoord).rgb);
    gbuffer0.a = 1.0;

    vec3 normal = vec3(0.0, 0.0, 1.0);
    if (normalmap_enabled > 0) {
        normal = texture(normal_tex, texCoord * normalmap_tiling).rgb * 2.0 - 1.0;
        // DDS has flipped normals
        if (normalmap_dds > 0)
            normal = -normal;
    }
    normal = normalize(TBN * normal);
    gbuffer1 = encodeNormal(normal);

    gbuffer2 = vec4(DEFAULT_COMBINED_METALNESS,
                    DEFAULT_COMBINED_ROUGHNESS,
                    0.0,
                    0.0);
}
