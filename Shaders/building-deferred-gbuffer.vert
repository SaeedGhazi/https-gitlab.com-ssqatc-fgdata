// -*- mode: C; -*-
// Licence: GPL v2
// Author: Frederic Bouvier.
//
#version 120
#extension GL_EXT_draw_instanced : enable

attribute vec3 instancePosition; // (x,y,z)
attribute vec3 instanceScaleRotate; // (width, depth, height)
attribute vec3 rotPitchWtex0x; // (rotation, pitch height, texture x offset)
attribute vec3 wtex0yTex1xTex1y; // (wall texture y offset, wall/roof texture x gain, wall/roof texture y gain)
attribute vec3 rtex0xRtex0y; // (roof texture y offset, roof texture x gain, texture y gain)
attribute vec3 rooftopscale; // (rooftop x scale, rooftop y scale)

varying vec3 ecNormal;
varying float alpha;

void main() {
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

  // Rotate the normal.
  ecNormal = gl_Normal;
  ecNormal.xy = vec2(dot(ecNormal.xy, vec2(cr, sr)), dot(ecNormal.xy, vec2(-sr, cr)));
  ecNormal = gl_NormalMatrix * ecNormal;

  gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  gl_FrontColor = vec4(1.0, 1.0, 1.0, 1.0);
  gl_BackColor = vec4(1.0, 1.0, 1.0, 1.0);
  alpha = 1.0;
}
