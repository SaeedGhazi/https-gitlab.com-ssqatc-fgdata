#version 330 core

out vec3 fragColor;

in vec2 texCoord;

uniform mat4 fg_ViewMatrixInverse;
uniform mat4 fg_ProjectionMatrixInverse;
uniform vec3 fg_CameraPositionCart;
uniform vec3 fg_CameraPositionGeod;
uniform vec3 fg_SunDirection;
uniform vec2 fg_BufferSize;

uniform sampler2D hdr_tex;
uniform sampler2D depth_tex;

vec3 calculateScattering(vec3 rayOrigin,
                         vec3 rayDir,
                         vec3 sceneColor,
                         float depth,
                         float maxDist,
                         float earthRadius,
                         vec3 lightDir);
vec3 positionFromDepth(vec2 pos, float depth);

void main()
{
    float depth = texture(depth_tex, texCoord).r;
    vec3 fragPos = positionFromDepth(texCoord * 2.0 - 1.0,
                                     depth    * 2.0 - 1.0);
    vec3 rayDir = vec4(fg_ViewMatrixInverse * vec4(normalize(fragPos), 0.0)).xyz;

    // Since FG internally uses WG84 coordinates, we use the current Earth
    // radius under the camera, which varies with the latitude. For practical
    // purposes we model the Earth as a perfect sphere with this radius.
    float earthRadius = length(fg_CameraPositionCart) - fg_CameraPositionGeod.z;

    vec3 sceneColor = texture(hdr_tex, texCoord).rgb;

    vec3 color = calculateScattering(fg_CameraPositionCart,
                                     rayDir,
                                     sceneColor,
                                     depth,
                                     length(fragPos),
                                     earthRadius,
                                     fg_SunDirection);
    fragColor = color;
}
