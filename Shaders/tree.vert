  // Tree instance scheme:
// vertex - local position of quad vertex.
// normal - x y scaling, z number of varieties
// fog coord - rotation
// color - xyz of tree quad origin, replicated 4 times.
#version 120
#extension GL_EXT_draw_instanced : enable

attribute vec3 instancePosition; // (x,y,z)

//varying float fogCoord;
// varying vec3 PointPos;
//varying vec4 EyePos;
// ////fog "include"////////
// uniform int fogType;
//
// void fog_Func(int type);
// /////////////////////////
uniform float season;


void main(void)
{
  float numVarieties = gl_Normal.z;
  float texFract = floor(fract(instancePosition.x) * numVarieties) / numVarieties;
  texFract += floor(gl_MultiTexCoord0.x) / numVarieties;
  
  // Randomly rotate the tree quad.
  float sr = sin(instancePosition.x);
  float cr = cos(instancePosition.x);
  gl_TexCoord[0] = vec4(texFract, gl_MultiTexCoord0.y, 0.0, 0.0);
  gl_TexCoord[0].y =  gl_TexCoord[0].y + 0.5 * season;

  // scaling
  float scale = (fract(instancePosition.x) + fract(instancePosition.y))/2.0f + 0.5f;
  vec3 position = gl_Vertex.xyz * gl_Normal.xxy * scale;

  // Rotation of the generic quad to specific one for the tree.
  position.xy = vec2(dot(position.xy, vec2(cr, sr)), dot(position.xy, vec2(-sr, cr)));
  position = position + instancePosition.xyz;
  gl_Position   = gl_ModelViewProjectionMatrix * vec4(position,1.0);
  vec3 ecPosition = vec3(gl_ModelViewMatrix * vec4(position, 1.0));

  float n = dot(normalize(gl_LightSource[0].position.xyz), normalize(-ecPosition));

  vec3 diffuse = gl_FrontMaterial.diffuse.rgb * max(0.1, n);
  vec4 ambientColor = gl_FrontLightModelProduct.sceneColor + gl_LightSource[0].ambient * gl_FrontMaterial.ambient;
  gl_FrontColor = ambientColor + gl_LightSource[0].diffuse * vec4(diffuse, 1.0);

  //fogCoord = abs(ecPosition.z);
  //fogFactor = exp( -gl_Fog.density * gl_Fog.density * fogCoord * fogCoord);
  //fogFactor = clamp(fogFactor, 0.0, 1.0);
//	fog_Func(fogType);
// 	PointPos = ecPosition;
	//EyePos = gl_ModelViewMatrixInverse * vec4(0.0,0.0,0.0,1.0);
}
