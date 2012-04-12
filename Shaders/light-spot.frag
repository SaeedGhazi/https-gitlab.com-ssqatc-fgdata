uniform vec2 fg_BufferSize;
uniform vec3 fg_Planes;

uniform sampler2D depth_tex;
uniform sampler2D normal_tex;
uniform sampler2D color_tex;
uniform sampler2D spec_emis_tex;
uniform vec4 LightPosition;
uniform vec4 LightDirection;
uniform vec4 Ambient;
uniform vec4 Diffuse;
uniform vec4 Specular;
uniform vec3 Attenuation;
uniform float Exponent;
uniform float Cutoff;
uniform float CosCutoff;
uniform float Near;
uniform float Far;

varying vec4 ecPosition;

vec3 position( vec3 viewdir, float depth );
vec3 normal_decode(vec2 enc);

void main() {
	vec3 ray = ecPosition.xyz / ecPosition.w;
	vec3 ecPos3 = ray;
    vec3 viewDir = normalize(ray);
	vec2 coords = gl_FragCoord.xy / fg_BufferSize;
	
	vec3 normal = normal_decode(texture2D( normal_tex, coords ).rg);
	vec4 spec_emis = texture2D( spec_emis_tex, coords );
	
    vec3 pos = position(viewDir, texture2D( depth_tex, coords ).r);

	if ( pos.z < ecPos3.z ) // Negative direction in z
		discard; // Don't light surface outside the light volume
	
	vec3 VP = LightPosition.xyz - pos;
	if ( dot( VP, VP ) > ( Far * Far ) )
		discard; // Don't light surface outside the light volume

	float d = length( VP );
	VP /= d;

	vec3 halfVector = normalize(VP - viewDir);

    float att = 1.0 / (Attenuation.x + Attenuation.y * d + Attenuation.z *d*d);
	float spotDot = dot(-VP, normalize(LightDirection.xyz));
	
	float spotAttenuation = 0.0;
	if (spotDot < CosCutoff)
	    spotAttenuation = 0.0;
	else
	    spotAttenuation = pow(spotDot, Exponent);
	att *= spotAttenuation;
		
	float nDotVP = max(0.0, dot(normal, VP));
	float nDotHV = max(0.0, dot(normal, halfVector));
	
	vec4 color = texture2D( color_tex, coords );
	vec4 Iamb = Ambient * color * att;
	vec4 Idiff = Diffuse * color * att * nDotVP;
	vec3 Ispec = pow( nDotHV, spec_emis.y ) * spec_emis.x * att * Specular.rgb;
	
	gl_FragColor = vec4(Iamb.rgb + Idiff.rgb + Ispec, 1.0);
}
