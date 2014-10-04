// -*-C++-*-

vec3 headlight(in float dist)
{

vec2 center = vec2 (600.0, 400.0);
float angularDist; 
float headlightIntensity;  

angularDist = length(gl_FragCoord.xy -center);
if (angularDist <200.0)
	{
	headlightIntensity = pow(cos(angularDist/200.0 * 3.1415/2.0),2.0);
	headlightIntensity = headlightIntensity * min(1.0, 1000.0/(dist*dist));
	return  headlightIntensity * vec3 (0.5,0.5, 0.5);
	}
else return vec3 (0.0,0.0,0.0);
}
