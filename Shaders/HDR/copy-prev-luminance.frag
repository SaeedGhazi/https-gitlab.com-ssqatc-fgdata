#version 330 core

out float prevLum;

uniform sampler2D tex;

void main()
{
    prevLum = texelFetch(tex, ivec2(0), 0).r;
}
