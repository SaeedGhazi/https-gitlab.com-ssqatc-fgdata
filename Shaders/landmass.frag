#version 120

varying vec4  rawpos;
varying vec4  ecPosition;
varying vec3  VNormal;
varying vec3  Normal;
varying vec4 constantColor;

uniform sampler3D NoiseTex;
uniform sampler2D BaseTex;

const float scale = 1.0;

void main (void)
{
	const float snowlevel=2000.0;
	vec4 noisevec   = texture3D(NoiseTex, (rawpos.xyz)*0.01*scale);
	vec4 nvL   = texture3D(NoiseTex, (rawpos.xyz)*0.00066*scale);

	float fogFactor;
	float fogCoord = ecPosition.z;
	const float LOG2 = 1.442695;
	fogFactor = exp2(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord * LOG2);
//	float biasFactor = exp2(-0.00000002 * fogCoord * fogCoord * LOG2);
	float biasFactor = fogFactor = clamp(fogFactor, 0.0, 1.0);

	float n=0.06;
	n += nvL[0]*0.4;
	n += nvL[1]*0.6;
	n += nvL[2]*2.0;
	n += nvL[3]*4.0;
	n += noisevec[0]*0.1;
	n += noisevec[1]*0.4;

	n += noisevec[2]*0.8;
	n += noisevec[3]*2.1;
	n = mix(0.6, n, biasFactor);
	// good
	vec4 c1 = texture2D(BaseTex, gl_TexCoord[0].st);
	//brown
	//c1 = mix(c1, vec4(n-0.46, n-0.45, n-0.53, 1.0), smoothstep(0.50, 0.55, nvL[2]*6.6));
	//"steep = gray"
	c1 = mix(vec4(n-0.30, n-0.29, n-0.37, 1.0), c1, smoothstep(0.970, 0.990, abs(normalize(Normal).z)+nvL[2]*1.3));
	//"snow"
	c1 = mix(c1, clamp(n+nvL[2]*4.1+vec4(0.1, 0.1, nvL[2]*2.2, 1.0), 0.7, 1.0), smoothstep(snowlevel+300.0, snowlevel+360.0, (rawpos.z)+nvL[1]*3000.0));

    vec3 diffuse = gl_Color.rgb * max(0.0, dot(normalize(VNormal), gl_LightSource[0].position.xyz));
    vec4 ambient_light = constantColor + gl_LightSource[0].diffuse * vec4(diffuse, 1.0);

	c1 *= ambient_light;
	vec4 finalColor = c1;

	if(gl_Fog.density == 1.0)
		fogFactor=1.0;

	gl_FragColor = mix(gl_Fog.color ,finalColor, fogFactor);
}
