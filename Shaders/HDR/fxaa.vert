#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multiTexCoord0;

out vec2 texCoord;
out vec4 posPos;

uniform mat4 osg_ModelViewProjectionMatrix;

uniform sampler2D color_tex;

const float FXAA_SUBPIX_SHIFT = 1.0/4.0;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texCoord = multiTexCoord0.st;
    vec2 rcpFrame = 1.0 / textureSize(color_tex, 0);
    posPos.xy = multiTexCoord0.xy;
    posPos.zw = multiTexCoord0.xy - (rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT));
}
