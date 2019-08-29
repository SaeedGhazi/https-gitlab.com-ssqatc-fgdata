// -*- mode: C; -*-
// Licence: GPL v2
// © Emilian Huminiuc and Vivian Meazza 2011
#version 120

attribute vec3 instancePosition; // (x,y,z)
attribute vec3 instanceScaleRotate; // (width, depth, height)
attribute vec3 rotPitchTex0x; // (rotation, pitch height, texture x offset)
attribute vec3 tex0yTex1xTex1y; // (texture y offset, texture x gain, texture y gain)

varying	vec3	rawpos;
varying	vec3	VNormal;
varying	vec3	VTangent;
varying	vec3	VBinormal;
varying	vec3	vViewVec;
varying vec3	vertVec;
varying	vec3	reflVec;

varying	float	alpha;

attribute	vec3	tangent;
attribute	vec3	binormal;

uniform	float		pitch;
uniform	float		roll;
uniform	float		hdg;
uniform	int  		refl_dynamic;
uniform int  		nmap_enabled;
uniform int  		shader_qual;
uniform int			rembrandt_enabled;
uniform int     color_is_position;

//////Fog Include///////////
// uniform	int 	fogType;
// void	fog_Func(int type);
////////////////////////////

void	rotationMatrixPR(in float sinRx, in float cosRx, in float sinRy, in float cosRy, out mat4 rotmat)
{
	rotmat = mat4(	cosRy ,	sinRx * sinRy ,	cosRx * sinRy,	0.0,
									0.0   ,	cosRx        ,	-sinRx * cosRx,	0.0,
									-sinRy,	sinRx * cosRy,	cosRx * cosRy ,	0.0,
									0.0   ,	0.0          ,	0.0           ,	1.0 );
}

void	rotationMatrixH(in float sinRz, in float cosRz, out mat4 rotmat)
{
	rotmat = mat4(	cosRz,	-sinRz,	0.0,	0.0,
									sinRz,	cosRz,	0.0,	0.0,
									0.0  ,	0.0  ,	1.0,	0.0,
									0.0  ,	0.0  ,	0.0,	1.0 );
}

void	main(void)
{
	// Determine the rotation for the building.
	float sr = sin(6.28 * rotPitchTex0x.x);
	float cr = cos(6.28 * rotPitchTex0x.x);

	// Adjust pitch of roof to the correct height.
	// The top roof vertices are the only ones that have fractional z values (1.5),
	// so we can use this to identify them and scale up any pitched roof vertex to
	// the correct pitch (rotPitchTex0x.y * 2.0 because of the fractional z value),
	// then scale down by the building height (instanceScaleRotate.z) because
	// immediately afterwards we will scale UP the vertex to the correct scale.
	rawpos = gl_Vertex.xyz;
	rawpos.z = rawpos.z + fract(rawpos.z) * 2.0 * rotPitchTex0x.y / instanceScaleRotate.z - fract(rawpos.z);
	rawpos = rawpos * instanceScaleRotate.xyz;

	// Rotation of the building and movement into rawpos
	rawpos.xy = vec2(dot(rawpos.xy, vec2(cr, sr)), dot(rawpos.xy, vec2(-sr, cr)));
	rawpos = rawpos + instancePosition.xyz;
	vec4 ecPosition = gl_ModelViewMatrix * vec4(rawpos, 1.0);

	// Texture coordinates are stored as tex0 and tex1 across two attributes.
	// tex0 contains the bottom leftmost point, and tex1 contains (w,h).
	gl_TexCoord[0].x = sign(gl_MultiTexCoord0.x) * rotPitchTex0x.z + gl_MultiTexCoord0.x * tex0yTex1xTex1y.y;
	gl_TexCoord[0].y = tex0yTex1xTex1y.x + gl_MultiTexCoord0.y * tex0yTex1xTex1y.z;

	// Rotate the normal.
	vec3 normal = gl_Normal;

	// The roof pieces have a normal of (+/-0.7, 0.0, 0.7)
	// If the roof is flat, then we need to change it to (0,0,1).
	// First term evaluates for normals without a +z component (all except roof)
	// Second term evaluates for roof normals with a pitch
	// Third term evaluates for flat roofs
	normal = step(0.5, 1.0 - normal.z) * normal +
            step(0.5, normal.z) * clamp(rotPitchTex0x.y, 0.0, 1.0) * normal +
						step(0.5, normal.z) * (1.0 - clamp(rotPitchTex0x.y, 0.0, 1.0)) * vec3(0,0,1);

	// Rotate the normal as per the building.
	normal.xy = vec2(dot(normal.xy, vec2(cr, sr)), dot(normal.xy, vec2(-sr, cr)));

	VNormal = normalize(gl_NormalMatrix * normal);
  vec3 n = normalize(normal);
  vec3 tempTangent = cross(n, vec3(1.0,0.0,0.0));
  vec3 tempBinormal = cross(n, tempTangent);

  if (nmap_enabled > 0){
      tempTangent = tangent;
      tempBinormal  = binormal;
    }

  VTangent = normalize(gl_NormalMatrix * tempTangent);
  VBinormal = normalize(gl_NormalMatrix * tempBinormal);
  vec3 t = tempTangent;
  vec3 b = tempBinormal;

	// Super hack: if diffuse material alpha is less than 1, assume a
	// transparency animation is at work
	if (gl_FrontMaterial.diffuse.a < 1.0)
		alpha = gl_FrontMaterial.diffuse.a;
	else
		alpha = 1.0;

  // Vertex in eye coordinates
	vertVec = ecPosition.xyz;
	vViewVec.x = dot(t, vertVec);
	vViewVec.y = dot(b, vertVec);
	vViewVec.z = dot(n, vertVec);

	// calculate the reflection vector
	vec4 reflect_eye = vec4(reflect(vertVec, VNormal), 0.0);
	vec3 reflVec_stat = normalize(gl_ModelViewMatrixInverse * reflect_eye).xyz;
	if (refl_dynamic > 0){
		//prepare rotation matrix
		mat4 RotMatPR;
		mat4 RotMatH;
		float _roll = roll;
		if (_roll>90.0 || _roll < -90.0)
		{
			_roll = -_roll;
		}
		float cosRx = cos(radians(_roll));
		float sinRx = sin(radians(_roll));
		float cosRy = cos(radians(-pitch));
		float sinRy = sin(radians(-pitch));
		float cosRz = cos(radians(hdg));
		float sinRz = sin(radians(hdg));
		rotationMatrixPR(sinRx, cosRx, sinRy, cosRy, RotMatPR);
		rotationMatrixH(sinRz, cosRz, RotMatH);
		vec3 reflVec_dyn = (RotMatH * (RotMatPR * normalize(gl_ModelViewMatrixInverse * reflect_eye))).xyz;

		reflVec = reflVec_dyn;
	} else {
		reflVec = reflVec_stat;
	}

	if(rembrandt_enabled < 1){
	gl_FrontColor = gl_FrontMaterial.emission + vec4(1.0,1.0,1.0,1.0)
				  * (gl_LightModel.ambient + gl_LightSource[0].ambient);
	} else {
	  gl_FrontColor = vec4(1.0,1.0,1.0,1.0);
	}
	gl_Position  = gl_ModelViewProjectionMatrix * vec4(rawpos,1.0);
}
