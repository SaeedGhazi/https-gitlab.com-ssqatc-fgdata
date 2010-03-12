#version 120

varying vec4  rawpos;
varying vec4  ecPosition;
varying vec3  VNormal;
varying vec3  VTangent;
varying vec3  VBinormal;
varying vec3  Normal;
varying vec4  constantColor;

uniform sampler2D BaseTex;
uniform sampler2D NormalTex;
uniform float depth_factor;

const float scale = 1.0;

float ray_intersect(sampler2D reliefMap, vec2 dp, vec2 ds)
{
	const int linear_search_steps = 10;

	float size = 1.0 / float(linear_search_steps);
	float depth = 0.0;
	float best_depth = 1.0;

	for(int i = 0; i < linear_search_steps - 1; ++i)
	{
		depth += size;
		float t = texture2D(reliefMap, dp + ds * depth).a;
		if(best_depth > 0.996)
			if(depth >= t)
				best_depth = depth;
	}
	depth = best_depth;

	const int binary_search_steps = 5;

	for(int i = 0; i < binary_search_steps; ++i)
	{
		size *= 0.5;
		float t = texture2D(reliefMap, dp + ds * depth).a;
		if(depth >= t)
		{
			best_depth = depth;
			depth -= 2.0 * size;
		}
		depth += size;
	}

	return(best_depth);
}

void main (void)
{
	vec3 V = normalize(ecPosition.xyz);
	vec3 s = vec3(dot(V, VTangent), dot(V, VBinormal), dot(VNormal, V));
	vec2 ds = s.xy * depth_factor / s.z;
	vec2 dp = gl_TexCoord[0].st;
	float d = ray_intersect(NormalTex, dp, ds);

	vec2 uv = dp + ds * d;
	vec3 N = texture2D(NormalTex, uv).xyz * 2.0 - 1.0;

	float fogFactor;
	float fogCoord = ecPosition.z;
	const float LOG2 = 1.442695;
	fogFactor = exp2(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord * LOG2);
	fogFactor = clamp(fogFactor, 0.0, 1.0);

	vec4 c1 = texture2D(BaseTex, uv);

	N = normalize(N.x * VTangent + N.y * VBinormal + N.z * VNormal);

	vec3 l = gl_LightSource[0].position.xyz;
	vec3 diffuse = gl_Color.rgb * max(0.0, dot(N, l));

	vec4 ambient_light = constantColor + gl_LightSource[0].diffuse * vec4(diffuse, 1.0);

	c1 *= ambient_light;
	vec4 finalColor = c1;

	if(gl_Fog.density == 1.0)
		fogFactor=1.0;

	gl_FragColor = mix(gl_Fog.color ,finalColor, fogFactor);
}
