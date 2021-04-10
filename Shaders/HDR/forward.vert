#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multiTexCoord0;

out vec3 normalVS;
out vec2 texCoord;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    normalVS = normalize(osg_NormalMatrix * normal);
    texCoord = multiTexCoord0.st;
}
