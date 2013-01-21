// -*-C++-*-

// written by Thorsten Renk, Oct 2011, based on default.frag
// Ambient term comes in gl_Color.rgb.
varying vec4 diffuse_term;
varying vec3 normal;
//varying vec2 nvec;
varying vec3 relPos;
varying vec2 rawPos;
//varying vec2 worldPos;
varying vec3 ecViewdir;
varying vec3 ecNormal;


uniform sampler2D texture;
uniform sampler3D NoiseTex;
uniform sampler2D snow_texture;
uniform sampler2D detail_texture;
uniform sampler2D mix_texture;
uniform sampler2D grain_texture;
uniform sampler2D dot_texture;
uniform sampler2D gradient_texture;
//uniform sampler2D foam_texture;


//varying float yprime_alt;
//varying float mie_angle;
varying float steepness;
varying float grad_dir;


uniform float visibility;
uniform float avisibility;
uniform float scattering;
uniform float terminator;
uniform float terrain_alt; 
uniform float hazeLayerAltitude;
uniform float overcast;
uniform float eye_alt;
uniform float snowlevel;
uniform float dust_cover_factor;
uniform float lichen_cover_factor;
uniform float wetness;
uniform float fogstructure;
uniform float snow_thickness_factor;
uniform float cloud_self_shading;
uniform float moonlight;
uniform float season;
uniform float windspeed;
uniform float grain_strength;
uniform float intrinsic_wetness;
uniform float transition_model;
uniform float hires_overlay_bias;
uniform float dot_density;
uniform float dot_size;
uniform float dust_resistance;
uniform float osg_SimulationTime;
uniform int quality_level;
uniform int tquality_level;

const float EarthRadius = 5800000.0;
const float terminator_width = 200000.0;

float alt;
float eShade;
float yprime_alt;
float mie_angle;



float rand2D(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float cosine_interpolate(in float a, in float b, in float x)
{
	float ft = x * 3.1415927;
	float f = (1.0 - cos(ft)) * .5;

	return  a*(1.0-f) + b*f;
}

float simple_interpolate(in float a, in float b, in float x)
{
return a + smoothstep(0.0,1.0,x) * (b-a);
}

float interpolatedNoise2D(in float x, in float y)
{
      float integer_x    = x - fract(x);
      float fractional_x = x - integer_x;

      float integer_y    = y - fract(y);
      float fractional_y = y - integer_y;

      float v1 = rand2D(vec2(integer_x, integer_y));
      float v2 = rand2D(vec2(integer_x+1.0, integer_y));
      float v3 = rand2D(vec2(integer_x, integer_y+1.0));
      float v4 = rand2D(vec2(integer_x+1.0, integer_y +1.0));

      float i1 = simple_interpolate(v1 , v2 , fractional_x);
      float i2 = simple_interpolate(v3 , v4 , fractional_x);

      return simple_interpolate(i1 , i2 , fractional_y);
}



float Noise2D(in vec2 coord, in float wavelength)
{
return interpolatedNoise2D(coord.x/wavelength, coord.y/wavelength);

}

float dotNoise2D(in float x, in float y, in float fractionalMaxDotSize)
{
	float integer_x    = x - fract(x);
    float fractional_x = x - integer_x;

    float integer_y    = y - fract(y);
    float fractional_y = y - integer_y;

	if (rand2D(vec2(integer_x+1.0, integer_y +1.0)) > dot_density)
		{return 0.0;}

    float xoffset = (rand2D(vec2(integer_x, integer_y)) -0.5);
    float yoffset = (rand2D(vec2(integer_x+1.0, integer_y)) - 0.5);
    float dotSize = 0.5 * fractionalMaxDotSize * max(0.25,rand2D(vec2(integer_x, integer_y+1.0)));

	
	vec2 truePos = vec2 (0.5 + xoffset * (1.0 - 2.0 * dotSize) , 0.5 + yoffset * (1.0 -2.0 * dotSize));

	float distance = length(truePos - vec2(fractional_x, fractional_y));
	
	return 1.0 - smoothstep (0.3 * dotSize, 1.0* dotSize, distance);
}

float DotNoise2D(in vec2 coord, in float wavelength, in float fractionalMaxDotSize)
{
return dotNoise2D(coord.x/wavelength, coord.y/wavelength, fractionalMaxDotSize);
}



float light_func (in float x, in float a, in float b, in float c, in float d, in float e)
{
x = x - 0.5;

// use the asymptotics to shorten computations
if (x > 30.0) {return e;}
if (x < -15.0) {return 0.0;}

return e / pow((1.0 + a * exp(-b * (x-c)) ),(1.0/d));
}


// a fade function for procedural scales which are smaller than a pixel

float detail_fade (in float scale, in float angle, in float dist)
{
float fade_dist = 2000.0 * scale * angle/max(pow(steepness,4.0), 0.1);

return 1.0 - smoothstep(0.5 * fade_dist, fade_dist, dist);
}


// this determines how light is attenuated in the distance
// physically this should be exp(-arg) but for technical reasons we use a sharper cutoff
// for distance > visibility

float fog_func (in float targ)
{


float fade_mix;

// for large altitude > 30 km, we switch to some component of quadratic distance fading to
// create the illusion of improved visibility range

targ = 1.25 * targ * smoothstep(0.04,0.06,targ); // need to sync with the distance to which terrain is drawn


if (alt < 30000.0)
	{return exp(-targ - targ * targ * targ * targ);}
else if (alt < 50000.0)
	{
	fade_mix = (alt - 30000.0)/20000.0;
	return fade_mix * exp(-targ*targ - pow(targ,4.0)) + (1.0 - fade_mix) * exp(-targ - pow(targ,4.0));	
	}
else 
	{
	return exp(- targ * targ - pow(targ,4.0));
	}

}

void main()
{


yprime_alt = diffuse_term.a;
//diffuse_term.a = 1.0;
mie_angle = gl_Color.a;
float effective_scattering = min(scattering, cloud_self_shading);

// distance to fragment
float dist = length(relPos);
// angle of view vector with horizon
float ct = dot(vec3(0.0, 0.0, 1.0), relPos)/dist;
// float altitude of fragment above sea level
float msl_altitude = (relPos.z + eye_alt);


  vec3 shadedFogColor = vec3(0.65, 0.67, 0.78);
// this is taken from default.frag
    vec3 n;
    float NdotL, NdotHV, fogFactor;
    vec4 color = gl_Color;
    color.a = 1.0;
    vec3 lightDir = gl_LightSource[0].position.xyz;
    vec3 halfVector = normalize(normalize(lightDir) + normalize(ecViewdir));
    vec4 texel;
    vec4 snow_texel;
    vec4 detail_texel;
    vec4 mix_texel;
	vec4 grain_texel;
	vec4 dot_texel;
	vec4 gradient_texel;
	vec4 foam_texel;
    vec4 fragColor;
    vec4 specular = vec4(0.0);
    float intensity;
    

// get noise at different wavelengths

// used:	5m, 5m gradient, 10m, 10m gradient: heightmap of the closeup terrain, 10m also snow
//		50m: detail texel
//		250m: detail texel
//		500m: distortion and overlay
// 		1500m: overlay, detail, dust, fog
//		2000m: overlay, detail, snow, fog

// Perlin noise

float noise_10m = Noise2D(rawPos.xy, 10.0);
float noise_5m = Noise2D(rawPos.xy ,5.0);
float noise_2m = Noise2D(rawPos.xy ,2.0); 
float noise_1m = Noise2D(rawPos.xy ,1.0); 
float noise_01m = Noise2D(rawPos.xy, 0.1);

float noisegrad_10m;
float noisegrad_5m;
float noisegrad_2m;
float noisegrad_1m;



float noise_25m = Noise2D(rawPos.xy, 25.0);
float noise_50m = Noise2D(rawPos.xy, 50.0);


float noise_250m = Noise2D(rawPos.xy,250.0);
float noise_500m = Noise2D(rawPos.xy, 500.0);
float noise_1500m = Noise2D(rawPos.xy, 1500.0);
float noise_2000m = Noise2D(rawPos.xy, 2000.0);

// dot noise

float dotnoise_2m = DotNoise2D(rawPos.xy, 2.0 * dot_size,0.5);
float dotnoise_10m = DotNoise2D(rawPos.xy, 10.0 * dot_size, 0.5);
float dotnoise_15m = DotNoise2D(rawPos.xy, 15.0 * dot_size, 0.33);

float dotnoisegrad_10m;

// get the texels


    float local_autumn_factor = texel.a;
    float distortion_factor = 1.0;
    vec2 stprime;
    int flag = 1;
    int mix_flag = 1;
    float noise_term;
    float snow_alpha;

    texel = texture2D(texture, gl_TexCoord[0].st);
	grain_texel = texture2D(grain_texture, gl_TexCoord[0].st * 25.0);
	gradient_texel = texture2D(gradient_texture, gl_TexCoord[0].st * 4.0);

	stprime = gl_TexCoord[0].st * 80.0;
	stprime = stprime + normalize(relPos).xy * 0.01 * (dotnoise_10m +  dotnoise_15m);
	dot_texel = texture2D(dot_texture, vec2 (stprime.y, stprime.x) );

	// we need to fade procedural structures when they get smaller than a single pixel, for this we need
	// to know under what angle we see the surface

    float view_angle = abs(dot(normalize(normal), normalize(ecViewdir)));
	float sfactor = sqrt(2.0 * (1.0-steepness)/0.03) + abs(ct)/0.15;

	// the snow texel is generated procedurally
    if (msl_altitude +500.0 > snowlevel)
	{
	snow_texel = vec4 (0.95, 0.95, 0.95, 1.0) * (0.9 + 0.1* noise_500m + 0.1* (1.0 - noise_10m) );
	snow_texel.r = snow_texel.r * (0.9 + 0.05 * (noise_10m + noise_5m));
	snow_texel.g = snow_texel.g * (0.9 + 0.05 * (noise_10m + noise_5m));
	snow_texel.a = 1.0;
	noise_term = 0.1 * (noise_500m-0.5) ;
	noise_term = noise_term + 0.2 * (noise_50m -0.5) * detail_fade(50.0, view_angle, 0.5*dist) ;
	noise_term = noise_term + 0.2 * (noise_25m -0.5) * detail_fade(25.0, view_angle, 0.5*dist) ;
	noise_term = noise_term + 0.3 * (noise_10m -0.5) * detail_fade(10.0, view_angle, 0.8*dist) ;
	noise_term = noise_term + 0.3 * (noise_5m - 0.5) * detail_fade(5.0, view_angle, dist);
	noise_term = noise_term + 0.15 * (noise_2m -0.5) *  detail_fade(2.0, view_angle, dist);
	noise_term = noise_term + 0.08 * (noise_1m -0.5) * detail_fade(1.0, view_angle, dist);
	snow_texel.a = snow_texel.a * 0.2+0.8* smoothstep(0.2,0.8, 0.3 +noise_term + snow_thickness_factor +0.0001*(msl_altitude -snowlevel) );
	}

	// the mixture/gradient texture
	mix_texel = texture2D(mix_texture, gl_TexCoord[0].st * 1.3);
	if (mix_texel.a <0.1) {mix_flag = 0;}

	// the hires overlay texture is loaded with parallax mapping
	
	stprime = vec2 (0.86*gl_TexCoord[0].s + 0.5*gl_TexCoord[0].t, 0.5*gl_TexCoord[0].s - 0.86*gl_TexCoord[0].t);
	distortion_factor = 0.97 + 0.06 * noise_500m;
	stprime = stprime * distortion_factor * 15.0;
	stprime = stprime + normalize(relPos).xy * 0.022 * (noise_10m + 0.5 * noise_5m +0.25 * noise_2m - 0.875 );
	
    detail_texel = texture2D(detail_texture, stprime);
	if (detail_texel.a <0.1) {flag = 0;}
	


// texture preparation according to detail level

// mix in hires texture patches

float dist_fact; 
float nSum;
float mix_factor;
   
   // first the second texture overlay
   // transition model 0: random patch overlay without any gradient information
   // transition model 1: only gradient-driven transitions, no randomness
   
   
   if (mix_flag == 1)
	{
	nSum =  0.18 * (2.0 * noise_2000m + 2.0 * noise_1500m + noise_500m);
	nSum = mix(nSum, 0.5, max(0.0, 2.0 * (transition_model - 0.5)));
	nSum = nSum + 0.4 * (1.0 -smoothstep(0.9,0.95, abs(steepness)+ 0.05 * (noise_50m - 0.5))) * min(1.0, 2.0 * transition_model);
	mix_factor = smoothstep(0.5, 0.54, nSum);
    texel = mix(texel, mix_texel, mix_factor);
	local_autumn_factor = texel.a;
	}
   
   // then the detail texture overlay	
    
	mix_factor = 0.0;
   if (dist < 40000.0)
   	{
	if (flag == 1)
		{
		dist_fact =  0.1 * smoothstep(15000.0,40000.0, dist) - 0.03 * (1.0 - smoothstep(500.0,5000.0, dist));
		nSum = ((1.0 -noise_2000m) + noise_1500m + 2.0 * noise_250m  +noise_50m)/5.0;
        nSum = nSum - 0.08 * (1.0 -smoothstep(0.9,0.95, abs(steepness)));		
		mix_factor = smoothstep(0.47, 0.54, nSum +hires_overlay_bias- dist_fact);
		if (mix_factor > 0.8) {mix_factor = 0.8;}
		texel =  mix(texel, detail_texel,mix_factor);				
		}
	}
	
	// rock for very steep gradients
	
	if (gradient_texel.a > 0.0)
		{
		texel = mix(texel, gradient_texel, 1.0 - smoothstep(0.75,0.8,abs(steepness)+ 0.00002* msl_altitude + 0.05 * (noise_50m - 0.5)));
		local_autumn_factor = texel.a;
		}
   
   // the dot vegetation texture overlay
   
   texel.rgb = mix(texel.rgb, dot_texel.rgb, dot_texel.a * (dotnoise_10m + dotnoise_15m) * detail_fade(1.0 * (dot_size * (1.0 +0.1*dot_size)), view_angle,dist));
   texel.rgb = mix(texel.rgb, dot_texel.rgb, dot_texel.a * dotnoise_2m * detail_fade(0.1 * dot_size, view_angle,dist));

   
   // then the grain texture overlay
   
   texel.rgb = mix(texel.rgb, grain_texel.rgb, grain_strength * grain_texel.a * (1.0 - mix_factor) * (1.0-smoothstep(2000.0,5000.0, dist)));

   // for really hires, add procedural noise overlay
   texel.rgb = texel.rgb * (1.0 + 0.4 * (noise_01m-0.5) * detail_fade(0.1, view_angle, dist)) ;

// autumn colors

float autumn_factor = season * 2.0 * (1.0 - local_autumn_factor) ;


texel.r = min(1.0, (1.0 + 2.5 * autumn_factor) * texel.r);
texel.g = texel.g;
texel.b = max(0.0, (1.0 - 4.0 * autumn_factor) *  texel.b);


if (local_autumn_factor < 1.0)
	{
	intensity = length(texel.rgb) * (1.0 - 0.5 * smoothstep(1.1,2.0,season));
	texel.rgb = intensity * normalize(mix(texel.rgb, vec3(0.23,0.17,0.08), smoothstep(1.1,2.0, season)));
	}

//const vec4 dust_color  = vec4 (0.76, 0.71, 0.56, 1.0);
const vec4 dust_color  = vec4 (0.76, 0.65, 0.45, 1.0);
const vec4 lichen_color = vec4 (0.17, 0.20, 0.06, 1.0);

// mix vegetation
float gradient_factor = smoothstep(0.5, 1.0, steepness);
texel = mix(texel, lichen_color, gradient_factor * (0.4 * lichen_cover_factor +  0.8 * lichen_cover_factor * 0.5 * (noise_10m + (1.0 - noise_5m)))  );
// mix dust
texel = mix(texel, dust_color, clamp(0.5 * dust_cover_factor *dust_resistance + 3.0 * dust_cover_factor * dust_resistance *(((noise_1500m - 0.5) * 0.125)+0.125 ),0.0, 1.0) );
// mix snow
float snow_mix_factor = 0.0;
if (msl_altitude +500.0 > snowlevel)
	{
   	snow_alpha = smoothstep(0.75, 0.85, abs(steepness));
	snow_mix_factor = snow_texel.a* smoothstep(snowlevel, snowlevel+200.0,  snow_alpha * msl_altitude+ (noise_2000m + 0.1 * noise_10m -0.55) *400.0);
	texel = mix(texel, snow_texel, snow_mix_factor);
	}
	



// get distribution of water when terrain is wet

float combined_wetness = min(1.0, wetness + intrinsic_wetness);
float water_threshold1;
float water_threshold2;
float water_factor =0.0;


if ((dist < 5000.0)&& (quality_level > 3) && (combined_wetness>0.0))
		{
		water_threshold1 = 1.0-0.5* combined_wetness;
		water_threshold2 = 1.0 - 0.3 * combined_wetness;
		water_factor = smoothstep(water_threshold1, water_threshold2 ,   (0.3 * (2.0 * (1.0-noise_10m) + (1.0 -noise_5m)) *   (1.0 - smoothstep(2000.0, 5000.0, dist))) - 5.0 * (1.0 -steepness));
	}

// darken wet terrain

    texel.rgb = texel.rgb * (1.0 - 0.6 * combined_wetness);
	
// surf - terrain is too bad...
/*	foam_texel.rgb =vec3 (1.0, 1.0, 1.0);
	foam_texel.rg = 0.7 * foam_texel.rg +0.3 * noise_2m * foam_texel.rg;
	float surf_strength = 1.0 + windspeed/5.0;
	float surf_sine = sin(osg_SimulationTime+5.0*noise_25m);
	float surf_steepcorr = 1.0 -smoothstep(0.99,1.01,abs(steepness));
	float surf_alt = (relPos.z+eye_alt )  - 20.0 * surf_steepcorr ;//+ noise_10m * surf_steepcorr
	texel.rgb = mix(foam_texel.rgb, texel.rgb, smoothstep((0.3 +0.3*surf_strength+ surf_sine) * surf_steepcorr-20.0, (0.3+ surf_strength + surf_sine) * surf_steepcorr-19.0, surf_alt));
*/

// light computations


    vec4 light_specular = gl_LightSource[0].specular;

    // If gl_Color.a == 0, this is a back-facing polygon and the
    // normal should be reversed.
    //n = (2.0 * gl_Color.a - 1.0) * normal;
    n = normal;//vec3 (nvec.x, nvec.y, sqrt(1.0 -pow(nvec.x,2.0) - pow(nvec.y,2.0) ));
    n = normalize(n);

    NdotL = dot(n, lightDir);
	
	noisegrad_10m = (noise_10m - Noise2D(rawPos.xy+ 0.05 * normalize(lightDir.xy),10.0))/0.05;
	noisegrad_5m = (noise_5m - Noise2D(rawPos.xy+ 0.05 * normalize(lightDir.xy),5.0))/0.05;
	noisegrad_2m = (noise_2m - Noise2D(rawPos.xy+ 0.05 * normalize(lightDir.xy),2.0))/0.05;
	noisegrad_1m = (noise_1m - Noise2D(rawPos.xy+ 0.05 * normalize(lightDir.xy),1.0))/0.05;

	dotnoisegrad_10m = (dotnoise_10m - DotNoise2D(rawPos.xy+ 0.05 * normalize(lightDir.xy),10.0 * dot_size,0.5))/0.05;

	
	NdotL = NdotL + (noisegrad_10m * detail_fade(10.0, view_angle,dist) + 0.5* noisegrad_5m * detail_fade(5.0, view_angle,dist)) * mix_factor/0.8;
	NdotL = NdotL + 0.15 * noisegrad_2m * mix_factor/0.8 * detail_fade(2.0,view_angle,dist);
	NdotL = NdotL + 0.1 * noisegrad_2m * detail_fade(2.0,view_angle,dist);
	NdotL = NdotL + 0.05 * noisegrad_1m * detail_fade(1.0, view_angle,dist);
	NdotL = NdotL + (1.0-snow_mix_factor) * 0.3* dot_texel.a * (0.5* dotnoisegrad_10m * detail_fade(1.0 * dot_size, view_angle, dist) +0.5 * dotnoisegrad_10m * noise_01m * detail_fade(0.1, view_angle, dist)) ;
	
    if (NdotL > 0.0) {
        color += diffuse_term * NdotL;
        NdotHV = max(dot(n, halfVector), 0.0);
        if (gl_FrontMaterial.shininess > 0.0)
            specular.rgb = ((gl_FrontMaterial.specular.rgb + (water_factor * vec3 (1.0, 1.0, 1.0)))
                            * light_specular.rgb
                            * pow(NdotHV, gl_FrontMaterial.shininess + (20.0 * water_factor)));
    }
    color.a = 1.0;//diffuse_term.a;
    // This shouldn't be necessary, but our lighting becomes very
    // saturated. Clamping the color before modulating by the texture
    // is closer to what the OpenGL fixed function pipeline does.
    color = clamp(color, 0.0, 1.0);




    fragColor = color * texel + specular;

// here comes the terrain haze model


float delta_z = hazeLayerAltitude - eye_alt;

if (dist > max(40.0, 0.04 * min(visibility,avisibility))) 
//if ((gl_FragCoord.y > ylimit) || (gl_FragCoord.x < zlimit1) || (gl_FragCoord.x > zlimit2))
//if (dist > 40.0)
{

alt = eye_alt;


float transmission;
float vAltitude;
float delta_zv;
float H;
float distance_in_layer;
float transmission_arg;




// we solve the geometry what part of the light path is attenuated normally and what is through the haze layer

if (delta_z > 0.0) // we're inside the layer
	{
	if (ct < 0.0) // we look down 
		{
		distance_in_layer = dist;
		vAltitude = min(distance_in_layer,min(visibility, avisibility)) * ct;
  		delta_zv = delta_z - vAltitude;
		}
	else 	// we may look through upper layer edge
		{
		H = dist * ct;
		if (H > delta_z) {distance_in_layer = dist/H * delta_z;}
		else {distance_in_layer = dist;}
		vAltitude = min(distance_in_layer,visibility) * ct;
  		delta_zv = delta_z - vAltitude;	
		}
	}
  else // we see the layer from above, delta_z < 0.0
	{	
	H = dist * -ct;
	if (H  < (-delta_z)) // we don't see into the layer at all, aloft visibility is the only fading
		{
		distance_in_layer = 0.0;
		delta_zv = 0.0;
		}		
	else
		{
		vAltitude = H + delta_z;
		distance_in_layer = vAltitude/H * dist; 
		vAltitude = min(distance_in_layer,visibility) * (-ct);
		delta_zv = vAltitude;
		} 
	}
	

// ground haze cannot be thinner than aloft visibility in the model,
// so we need to use aloft visibility otherwise


transmission_arg = (dist-distance_in_layer)/avisibility;


float eqColorFactor;



if (visibility < avisibility)
	{
	if (quality_level > 3)
		{
		transmission_arg = transmission_arg + (distance_in_layer/(1.0 * visibility + 1.0 * visibility * fogstructure * 0.06 * (noise_1500m + noise_2000m -1.0) ));

		}
	else
		{
		transmission_arg = transmission_arg + (distance_in_layer/visibility);
		}
	// this combines the Weber-Fechner intensity
	eqColorFactor = 1.0 - 0.1 * delta_zv/visibility - (1.0 - effective_scattering);

	}
else 
	{
	if (quality_level > 3)
		{
		transmission_arg = transmission_arg + (distance_in_layer/(1.0 * avisibility + 1.0 * avisibility * fogstructure * 0.06 * (noise_1500m + noise_2000m  - 1.0) ));
		}
	else
		{
		transmission_arg = transmission_arg + (distance_in_layer/avisibility);
		}
	// this combines the Weber-Fechner intensity
	eqColorFactor = 1.0 - 0.1 * delta_zv/avisibility - (1.0 - effective_scattering);
	}



transmission =  fog_func(transmission_arg);

// there's always residual intensity, we should never be driven to zero
if (eqColorFactor < 0.2) eqColorFactor = 0.2;


float lightArg = (terminator-yprime_alt)/100000.0;

vec3 hazeColor;

hazeColor.b = light_func(lightArg, 1.330e-05, 0.264, 2.527, 1.08e-05, 1.0);
hazeColor.g = light_func(lightArg, 3.931e-06, 0.264, 3.827, 7.93e-06, 1.0);
hazeColor.r = light_func(lightArg, 8.305e-06, 0.161, 3.827, 3.04e-05, 1.0);


// now dim the light for haze
eShade = 0.9 * smoothstep(terminator_width+ terminator, -terminator_width + terminator, yprime_alt) + 0.1;

// Mie-like factor

	if (lightArg < 10.0)
		{
		intensity = length(hazeColor);
		float mie_magnitude = 0.5 * smoothstep(350000.0, 150000.0, terminator-sqrt(2.0 * EarthRadius * terrain_alt));
		hazeColor = intensity * ((1.0 - mie_magnitude) + mie_magnitude * mie_angle) * normalize(mix(hazeColor,  vec3 (0.5, 0.58, 0.65), mie_magnitude * (0.5 - 0.5 * mie_angle)) ); 
		}

intensity = length(hazeColor);

if (intensity > 0.0) // this needs to be a condition, because otherwise hazeColor doesn't come out correctly
{
	

	// high altitude desaturation of the haze color
	hazeColor = intensity * normalize (mix(hazeColor, intensity * vec3 (1.0,1.0,1.0), 0.7* smoothstep(5000.0, 50000.0, alt)));

	// blue hue of haze
	hazeColor.x = hazeColor.x * 0.83;
	hazeColor.y = hazeColor.y * 0.9; 


	// additional blue in indirect light
	float fade_out = max(0.65 - 0.3 *overcast, 0.45);
	intensity = length(hazeColor);
	hazeColor = intensity * normalize(mix(hazeColor,  1.5* shadedFogColor, 1.0 -smoothstep(0.25, fade_out,eShade) )); 

	// change haze color to blue hue for strong fogging
	hazeColor = intensity * normalize(mix(hazeColor,  shadedFogColor, (1.0-smoothstep(0.5,0.9,eqColorFactor)))); 

	

	// reduce haze intensity when looking at shaded surfaces, only in terminator region
	float shadow = mix( min(1.0 + dot(n,lightDir),1.0), 1.0, 1.0-smoothstep(0.1, 0.4, transmission));
	hazeColor = mix(shadow * hazeColor, hazeColor, 0.3 + 0.7* smoothstep(250000.0, 400000.0, terminator));
	}




fragColor.rgb = mix(eqColorFactor * hazeColor * eShade , fragColor.rgb,transmission);


gl_FragColor = fragColor;


}
else // if dist < threshold no fogging at all 
{
gl_FragColor =  fragColor;
}



}

