#version 330 core

out vec4 fragColor;

in vec3 rayDir;

uniform sampler2D sky_view_lut;

const float PI = 3.141592653;

void main()
{
    float azimuth = atan(rayDir.y, rayDir.x) / PI * 0.5 + 0.5;
    // Undo the non-linear transformation from the sky-view LUT
    float l = asin(rayDir.z);
    float elev = sqrt(abs(l) / (PI * 0.5)) * sign(l) * 0.5 + 0.5;

    vec3 color = texture(sky_view_lut, vec2(azimuth, elev)).rgb;
    fragColor = vec4(color, 1.0);
}
