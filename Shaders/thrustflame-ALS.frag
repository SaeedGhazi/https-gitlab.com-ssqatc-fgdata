// -*-C++-*-


varying vec3 vertex;
varying vec3 viewDir;

uniform float osg_SimulationTime;
uniform float thrust_collimation;
uniform float thrust_density;
uniform float shock_frequency;
uniform float noise_strength;
uniform float noise_scale;

uniform float flame_color_low_r;
uniform float flame_color_low_g;
uniform float flame_color_low_b;

uniform float flame_color_high_r;
uniform float flame_color_high_g;
uniform float flame_color_high_b;

uniform int use_shocks;
uniform int use_noise;

float Noise3D(in vec3 coord, in float wavelength);
float Noise2D(in vec2 coord, in float wavelength);

const int n_steps = 100;

float spherical_smoothstep (in vec3 pos)
{

float noise = Noise3D(vec3(pos.x - osg_SimulationTime * 5.0 , pos.y, pos.z), 0.3);

pos *=4.0;

pos.x *=0.5;
float d = length(pos);



return 3.0 * (1.0 - smoothstep(0.3, 0.7, d)) /float(n_steps)* (0.5 + 0.5 * noise);
}

float spherical_smoothstep1 (in vec3 pos)
{
pos.x *=0.2;
float d = length(pos);

return 1.0 * (1.0 - smoothstep(0.3, 0.7, d)) /float(n_steps);
}

float thrust_flame (in vec3 pos)
{


//float noise = Noise3D(vec3(pos.x - osg_SimulationTime * 20.0 , pos.y, pos.z), 0.3);
float noise = Noise2D(vec2(pos.x - osg_SimulationTime * 30.0 , length(pos.yz)), noise_scale);

float d = 1.0 - pos.x/2.5 ;
float radius = 0.2 + thrust_collimation * 1.4 * pow((pos.x+0.1),0.5);

d *= (1.0 - smoothstep(0.125, radius, length(pos.yz))) * (1.0 - noise_strength + noise_strength* noise);

if (use_shocks == 1)
	{
	float shock = sin(pos.x * 20.0 * shock_frequency);
	d += shock * shock * shock * shock * (1.0 - pos.x/2.5) * (1.0 - smoothstep(0.05, 0.1, length(pos.yz))) *  (1.0 - smoothstep(0.0, 1.0, thrust_collimation));
	}

return 10.0 * thrust_density *  d / (radius/0.2);
}



void main()
{

float t_x = 2.0 * abs(vertex.x) / max(viewDir.x, 0.0001);
float t_y = 2.0 * abs(vertex.y) / max(viewDir.y, 0.0001);
float t_z = 2.0 * abs(vertex.z) / max(viewDir.z, 0.0001);

float t_min = min(t_x, t_y);
t_min = min(t_min, t_z);

t_min = 5.0;

float dt = t_min  / float(n_steps);

vec3 step = viewDir * dt;
vec3 pos = vertex;

float density1 = 0.0;
float density2 = 0.0;



for (int i = 0; i < n_steps; i++)
	{
	pos = pos + step;
	if ((pos.x > 5.0) || (pos.x <0.0)) {break;} 
	if ((pos.y > 1.0) || (pos.y <-1.0)) {break;} 
	if ((pos.z > 1.0) || (pos.z <-1.0)) {break;} 
	//density1 += spherical_smoothstep(pos);
	//density2 += spherical_smoothstep1(pos);
	density2 += thrust_flame(pos) * dt;
	}




float density = density1 + density2;
density = clamp(density,0.0,1.0);


vec3 flame_color_low = vec3 (flame_color_low_r, flame_color_low_g, flame_color_low_b);
vec3 flame_color_high = vec3 (flame_color_high_r, flame_color_high_g, flame_color_high_b);

vec3 color = mix(flame_color_low, flame_color_high, density2+density1);

vec4 finalColor = vec4 (color.rgb, density);

gl_FragColor = finalColor;
}
