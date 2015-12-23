#version 120

varying vec3 vertex;
varying vec3 normal;
varying vec3 relVec;

void main()
{
	
    normal = gl_Normal;
    vertex = gl_Vertex.xyz;
    vec3 ep = (gl_ModelViewMatrixInverse * vec4 (0.0, 0.0, 0.0, 1.0)).xyz;
    relVec = vertex - ep;
    gl_Position = ftransform();
}
