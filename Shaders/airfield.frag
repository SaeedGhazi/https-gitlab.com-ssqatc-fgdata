
// -*-C++-*-

// written by Thorsten Renk, Oct 2011, based on default.frag
// Ambient term comes in gl_Color.rgb.
varying vec4 diffuse_term;
varying vec3 normal;
varying vec3 relPos;
varying vec2 rawPos;
varying vec3 ecViewdir;


uniform sampler2D texture;
uniform sampler2D snow_texture;

varying float steepness;


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
uniform float fogstructure;
uniform float cloud_self_shading;
uniform float snow_thickness_factor;
uniform float ylimit;
uniform float zlimit1;
uniform float zlimit2;
uniform float wetness;
uniform int quality_level;
uniform int tquality_level;
uniform int cloud_shadow_flag;

const float EarthRadius = 5800000.0;
const float terminator_width = 200000.0;

float alt;
float eShade;
float yprime_alt;
float mie_angle;

float shadow_func (in float x, in float y, in float noise, in float dist);


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
//return mix(a,b,x); 
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



float light_func (in float x, in float a, in float b, in float c, in float d, in float e)
{
x = x - 0.5;

// use the asymptotics to shorten computations
if (x > 30.0) {return e;}
if (x < -15.0) {return 0.0;}

return e / pow((1.0 + a * exp(-b * (x-c)) ),(1.0/d));
}

float detail_fade (in float scale, in float angle, in float dist)
{
float fade_dist = 4000.0 * scale * angle;

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

//if ((gl_FragCoord.y < ylimit) && (gl_FragCoord.x > zlimit1) && (gl_FragCoord.x < zlimit2))
//	{discard;}


float effective_scattering = min(scattering, cloud_self_shading);
yprime_alt = diffuse_term.a;
//diffuse_term.a = 1.0;
mie_angle = gl_Color.a;

vec3 shadedFogColor = vec3(0.65, 0.67, 0.78);

float dist = length(relPos);
float ct = dot(vec3(0.0, 0.0, 1.0), relPos)/dist;

// this is taken from default.frag
    vec3 n;
    float NdotL, NdotHV, fogFactor;
    vec4 color = gl_Color;
    color.a = 1.0;
    vec3 lightDir = gl_LightSource[0].position.xyz;
    vec3 halfVector;
    if (quality_level<6)
	{halfVector = gl_LightSource[0].halfVector.xyz;}
    else
	{halfVector = normalize(normalize(lightDir) + normalize(ecViewdir));}
    vec4 texel;
    vec4 snow_texel;
    vec4 detail_texel;
    vec4 mix_texel;
    vec4 fragColor;
    vec4 specular = vec4(0.0);
    float intensity;
    

// get noise at different wavelengths

// used:	5m, 5m gradient, 10m, 10m gradient: heightmap of the closeup terrain, 10m also snow
//		500m: distortion and overlay
// 		1500m: overlay, detail, dust, fog
//		2000m: overlay, detail, snow, fog

float noise_01m; 
float noise_1m = Noise2D(rawPos.xy, 1.0); 
float noise_2m;

float noise_10m = Noise2D(rawPos.xy, 10.0);
float noise_5m = Noise2D(rawPos.xy,5.0);



float noise_50m = Noise2D(rawPos.xy, 500.0);
float noise_1500m = Noise2D(rawPos.xy, 1500.0);
float noise_2000m = Noise2D(rawPos.xy, 2000.0);





//


// get the texels

    texel = texture2D(texture, gl_TexCoord[0].st * 5.0); 

    float distortion_factor = 1.0;
    float noise_term;
    float snow_alpha;
   
    if (quality_level > 3)
	{
	//snow_texel = texture2D(snow_texture, gl_TexCoord[0].st);
	float sfactor;
	snow_texel = vec4 (0.95, 0.95, 0.95, 1.0) * (0.9 + 0.1* noise_50m + 0.1* (1.0 - noise_10m) );
	snow_texel.a = 1.0;
	noise_term = 0.1 * (noise_50m-0.5);
	sfactor = 1.0;//sqrt(2.0 * (1.0-steepness)/0.03) + abs(ct)/0.15;
	noise_term = noise_term + 0.2 * (noise_10m -0.5) * (1.0 - smoothstep(10000.0*sfactor, 16000.0*sfactor, dist)  ) ;
	noise_term = noise_term + 0.3 * (noise_5m -0.5) * (1.0 - smoothstep(1200.0 * sfactor, 2000.0 * sfactor, dist)  ) ;
	if (dist < 1000.0*sfactor){ noise_term = noise_term + 0.3 * (noise_1m -0.5) * (1.0 - smoothstep(500.0 * sfactor, 1000.0 *sfactor, dist)  );}
	snow_texel.a = snow_texel.a * 0.2+0.8* smoothstep(0.2,0.8, 0.3 +noise_term + snow_thickness_factor +0.0001*(relPos.z +eye_alt -snowlevel) );
	}

   



float dist_fact; 
float nSum;
float mix_factor;
float water_factor = 0.0;
float water_threshold1;
float water_threshold2;


// get distribution of water when terrain is wet

if ((dist < 3000.0)&& (quality_level > 3) && (wetness>0.0))
		{
		water_threshold1 = 1.0-0.5* wetness;
		water_threshold2 = 1.0 - 0.3 * wetness;
		water_factor = smoothstep(water_threshold1, water_threshold2 , 0.5 * (noise_5m + (1.0 -noise_1m))) *   (1.0 - smoothstep(1000.0, 3000.0, dist));
	}


// color and shade variation of the grass

	float nfact_1m = 3.0 * (noise_1m - 0.5) * detail_fade(1.0, abs(ct),dist);//* (1.0 - smoothstep(3000.0, 6000.0, dist/ abs(ct)));
	float nfact_5m = 2.0 * (noise_5m - 0.5) * detail_fade(2.0, abs(ct),dist);;
	float nfact_10m = 1.0 * (noise_10m - 0.5);
	texel.rgb = texel.rgb * (0.85 + 0.1 * (nfact_1m * detail_fade(1.0, abs(ct),dist) + nfact_5m + nfact_10m));
    texel.r = texel.r * (1.0 + 0.14 * smoothstep(0.5,0.7, 0.33*(2.0 * noise_10m + (1.0-noise_5m))));


vec4 dust_color;

if (quality_level > 3)
	{
	// mix dust
    	dust_color = vec4 (0.76, 0.71, 0.56, 1.0);
    	texel = mix(texel, dust_color, clamp(0.5 * dust_cover_factor + 3.0 * dust_cover_factor * (((noise_1500m - 0.5) * 0.125)+0.125 ),0.0, 1.0) );

    // mix snow
   	snow_alpha = smoothstep(0.75, 0.85, abs(steepness));
	texel = mix(texel, snow_texel, snow_texel.a * smoothstep(snowlevel, snowlevel+200.0, snow_alpha * (relPos.z + eye_alt)+ (noise_2000m + 0.1 * noise_10m -0.55) *400.0));
	}


// darken grass when wet
    texel.rgb = texel.rgb * (1.0 - 0.6 * wetness);



// light computations


    vec4 light_specular = gl_LightSource[0].specular ;
  
    // If gl_Color.a == 0, this is a back-facing polygon and the
    // normal should be reversed.
    //n = (2.0 * gl_Color.a - 1.0) * normal;
    //n = normalize(n);
    n = normal;//vec3 (nvec.x, nvec.y, sqrt(1.0 -pow(nvec.x,2.0) - pow(nvec.y,2.0) ));
    n = normalize(n);

    NdotL = dot(n, lightDir);
	if ((dist < 200.0) && (quality_level > 4))
		{
		noise_01m = Noise2D(rawPos.xy,0.1);
		NdotL = NdotL + 0.8 * (noise_01m-0.5) *  detail_fade(0.1, abs(ct),dist) * (1.0 - water_factor);
		}
	
    if (NdotL > 0.0) {
   	if (cloud_shadow_flag == 1) 
		{NdotL = NdotL * shadow_func(relPos.x, relPos.y,  noise_1500m, dist);}
        color += diffuse_term * NdotL;
	

        NdotHV = max(dot(n, halfVector), 0.0);
	
        if (gl_FrontMaterial.shininess > 0.0)
            specular.rgb = ((gl_FrontMaterial.specular.rgb + (water_factor * vec3 (1.0, 1.0, 1.0)))
                            * light_specular.rgb 
                            * pow(NdotHV, (gl_FrontMaterial.shininess + 20.0 * water_factor)));
    }
    color.a = 1.0;
    // This shouldn't be necessary, but our lighting becomes very
    // saturated. Clamping the color before modulating by the texture
    // is closer to what the OpenGL fixed function pipeline does.
    color = clamp(color, 0.0, 1.0);




    fragColor = color * texel + specular;

// here comes the terrain haze model


float delta_z = hazeLayerAltitude - eye_alt;

if (dist > 0.04 * min(visibility,avisibility)) 
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
	{intensity = length(hazeColor);
	float mie_magnitude = 0.5 * smoothstep(350000.0, 150000.0, terminator-sqrt(2.0 * EarthRadius * terrain_alt));
	hazeColor = intensity * ((1.0 - mie_magnitude) + mie_magnitude * mie_angle) * normalize(mix(hazeColor,  vec3 (0.5, 0.58, 0.65), mie_magnitude * (0.5 - 0.5 * mie_angle)) ); 
	}

// high altitude desaturation of the haze color

intensity = length(hazeColor);
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



hazeColor = clamp(hazeColor,0.0,1.0);
fragColor.xyz = mix(eqColorFactor * hazeColor * eShade, fragColor.xyz,transmission);


gl_FragColor = fragColor;


}
else // if dist < threshold no fogging at all 
{
gl_FragColor = fragColor;
}



}
