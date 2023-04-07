#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multitexcoord0;
layout(location = 6) in vec3 tangent;
layout(location = 7) in vec3 binormal;

out vec2 texcoord;
out mat3 TBN;

uniform int normalmap_enabled;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texcoord = multitexcoord0.st;

    vec3 N = normalize(normal);
    vec3 T, B;
    if (normalmap_enabled > 0) {
        T = tangent;
        B = binormal;
    } else {
        T = cross(N, vec3(1.0, 0.0, 0.0));
        B = cross(N, T);
    }
    TBN = mat3(normalize(osg_NormalMatrix * T),
               normalize(osg_NormalMatrix * B),
               normalize(osg_NormalMatrix * N));
}
