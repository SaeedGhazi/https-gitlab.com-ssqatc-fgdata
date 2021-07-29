#version 330 core

layout(location = 0) in vec4 pos;

out vec3 vRayDir;
out vec3 vRayDirView;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    // Get the camera height (0 being the ground)
    vec4 groundPoint = osg_ModelViewMatrix * vec4(0.0, 0.0, 0.0, 1.0);
    float altitude = length(groundPoint);
    // Compensate for the skydome being fixed on the ground
    vRayDir = normalize(pos.xyz - vec3(0.0, 0.0, altitude));
    vRayDirView = (osg_ModelViewMatrix * vec4(vRayDir, 0.0)).xyz;
}
