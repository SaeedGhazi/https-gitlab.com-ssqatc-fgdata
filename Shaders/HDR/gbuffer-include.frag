#version 330 core

uniform mat4 fg_ProjectionMatrixInverse;

// https://aras-p.info/texts/CompactNormalStorage.html
// Method #4: Spheremap Transform
// Lambert Azimuthal Equal-Area projection
vec2 encodeNormal(vec3 n)
{
    float p = sqrt(n.z * 8.0 + 8.0);
    return vec2(n.xy / p + 0.5);
}

vec3 decodeNormal(vec2 enc)
{
    vec2 fenc = enc * 4.0 - 2.0;
    float f = dot(fenc, fenc);
    float g = sqrt(1.0 - f / 4.0);
    vec3 n;
    n.xy = fenc * g;
    n.z = 1.0 - f / 2.0;
    return n;
}

// Given a position in clip space (values in the range [-1,1]), return
// the view space position.
vec3 positionFromDepth(vec2 pos, float depth)
{
    vec4 p = fg_ProjectionMatrixInverse * vec4(pos, depth, 1.0);
    p.xyz /= p.w;
    return p.xyz;
}
