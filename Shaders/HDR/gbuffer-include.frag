#version 330 core

uniform mat4 fg_ProjectionMatrixInverse;
uniform vec2 fg_NearFar;

// Octahedron normal encoding
// https://knarkowicz.wordpress.com/2014/04/16/octahedron-normal-vector-encoding/
vec2 msign(vec2 v)
{
    return vec2((v.x >= 0.0) ? 1.0 : -1.0,
                (v.y >= 0.0) ? 1.0 : -1.0);
}

vec2 encodeNormal(vec3 n)
{
    n /= (abs(n.x) + abs(n.y) + abs(n.z));
    n.xy = (n.z >= 0) ? n.xy : (1.0 - abs(n.yx)) * msign(n.xy);
    n.xy = n.xy * 0.5 + 0.5;
    return n.xy;
}

vec3 decodeNormal(vec2 f)
{
    f = f * 2.0 - 1.0;
    vec3 n = vec3(f, 1.0 - abs(f.x) - abs(f.y));
    float t = max(-n.z, 0.0);
    n.x += (n.x > 0.0) ? -t : t;
    n.y += (n.y > 0.0) ? -t : t;
    return normalize(n);
}

// Given a 2D coordinate in the range [0,1] and a depth value from a depth
// buffer, also in the [0,1] range, return the view space position.
vec3 positionFromDepth(vec2 pos, float depth)
{
    // We are using a reversed depth buffer. 1.0 corresponds to the near plane
    // and 0.0 to the far plane. We convert this back to clip space by doing
    //     1.0 - depth          to undo the depth reversal
    //     2.0 * depth - 1.0    to transform it to clip space [-1,1]
    vec4 clipSpacePos = vec4(pos * 2.0 - 1.0, 1.0 - depth * 2.0, 1.0);
    vec4 viewSpacePos = fg_ProjectionMatrixInverse * clipSpacePos;
    viewSpacePos.xyz /= viewSpacePos.w;
    return viewSpacePos.xyz;
}

// http://www.geeks3d.com/20091216/geexlab-how-to-visualize-the-depth-buffer-in-glsl/
float linearizeDepth(float depth)
{
    float z = 1.0 - depth;  // Undo the depth reversal
    return 2.0 * fg_NearFar.x
        / (fg_NearFar.y + fg_NearFar.x - z * (fg_NearFar.y - fg_NearFar.x));
}

vec3 decodeSRGB(vec3 screenRGB)
{
    vec3 a = screenRGB / 12.92;
    vec3 b = pow((screenRGB + 0.055) / 1.055, vec3(2.4));
    vec3 c = step(vec3(0.04045), screenRGB);
    return mix(a, b, c);
}
