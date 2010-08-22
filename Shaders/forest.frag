#version 120

varying vec4  rawpos;
varying vec4 ecPosition;
varying vec3 VNormal;
varying vec3 Normal;

uniform sampler3D NoiseTex;
uniform sampler2D SampleTex;
uniform sampler1D ColorsTex;
uniform sampler2D SampleTex2;

uniform float snowlevel; // From /sim/rendering/snow-level-m

const float scale = 1.0;


void main (void)
{

	vec4 basecolor = texture2D(SampleTex, rawpos.xy*0.000144);
	vec4 basecolor2 = texture2D(SampleTex2, rawpos.xy*0.000144);
	
	basecolor = texture1D(ColorsTex, basecolor.r+0.0);
	
	vec4 noisevec   = texture3D(NoiseTex, (rawpos.xyz)*0.01*scale);

	vec4 nvL   = texture3D(NoiseTex, (rawpos.xyz)*0.00066*scale);
	
	float vegetationlevel = (rawpos.z)+nvL[2]*3000.0;

	float fogFactor;
	float fogCoord = ecPosition.z;
	const float LOG2 = 1.442695;
	fogFactor = exp2(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord * LOG2);
	float biasFactor = exp2(-0.00000002 * fogCoord * fogCoord * LOG2);

	float n=0.12;
	n += nvL[0]*0.4;
	n += nvL[1]*0.6;
	n += nvL[2]*2.0;
	n += nvL[3]*4.0;
	n += noisevec[0]*0.1;
	n += noisevec[1]*0.4;

	n += noisevec[2]*0.8;
	n += noisevec[3]*2.1;
	n = mix(0.6, n, biasFactor);
	
	vec4 c1;
	c1 = basecolor * vec4(smoothstep(-1.3, 0.5, n), smoothstep(-1.3, 0.5, n), smoothstep(-2.0, 0.9, n), 0.0);
	
	vec4 c2;
	c2 = basecolor2 * vec4(smoothstep(-1.3, 0.5, n), smoothstep(-1.3, 0.5, n), smoothstep(-2.0, 0.9, n), 0.0);
	
	//draw floor where !steep, and another blurb for smoothing transitions
	vec4 c3, c4, c5;
	c3 = mix(vec4(n-0.88, n-0.14, -n, 0.0), c1, smoothstep(0.990, 0.970, abs(normalize(Normal).z)+nvL[2]*1.3));
	c4 = mix(vec4(n-0.88, n-0.74, -n, 0.0), c1, smoothstep(0.990, 0.890, abs(normalize(Normal).z)+nvL[2]*0.9));
	c5 = mix(c3, c4, 1.0);
	
	//brings vegetation 'floor' only at vegetationlevel
	
	if (vegetationlevel < 2200) {
	c1 = mix(c2, c5, clamp(0.65, n*0.5, 0.4));
	}
	
	//draw (almost) bare peaks
	else {
	c1 = mix(c2, c5, clamp(0.65, n*0.5, 0.1));
	}
	
	//adding snow and permanent snow/glacier
	if (vegetationlevel > snowlevel || vegetationlevel > 3300) {
	c3 = mix(vec4(n+0.94, n+0.94, n+1.0, 0.7), c1, smoothstep(0.990, 0.965, abs(normalize(Normal).z)+nvL[2]*1.3));
	c4 = mix(vec4(n+0.94, n+0.94, n+1.0, 0.7), c1, smoothstep(0.990, 0.965, abs(normalize(Normal).z)+nvL[2]*1.2));
	c5 = mix(c3, c4, 1.0);
	c1 = mix(c1, c5, clamp(0.65, -n, 0.6));
	}
	
	//snow (just white color at the moment)
	//c1 = mix(c1, clamp(n+nvL[2]*4.1+vec4(0.1, 0.1, nvL[2]*2.2, 1.0), 0.7, 1.0), smoothstep(snowlevel+300.0, snowlevel+360.0, (rawpos.z)+nvL[1]*3000.0));

    vec3 diffuse = gl_Color.rgb * max(0.4, dot(VNormal, gl_LightSource[0].position.xyz));
    vec4 ambient_light = gl_LightSource[0].diffuse * vec4(diffuse, 1.0);

	c1 *= ambient_light;
	vec4 finalColor = c1;

	if(gl_Fog.density == 1.0)
		fogFactor=1.0;

	gl_FragColor = mix(gl_Fog.color ,finalColor, fogFactor);
}
