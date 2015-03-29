// -*- mode: C; -*-
// RANDOM BUILDINGS for the UBERSHADER vertex shader
// Licence: GPL v2
// © Emilian Huminiuc and Vivian Meazza 2011
#version 120

varying	vec4	diffuseColor;
varying	vec3 	VBinormal;
varying	vec3 	VNormal;
varying	vec3 	VTangent;
varying	vec3 	rawpos;
varying vec3	eyeVec;

uniform	int  		refl_dynamic;
uniform int  		nmap_enabled;
uniform int  		shader_qual;
uniform int			rembrandt_enabled;

void	main(void)
{
    float sr = sin(6.28 * gl_Color.a);
    float cr = cos(6.28 * gl_Color.a);    
    rawpos = gl_Vertex.xyz;
  
    // Rotation of the object and movement into position
    rawpos.xy = vec2(dot(rawpos.xy, vec2(cr, sr)), dot(rawpos.xy, vec2(-sr, cr)));
    rawpos = rawpos + gl_Color.xyz;    
    
	vec4 ecPosition = gl_ModelViewMatrix * vec4(rawpos.xyz, 1.0);

	eyeVec = ecPosition.xyz;

    // Rotate the normal.
    vec3 normal = gl_Normal;
    normal.xy = vec2(dot(normal.xy, vec2(cr, sr)), dot(normal.xy, vec2(-sr, cr)));

    VNormal = normalize(gl_NormalMatrix * normal);
    vec3 n = normalize(normal);
    vec3 c1 = cross(n, vec3(0.0,0.0,1.0));
    vec3 c2 = cross(n, vec3(0.0,1.0,0.0));

    VTangent = c1;
    if(length(c2)>length(c1)){
		VTangent = c2;
    }

    VBinormal = cross(n, VTangent);

    VTangent = normalize(gl_NormalMatrix * -VTangent);
    VBinormal = normalize(gl_NormalMatrix * VBinormal);



// 	Force no alpha on random buildings
	diffuseColor = vec4(gl_FrontMaterial.diffuse.rgb,1.0);

	if(rembrandt_enabled < 1){
	gl_FrontColor = gl_FrontMaterial.emission + vec4(1.0)
					* (gl_LightModel.ambient + gl_LightSource[0].ambient);
	} else {
		gl_FrontColor = vec4(1.0);
	}
	gl_Position  = gl_ModelViewProjectionMatrix * vec4(rawpos,1.0);
	gl_ClipVertex = ecPosition;
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}
