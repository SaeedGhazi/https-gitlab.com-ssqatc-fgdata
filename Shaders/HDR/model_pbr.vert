#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multitexcoord0;
layout(location = 6) in vec3 tangent;
layout(location = 7) in vec3 binormal;

out vec2 texcoord;
out mat3 TBN;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

uniform bool flip_vertically;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texcoord = multitexcoord0.st;
    if (flip_vertically)
        texcoord.y = 1.0 - texcoord.y;

    vec3 T = normalize(osg_NormalMatrix * tangent);
    vec3 B = normalize(osg_NormalMatrix * binormal);
    vec3 N = normalize(osg_NormalMatrix * normal);
    TBN = mat3(T, B, N);
}
