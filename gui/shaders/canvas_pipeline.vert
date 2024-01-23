#version 330 core

out vec2 texImageCoord;
out vec2 paintCoord;

in vec2 pos;
in vec2 textureUV;

uniform mat4 sh_Model;
uniform mat4 sh_Ortho;
uniform mat3 paintInverted;

void main()
{
    gl_Position = sh_Ortho * sh_Model * vec4(pos, 0.0, 1.0);
    texImageCoord = textureUV;
    paintCoord = (paintInverted * vec3(pos, 1.0)).xy;
}
