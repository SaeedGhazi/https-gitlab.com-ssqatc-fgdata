#version 330 core

layout(location = 0) in vec4 pos;

out vec3 rayDirVertex;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat4 osg_ViewMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vec4 rayDirView = normalize(osg_ModelViewMatrix * pos);
    rayDirView.w = 0.0;
    rayDirVertex = vec4(inverse(osg_ViewMatrix) * rayDirView).xyz;
    rayDirVertex = normalize(rayDirVertex);
}
