#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec4 multiTexCoord0;

out vec2 texCoord;
out vec4 cloudColor;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat4 osg_ViewMatrixInverse;
uniform vec3 fg_SunDirectionWorld;

const float shade = 0.8;
const float cloud_height = 1000.0;

// aerial-perspective-include.frag
vec3 add_aerial_perspective(vec3 color, vec2 coord, float depth);
vec3 get_sun_radiance(vec3 p);

void main()
{
    texCoord = multiTexCoord0.st;

    // XXX: Should be sent as an uniform
    mat4 inverseModelViewMatrix = inverse(osg_ModelViewMatrix);

    vec4 ep = inverseModelViewMatrix * vec4(0.0, 0.0, 0.0, 1.0);
    vec4 l  = inverseModelViewMatrix * vec4(0.0, 0.0, 1.0, 1.0);
    vec3 u = normalize(ep.xyz - l.xyz);

    vec4 final_pos = vec4(0.0, 0.0, 0.0, 1.0);
    final_pos.x = pos.x;
    final_pos.y = pos.y;
    final_pos.z = pos.z;
    final_pos.xyz += vertexColor.xyz;

    gl_Position = osg_ModelViewProjectionMatrix * final_pos;

    // Determine a lighting normal based on the vertex position from the
    // center of the cloud, so that sprite on the opposite side of the cloud
    // to the sun are darker.
    vec3 n = normalize(vec3(osg_ViewMatrixInverse *
                            osg_ModelViewMatrix * vec4(-final_pos.xyz, 0.0)));
    float NdotL = dot(-fg_SunDirectionWorld, n);

    vec4 final_view_pos = osg_ModelViewMatrix * final_pos;
    vec4 final_world_pos = osg_ViewMatrixInverse * final_view_pos;

    float fogCoord = abs(final_view_pos.z);
    float fract = smoothstep(0.0, cloud_height, final_pos.z + cloud_height);

    vec3 sun_radiance = get_sun_radiance(final_world_pos.xyz);

    // Determine the shading of the sprite based on its vertical position and
    // position relative to the sun.
    NdotL = min(smoothstep(-0.5, 0.0, NdotL), fract);
    // Determine the shading based on a mixture from the backlight to the front
    vec3 backlight = shade * sun_radiance;

    cloudColor.rgb = mix(backlight, sun_radiance, NdotL);

    // Perspective division and scale to [0, 1] to get the screen position
    // of the vertex.
    vec2 coord = (gl_Position.xy / gl_Position.w) * 0.5 + 0.5;
    cloudColor.rgb = add_aerial_perspective(
        cloudColor.rgb, coord, length(final_view_pos));

    // As we get within 100m of the sprite, it is faded out. Equally at large
    // distances it also fades out.
    cloudColor.a = min(smoothstep(100.0, 250.0, fogCoord),
                       1.0 - smoothstep(70000.0, 75000.0, fogCoord));
}
