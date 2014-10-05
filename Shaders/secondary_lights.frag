// -*-C++-*-

uniform int display_xsize;
uniform int display_ysize;
uniform float field_of_view;
uniform float view_pitch_offset;
uniform float view_heading_offset;

vec3 searchlight(in float dist)
{

vec2 center = vec2 (float(display_xsize) * 0.5, float(display_ysize) * 0.4);
float angularDist; 
float headlightIntensity;  

angularDist = length(gl_FragCoord.xy -center);
if (angularDist <200.0)
	{
	headlightIntensity = pow(cos(angularDist/200.0 * 3.1415/2.0),2.0);
	headlightIntensity = headlightIntensity * min(1.0, 10000.0/(dist*dist));
	return  headlightIntensity * vec3 (0.5,0.5, 0.5);
	}
else return vec3 (0.0,0.0,0.0);
}

vec3 landing_light(in float dist)
{

float fov_h = field_of_view;
float fov_v = float(display_ysize)/float(display_xsize) * field_of_view; 

float yaw_offset;

if (view_heading_offset > 180.0)
	{yaw_offset = -360.0+view_heading_offset;}
else 
	{yaw_offset = view_heading_offset;}

float x_offset = (float(display_xsize) / fov_h * yaw_offset);
float y_offset = -(float(display_ysize) / fov_v * view_pitch_offset);

vec2 center = vec2 (float(display_xsize) * 0.5 + x_offset, float(display_ysize) * 0.4 + y_offset);


float angularDist; 
float headlightIntensity;  

angularDist = length(gl_FragCoord.xy -center);
if (angularDist <200.0)
	{
	headlightIntensity = pow(cos(angularDist/200.0 * 3.1415/2.0),2.0);
	headlightIntensity = headlightIntensity * min(1.0, 10000.0/(dist*dist));
	return  headlightIntensity * vec3 (0.5,0.5, 0.5);
	}
else return vec3 (0.0,0.0,0.0);
}
