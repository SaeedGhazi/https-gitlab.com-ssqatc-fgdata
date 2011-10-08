// -*-C++-*-
#version 120

varying float fogFactor;

uniform float range; // From /sim/rendering/clouds3d-vis-range

attribute vec3 usrAttr1;
attribute vec3 usrAttr2;
attribute vec3 usrAttr3;

float textureIndexX = usrAttr1.r;
float textureIndexY = usrAttr1.g;
float wScale = usrAttr1.b;
float hScale = usrAttr2.r;
float shade_factor = usrAttr2.g;
float cloud_height = usrAttr2.b;
float bottom_factor = shade_factor;
float middle_factor = 1.0;
float top_factor = 1.0;

void main(void)
{
  gl_TexCoord[0] = gl_MultiTexCoord0 + vec4(textureIndexX, textureIndexY, 0.0, 0.0);
  vec4 ep = gl_ModelViewMatrixInverse * vec4(0.0,0.0,0.0,1.0);
  vec4 l  = gl_ModelViewMatrixInverse * vec4(0.0,0.0,1.0,1.0);
  vec3 u = normalize(ep.xyz - l.xyz);

  // Find a rotation matrix that rotates 1,0,0 into u. u, r and w are
  // the columns of that matrix.
  vec3 absu = abs(u);
  vec3 r = normalize(vec3(-u.y, u.x, 0.0));
  vec3 w = cross(u, r);

  // Do the matrix multiplication by [ u r w pos]. Assume no
  // scaling in the homogeneous component of pos.
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  gl_Position.xyz = gl_Vertex.x * u;
  gl_Position.xyz += gl_Vertex.y * r * wScale;
  gl_Position.xyz += gl_Vertex.z * w  * hScale;
  // Apply Z scaling to allow sprites to be squashed in the z-axis
  gl_Position.z = gl_Position.z * gl_Color.w;

  // Now shift the sprite to the correct position in the cloud.
  gl_Position.xyz += gl_Color.xyz;

  // Determine a lighting normal based on the vertex position from the
  // center of the cloud, so that sprite on the opposite side of the cloud to the sun are darker.
  float n = dot(normalize(-gl_LightSource[0].position.xyz),
                normalize(vec3(gl_ModelViewMatrix * vec4(- gl_Position.x, - gl_Position.y, - gl_Position.z, 0.0))));

  // Determine the position - used for fog and shading calculations
  vec3 ecPosition = vec3(gl_ModelViewMatrix * gl_Position);
  float fogCoord = abs(ecPosition.z);
  
  // Determine the shading of the vertex. We shade it based on it's position
  // in the cloud relative to the sun, and it's vertical position in the cloud.
  float shade = mix(shade_factor, top_factor,  smoothstep(-0.3, 0.0, n));
  //if (n < 0) {
  //  shade = mix(top_factor, shade_factor, abs(n));
  //} 
  
  float h = gl_Position.z;
  shade = min(shade,
              min(mix(bottom_factor, middle_factor, smoothstep(0.0, 0.5 * h, h)),
                  mix(middle_factor, top_factor, smoothstep(0.5 * h, h, h))      ) );
                
  //float h = gl_Position.z / cloud_height;
  //if (h < 0.5) {
  //  shade = min(shade, mix(bottom_factor, middle_factor, smoothstep(0.0, 0.5, h)));
  //} else {
  //  shade = min(shade, mix(middle_factor, top_factor, smoothstep(2.0 * (h - 0.5)));    
 // }
  
  // Final position of the sprite
  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;
  
  gl_FrontColor = gl_LightSource[0].diffuse * shade + gl_FrontLightModelProduct.sceneColor;

  // As we get within 100m of the sprite, it is faded out. Equally at large distances it also fades out.
  gl_FrontColor.a = min(smoothstep(10.0, 100.0, fogCoord), 1.0 - smoothstep(range*0.8, range, fogCoord));
  gl_BackColor = gl_FrontColor;

  // Fog doesn't affect clouds as much as other objects.
  fogFactor = exp( -gl_Fog.density * fogCoord * 0.5);
  fogFactor = clamp(fogFactor, 0.0, 1.0);
}
