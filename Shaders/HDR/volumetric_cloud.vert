$FG_GLSL_VERSION

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multitexcoord0;

out float flogz;
out vec4 ap_color;
out vec3 texcoord;
out vec4 vs_pos;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat4 osg_ViewMatrixInverse;

uniform mat3 osg_NormalMatrix;
uniform mat4 fg_TextureMatrix;

// aerial_perspective.glsl
vec4 get_aerial_perspective(vec2 raw_coord, vec3 P);
// logarithmic_depth.glsl
float logdepth_prepare_vs_depth(float z);

void main()
{
    vec4 ws_pos;
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vs_pos = osg_ModelViewMatrix * pos;
    ws_pos = osg_ViewMatrixInverse * vs_pos;

    flogz = logdepth_prepare_vs_depth(gl_Position.w);

    // Perspective division and scale to [0, 1] to get the screen position
    // of the vertex.
    vec2 raw_coord = (gl_Position.xy / gl_Position.w) * 0.5 + 0.5;
    ap_color = get_aerial_perspective(raw_coord, vs_pos.xyz);
    texcoord = multitexcoord0.xyz;
}
