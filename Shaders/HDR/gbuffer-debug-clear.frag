#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

void main()
{
    outGBuffer0 = vec4(0.0);
    outGBuffer1 = vec4(0.0);
    outGBuffer2 = vec4(0.0);
}
