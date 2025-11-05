$FG_GLSL_VERSION

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multitexcoord0;

out vec4 ap_color;

uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat4 osg_ViewMatrixInverse;

// aerial_perspective_envmap.glsl
vec4 get_aerial_perspective(vec3 pos);

void main()
{
    vec4 vs_pos, ws_pos;
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vs_pos = osg_ModelViewMatrix * pos;
    ws_pos = osg_ViewMatrixInverse * vs_pos;

    ap_color = get_aerial_perspective(ws_pos.xyz);
}
