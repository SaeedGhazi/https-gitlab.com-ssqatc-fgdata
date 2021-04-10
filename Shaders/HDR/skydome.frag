#version 330 core

out vec4 fragColor;

in vec3 rayDirVertex;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ViewMatrix;
uniform vec3 fg_SunDirection;

vec3 calculateScattering(vec3 rayOrigin,
                         vec3 rayDir,
                         vec3 sceneColor,
                         float depth,
                         float maxDist,
                         float earthRadius,
                         vec3 lightDir);

void main()
{
    // Ground point (skydome center) in eye coordinates
    vec4 groundPoint = inverse(osg_ViewMatrix) * osg_ModelViewMatrix
        * vec4(0.0, 0.0, 0.0, 1.0);

    // HACK: WGS84 models the Earth as an oblate spheroid, so we can't use
    // a constant Earth radius. This should be precomputed!
    float earthRadius = length(groundPoint);

    vec3 cameraPos = vec4(inverse(osg_ViewMatrix) * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 rayDir = normalize(rayDirVertex);

    vec3 color = calculateScattering(cameraPos,
                                     rayDir,
                                     vec3(0.0),
                                     1.0,
                                     3.0 * earthRadius,
                                     earthRadius,
                                     fg_SunDirection);
    fragColor = vec4(color, 1.0);
}
