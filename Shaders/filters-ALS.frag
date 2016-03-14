// -*-C++-*-

// This is a library of filter functions

// Thorsten Renk 2016

#version 120

uniform float gamma;
uniform float brightness;

uniform bool use_filtering;
uniform bool use_night_vision;


vec3 gamma_correction (in vec3 color) {


float value = length(color)/1.732;
return pow(value, gamma) * color;

}

vec3 brightness_adjust (in vec3 color) {

return clamp(brightness * color, 0.0, 1.0);

}

vec3 night_vision (in vec3 color) {

float value = length(color)/1.732;

return vec3 (0.0, 1.0, 0.0) * value;

}

vec3 filter_combined (in vec3 color) {

if (use_filtering == false)
	{
	return color;
	}


color = brightness_adjust(color);

if (use_night_vision)
	{
	color = night_vision(color);
	}

return gamma_correction (color);

}


