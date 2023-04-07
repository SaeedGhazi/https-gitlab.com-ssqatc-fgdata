#version 330 core

#define MODE_OFF 0
#define MODE_DIFFUSE 1
#define MODE_AMBIENT_AND_DIFFUSE 2

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec4 vertex_color;
layout(location = 3) in vec4 multitexcoord0;

out vec3 vN;
out vec2 texcoord;
out vec4 material_color;

uniform int color_mode;
uniform vec4 material_diffuse;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vN = normalize(osg_NormalMatrix * normal);
    texcoord = multitexcoord0.st;

    // Legacy material handling
    if (color_mode == MODE_DIFFUSE)
        material_color = vertex_color;
    else if (color_mode == MODE_AMBIENT_AND_DIFFUSE)
        material_color = vertex_color;
    else
        material_color = material_diffuse;
}
