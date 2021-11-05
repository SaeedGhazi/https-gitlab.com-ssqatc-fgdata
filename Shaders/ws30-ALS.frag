// WS30 FRAGMENT SHADER

// -*-C++-*-
#version 130
#extension GL_EXT_texture_array : enable

// written by Thorsten Renk, Oct 2011, based on default.frag
// Ambient term comes in gl_Color.rgb.
varying vec4 light_diffuse_comp;
varying vec3 normal;
varying vec3 relPos;

uniform sampler2D landclass;
uniform sampler2DArray textureArray;
uniform sampler1D dimensionsArray;
uniform sampler1D diffuseArray;
uniform sampler1D specularArray;
uniform sampler2D perlin;

varying float yprime_alt;
varying float mie_angle;
varying vec4 ecPosition;

uniform float visibility;
uniform float avisibility;
uniform float scattering;
uniform float terminator;
uniform float terrain_alt; 
uniform float hazeLayerAltitude;
uniform float overcast;
uniform float eye_alt;
uniform float cloud_self_shading;

// Passed from VPBTechnique, not the Effect
uniform int tile_level;
uniform float tile_width;
uniform float tile_height;

const float EarthRadius = 5800000.0;
const float terminator_width = 200000.0;

float alt;
float eShade;

float fog_func (in float targ, in float alt);
vec3 get_hazeColor(in float light_arg);
vec3 filter_combined (in vec3 color) ;

float getShadowing();
vec3 getClusteredLightsContribution(vec3 p, vec3 n, vec3 texel);

float luminance(vec3 color)
{
    return dot(vec3(0.212671, 0.715160, 0.072169), color);
}


// Test-phase code:

float rand2D(in vec2 co);

// Create random landclasses without a texture lookup to stress test
// Each square of square_size in m is assigned a random landclass value
int get_random_landclass(in vec2 co)
{
    float square_size = 200.0;
    //float r = rand2D(  floor(vec2(co.s*tile_width, co.t*tile_height)/square_size)  );
    float r = rand2D(  floor(vec2(co.s*tile_height, co.t*tile_width)/square_size)  );
    int lc = int(r*48.0); // only 48 landclasses mapped so far
    return lc;
}

float Noise2D(in vec2 coord, in float wavelength);
// End Test-phase code


void main()
{
    vec3 shadedFogColor = vec3(0.55, 0.67, 0.88);
    // this is taken from default.frag
    vec3 n;
    float NdotL, NdotHV, fogFactor;
    vec3 lightDir = gl_LightSource[0].position.xyz;
    vec3 halfVector = gl_LightSource[0].halfVector.xyz;
    vec4 texel;
    vec4 fragColor;
    vec4 specular = vec4(0.0);
    float intensity;



    // Oct 2021:
    // Geometry is in the form of roughly rectangular 'tiles'
    // with a mesh forming a grid with regular spacing. 
    // Each vertex in the mesh is given an elevation

    // Tile dimensions in m
    vec2 tile_size = vec2(tile_width , tile_height);
    // Temp: sizes are the wrong way around currently
    tile_size.xy =tile_size.yx;

    // Tile texture coordinates range [0..1] over the tile 'rectangle'
    vec2 tile_coord = gl_TexCoord[0].st;

    // Look up the landclass id [0 .. 255] for this particular fragment
    // Each tile has 1 texture containing landclass ids stetched over it

    // Testing. Landclass sources: texture or random
    int tlc = int(texture2D(landclass, tile_coord.st).g * 255.0 + 0.5);
    //int rlc = get_random_landclass(tile_coord.st);
    int lc = tlc;

    // The landclass id is used to index into arrays containing
    // material parameters and textures for the landclass as 
    // defined in the regional definitions
    float index = float(lc)/512.0;

    float mat_shininess = texture(dimensionsArray, index).z;
    vec4 mat_diffuse = texture(diffuseArray, index);
    vec4 mat_specular = texture(specularArray, index);

    vec4 color = gl_Color;

    // Testing code:
    // Use rlc even when looking up textures to recreate the extra performance hit
    // so any performance difference between the two is due to the texture lookup
    // color = color+0.00001*float(rlc);

    float effective_scattering = min(scattering, cloud_self_shading);

    vec4 light_specular = gl_LightSource[0].specular;

    // If gl_Color.a == 0, this is a back-facing polygon and the
    // normal should be reversed.
    //n = (2.0 * gl_Color.a - 1.0) * normal;
    n = normalize(normal);


    NdotL = dot(n, lightDir);
    if (NdotL > 0.0) {
        float shadowmap = getShadowing();
        color += (light_diffuse_comp * mat_diffuse) * NdotL * shadowmap;
        NdotHV = max(dot(n, halfVector), 0.0);
        if (mat_shininess > 0.0)
            specular.rgb = (mat_specular.rgb
                            * light_specular.rgb
                            * pow(NdotHV, gl_FrontMaterial.shininess)
                            * shadowmap);
    }
    color.a = light_diffuse_comp.a;
    // This shouldn't be necessary, but our lighting becomes very
    // saturated. Clamping the color before modulating by the texture
    // is closer to what the OpenGL fixed function pipeline does.
    color = clamp(color, 0.0, 1.0);


    // Look up ground textures by indexing into the texture array.
    // Different textures are stretched along the ground to different 
    // lengths along each axes as set by <xsize> and <ysize> 
    // regional definitions parameters

    // Look up stretching dimensions of textures in m - scaled to fit in [0..1], so rescale 
    vec2 g_texture_stretch_dim = 10000.0 * texture(dimensionsArray, index).st;

    vec2 g_texture_scale =  tile_size.xy / g_texture_stretch_dim.xy;
    // Ground texture coords
    vec2 st = g_texture_scale * tile_coord.st;

    // Rotate texture using the perlin texture as a mask to reduce tiling
    float pnoise1 = texture(perlin, st / 8.0).r;
    float pnoise2 = texture(perlin, - st / 16.0).r;

    //Testing: Non texture alternative
    //float pnoise1 = Noise2D(st, 8.0);
    //float pnoise2 = Noise2D(-st, 16.0);

    if (pnoise1 >= 0.5) st = g_texture_scale.st * tile_coord.ts;
    if (pnoise2 >= 0.5) st = -st;

    texel = texture(textureArray, vec3(st, lc));

    fragColor = color * texel + specular;
    fragColor.rgb += getClusteredLightsContribution(ecPosition.xyz, n, texel.rgb);

	// here comes the terrain haze model
	float delta_z = hazeLayerAltitude - eye_alt;
	float dist = length(relPos);

	float mvisibility = min(visibility,avisibility);

	if (dist > 0.04 * mvisibility) 
	{

	alt = eye_alt;

	float transmission;
	float vAltitude;
	float delta_zv;
	float H;
	float distance_in_layer;
	float transmission_arg;

	// angle with horizon
	float ct = dot(vec3(0.0, 0.0, 1.0), relPos)/dist;


	// we solve the geometry what part of the light path is attenuated normally and what is through the haze layer
	if (delta_z > 0.0) // we're inside the layer
	{
	if (ct < 0.0) // we look down 
		{
		distance_in_layer = dist;
		vAltitude = min(distance_in_layer,mvisibility) * ct;
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
	transmission_arg = transmission_arg + (distance_in_layer/visibility);
	// this combines the Weber-Fechner intensity
	eqColorFactor = 1.0 - 0.1 * delta_zv/visibility - (1.0 -effective_scattering);

	}
	else 
	{
	transmission_arg = transmission_arg + (distance_in_layer/avisibility);
	// this combines the Weber-Fechner intensity
	eqColorFactor = 1.0 - 0.1 * delta_zv/avisibility - (1.0 -effective_scattering);
	}

	transmission =  fog_func(transmission_arg, alt);

	// there's always residual intensity, we should never be driven to zero
	if (eqColorFactor < 0.2) {eqColorFactor = 0.2;}

	float lightArg = (terminator-yprime_alt)/100000.0;
	vec3 hazeColor = get_hazeColor(lightArg);

	// now dim the light for haze
	eShade = 1.0 - 0.9 * smoothstep(-terminator_width+ terminator, terminator_width + terminator, yprime_alt);

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
	//intensity = length(hazeColor);
	hazeColor = intensity * normalize(mix(hazeColor,  shadedFogColor, (1.0-smoothstep(0.5,0.9,eqColorFactor)))); 


	// reduce haze intensity when looking at shaded surfaces, only in terminator region

	float shadow = mix( min(1.0 + dot(normal,lightDir),1.0), 1.0, 1.0-smoothstep(0.1, 0.4, transmission));
	hazeColor = mix(shadow * hazeColor, hazeColor, 0.3 + 0.7* smoothstep(250000.0, 400000.0, terminator));

	// don't let the light fade out too rapidly
	lightArg = (terminator + 200000.0)/100000.0;
	float minLightIntensity = min(0.2,0.16 * lightArg + 0.5);
	vec3 minLight = minLightIntensity * vec3 (0.2, 0.3, 0.4);
	hazeColor *= eqColorFactor * eShade;
	hazeColor.rgb = max(hazeColor.rgb, minLight.rgb);

	// determine the right mix of transmission and haze

	fragColor.rgb = mix(hazeColor, fragColor.rgb,transmission);
	}

	fragColor.rgb = filter_combined(fragColor.rgb);

	gl_FragColor = fragColor;
}
