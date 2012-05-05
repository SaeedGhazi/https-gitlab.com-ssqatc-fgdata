//uniform mat4 fg_ViewMatrixInverse;
uniform mat4 fg_ProjectionMatrixInverse;
varying vec3 ray;
varying vec4 eyePlaneS;
varying vec4 eyePlaneT;
varying vec4 eyePlaneR;
varying vec4 eyePlaneQ;

void main() {
    gl_Position = gl_Vertex;
    gl_TexCoord[0] = gl_MultiTexCoord0;
//    ray = (fg_ViewMatrixInverse * vec4((fg_ProjectionMatrixInverse * gl_Vertex).xyz, 0.0)).xyz;
    ray = (fg_ProjectionMatrixInverse * gl_Vertex).xyz;
    
    eyePlaneS = gl_EyePlaneS[1];
    eyePlaneT = gl_EyePlaneT[1];
    eyePlaneR = gl_EyePlaneR[1];
    eyePlaneQ = gl_EyePlaneQ[1];
}
