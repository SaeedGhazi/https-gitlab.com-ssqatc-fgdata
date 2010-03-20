// -*- mode: C; -*-
// Licence: GPL v2
// Author: Frederic Bouvier

varying vec4 ecPosition;
varying vec3 VNormal;
varying vec3 VTangent;
varying vec3 VBinormal;
varying vec4 constantColor;

attribute vec3 tangent;
attribute vec3 binormal;

void main (void)
{
	ecPosition = gl_ModelViewMatrix * gl_Vertex;
	VNormal = normalize(gl_NormalMatrix * gl_Normal);
	VTangent = normalize(gl_NormalMatrix * tangent);
	VBinormal = normalize(gl_NormalMatrix * binormal);
	constantColor = gl_FrontLightModelProduct.sceneColor + gl_LightSource[0].ambient * gl_FrontMaterial.ambient;
	gl_FrontColor = constantColor;
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = ftransform();
}
