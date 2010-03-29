varying vec4 rawposIn;
varying vec3 NormalIn;
varying vec3 VTangentIn;
varying vec3 VBinormalIn;

attribute vec3 tangent;
attribute vec3 binormal;

void main(void)
{
	rawposIn = gl_Vertex;
	NormalIn = normalize(gl_Normal);
	VTangentIn = gl_NormalMatrix * tangent;
	VBinormalIn = gl_NormalMatrix * binormal;

	gl_FrontColor = gl_Color;
	gl_Position = ftransform();
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}
