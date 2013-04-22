// -*- mode: C; -*-
// Licence: GPL v2
// Author: Frederic Bouvier.
//  Adapted from the paper by F. Policarpo et al. : Real-time Relief Mapping on Arbitrary Polygonal Surfaces
//  Adapted from the paper and sources by M. Drobot in GPU Pro : Quadtree Displacement Mapping with Height Blending

#version 120

#extension GL_ATI_shader_texture_lod : enable
#extension GL_ARB_shader_texture_lod : enable

#define TEXTURE_MIP_LEVELS 10
#define TEXTURE_PIX_COUNT  1024 //pow(2,TEXTURE_MIP_LEVELS)
#define BINARY_SEARCH_COUNT 10
#define BILINEAR_SMOOTH_FACTOR 2.0

varying vec3  worldPos;
varying vec4  ecPosition;
varying vec3  VNormal;
varying vec3  VTangent;
//varying vec3  VBinormal;
//varying vec3  Normal;
varying vec4  constantColor;
varying vec3  light_diffuse;
varying vec3 relPos;

varying float yprime_alt;
varying float mie_angle;
//varying float steepness;

//uniform sampler3D NoiseTex;
uniform sampler2D BaseTex;
uniform sampler2D NormalTex;
uniform sampler2D QDMTex;
uniform float depth_factor;
uniform float tile_size;
uniform float quality_level;
uniform float visibility;
uniform float avisibility;
uniform float scattering;
uniform float terminator;
uniform float terrain_alt; 
uniform float hazeLayerAltitude;
uniform float overcast;
uniform float eye_alt;
uniform float mysnowlevel;
uniform float dust_cover_factor;
uniform float wetness;
uniform float fogstructure;
uniform float cloud_self_shading;
uniform vec3 night_color;

const float scale = 1.0;
int linear_search_steps = 10;
int GlobalIterationCount = 0;
int gIterationCap = 64;

const float EarthRadius = 5800000.0;
const float terminator_width = 200000.0;

float alt;
float eShade;


float rand2D(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand3D(in vec3 co){
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,144.7272))) * 43758.5453);
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


float interpolatedNoise3D(in float x, in float y, in float z)
{
      float integer_x    = x - fract(x);
      float fractional_x = x - integer_x;

      float integer_y    = y - fract(y);
      float fractional_y = y - integer_y;

      float integer_z    = z - fract(z);
      float fractional_z = z - integer_z;

      float v1 = rand3D(vec3(integer_x, integer_y, integer_z));
      float v2 = rand3D(vec3(integer_x+1.0, integer_y, integer_z));
      float v3 = rand3D(vec3(integer_x, integer_y+1.0, integer_z));
      float v4 = rand3D(vec3(integer_x+1.0, integer_y +1.0, integer_z));

      float v5 = rand3D(vec3(integer_x, integer_y, integer_z+1.0));
      float v6 = rand3D(vec3(integer_x+1.0, integer_y, integer_z+1.0));
      float v7 = rand3D(vec3(integer_x, integer_y+1.0, integer_z+1.0));
      float v8 = rand3D(vec3(integer_x+1.0, integer_y +1.0, integer_z+1.0));


      float i1 = simple_interpolate(v1,v5, fractional_z);
      float i2 = simple_interpolate(v2,v6, fractional_z);
      float i3 = simple_interpolate(v3,v7, fractional_z);
      float i4 = simple_interpolate(v4,v8, fractional_z);

      float ii1 = simple_interpolate(i1,i2,fractional_x);
      float ii2 = simple_interpolate(i3,i4,fractional_x);
 

      return simple_interpolate(ii1 , ii2 , fractional_y);
}

float Noise2D(in vec2 coord, in float wavelength)
{
return interpolatedNoise2D(coord.x/wavelength, coord.y/wavelength);

}

float Noise3D(in vec3 coord, in float wavelength)
{
return interpolatedNoise3D(coord.x/wavelength, coord.y/wavelength, coord.z/wavelength);
}


float light_func (in float x, in float a, in float b, in float c, in float d, in float e)
{
x = x - 0.5;

// use the asymptotics to shorten computations
if (x > 30.0) {return e;}
if (x < -15.0) {return 0.0;}

return e / pow((1.0 + a * exp(-b * (x-c)) ),(1.0/d));
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




void QDM(inout vec3 p, inout vec3 v)
{
    const int MAX_LEVEL = TEXTURE_MIP_LEVELS;
    const float NODE_COUNT = TEXTURE_PIX_COUNT;
    const float TEXEL_SPAN_HALF = 1.0 / NODE_COUNT / 2.0;

    float fDeltaNC = TEXEL_SPAN_HALF * depth_factor;

    vec3 p2 = p;
    float level = MAX_LEVEL;
    vec2 dirSign = (sign(v.xy) + 1.0) * 0.5;
    GlobalIterationCount = 0;
    float d = 0.0;

    while (level >= 0.0 && GlobalIterationCount < gIterationCap)
    {
        vec4 uv = vec4(p2.xyz, level);
        d = texture2DLod(QDMTex, uv.xy, uv.w).w;

        if (d > p2.z)
        {
            //predictive point of ray traversal
            vec3 tmpP2 = p + v * d;

            //current node count
            float nodeCount = pow(2.0, (MAX_LEVEL - level));
            //current and predictive node ID
            vec4 nodeID = floor(vec4(p2.xy, tmpP2.xy)*nodeCount);

            //check if we are crossing the current cell
            if (nodeID.x != nodeID.z || nodeID.y != nodeID.w)
            {
                //calculate distance to nearest bound
                vec2 a = p2.xy - p.xy;
                vec2 p3 = (nodeID.xy + dirSign) / nodeCount;
                vec2 b = p3.xy - p.xy;

                vec2 dNC = (b.xy * p2.z) / a.xy;
                //take the nearest cell
                d = min(d,min(dNC.x, dNC.y))+fDeltaNC;

                level++;

                //use additional convergence speed-up
                #ifdef USE_QDM_ASCEND_INTERVAL
                if(frac(level*0.5) > EPSILON)
                  level++;
                #elseif USE_QDM_ASCEND_CONST
                 level++;
                #endif
            }
            p2 = p + v * d;
        }
        level--;
        GlobalIterationCount++;
    }

    //
    // Manual Bilinear filtering
    //
    float rayLength =  length(p2.xy - p.xy) + fDeltaNC;

    float dA = p2.z * (rayLength - BILINEAR_SMOOTH_FACTOR * TEXEL_SPAN_HALF) / rayLength;
    float dB = p2.z * (rayLength + BILINEAR_SMOOTH_FACTOR * TEXEL_SPAN_HALF) / rayLength;

    vec4 p2a = vec4(p + v * dA, 0.0);
    vec4 p2b = vec4(p + v * dB, 0.0);
    dA = texture2DLod(NormalTex, p2a.xy, p2a.w).w;
    dB = texture2DLod(NormalTex, p2b.xy, p2b.w).w;

    dA = abs(p2a.z - dA);
    dB = abs(p2b.z - dB);

    p2 = mix(p2a.xyz, p2b.xyz, dA / (dA + dB));

    p = p2;
}

float ray_intersect_QDM(vec2 dp, vec2 ds)
{
    vec3 p = vec3( dp, 0.0 );
    vec3 v = vec3( ds, 1.0 );
    QDM( p, v );
    return p.z;
}

float ray_intersect_relief(vec2 dp, vec2 ds)
{
    float size = 1.0 / float(linear_search_steps);
    float depth = 0.0;
    float best_depth = 1.0;

    for(int i = 0; i < linear_search_steps - 1; ++i)
    {
        depth += size;
        float t = step(0.95, texture2D(NormalTex, dp + ds * depth).a);
        if(best_depth > 0.996)
            if(depth >= t)
                best_depth = depth;
    }
    depth = best_depth;

    const int binary_search_steps = 5;

    for(int i = 0; i < binary_search_steps; ++i)
    {
        size *= 0.5;
        float t = step(0.95, texture2D(NormalTex, dp + ds * depth).a);
        if(depth >= t)
        {
            best_depth = depth;
            depth -= 2.0 * size;
        }
        depth += size;
    }

    return(best_depth);
}

float ray_intersect(vec2 dp, vec2 ds)
{
    if ( quality_level >= 4.0 )
        return ray_intersect_QDM( dp, ds );
    else
        return ray_intersect_relief( dp, ds );
}

void main (void)
{
    if ( quality_level >= 3.0 ) {
        linear_search_steps = 20;
    }
    vec3 shadedFogColor = vec3(0.65, 0.67, 0.78);
    float effective_scattering = min(scattering, cloud_self_shading);
    vec3 normal = normalize(VNormal);
    vec3 tangent = normalize(VTangent);
    //vec3 binormal = normalize(VBinormal);
    vec3 binormal = normalize(cross(normal, tangent));
    vec3 ecPos3 = ecPosition.xyz / ecPosition.w;
    vec3 V = normalize(ecPos3);
    vec3 s = vec3(dot(V, tangent), dot(V, binormal), dot(normal, -V));
    vec2 ds = s.xy * depth_factor / s.z;
    vec2 dp = gl_TexCoord[0].st - ds;
    float d = ray_intersect(dp, ds);

    vec2 uv = dp + ds * d;
    vec3 N = texture2D(NormalTex, uv).xyz * 2.0 - 1.0;


    float emis = N.z;
    N.z = sqrt(1.0 - min(1.0,dot(N.xy, N.xy)));
    float Nz = N.z;
    N = normalize(N.x * tangent + N.y * binormal + N.z * normal);

    vec3 l = gl_LightSource[0].position.xyz;
    vec3 diffuse = gl_Color.rgb * max(0.0, dot(N, l));
    float shadow_factor = 1.0;

    // Shadow
    if ( quality_level >= 2.0 ) {
        dp += ds * d;
        vec3 sl = normalize( vec3( dot( l, tangent ), dot( l, binormal ), dot( -l, normal ) ) );
        ds = sl.xy * depth_factor / sl.z;
        dp -= ds * d;
        float dl = ray_intersect(dp, ds);
        if ( dl < d - 0.05 )
            shadow_factor = dot( constantColor.xyz, vec3( 1.0, 1.0, 1.0 ) ) * 0.25;
    }
    // end shadow

    vec4 ambient_light = constantColor + vec4 (light_diffuse,1.0) * vec4(diffuse, 1.0);
    float reflectance = ambient_light.r * 0.3 + ambient_light.g * 0.59 + ambient_light.b * 0.11;
    if ( shadow_factor < 1.0 )
        ambient_light = constantColor + vec4(light_diffuse,1.0) * shadow_factor * vec4(diffuse, 1.0);
    float emission_factor = (1.0 - smoothstep(0.15, 0.25, reflectance)) * emis;
    vec4 tc = texture2D(BaseTex, uv);
    emission_factor *= 0.5*pow(tc.r+0.8*tc.g+0.2*tc.b, 2.0) -0.2;
    ambient_light += (emission_factor * vec4(night_color, 0.0));

   

    vec4 finalColor = texture2D(BaseTex, uv);
    

// texel postprocessing by shader effects


// dust effect

vec4 dust_color;


float noise_1500m = Noise3D(worldPos.xyz,1500.0);
float noise_2000m = Noise3D(worldPos.xyz,2000.0);

if (quality_level > 2)
	{
	// mix dust
    	dust_color = vec4 (0.76, 0.71, 0.56, 1.0);

    	finalColor = mix(finalColor, dust_color, clamp(0.5 * dust_cover_factor + 3.0 * dust_cover_factor * (((noise_1500m - 0.5) * 0.125)+0.125 ),0.0, 1.0) );
	}


// darken wet terrain

    finalColor.rgb = finalColor.rgb * (1.0 - 0.6 * wetness);

    finalColor *= ambient_light;

    vec4 p = vec4( ecPos3 + tile_size * V * (d-1.0) * depth_factor / s.z, 1.0 );

    //finalColor.rgb = fog_Func(finalColor.rgb, fogType);


// here comes the terrain haze model

float dist = length(relPos);
float delta_z = hazeLayerAltitude - eye_alt;


if (dist > max(40.0, 0.04 * min(visibility,avisibility))) 
{

alt = eye_alt;


float transmission;
float vAltitude;
float delta_zv;
float H;
float distance_in_layer;
float transmission_arg;
float intensity;
vec3 lightDir = gl_LightSource[0].position.xyz;

// angle with horizon
float ct = dot(vec3(0.0, 0.0, 1.0), relPos)/dist;


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
	// Mie-like factor

	if (lightArg < 10.0)
		{
		float mie_magnitude = 0.5 * smoothstep(350000.0, 150000.0, terminator-sqrt(2.0 * EarthRadius * terrain_alt));
		hazeColor = intensity * ((1.0 - mie_magnitude) + mie_magnitude * mie_angle) * normalize(mix(hazeColor,  vec3 (0.5, 0.58, 0.65), 	mie_magnitude * (0.5 - 0.5 * mie_angle)) ); 
		}

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

	float shadow = mix( min(1.0 + dot(VNormal,lightDir),1.0), 1.0, 1.0-smoothstep(0.1, 0.4, transmission));
	hazeColor = mix(shadow * hazeColor, hazeColor, 0.3 + 0.7* smoothstep(250000.0, 400000.0, terminator));
	}



finalColor.xyz = mix(eqColorFactor * hazeColor * eShade, finalColor.xyz,transmission);
gl_FragColor = finalColor;

}
else // if dist < threshold no fogging at all 
{
gl_FragColor = finalColor;
}


   // gl_FragColor = finalColor;

    if (dot(normal,-V) > 0.1) {
        vec4 iproj = gl_ProjectionMatrix * p;
        iproj /= iproj.w;
        gl_FragDepth = (iproj.z+1.0)/2.0;
    } else {
        gl_FragDepth = gl_FragCoord.z;
    }
}
