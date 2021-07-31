#version 330 core

uniform mat4 fg_ProjectionMatrixInverse;
uniform vec2 fg_NearFar;

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
    float g = sqrt(1.0 - f * 0.25);
    vec3 n;
    n.xy = fenc * g;
    n.z = 1.0 - f * 0.5;
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

// http://www.geeks3d.com/20091216/geexlab-how-to-visualize-the-depth-buffer-in-glsl/
float linearizeDepth(float depth)
{
    return (2.0 * fg_NearFar.x) / (
        fg_NearFar.y + fg_NearFar.x - depth * (fg_NearFar.y - fg_NearFar.x));
}

vec3 decodeSRGB(vec3 screenRGB)
{
    vec3 a = screenRGB / 12.92;
    vec3 b = pow((screenRGB + 0.055) / 1.055, vec3(2.4));
    vec3 c = step(vec3(0.04045), screenRGB);
    return mix(a, b, c);
}
