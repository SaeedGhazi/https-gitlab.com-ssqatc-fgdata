#version 330 core

out vec4 fragColor;

in vec3 vRayDir;
in vec3 vRayDirView;

uniform sampler2D sky_view_lut;
uniform sampler2D transmittance_lut;
uniform vec3 fg_SunDirection;

const float PI = 3.141592653;
const vec3 SUN_INTENSITY = vec3(20.0);

const float sun_solid_angle = 0.53*PI/180.0; // ~half a degree
const float sun_cos_solid_angle = cos(sun_solid_angle);

void main()
{
    vec3 rayDir = normalize(vRayDir);
    float azimuth = atan(rayDir.y, rayDir.x) / PI * 0.5 + 0.5;
    // Undo the non-linear transformation from the sky-view LUT
    float l = asin(rayDir.z);
    float elev = sqrt(abs(l) / (PI * 0.5)) * sign(l) * 0.5 + 0.5;

    vec3 color = texture(sky_view_lut, vec2(azimuth, elev)).rgb;
    color *= SUN_INTENSITY;

    // Render the Sun disk
    // XXX: Apply transmittance
    float cosTheta = dot(normalize(vRayDirView), fg_SunDirection);
    if (cosTheta >= sun_cos_solid_angle)
        color += SUN_INTENSITY;

    fragColor = vec4(color, 1.0);
}
