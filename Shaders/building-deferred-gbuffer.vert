// -*- mode: C; -*-
// Licence: GPL v2
// Author: Frederic Bouvier.
//
#version 120
#extension GL_EXT_draw_instanced : enable

attribute vec3 instancePosition; // (x,y,z)
attribute vec3 instanceScaleRotate; // (width, depth, height)
attribute vec3 rotPitchTex0x; // (rotation, pitch height, texture x offset)
attribute vec3 tex0yTex1xTex1y; // (texture y offset, texture x gain, texture y gain)

varying vec3 ecNormal;
varying float alpha;

void main() {
  // Determine the rotation for the building.
  float sr = sin(6.28 * rotPitchTex0x.x);
  float cr = cos(6.28 * rotPitchTex0x.x);

  // Adjust pitch of roof to the correct height.
  // The top roof vertices are the only ones that have fractional z values (1.5),
  // so we can use this to identify them and scale up any pitched roof vertex to
  // the correct pitch (rotPitchTex0x.y * 2.0 because of the fractional z value),
  // then scale down by the building height (instanceScaleRotate.z) because
  // immediately afterwards we will scale UP the vertex to the correct scale.
  vec3 position = gl_Vertex.xyz;
  position.z = position.z + fract(position.z) * 2.0 * rotPitchTex0x.y / instanceScaleRotate.z - fract(position.z);
  position = position * instanceScaleRotate.xyz;

  // Rotation of the building and movement into position
  position.xy = vec2(dot(position.xy, vec2(cr, sr)), dot(position.xy, vec2(-sr, cr)));
  position = position + instancePosition.xyz;

  gl_Position = gl_ModelViewProjectionMatrix * vec4(position,1.0);

  // Texture coordinates are stored as tex0 and tex1 across two attributes.
  // tex0 contains the bottom leftmost point, and tex1 contains (w,h).
  gl_TexCoord[0].x = sign(gl_MultiTexCoord0.x) * rotPitchTex0x.z + gl_MultiTexCoord0.x * tex0yTex1xTex1y.y;
  gl_TexCoord[0].y = tex0yTex1xTex1y.x + gl_MultiTexCoord0.y * tex0yTex1xTex1y.z;

  // Rotate the normal.
  ecNormal = gl_Normal;

  // The roof pieces have a normal of (+/-0.7, 0.0, 0.7)
  // If the roof is flat, then we need to change it to (0,0,1).
  // First term evaluates for normals without a +z component (all except roof)
  // Second term evaluates for roof normals with a pitch
  // Third term evaluates for flat roofs
  ecNormal = step(0.5, 1.0 - ecNormal.z) * ecNormal +
             step(0.5, ecNormal.z) * clamp(rotPitchTex0x.y, 0.0, 1.0) * ecNormal +
             step(0.5, ecNormal.z) * (1.0 - clamp(rotPitchTex0x.y, 0.0, 1.0)) * vec3(0,0,1);

  // Rotate the normal as per the building.
  ecNormal.xy = vec2(dot(ecNormal.xy, vec2(cr, sr)), dot(ecNormal.xy, vec2(-sr, cr)));
  ecNormal = gl_NormalMatrix * ecNormal;

  gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  gl_FrontColor = vec4(1.0, 1.0, 1.0, 1.0);
  gl_BackColor = vec4(1.0, 1.0, 1.0, 1.0);
  alpha = 1.0;
}
