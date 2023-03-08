// -*-C++-*-
#version 330 core

in vec2 pos;
in vec2 textureUV;
uniform mat3 paintInverted;

out vec2 texImageCoord;
out vec2 paintCoord;

void main()
{
//  gl_Position = vec4(pos, 0, 1);
    texImageCoord = textureUV;
    paintCoord = (paintInverted * vec3(pos, 1)).xy;
}
