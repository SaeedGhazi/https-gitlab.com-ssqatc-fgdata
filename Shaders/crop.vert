#version 120

varying vec4  rawpos;
varying vec4  ecPosition;
varying vec3  VNormal;
varying vec3  Normal;
centroid varying vec4 ipos;

void main(void)
{
	gl_TexCoord[0]  = gl_MultiTexCoord0;

	rawpos     = gl_Vertex;
	ipos     = gl_Vertex;
	ecPosition = gl_ModelViewMatrix * gl_Vertex;
	VNormal = normalize(gl_NormalMatrix * gl_Normal);
	Normal = normalize(gl_Normal);

	gl_Position = ftransform();
}
