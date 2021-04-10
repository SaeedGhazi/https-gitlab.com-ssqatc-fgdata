#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multiTexCoord0;

out vec2 texCoord;
out mat3 TBN;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

attribute vec3 tangent;
attribute vec3 binormal;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texCoord = multiTexCoord0.st;

    vec3 T = normalize(osg_NormalMatrix * tangent);
    vec3 B = normalize(osg_NormalMatrix * binormal);
    vec3 N = normalize(osg_NormalMatrix * normal);
    TBN = mat3(T, B, N);
}
