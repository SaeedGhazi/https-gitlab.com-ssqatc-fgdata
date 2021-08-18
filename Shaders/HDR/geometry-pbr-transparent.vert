#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 1) in vec3 normal;
layout(location = 3) in vec4 multiTexCoord0;
layout(location = 6) in vec3 tangent;
layout(location = 7) in vec3 binormal;

out vec2 texCoord;
out mat3 TBN;
out vec3 ecPos;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat3 osg_NormalMatrix;

uniform bool flip_vertically;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texCoord = multiTexCoord0.st;
    if (flip_vertically)
        texCoord.y = 1.0 - texCoord.y;

    vec3 T = normalize(osg_NormalMatrix * tangent);
    vec3 B = normalize(osg_NormalMatrix * binormal);
    vec3 N = normalize(osg_NormalMatrix * normal);
    TBN = mat3(T, B, N);

    ecPos = (osg_ModelViewMatrix * pos).xyz;
}
