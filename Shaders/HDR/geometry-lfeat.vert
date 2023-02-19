#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec4 multiTexCoord0;

out vec3 normalVS;
out vec2 texCoord;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

void main()
{
    vec4 raised_pos = pos;
    raised_pos.z += 0.05;
    gl_Position = osg_ModelViewProjectionMatrix * raised_pos;
    normalVS = normalize(osg_NormalMatrix * normal);
    texCoord = multiTexCoord0.st;
}
