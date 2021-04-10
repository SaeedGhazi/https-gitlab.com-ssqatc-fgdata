#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform sampler2D hdr_tex;
uniform sampler2D lum_tex;

void main()
{
    vec3 hdrColor = texture(hdr_tex, texCoord).rgb;
    float avgLuminance = texture(lum_tex, texCoord).r;
    // XXX: Maybe we should actually control the EV compensation value itself
    // instead of hardcoding a factor?
    float exposure = 1.0 / (200.0 * avgLuminance);
    hdrColor *= exposure;

    if (dot(hdrColor, vec3(0.333)) <= 0.001)
		fragColor = vec3(0.0);
    else
        fragColor = hdrColor;
}
