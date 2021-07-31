#version 330 core

out float adaptedLum;

uniform sampler2D prev_lum_tex;
uniform sampler2D current_lum_tex;

uniform float osg_DeltaFrameTime;

// Higher values give faster eye adaptation times
const float TAU = 4.0;

void main()
{
    float prevLum = texelFetch(prev_lum_tex, ivec2(0), 0).r;
    float currentLum = exp(textureLod(current_lum_tex, vec2(0.5), 10.0).r);
    adaptedLum = prevLum + (currentLum - prevLum) *
        (1.0 - exp(-osg_DeltaFrameTime * TAU));
}
