#version 120
#extension GL_EXT_geometry_shader4 : enable

varying in vec4 ecPositionIn[];
varying in vec3 ecNormalIn[];

varying out vec4 ecPosition;
varying out vec3 ecNormal;

void main() {
    gl_Position = gl_PositionIn[0];
    gl_TexCoord[0] = gl_TexCoordIn[0][0];
    ecPosition = ecPositionIn[0];
    ecNormal = ecNormalIn[0];
    EmitVertex();

    gl_Position = gl_PositionIn[1];
    gl_TexCoord[0] = gl_TexCoordIn[1][0];
    ecPosition = ecPositionIn[1];
    ecNormal = ecNormalIn[1];
    EmitVertex();

    gl_Position = gl_PositionIn[2];
    gl_TexCoord[0] = gl_TexCoordIn[2][0];
    ecPosition = ecPositionIn[2];
    ecNormal = ecNormalIn[2];
    EmitVertex();

    EndPrimitive();
}
