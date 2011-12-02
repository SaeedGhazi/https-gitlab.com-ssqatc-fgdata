//#define fog_FuncTION
//default fog
//varying float fogCoord;
varying vec3 PointPos;
//varying vec4 EyePos;

vec3 fog_Func(vec3 color, int type)
{
	//if (type == 0){
		const float LOG2 = 1.442695;
		//vec3 EyePos = vec3(0.0);
		float fogCoord =length(PointPos);
		float fogFactor = exp2(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord * LOG2);

		if(gl_Fog.density == 1.0)
			fogFactor=1.0;

		return mix(gl_Fog.color.rgb, color, fogFactor);
}