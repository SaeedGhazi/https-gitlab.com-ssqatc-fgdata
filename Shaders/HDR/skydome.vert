#version 330 core

layout(location = 0) in vec4 pos;

out vec3 rayDir;

uniform mat4 osg_ModelViewProjectionMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    rayDir = normalize(pos.xyz);
}
