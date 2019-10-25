// -*- mode: C; -*-
// RANDOM BUILDINGS for the UBERSHADER vertex shader
// Licence: GPL v2
// © Emilian Huminiuc and Vivian Meazza 2011
#version 120
#extension GL_EXT_draw_instanced : enable

varying	vec4	diffuseColor;
varying	vec3 	VBinormal;
varying	vec3 	VNormal;
varying	vec3 	VTangent;
varying vec3	eyeVec;
varying vec3  normal;

uniform	int  		refl_dynamic;
uniform int  		nmap_enabled;
uniform int  		shader_qual;
uniform int			rembrandt_enabled;

attribute vec3 instancePosition; // (x,y,z)
attribute vec3 instanceScaleRotate; // (width, depth, height)
attribute vec3 rotPitchWtex0x; // (rotation, pitch height, texture x offset)
attribute vec3 wtex0yTex1xTex1y; // (wall texture y offset, wall/roof texture x gain, wall/roof texture y gain)
attribute vec3 rtex0xRtex0y; // (roof texture y offset, roof texture x gain, texture y gain)
attribute vec3 rooftopscale; // (rooftop x scale, rooftop y scale)

void	main(void)
{
  // Determine the rotation for the building.
  float sr = sin(6.28 * rotPitchWtex0x.x);
  float cr = cos(6.28 * rotPitchWtex0x.x);

  vec3 position = gl_Vertex.xyz;
  // Adjust the very top of the roof to match the rooftop scaling.  This shapes
  // the rooftop - gambled, gabled etc.  These vertices are identified by gl_Color.z
  position.x = (1.0 - gl_Color.z) * position.x + gl_Color.z * ((position.x + 0.5) * rooftopscale.x - 0.5);
  position.y = (1.0 - gl_Color.z) * position.y + gl_Color.z * (position.y * rooftopscale.y);

  // Adjust pitch of roof to the correct height. These vertices are identified by gl_Color.z
  // Scale down by the building height (instanceScaleRotate.z) because
  // immediately afterwards we will scale UP the vertex to the correct scale.
  position.z = position.z + gl_Color.z * rotPitchWtex0x.y / instanceScaleRotate.z;
  position = position * instanceScaleRotate.xyz;

  // Rotation of the building and movement into position
  position.xy = vec2(dot(position.xy, vec2(cr, sr)), dot(position.xy, vec2(-sr, cr)));
  position = position + instancePosition.xyz;

  gl_Position = gl_ModelViewProjectionMatrix * vec4(position,1.0);
	vec4 ecPosition = gl_ModelViewMatrix * vec4(position, 1.0);

	eyeVec = ecPosition.xyz;

  // Rotate the normal.
  normal = gl_Normal;

  // Rotate the normal as per the building.
  normal.xy = vec2(dot(normal.xy, vec2(cr, sr)), dot(normal.xy, vec2(-sr, cr)));
  vec3 n = normalize(normal);

  vec3 c1 = cross(n, vec3(0.0,0.0,1.0));
  vec3 c2 = cross(n, vec3(0.0,1.0,0.0));
  VNormal = normalize(gl_NormalMatrix * normal);

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
	gl_ClipVertex = ecPosition;

  // Texture coordinates are stored as:
  // - a separate offset for the wall (wtex0x, wtex0y), and roof (rtex0x, rtex0y)
  // - a shared gain value (tex1x, tex1y)
  //
  // The vertex color value selects between them, with glColor.x=1 indicating walls
  // and glColor.y=1 indicating roofs.
  // Finally, the roof texture is on the left of the texture sheet
  vec2 tex0 = vec2(sign(gl_MultiTexCoord0.x) * (gl_Color.x*rotPitchWtex0x.z + gl_Color.y*rtex0xRtex0y.x),
                   gl_Color.x*wtex0yTex1xTex1y.x + gl_Color.y*rtex0xRtex0y.y);
  gl_TexCoord[0].x = tex0.x + gl_MultiTexCoord0.x * wtex0yTex1xTex1y.y;
  gl_TexCoord[0].y = tex0.y + gl_MultiTexCoord0.y * wtex0yTex1xTex1y.z;
}
