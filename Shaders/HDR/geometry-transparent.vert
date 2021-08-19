#version 330 core

#define MODE_OFF 0
#define MODE_DIFFUSE 1
#define MODE_AMBIENT_AND_DIFFUSE 2

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec4 multiTexCoord0;

out vec3 normalVS;
out vec2 texCoord;
out vec4 materialColor;
out vec3 ecPos;

uniform int color_mode;
uniform vec4 material_diffuse;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    normalVS = normalize(osg_NormalMatrix * normal);
    texCoord = multiTexCoord0.st;
    ecPos = (osg_ModelViewMatrix * pos).xyz;

    // Legacy material handling
    if (color_mode == MODE_DIFFUSE)
        materialColor = vertexColor;
    else if (color_mode == MODE_AMBIENT_AND_DIFFUSE)
        materialColor = vertexColor;
    else
        materialColor = material_diffuse;
    // Super hack: if diffuse material alpha is less than 1, assume a
    // transparency animation is at work
    if (material_diffuse.a < 1.0)
        materialColor.a = material_diffuse.a;
    else
        materialColor.a = vertexColor.a;
}
