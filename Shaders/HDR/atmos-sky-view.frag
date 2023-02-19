#version 330 core

out vec4 fragColor;

in vec2 texCoord;

uniform sampler2D transmittance_lut;
uniform float fg_SunZenithCosTheta;
uniform float fg_CameraDistanceToEarthCenter;

const float PI = 3.14159265358979323846;
const int SKY_STEPS = 32;

// atmos-include.frag
vec4 compute_inscattering(in vec3 ray_origin,
                          in vec3 ray_dir,
                          in float t_max,
                          in vec3 sun_dir,
                          in int steps,
                          in sampler2D transmittance_lut,
                          out vec4 transmittance);

void main()
{
    // Always leave the Sun right in the middle of the sky texture.
    // The skydome model implemented in SimGear already takes care of rotating
    // the Sun for us.
    vec3 sun_dir = vec3(
        -sqrt(1.0 - fg_SunZenithCosTheta*fg_SunZenithCosTheta),
        0.0,
        fg_SunZenithCosTheta);

    float azimuth = 2.0 * PI * texCoord.x; // [0, 2pi]
    // Apply a non-linear transformation to the elevation to dedicate more
    // texels to the horizon, where having more detail matters.
    float l = texCoord.y * 2.0 - 1.0;
    float elev = l*l * sign(l) * PI * 0.5; // [-pi/2, pi/2]

    vec3 ray_dir = vec3(cos(elev) * cos(azimuth),
                        cos(elev) * sin(azimuth),
                        sin(elev));

    vec3 ray_origin = vec3(0.0, 0.0, fg_CameraDistanceToEarthCenter);

    vec4 transmittance;
    vec4 L = compute_inscattering(ray_origin,
                                  ray_dir,
                                  1e7,
                                  sun_dir,
                                  SKY_STEPS,
                                  transmittance_lut,
                                  transmittance);
    fragColor = L;
}
