#version 120

varying vec4 ecPositionIn;
varying vec3 ecNormalIn;

void main() {
    ecPositionIn = gl_ModelViewMatrix * gl_Vertex;
    ecNormalIn = gl_NormalMatrix * gl_Normal;
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    gl_Position = ftransform();
}
