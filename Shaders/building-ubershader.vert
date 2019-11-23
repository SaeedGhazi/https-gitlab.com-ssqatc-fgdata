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
attribute vec3 instanceScale; // (width, depth, height)
attribute vec3 rotPitchWtexX0; // (rotation, pitch height, wall texture x0)
attribute vec3 wtexY0FRtexx1FSRtexY1; // (wall texture y0, front/roof texture x1, front/side/roof texture y1)
attribute vec3 rtexX0RtexY0StexX1; // (roof texture x0, roof texture y0, side texture x1)
attribute vec3 rooftopscale; // (rooftop x scale, rooftop y scale)

void	main(void)
{
  // Determine the rotation for the building.
  float sr = sin(6.28 * rotPitchWtexX0.x);
  float cr = cos(6.28 * rotPitchWtexX0.x);

  vec3 position = gl_Vertex.xyz;
  // Adjust the very top of the roof to match the rooftop scaling.  This shapes
  // the rooftop - gambled, gabled etc.  These vertices are identified by gl_Color.z
  position.x = (1.0 - gl_Color.z) * position.x + gl_Color.z * ((position.x + 0.5) * rooftopscale.x - 0.5);
  position.y = (1.0 - gl_Color.z) * position.y + gl_Color.z * (position.y * rooftopscale.y);

  // Adjust pitch of roof to the correct height. These vertices are identified by gl_Color.z
  // Scale down by the building height (instanceScale.z) because
  // immediately afterwards we will scale UP the vertex to the correct scale.
  position.z = position.z + gl_Color.z * rotPitchWtexX0.y / instanceScale.z;
  position = position * instanceScale.xyz;

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
  // - a separate offset (x0, y0) for the wall (wtex0x, wtex0y), and roof (rtex0x, rtex0y)
  // - a semi-shared (x1, y1) so that the front and side of the building can have
  //   different texture mappings
  //
  // The vertex color value selects between them:
  // gl_Color.x=1 indicates front/back walls
  // gl_Color.y=1 indicates roof
  // gl_Color.z=1 indicates top roof vertexs (used above)
  // gl_Color.a=1 indicates sides
  // Finally, the roof texture is on the right of the texture sheet
  float wtex0x = rotPitchWtexX0.z;     // Front/Side texture X0
  float wtex0y = wtexY0FRtexx1FSRtexY1.x;   // Front/Side texture Y0
  float rtex0x = rtexX0RtexY0StexX1.x; // Roof texture X0
  float rtex0y = rtexX0RtexY0StexX1.y; // Roof texture Y0
  float wtex1x = wtexY0FRtexx1FSRtexY1.y;   // Front/Roof texture X1
  float stex1x = rtexX0RtexY0StexX1.z; // Side texture X1
  float wtex1y = wtexY0FRtexx1FSRtexY1.z;   // Front/Roof/Side texture Y1
  vec2 tex0 = vec2(sign(gl_MultiTexCoord0.x) * (gl_Color.x*wtex0x + gl_Color.y*rtex0x + gl_Color.a*wtex0x),
                   gl_Color.x*wtex0y + gl_Color.y*rtex0y + gl_Color.a*wtex0y);

  vec2 tex1 = vec2(gl_Color.x*wtex1x + gl_Color.y*wtex1x + gl_Color.a*stex1x,
                   wtex1y);

  gl_TexCoord[0].x = tex0.x + gl_MultiTexCoord0.x * tex1.x;
  gl_TexCoord[0].y = tex0.y + gl_MultiTexCoord0.y * tex1.y;}
