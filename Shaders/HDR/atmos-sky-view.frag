#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform vec3 fg_CameraPositionCart;
uniform vec3 fg_CameraPositionGeod;
uniform vec3 fg_SunDirectionWorld;

const float PI = 3.141592653;

void calculateScattering(in vec3 rayOrigin,
                         in vec3 rayDir,
                         in float tmax,
                         in vec3 lightDir,
                         in float earthRadius,
                         out vec3 inscatter,
                         out vec3 transmittance);

void main()
{
    // Always leave the sun right in the middle of the texture as the skydome
    // model is already being rotated.
    float sunCosTheta = dot(fg_SunDirectionWorld, normalize(fg_CameraPositionCart));
    vec3 lightDir = vec3(-sqrt(1.0 - sunCosTheta*sunCosTheta), 0.0, sunCosTheta);

    float azimuth = 2.0 * PI * texCoord.x; // [0, 2pi]
    // Apply a non-linear transformation to the elevation to dedicate more
    // texels to the horizon, which is where having more detail matters.
    float l = texCoord.y * 2.0 - 1.0;
    float elev = l*l * sign(l) * PI * 0.5; // [-pi/2, pi/2]
    vec3 rayDir = vec3(cos(elev) * cos(azimuth), cos(elev) * sin(azimuth), sin(elev));

    float cameraPosLength = length(fg_CameraPositionCart);
    // Since FG internally uses WG84 coordinates, we use the current Earth
    // radius under the camera, which varies with the latitude. For practical
    // purposes we model the Earth as a perfect sphere with this radius.
    float earthRadius = cameraPosLength - fg_CameraPositionGeod.z;

    vec3 rayOrigin = vec3(0.0, 0.0, cameraPosLength);

    vec3 inscatter, transmittance;
    calculateScattering(rayOrigin,
                        rayDir,
                        9.0e8,
                        lightDir,
                        earthRadius,
                        inscatter, transmittance);
    fragColor = inscatter;
}
