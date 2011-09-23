#version 120
 
// Atmospheric scattering shader for flightgear
// Written by Lauri Peltonen (Zan)
// Implementation of O'Neil's algorithm
 
varying vec3 rayleigh;
varying vec3 mie;
varying vec3 eye;
varying float ct;
 
float miePhase(in float cosTheta, in float g)
{
  float g2 = g*g;
  float a = 1.5 * (1.0 - g2);
  float b = (2.0 + g2);
  float c = 1.0 + cosTheta*cosTheta;
  float d = pow(1.0 + g2 - 2.0 * g * cosTheta, 0.6667);
 
  return (a*c) / (b*d);
}
 
float rayleighPhase(in float cosTheta)
{
  //return 1.5 * (1.0 + cosTheta*cosTheta);
  return 1.5 * (2.0 + 0.5*cosTheta*cosTheta);
}
 
 
 
void main()
{
  float cosTheta = dot(normalize(eye), gl_LightSource[0].position.xyz);
 

  vec3 color = rayleigh * rayleighPhase(cosTheta);
  color += mie * miePhase(cosTheta, -0.8);

  vec3 white = vec3(1.0,1.0,1.0);


  //float scale = dot(normalize(white),normalize(color));
  //float scale1 = 1.0 - exp(-5.0 * length(color));
  //float scale2 = length(color)/length(white);	

  //if (scale1>1.0) color = color/scale1;
	
  //color = color/scale1;


  
  if (color.x > 0.8) color.x = 0.8 + 0.8* log(color.x/0.8);
  if (color.y > 0.8) color.y = 0.8 + 0.8* log(color.y/0.8);
  if (color.z > 0.8) color.z = 0.8 + 0.8* log(color.z/0.8);

   vec3 fogColor = vec3 (gl_Fog.color.x, gl_Fog.color.y, gl_Fog.color.z);

 
  if (ct > -0.03) color = mix(color, fogColor ,smoothstep(0.2, -0.2, ct));
   else color = mix (color, fogColor, smoothstep(0.2,-0.2,-0.03));
  

 
  gl_FragColor = vec4(color, 1.0);
  gl_FragDepth = 0.1;
}

