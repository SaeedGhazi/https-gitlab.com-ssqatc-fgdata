#version 120

uniform bool shadows_enabled;
uniform int sun_atlas_size;

uniform mat4 fg_LightMatrix_csm0;
uniform mat4 fg_LightMatrix_csm1;
uniform mat4 fg_LightMatrix_csm2;
uniform mat4 fg_LightMatrix_csm3;

varying vec4 lightSpacePos[4];

const float NORMAL_OFFSET_SCALE = 200.0;


void setupShadows(vec4 eyeSpacePos)
{
    if (!shadows_enabled)
        return;

    vec3 normal = gl_NormalMatrix * gl_Normal;

    vec3 toLight = normalize(gl_LightSource[0].position.xyz);
    float costheta = dot(normal, toLight);
    float slopeScale = clamp(1.0 - costheta, 0.0, 1.0);
    float texelSize = 1.0 / sun_atlas_size;
    float normalOffset = NORMAL_OFFSET_SCALE * slopeScale * texelSize;

    vec4 offsetPos = eyeSpacePos + vec4(normal * normalOffset, 0.0);

    vec4 offsets[4];
    offsets[0] = fg_LightMatrix_csm0 * offsetPos;
    offsets[1] = fg_LightMatrix_csm1 * offsetPos;
    offsets[2] = fg_LightMatrix_csm2 * offsetPos;
    offsets[3] = fg_LightMatrix_csm3 * offsetPos;

    lightSpacePos[0] = fg_LightMatrix_csm0 * eyeSpacePos;
    lightSpacePos[1] = fg_LightMatrix_csm1 * eyeSpacePos;
    lightSpacePos[2] = fg_LightMatrix_csm2 * eyeSpacePos;
    lightSpacePos[3] = fg_LightMatrix_csm3 * eyeSpacePos;

    // Offset only in UV space
    lightSpacePos[0].xy = offsets[0].xy;
    lightSpacePos[1].xy = offsets[1].xy;
    lightSpacePos[2].xy = offsets[2].xy;
    lightSpacePos[3].xy = offsets[3].xy;
}
