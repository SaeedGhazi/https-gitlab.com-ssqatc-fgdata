#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multitexcoord0;
layout(location = 6) in vec3 tangent;
layout(location = 7) in vec3 binormal;

out vec3 vP;
out vec2 texcoord;
out mat3 TBN;
out vec4 ap_color;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

uniform bool flip_vertically;

// aerial_perspective.glsl
vec4 get_aerial_perspective(vec2 coord, float depth);

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vP = (osg_ModelViewMatrix * pos).xyz;
    texcoord = multitexcoord0.st;
    if (flip_vertically)
        texcoord.y = 1.0 - texcoord.y;

    vec3 T = normalize(osg_NormalMatrix * tangent);
    vec3 B = normalize(osg_NormalMatrix * binormal);
    vec3 N = normalize(osg_NormalMatrix * normal);
    TBN = mat3(T, B, N);

    vec2 coord = (gl_Position.xy / gl_Position.w) * 0.5 + 0.5;
    ap_color = get_aerial_perspective(coord, length(vP));
}
