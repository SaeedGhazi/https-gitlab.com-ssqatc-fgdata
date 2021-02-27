// -*-C++-*-
#version 330
#pragma vscode_glsllint_stage : vert

out vec2 texCoord;
out vec4 vertexColor;

void main(void)
{
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texCoord = gl_MultiTexCoord0.xy;
    vertexColor = gl_Color;
}
