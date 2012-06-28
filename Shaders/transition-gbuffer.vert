// -*- mode: C; -*-
// Licence: GPL v2
// Authors: Frederic Bouvier, Emilian Huminiuc
//

varying vec4	RawPos;

varying vec3	normal;
varying vec3	Vnormal;

void main() {
	RawPos = gl_Vertex;
	gl_Position = ftransform();
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	normal = normalize(gl_Normal);
	Vnormal = gl_NormalMatrix * gl_Normal;
}
