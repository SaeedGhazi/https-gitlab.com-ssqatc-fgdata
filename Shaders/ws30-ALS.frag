// WS30 FRAGMENT SHADER

// -*-C++-*-
#version 130
#extension GL_EXT_texture_array : enable
// written by Thorsten Renk, Oct 2011, based on default.frag


//////////////////////////////////////////////////////////////////
// TEST PHASE TOGGLES AND CONTROLS
//

// Development tools:
//   Reduce haze to almost zero, while preserving lighting. Useful for observing distant tiles.
//     Keeps the calculation overhead. This can be used for profiling.
//     Possible values: 0:Normal, 1:Reduced haze.
    const int reduce_haze_without_removing_calculation_overhead = 0;

//   Remove haze and lighting and shows just the texture. 
//     Useful for checking texture rendering and scenery.
//     The compiler will likely optimise out the haze and lighting calculations.
//     Possible values: 0:Normal, 1:Just the texture.
  const int remove_haze_and_lighting = 0;

//
// End of test phase controls
//////////////////////////////////////////////////////////////////














// Ambient term comes in gl_Color.rgb.
varying vec4 light_diffuse_comp;
varying vec3 normal;
varying vec3 relPos;

uniform sampler2D landclass;
uniform sampler2DArray textureArray;

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
uniform bool photoScenery;
uniform vec4 dimensionsArray[128];
uniform vec4 ambientArray[128];
uniform vec4 diffuseArray[128];
uniform vec4 specularArray[128];

const float EarthRadius = 5800000.0;
const float terminator_width = 200000.0;

float alt;
float eShade;

float fog_func (in float targ, in float alt);
vec3 get_hazeColor(in float light_arg);
vec3 filter_combined (in vec3 color) ;

float shadow_func (in float x, in float y, in float noise, in float dist);
float DotNoise2D(in vec2 coord, in float wavelength, in float fractionalMaxDotSize, in float dot_density);
float Noise2D(in vec2 coord, in float wavelength);
float Noise3D(in vec3 coord, in float wavelength);
float SlopeLines2D(in vec2 coord, in vec2 gradDir, in float wavelength, in float steepness);
float Strata3D(in vec3 coord, in float wavelength, in float variation);
float fog_func (in float targ, in float alt);
float rayleigh_in_func(in float dist, in float air_pollution, in float avisibility, in float eye_alt, in float vertex_alt);
float alt_factor(in float eye_alt, in float vertex_alt);
float light_distance_fading(in float dist);
float fog_backscatter(in float avisibility);

vec3 rayleigh_out_shift(in vec3 color, in float outscatter);
vec3 get_hazeColor(in float light_arg);
vec3 searchlight();
vec3 landing_light(in float offset, in float offsetv);
vec3 filter_combined (in vec3 color) ;

float getShadowing();
vec3 getClusteredLightsContribution(vec3 p, vec3 n, vec3 texel);

// Not used
float luminance(vec3 color)
{
    return dot(vec3(0.212671, 0.715160, 0.072169), color);
}


//////////////////////////
// Test-phase code:


// These should be sent as uniforms

// Tile dimensions in meters
// vec2 tile_size = vec2(tile_width , tile_height);
// Testing: texture coords are sent flipped right now:

// Note tile_size is defined in the shader include: ws30-landclass-search-functions.frag.
// vec2 tile_size = vec2(tile_height , tile_width);

// From noise.frag
float rand2D(in vec2 co);

// These functions, and other function they depend on, are defined
// in ws30-ALS-landclass-search.frag.


// Create random landclasses without a texture lookup to stress test.
// Each square of square_size in m is assigned a random landclass value.
int get_random_landclass(in vec2 co, in vec2 tile_size);


// Lookup a ground texture at a point based on the landclass at that point, without visible 
//   seams at coordinate discontinuities or at landclass boundaries where texture are switched.
//   The partial derivatives of the tile_coord at the fragment is needed to adjust for 
//   the stretching of different textures, so that the correct mip-map level is looked 
//   up and there are no seams.

vec4 lookup_ground_texture_array(in vec2 tile_coord, in int landclass_id, in vec2 dx, in vec2 dy);


// Look up the landclass id [0 .. 255] for this particular fragment.
// Lookup id of any neighbouring landclass that is within the search distance.
// Searches are performed in upto 4 directions right now, but only one landclass is looked up
// Create a mix factor werighting the influences of nearby landclasses
void get_landclass_id(in vec2 tile_coord,   
  const in float landclass_texel_size_m, in vec2 dx, in vec2 dy,
  out int landclass_id, out ivec4 neighbor_landclass_ids, 
  out int num_unique_neighbors,out vec4 mix_factor
  );


// End Test-phase code
////////////////////////


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



  // Oct 27 2021:
  // Geometry is in the form of roughly rectangular 'tiles'
  // with a mesh forming a grid with regular spacing. 
  // Each vertex in the mesh is given an elevation

  // Tile dimensions in m
  // Testing: created from two float uniforms in global scope. Should be sent as a vec2
  // vec2 tile_size

  // Tile texture coordinates range [0..1] over the tile 'rectangle'
  vec2 tile_coord = gl_TexCoord[0].st;

  // Test phase: Constants and toggles for transitions between landlcasses are defined at
  // the top of this file.

  // Look up the landclass id [0 .. 255] for this particular fragment
  // and any neighbouring landclass that is close.
  // Each tile has 1 texture containing landclass ids stetched over it.

  // Landclass for current fragment, and up-to 4 neighboring landclasses - 2 used currently
  int lc;
  ivec4 lc_n;

  int num_unique_neighbors = 0;

  // Mix factor of base textures for 2 neighbour landclass(es)
  vec4 mfact;


  const float landclass_texel_size_m = 25.0;

  // Partial derivatives of s and t for this fragment, 
  // with respect to window (screen space) x and y axes.
  // Used to pick mipmap LoD levels, and turn off unneeded procedural detail
  vec2 dx = dFdx(tile_coord); 
  vec2 dy = dFdy(tile_coord);

  get_landclass_id(tile_coord, landclass_texel_size_m, dx, dy,
      lc, lc_n, num_unique_neighbors, mfact);

  // The landclass id is used to index into arrays containing
  // material parameters and textures for the landclass as 
  // defined in the regional definitions
  float index = float(lc)/512.0;
  vec4 index_n = vec4(lc_n)/512.0;

	// Material properties.
	vec4 mat_diffuse, mat_ambient, mat_specular;
	float mat_shininess;

  if (photoScenery) {
		mat_ambient = vec4(1.0,1.0,1.0,1.0);
		mat_diffuse = vec4(1.0,1.0,1.0,1.0);
		mat_specular = vec4(0.1, 0.1, 0.1, 1.0);
		mat_shininess = 1.2;

		texel = texture(landclass, vec2(gl_TexCoord[0].s, 1.0 - gl_TexCoord[0].t));
  } else {
		// Color Mode is always AMBIENT_AND_DIFFUSE, which means
		// using a base colour of white for ambient/diffuse,
		// rather than the material color from ambientArray/diffuseArray.
		mat_ambient = vec4(1.0,1.0,1.0,1.0);
		mat_diffuse = vec4(1.0,1.0,1.0,1.0);
		mat_specular = specularArray[lc];
		mat_shininess = dimensionsArray[lc].z;

    // Look up ground textures by indexing into the texture array.
    // Different textures are stretched along the ground to different 
    // lengths along each axes as set by <xsize> and <ysize> 
    // regional definitions parameters

    // Look up texture coordinates and scale of ground textures
    // Landclass for this fragment
    texel = lookup_ground_texture_array(tile_coord, lc, dx, dy);

    // Mix texels - to work consistently it needs a more preceptual interpolation than mix()
    if (num_unique_neighbors != 0)
    {
      // Closest neighbor landclass
      vec4 texel_closest = lookup_ground_texture_array(tile_coord, lc_n[0], dx, dy);

      // Neighbor contributions
      vec4 texel_nc=texel_closest;

      if (num_unique_neighbors > 1)
      {
        // 2nd Closest neighbor landclass
        vec4 texel_2nd_closest = lookup_ground_texture_array(tile_coord, lc_n[1],
                                    dx, dy);

        texel_nc = mix(texel_closest, texel_2nd_closest, mfact[1]);
      }

      texel = mix(texel, texel_nc, mfact[0]);
    }
  }

	vec4 color = mat_ambient * (gl_LightModel.ambient + gl_LightSource[0].ambient);

  // Testing code:
  // Use rlc even when looking up textures to recreate the extra performance hit
  // so any performance difference between the two is due to the texture lookup
  // color = color+0.00001*float(get_random_landclass(tile_coord.st, tile_size));

  float effective_scattering = min(scattering, cloud_self_shading);

  vec4 light_specular = gl_LightSource[0].specular;

  // If gl_Color.a == 0, this is a back-facing polygon and the
  // normal should be reversed.
  //n = (2.0 * gl_Color.a - 1.0) * normal;
  n = normalize(normal);


  NdotL = dot(n, lightDir);
  vec4 diffuse_term = light_diffuse_comp * mat_diffuse;
  if (NdotL > 0.0) {
      float shadowmap = getShadowing();
      vec4 diffuse_term = light_diffuse_comp * mat_diffuse;
      color += diffuse_term * NdotL * shadowmap;
      NdotHV = max(dot(n, halfVector), 0.0);
      if (mat_shininess > 0.0)
          specular.rgb = (mat_specular.rgb
                          * light_specular.rgb
                          * pow(NdotHV, gl_FrontMaterial.shininess)
                          * shadowmap);
  }
  color.a = diffuse_term.a;
  // This shouldn't be necessary, but our lighting becomes very
  // saturated. Clamping the color before modulating by the texture
  // is closer to what the OpenGL fixed function pipeline does.
  color = clamp(color, 0.0, 1.0);


  // Testing code: mix with green to show values of variables at each point
  //vec4 green = vec4(0.0, 0.5, 0.0, 0.0);
  //texel = mix(texel, green, (mfact[2]));


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


// Testing phase controls
if (reduce_haze_without_removing_calculation_overhead == 1)
{
transmission = 1.0 - (transmission/1000000.0);
}



  fragColor.rgb = mix(hazeColor, fragColor.rgb,transmission);
  }

  fragColor.rgb = filter_combined(fragColor.rgb);

  gl_FragColor = fragColor;



// Testing phase controls:
if (remove_haze_and_lighting == 1)
{
        gl_FragColor = texel;
}


        
}
