#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multiTexCoord0;

out vec2 texCoord;

uniform mat4 osg_ModelViewProjectionMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texCoord = multiTexCoord0.st;
}
