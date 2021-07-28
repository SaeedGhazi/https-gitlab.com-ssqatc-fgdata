#version 330 core

layout(location = 0) in vec4 pos;

out vec3 vRayDir;
out vec3 vRayDirView;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vRayDir = normalize(pos.xyz);
    vRayDirView = (osg_ModelViewMatrix * vec4(vRayDir, 0.0)).xyz;
}
