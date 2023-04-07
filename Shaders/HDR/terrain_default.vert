#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multitexcoord0;
layout(location = 5) in vec4 multitexcoord2;

out vec3 vN;
out vec2 texcoord;
out vec2 orthophoto_texcoord;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vN = normalize(osg_NormalMatrix * normal);
    texcoord = multitexcoord0.st;
    orthophoto_texcoord = multitexcoord2.st;
}
