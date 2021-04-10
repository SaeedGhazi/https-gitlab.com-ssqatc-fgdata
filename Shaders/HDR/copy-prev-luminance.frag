#version 330 core

out float prevLum;

uniform sampler2D lum_tex;

void main()
{
    prevLum = texelFetch(lum_tex, ivec2(0), 0).r;
}
