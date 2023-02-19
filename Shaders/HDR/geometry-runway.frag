#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 rawpos;
in vec2 texCoord;
in mat3 TBN;

uniform sampler2D color_tex;
uniform sampler2D normal_tex;
uniform sampler3D noise_tex;

const float NORMAL_MAP_SCALE = 8.0;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    vec4 texel = texture(color_tex, texCoord);
    vec3 color = decodeSRGB(texel.rgb);

    vec3 normal_texel = texture(normal_tex, texCoord * NORMAL_MAP_SCALE).rgb;
    vec3 normal = normalize(TBN * (normal_texel * 2.0 - 1.0));

    vec3 noise_large = texture(noise_tex, rawpos * 0.0045).rgb;
    vec3 noise_small = texture(noise_tex, rawpos).rgb;

    float mix_factor = noise_large.r * noise_large.g * noise_large.b * 350.0;
    mix_factor = smoothstep(0.0, 1.0, mix_factor);

    color = mix(color, noise_small, 0.15);

    float roughness = mix(0.94, 0.98, mix_factor);

    outGBuffer0.rg  = encodeNormal(normal);
    outGBuffer0.b   = roughness;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = vec3(color);
    outGBuffer1.a   = 0.0;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
