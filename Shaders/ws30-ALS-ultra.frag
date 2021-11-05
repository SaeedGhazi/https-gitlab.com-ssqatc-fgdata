// WS30 FRAGMENT SHADER

// -*-C++-*-
#version 130
#extension GL_EXT_texture_array : enable



//////////////////////////////////////////////////////////////////
// TEST PHASE TOGGLES AND CONTROLS FOR PROFILING ON DIFFERENT GPUS 
//

// Instructions for power users: 
//   Change the numbers for values and controls, save the file, and 
//     reload shaders to compare the difference.
//     In-sim menu > debug > configure development extensions > reload shaders.
//   It's safe to tinker with things in this section. 
//   At worst the terrain will look odd. If there's an error or a stray 
//     character, the shader will just not compile - the terrain changes 
//     appearance to black.
//   Simply try again and hit reload shaders button. You can also save a backup 
//     of this file.
//   "//" means everything on that line is a comment. 
//   Lines assigning numbers to variables end in a ";"

// Testing performance:
//   Use the UFO or video assistant. Turn all scenery layers off (vegetation, 
//     buildings, random scenery objects etc.).
//   The terrain quality shader level determines the shaders used. Set it to ultra.
//   The view should be 100% terrain. No sky. Try to minimise parts of terrain 
//     or scenery rendered by other shaders, as the results will be inaccurate.
//     Avoid clouds in view. Minimise water in view.
//   Going closer or reducing FoV works, but these also can change performance.
//   Looking towards the horizon at high altitude may cause perfomance to be CPU
//     bound due to OSG scene traveral.
//   Remember to mention factors that change performance: 
//     resolution, the rough area (regional definitions at work), altitude, 
//     scenery package, AA settings, driver control panel settings and overrides
//     - (you can set these to application controlled)


// Comparing performance:
//   GPU bound: To use FPS to compare performance you must be bottlenecked by 
//      the GPU (GPU bound).
//     When GPU bound (fragment bound), changing the window size slightly should
//       result in a change in FPS.
//     You can also tell if you are GPU bound, as GPU utilisation will be 100%.
//     Change in performance = FPS2/FPS1. 
//       e.g. increase of 15 FPS to 30 FPS = 30/15 = 2x or 200% increase. 
//   Not GPU bound: If your bottleneck is not the GPU, you need to measure 
//     GPU utilisation.
//     GPU utilisation is the GPU load - it will be less than 100%.
//     Change in performance = utilisation1/utilisation2. 
//       e.g. Drop from 40% to 20% = 40/20 = 2x increase in performance or 
//       doubling of FPS. e.g 40% to 30% = 40/30 = 1.33x increase.
//   CPU bound FPS limit: You can usually find your CPU bound FPS limit by 
//     reducing window size until FPS stops increasing. This depends on what's 
//     in view.
//   To Compare performace with WS2: untick the WS3 tick box in render settings, 
//     and make sure both WS2 and WS3 are GPU bound, and not CPU bound.     


//
// Note: 
//   Ensure in-sim menu > view > rendering options > throttle FPS is off. 
//   Ensure vsync is off.
//   Make sure your power plan is set to maximum or balanced in Windows, or 
//     results could be inaccurate - laptops may be on a power saving plan 
//     by default.

// To test: All transitions are off by default. Set both remove squareness and 
//   enable large scale transitions to 1 to get a quality with most features 
//   turned on.

// Maximum number of neighbor landclass textures to lookup if neighbors are found. 
//   The more landclass textures are looked up the more pressure on VRAM. 
//   Performance hit varies by altitude and how small the landclass blobs are.
//   More ground texture lookups may run slower on older generation GPUs - test and see.
//   Possible values: 0,1,2. Default: 2. To see texture mixing transitions you need 1 or 2.
  const int max_neighbor_landclass_texture_lookups = 2;



// Small scale transition controls

//   Remove squareness due to landclass texture by growing higher priority neighbors.
//     This adds 2 extra lookups of the landclass texture, and one math/noise lookup.
//     Large scale transition searches do not use this - as it triples the number of 
//        landclass texture acceses, as well as adding 1 noise lookup per search point.
//     This should be expected to be used on old GPUs, except when running at the absolute 
//       lowest graphics quality. It's faster than large scale transition searches.
//     Possible values: 1:enabled, 0:disabled. Default:0
    const int remove_squareness_from_landclass_texture = 0;

//   Transition at landclass texel scale
//     Mix in neighbor textures so landclass boundaries are not hard at the 
//       landclass texel scale.
//     Note: Disable enable large scale transition search, if using this. 
//       This needs extra ground texture lookups. It looks fine with 1 extra lookup.
//       This can be combined with removing squareness by growing borders.
//     Possible values: 1:enabled, 0:disabled
    const int use_landclass_texel_scale_transition_only = 0;



// Large scale transition controls

//   Enable large scale transitions: 1=on, 0=off
//     Disable use landclass texel scale transition, if using this.
  const int enable_large_scale_transition_search = 0;


//   The search pattern is center + n points in four directions forming a cross.
//     e.g. 1 search point = 1 + 4 * 1 = 5 points total. 
//     4 search points: 17 total. 10 search points = 41
//   The transition distance is the distance from the center to the furtherst 
//      point in any direction.


//   Landclass transition search distance in meters
//     Note: transitions occur on both sides of the landclass borders. 
//       The width of the transition is equal to 2x this value.
//     Default: 100m
  const float transition_search_distance_in_m = 100.0;

//   Number of points to search in any direction, in addition to this fragment
//     Default:4 points. Fewer points results in a less smooth transition (more banding)
//       Choose the lowest number of points to get a desired transition quality.
  const int num_search_points_in_a_direction = 4;




// Landclass transition weightings options
//   More options mean slightly more GPU math load
//
//   Use 2nd closest neighbour for transition weighting. 
//   Note this won't lookup a ground texture by itself, just sort through results
//     Possible values: 1:enable, 0=disable. Default: 1  
  const int enable_2nd_closest_neighbor_for_large_scale_transition_weights = 0;

//   Enable dithering to smooth transitions by reducing visible banding
//   Possible values: 1=enable, 0=disable. Default = 1
  const int enable_dithering_for_large_scale_transitions = 1;

//   Scale of dithering as a faction of the size of the bands - distance between
//     search points (=transition distance / number of steps)
//     0.2 seems to work ok - not real need to tinker with this.
//   Different values won't change performance.
  const float dithering_noise_wavelength_as_fraction_of_step_size = 0.2;

//   Grow the borders of landclasses a bit when large scale transitions are used
//     Higher priority landclasses grow onto lower priority ones. 
//     Landclass numbers are used as a placeholder for landclass priority.
//     This works by changing the weighting in the transition region using a 
//       noise lookup
//     Possibe values: 0=off, 1=on. Default:0
  const int grow_landclass_borders_with_large_scale_transition = 0; 



//////////////////////////////////////////////////////////////////
// Advanced controls - these are for testing scenery generation and rendering


// Landclass source:
//   Possible values: Default=1;
//     0=Normal landclass texture, 1 = Random landclass squares along s and t axes.    
//   Choose 1 to test impact of searching a texture. You should normally leave 
//     it at default.
  const int landclass_source = 0;

//   Random landclass square size in meters. Remember to adjust transition search distance.
//     Default: 200m 
    const float random_landclass_square_size_in_m = 3.3*transition_search_distance_in_m;

// Detiling noise source
//   Possible values: 0 = texture source, 1 = math source
//   The texture source still shows some tiling. The math source detiles better, but might
//     be slightly slower.
  const int detiling_noise_type = 0;

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
vec2 tile_size = vec2(tile_height , tile_width);


float rand2D(in vec2 co);


// Create random landclasses without a texture lookup to stress test.
// Each square of square_size in m is assigned a random landclass value.
int get_random_landclass(in vec2 co, in vec2 tile_size)
{
  float r = rand2D(  floor(vec2(co.s*tile_size.x, co.t*tile_size.y)/random_landclass_square_size_in_m)  );
  int lc = int(r*48.0); // only 48 landclasses mapped so far
  return lc;
}


// Look up texture coordinates and stretching scale of ground textures
void get_ground_texture_data(in float textureIndex, in vec2 tile_coord, 
  out vec2 st, out vec2 g_texture_scale, in out vec2 dx, in out vec2 dy)
{
  // Look up stretching dimensions of ground textures in m - scaled to 
  // fit in [0..1], so rescale 
  vec2 g_texture_stretch_dim = 10000.0 * texture(dimensionsArray, textureIndex).st;
  g_texture_scale =  tile_size.xy / g_texture_stretch_dim.xy;
  // Correct partial derivatives to account for stretching of different textures
  dx = dx * g_texture_scale;
  dy = dy * g_texture_scale;
  // Ground texture coords
  st = g_texture_scale * tile_coord.st;
}


// Rotate texture using the perlin texture as a mask to reduce tiling.
// type=0: use perlin texture, type = 1: use Noise2D to avoid texture lookup
// Testing: if this or get_ground_texture_data used in final WS3 to handle 
// many base texture lookups, see if optimising to handle many inputs helps 
// (vectorising Noise2D versus just many texture calls)

vec2 detile_texcoords_with_perlin_noise(in vec2 st, in vec2 ground_texture_scale, 
  in vec2 tile_coord, in out vec2 dx, in out vec2 dy)
{
  vec2 pnoise;

  // Ratio tile dimensions are stretched relative to s.
  // Tiles may not have equal dimensions.
  vec2 stretch_r = tile_size.st/tile_size.s;

  // Note: unresolved texture discontinuties (i.e. mipmap problems) with unequal stretch factors
  const vec2 local_stretch_factors = vec2(8.0, 8.0 /*16.0*/);

  if (detiling_noise_type==1) 
  {
      pnoise[0] = texture(perlin, st / local_stretch_factors[0]).r;
      pnoise[1] = texture(perlin, - st / local_stretch_factors[1]).r;
  } 
  else 
  {
      //Testing: Non texture alternative

      // Estimate of wavelength in /Textures/perlin.png in normalised texture coords
      const float ptex_wavelength = (1.0/7.0); 

      pnoise[0] = Noise2D(st / (local_stretch_factors[0]), ptex_wavelength);
      pnoise[1] = Noise2D(-st / (local_stretch_factors[1]), ptex_wavelength);
  }

  if (pnoise[0] >= 0.5) 
  {
    st = ground_texture_scale.st * (tile_coord * stretch_r).ts;
    // Get back original partial derivatives by undoing 
    // previous texture stretching adjustment done in get_ground_data
    dx = dx / ground_texture_scale.st;
    dy = dy / ground_texture_scale.st;
    // Recalculate new derivatives
    dx = dx.ts * ground_texture_scale.st * stretch_r.ts;	
    dy = dy.ts * ground_texture_scale.st * stretch_r.ts;

  } 

  if (pnoise[1] >= 0.5)
  {
    st = -st; dx = -dx; dy = -dy;
  }
  return st;
}


// Lookup a ground texture at a point based on the landclass at that point, without visible 
//   seams at coordinate discontinuities or at landclass boundaries where texture are switched.
//   The partial derivatives of the tile_coord at the fragment is needed to adjust for 
//   the stretching of different textures, so that the correct mip-map level is looked 
//   up and there are no seams.

vec4 lookup_ground_texture_array(in float index, in vec2 tile_coord, in int landclass_id,
  in vec2 dx, in vec2 dy)
{
  // Testing: may be able to save 1 or 2 op slots by combining dx/dy in a vec4 and
  // using swizzles which are free, but mostly operations are working independenly on s and t.
  // Only 1 place so far that just multiplies everything by a scalar.
  vec2 st;
  vec2 g_texture_scale;
  vec4 texel;
  int lc = landclass_id;

  get_ground_texture_data(index, tile_coord, st, g_texture_scale, dx, dy);


  st = detile_texcoords_with_perlin_noise(st, g_texture_scale, tile_coord, dx, dy);

  //texel = texture(textureArray, vec3(st, lc));
  //texel = textureLod(textureArray, vec3(st, lc), 12.0);
  texel = textureGrad(textureArray, vec3(st, lc), dx, dy);
  return texel;
}

// Landclass sources: texture or random 
int read_landclass_id(in vec2 tile_coord)
{
  vec2 dx = dFdx(tile_coord.st);
  vec2 dy = dFdy(tile_coord.st);
  int lc;

  if (landclass_source == 0) lc = (int(texture2D(landclass, tile_coord.st).g * 255.0 + 0.5));
  else lc = (get_random_landclass(tile_coord.st, tile_size));
  return lc;
}


int read_landclass_id_non_pixelated(in vec2 tile_coord, 
  const in float landclass_texel_size_m)
{
  vec2 c0 = tile_coord;
  vec2 sz = tile_size;
  vec2 tsz = vec2(landclass_texel_size_m)/tile_size;

  // Landclass sources: texture or random
  int lc = read_landclass_id(c0);

  return lc;
}


// Determine whether to grow a neighbor landclass onto current. 
// 1 = grow neighbor, 0 = don't grow neighbor
float get_growth_priority(in int current_landclass, in int neighbor_landclass)
{
  int lc1 = current_landclass;
  int lc2 = neighbor_landclass;
  return ((lc1 < lc2)?1.0:0.0);
}


// Determine whether to grow a one of 2 neighbor landclasses onto current. 
// 1 = grow neighbor, 0 = don't grow neighbor
float get_growth_priority(in int current_landclass, in int neighbor_landclass1, in int neighbor_landclass2)
{
  int lc1 = current_landclass;
  int lc2 = neighbor_landclass1;
  int lc3 = neighbor_landclass2;
  return ((lc1 < max(lc2,lc3))?1.0:0.0);
}



int lookup_landclass_id(in vec2 tile_coord, in vec2 dx, in vec2 dy,
    out ivec4 neighbor_texel_landclass_ids, 
    out int number_of_unique_neighbors_found, out vec4 landclass_neighbor_texel_weights)
{

  // To do: fix landclass border artifacts, with all shaders. do small scale texel mixing for 2 neighbors

  // Number of unique neighbours found
  int num_n = 0;

  vec2 c0 = tile_coord;
  vec2 sz = tile_size;

  // Landclass sources: texture or random
  int lc = read_landclass_id(c0);
  int output_landclass = lc;

  // Landclasses of up to 4 neighbor texels
  ivec4 lc_n = ivec4(lc);

  // Landclasses sorted
  ivec4 lc_n_s;

  // Combined weight from 2 neighbor texels
  float w = 0.0;

  // Landclass neighbor weights - for texel mixing only
  vec4 lc_n_w = vec4(0.0);

// Test phase controls
if ( (remove_squareness_from_landclass_texture == 1) || 
     ( (use_landclass_texel_scale_transition_only == 1) &&
       (enable_large_scale_transition_search == 0) ) 
   ) 
{


  // Remove squareness from the landclass texture due to nearest neighbour interpolation
  // A landclass with higher growth priority grows on to an adjacent landclass
  // with lower priority 

  // Landclass texture dimensions, in texels - Needs glsl 1.30+ 
  // Probably best to just send as uniforms if texture sizes don't vary, or are fixed per terrain LoD level.
  vec2 texture_dim_tx = vec2(textureSize(landclass, 0));

  // Coordinates of current fragment, in texels
  vec2 c0_tx = c0 * texture_dim_tx;

  // Coordinates of the center of the current texel, in texels
  // centers are n+(0.5,0.5) for n = 0,1,2...
  vec2 ct_c0_tx = floor(c0_tx) + 0.5;
  // center in normalised tex coords
  vec2 ct_c0 = ct_c0_tx/texture_dim_tx;

  // Landclass at center of current texel - same anywhere within a texel
  int lc_ct = lc;

  // Coords of centers of closest neighbors, in texels
  vec2 c_n_tx[2];


  // Coordinate of fragment relative to center of texel, in texels
  vec2 c0_rel_ct_tx = c0_tx - ct_c0_tx;

  float dist_ct = length(c0_rel_ct_tx);
  
  // need to avoid division by 0?
  if (dist_ct < 0.00001) dist_ct += 0.00001;

  // Choose closest neighbor based on angle wrt. to 
  // c0, center of texel, and s & t axes.
  // Choose the texel in the direction of the largest s & t component.
  // NB: This method will select a diagonal neighbor if 
  // both components of c0_rel_ct_tx are equal to cos(45).
  // Testing: look for a way that uses fewer instructions, 
  // maybe calculating 2 neighbors at once using a vec4.

  //vec2 a = abs(c0_rel_ct_tx);
  //offset_ct0 = ((a.s > a.t)?vec2(1.0,0.0):vec2(0.0,1.0))*sign(c0_rel_ct_tx);

  // Vectorisable
  const float cos45deg = cos(radians(45.0));
  vec2 offset_ct0 = step(cos45deg, abs(c0_rel_ct_tx/dist_ct))
                      *sign(c0_rel_ct_tx);
  
  c_n_tx[0] = (ct_c0_tx + offset_ct0);

  // Landclass of closest neighbor
  lc_n[0] = read_landclass_id(c_n_tx[0]/texture_dim_tx);


  // Choose 2nd closest neighbor
  // Choose texels in the direction of the smaller of s & t components
  vec2 offset_ct1 = abs(offset_ct0.ts)*step(0.0, abs(c0_rel_ct_tx/dist_ct))
                    * sign(c0_rel_ct_tx);

  c_n_tx[1] = (ct_c0_tx + offset_ct1);

  // Land class of 2nd closest neighbor
  lc_n[1] = read_landclass_id(c_n_tx[1]/texture_dim_tx);


  // Distinct neighbors found
  // Testing: possible optimisation, use booleans. 
  // Needs ivec4/1.30+, or vec4/1.20 - reliably supported by old compilers?
  // bvec4 n_found = notEqual(lc_n, ivec4(lc));

  ivec4 n_found = ivec4(((lc_n[0] != lc)?1:0), ((lc_n[1] != lc)?1:0), 0, 0);

  num_n = n_found[0]+ n_found[1];


  //if (any(n_found))
  if ((n_found[0] == 1) || (n_found[1] == 1))
  {
    
    // Weights for influence from neighbor landclasses
    //   The distance away from the neighbor texel side is used to determine influence.
    //   w_n: 0.5 at minimum possible distance, 0.0 at maximum possible distance 
  
    // Neighbor weights
    vec4 w_n = vec4(0.0);

  
    // Method 1:
    //   Use distance from side of neighbor texel for mixing
    //   This is has some issues, including with corners
  
    vec2 dir0 = offset_ct0;
    vec2 dir1 = offset_ct1;
  
    // Distance from side of neighbor texel, in texels
    vec2 d0 = dir0*c0_rel_ct_tx;
    vec2 d1 =dir1*c0_rel_ct_tx;
  
    w_n[0] = max(d0.x, d0.y);
    w_n[1] = max(d1.x, d1.y);



/*
    //Method 2:
    // use distance from center of neighbor texel for mixing
    // This doesn't really give better results than 1

    // Distance from center of neighbor texels, in texels
    vec2 dist_n_tx = vec2(0.0);

    dist_n_tx[0] = length(c0_tx - c_n_tx[0]);
    dist_n_tx[1] = length(c0_tx - c_n_tx[1]);


    // Weighting for closest neighbor - [0.5 to 0.0] as distance goes from [min to max]
    const float max_dist = sqrt(0.5*0.5+1.0);
    const float min_dist = 0.5;
    w_n[0] = (dist_n_tx[0]-min_dist)/(max_dist - min_dist);
    w_n[0] = mix(0.5, 0.0, w_n[0]);


    // Weighting for 2nd closest neighbor - [0.5 to 0.0] as distance goes from [min to max]
    //const float max_dist1 = sqrt(0.5*0.5+1.0);
    //const float min_dist = 0.5;
    w_n[1] = (dist_n_tx[1]-min_dist)/(max_dist-min_dist);
    w_n[1] = mix(0.5, 0.0, w_n[1]);
*/


    // Use weighting only if neighbour is different from landclass for this fragment
    // Testing: Can be omitted if not doing texture mixing as it doesn't really 
    //   make a difference.
    w_n = w_n * vec4(n_found);

    // Combined weighting - increase w_n[0] if the 2nd closest neigbour is
    // different such that w_n[0] remains under 0.5
    w = w_n[0];
    w = w + (0.5-w)*2.0*w_n[1];

    // Sort landclasses and weights
    lc_n_s = lc_n;
    // If closest neighbour is lc, move 2nd closest neighbour to closest slot, and
    // clear the 2nd closest slot
    if (n_found[0] == 0)
    {
      lc_n_s.xy = lc_n.yz;
      w_n.xy = w_n.yz;
    }


// Testing phase controls
if ( (use_landclass_texel_scale_transition_only == 1) && 
     (max_neighbor_landclass_texture_lookups > 0) &&
     (enable_large_scale_transition_search == 0)
   )
{
    // Assign mix factors for transitions by mixing texels
    // [0]: 0 to 0.5
    // [1]: split [0 to 1] between closest and 2nd closest landclass 
    lc_n_w[0] = w;
    lc_n_w[1] = w_n[1]/(w_n[0]+w_n[1]);
}


} // Testing controls: End if ((remove_squareness_from_landclass_texture == 1) || (use_landclass_texel_scale_transition_only == 1))


if (remove_squareness_from_landclass_texture == 1)
{
    // Turn neighbor growth off at longer ranges, otherwise there is flickering noise
    // Testing: The exact cutoff could be done sooner to save some performance - needs
    // to be part of a larger solution to similar issues. User should set a tolerance factor.
    float lod_factor = min(length(vec2(dx.s, dy.s)),length(vec2(dx.t, dy.t)));
    // Estimate of frequency of growth noise in texels - i.e. how many peaks and troughs fit in one texel
    const float frequency_g_n = 1000.0;
    const float cutoff = 1.0/frequency_g_n;

    if (lod_factor < cutoff)
    {
      // Decide whether to grow neighbor on to lc
      float grow_n = get_growth_priority(lc,lc_n[0]);

      // Noise on the scale of landclass texels in the texture
      // Testing: reduce instructions if this method is to be used. 
      //   To look at: corner visuals & sharp diagonals.

      // Minimum wavelength of transition noise
      const float wl_tn = (1.0/8.0);
      float tn = Noise2D(c0*texture_dim_tx, wl_tn); // old val 1.6

      float threshold = mix(1.0,0.0, w);

      float neighbor_growth_weight = (0.3*2.0)*w*step(threshold-0.15, tn);

      // Growth factor
      float g = ((grow_n > 0.0)?neighbor_growth_weight:-neighbor_growth_weight);
      //g = sqrt(abs(g))*sign(g);

      // Neighbor growth value
      float v;
      //v=w+g;
      v = w*(0.7+50.5*g);

      // Whether or not to grow neighbour onto nearby pixel

      // To do - mix factor between different neighbour lanclasses 
      // when using an extra ground texture lookup

      if (v > 0.5) output_landclass = lc_n_s[0];




// Testing phase controls
if ( (use_landclass_texel_scale_transition_only == 1) && 
     (max_neighbor_landclass_texture_lookups > 0) &&
     (enable_large_scale_transition_search == 0)
   )
{

    lc_n_w[0] = 0.0;
/*
    // Adjust mix factor weights and swap landclasses for extrusions

    // Method 1:

    lc_n_w[0] = (w-0.5*neighbor_growth_weight);
    if (v > 0.5) lc_n_s[0] = lc;
*/


    // Method 2:
    // Mix in neighbour texel, instead of change output landclass.

    // Undo previous output class assignment
    output_landclass = lc;

    // Reduce flickering noise due to small detail added when far away. Contrasting colors mean more visible issues.
    // Fade 0 to 1 as lod_factor goes from 1.0 to 4.0
    // The goal is to avoid flickering with worst case texture filtering and supersampling.
    // Testing: However, the quicker the detil fades, the more square distant ladnclasses look.
    //          Right now the noise function generates too many high frequency components (small detail)

    //const float mmax = 4000.0; const float mmin = mmax-1000.0; /* no flickering */
    const float mmax = 3000.0; const float mmin = mmax-1000.0;  /* bit of filckering */
    float fade = smoothstep(mmin, mmax, 1.0/lod_factor);

    lc_n_w[0] = (w-0.5*3.333*0.9*(neighbor_growth_weight*fade));
    if (v > 0.5) lc_n_w[0] = w+0.4*fade;



}



    } // End if (lod_factor > some value)


} // Testing code: End if (remove_squareness_from_landclass_texture == 1)



  } // End if (nfound[0] == 1) || (n_found[1] == 1)




  landclass_neighbor_texel_weights = lc_n_w;
  neighbor_texel_landclass_ids = lc_n_s;
  number_of_unique_neighbors_found = num_n;
  return output_landclass;

}



// Look up the landclass id [0 .. 255] for this particular fragment.
// Lookup id of any neighbouring landclass that is within the search distance.
// Searches are performed in upto 4 directions right now, but only one landclass is looked up
// Create a mix factor werighting the influences of nearby landclasses

void get_landclass_id(in vec2 tile_coord,   
  const in float landclass_texel_size_m, in vec2 dx, in vec2 dy,
  out int landclass_id, out ivec4 neighbor_landclass_ids, 
  out int num_unique_neighbors,out vec4 mix_factor
  )
{ 
  // Each tile has 1 texture containing landclass ids stetched over it

  // Landclass source type: 0=texture, 1=random squares
  // Controls are defined at global scope. const int landclass_source
  const float ts = landclass_texel_size_m;
  vec2 sz = tile_size;

  // Number of unique neighbors found
  int num_n = 0;

  // Only used for mixing textures of neighboring texels:
  // Landclass ids of neigbors in neighboring texels
  ivec4 lc_n_tx;
  // Weights of neighbour landclass texels
  vec4 lc_n_w;
  // Number of unique neighbors in neighboring texels
  int num_n_tx = 0;

  int lc = lookup_landclass_id(tile_coord, dx, dy, lc_n_tx, num_n_tx, lc_n_w);

  // Neighbor landclass ids
  ivec4 lc_n = ivec4(lc);

  // Mix factors: texels are mixed in from furthest, to closest
  //   mfact[1]: [0 to 1] mixing 1st and 2nd closest texels
  //   mfact[0]: [0 to 0.5] texel and previous neighbour contributions
  vec4 mfact = vec4(0.0);


// Testing phase controls
if ( (use_landclass_texel_scale_transition_only == 1) && 
     (max_neighbor_landclass_texture_lookups > 0) &&
     (enable_large_scale_transition_search == 0)
   )

{
  // Use the ground texture lookups to do a transition on the scale of
  // the landclass textures instead of doing a large scale transition
  num_n = num_n_tx;
  lc_n = lc_n_tx;
  mfact = lc_n_w;
}
      

// Testing phase controls
if ( (enable_large_scale_transition_search == 1) && 
     (max_neighbor_landclass_texture_lookups > 0) &&
     (use_landclass_texel_scale_transition_only == 0)
   )
{


  // Transition search

  const int n = num_search_points_in_a_direction;

  const float search_dist = transition_search_distance_in_m;
  vec2 step_size_m = vec2(search_dist/float(n));
  // step size in tile coords
  vec2 steps = step_size_m.st / tile_size.st;

  vec2 c0 = tile_coord;

  // Min number of points (loop counter value (i)) before 
  // a different landclass is found
  ivec4 mi = ivec4(n+1);

  // landclass - l can be accessed as an array e.g. l[0]=l.x
  ivec4 l = ivec4(lc);

  // Search in 4 directions. These for loops likely need unrolling, 
  // and optimising to use minimum instructions, if they are 
  // to be used outside of testing the search concept.
  // The texture access patterns may be suboptimal as well.
  // Travelling along s and t axes might work better.
  // Note: this returns the closest neighbor. There could be blobs
  // of multiple neighbors, or a tiny islands of neighbors among this
  // landclass.


  // +s direction
  vec2 dir = vec2(steps.s, 0.0);

  for (int i=1;i<=n;i++) {
      vec2 c = c0+float(i)*dir;
      int v = read_landclass_id(c);
      if ((v != lc) && (mi[0] > n)) {l[0] = v; mi[0] = i; }
  }


  // -s direction
  dir = vec2(-steps.s, 0.0);
  for (int i=1;i<=n;i++) 
  {
      vec2 c = c0+float(i)*dir; 
      int v = read_landclass_id(c);
      if ((v != lc) && (mi[1] > n)) {l[1] = v; mi[1] = i; }
  }


  // +t direction
  dir = vec2(0.0, steps.t);
  for (int i=1;i<=n;i++) 
  {
      vec2 c = c0+float(i)*dir;  
      int v = read_landclass_id(c);
      if ((v != lc) && (mi[2] > n)) {l[2] = v; mi[2] = i; }
  }


  // -t direction
  dir = vec2(0.0, -steps.t);
  for (int i=1;i<=n;i++) 
  {
      vec2 c = c0+float(i)*dir;
      int v = read_landclass_id(c);
      if ((v != lc) && (mi[3] > n)) {l[3] = v; mi[3] = i; }
  }


  // Set neighbour landclass

  // Choose closest neighbor
  // min number of steps before a neighbor was found in any direction
  int mns = n+1;
  // index of mi[] with min number of steps
  int idx1=-1;
  for (int j=0;j<4;j++)
  {
      if (mi[j] < mns) {mns = mi[j]; idx1 = j; lc_n[0] = l[j]; num_n=1;}
  }

  // Transitions:
  // Possible landclass property: Transition distance or weighting
  // e.g. larger transition between sand/grass terrain compared to forest/agriculture

  // Find mix factor and increase influence for 2, 3 or 4 nearby landclass blobs. 
  // If one neighbor landclass texture is looked up, even if the nearby landclasses 
  // are different only one texture will get prominence

  // At the boundary between landclasses there should be 50% influence.
  // If needed it's possible to add a dominance factor.

  // mi ranges from n+1 to 1. Mix factor ranges from [0.0 to 0.5] 
  // 3 point search example: 
  // [Num steps=Mixfactor value]: [no neighbor found = 0.0], [1 = 0.25], [2 = 0.5]

  
  // Calculate weights: map [n+1 to 1] to [0.0 to 0.5]
  vec4 w = 0.5*(1.0-(vec4(mi-1)/float(n)));


  // Calculate mix factor to draw one neighbor landclass
  float mf1=0.0;

  // Method 1:
  float max_w = max(max(max(w[0],w[1]),w[2]),w[3]);
  //mf1 = max_w;

  // Method 2: add up the influence and clamp to 0.5
  //mf1 = min(w.x+w.y+w.z+w.w, 0.5);


  // Method 3: weight influence without going over limit or needing to clamp
  // Example with influence [0 to 1]: 
  //    2 neighbors with 0.5 influence: 0.75 . 3 neighbors with 0.5 = 87.25
  //    of course influence is [0 to 0.5] but idea is the same
  mf1 = w[0];
  mf1 += (0.5-mf1)*w[1];
  mf1 += (0.5-mf1)*w[2];
  mf1 += (0.5-mf1)*w[3];

  // Mix factors: texels are mixed in from furthest, to closest
  //   mfact[0]: [0 to 0.5] texel and previous neighbour contributions
  //   mfact[1]: [0 to 1] mixing 1st and 2nd closest texels
  mfact[0] = mf1;


// Test phase controls:
if (enable_2nd_closest_neighbor_for_large_scale_transition_weights == 1)
{
  
  // Calculate mix factor for the case of two neighbour landclasses

  // index of mi[] with the 2nd lowest number of steps
  int idx2=-1;
  if (idx1 != -1) {

      // Choose 2nd closest neighbor        
      // Testing: look at a way to find 2 closest neighbors with less instructions
      // 2nd lowest number of steps
      int mns2 = n+1;
      for (int j=0;j<4;j++) {
          if ((mi[j] < mns2) && (mi[j] >= mns) && (j != idx1))
              {mns2 = mi[j]; lc_n[1] = l[j]; idx2=j; num_n=2;}
      }
  }


  // If two neighbors are found split available mix factor (mf1) by relative weights
  if (idx2 != -1) {
      float rw = w[idx2]/(w[idx1]+w[idx2]);
      mfact[1] = rw;
   }


} // End if (enable_2nd_closest_neighbor_for_large_scale_transition_weights == 1)


// Test phase controls
if (enable_dithering_for_large_scale_transitions == 1)
{ 
  // Add noise to change transition
  float tnoise1= Noise2D(tile_coord, dithering_noise_wavelength_as_fraction_of_step_size*steps.x);
  float noise = 0.5*(1.0-tnoise1)/float(n);
  mfact[0]=mfact[0]+noise; 
  mfact[0]=clamp(mfact[0],0.0,0.5);
}


// Test phase controls
if (grow_landclass_borders_with_large_scale_transition == 1)
{

  // Grow landclass borders with noise so landclass blobs that are too artificial
  // looking or coarse look natural.
  // A landclass with higher growth priority grows on to an adjacent landclass
  // with lower priority 

  // Decide whether to grow neighbor on to lc
  float grow_n = get_growth_priority(lc,lc_n[0],lc_n[1]);

  // Noise on the scale of landclass texels in the texture
  float tnoise2 = Noise2D(tile_coord, 0.4*transition_search_distance_in_m/tile_size.x);
  float threshold = mix(1.0,0.0, mfact[0]);
  float neighbor_growth_mixf = 0.3*mix(0.0,1.0,mfact[0]*2.0)*step(threshold-0.15,tnoise2);

  mfact[0] = mfact[0]+((grow_n > 0.0)?neighbor_growth_mixf:-neighbor_growth_mixf);
  mfact[0] = clamp(mfact[0],0.0,1.0);


  // Decide whether to extrude furthest neighbor or closest neighbor onto lc
  float grow_n1 = get_growth_priority(lc_n[0],lc_n[1]);

  mfact[1] = mfact[1]+((grow_n > 0.0)?neighbor_growth_mixf:+neighbor_growth_mixf);
  mfact[1] = clamp(mfact[1],0.0,1.0);


} // Testing: End if (grow_landclass_borders_with_large_scale_transition == 1)


} // Testing: End if ((enable_large_scale_transition_search == 1) && (max_neighbor_landclass_texture_lookups > 0))



  landclass_id = lc;
  neighbor_landclass_ids=lc_n;
  num_unique_neighbors = num_n;
  mix_factor = mfact;
}



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

  float mat_shininess = texture(dimensionsArray, index).z;
  vec4 mat_diffuse = texture(diffuseArray, index);
  vec4 mat_specular = texture(specularArray, index);

  vec4 color = gl_Color;

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

  // Look up texture coordinates and scale of ground textures

  // Landclass for this fragment

  texel = lookup_ground_texture_array(index, tile_coord, lc, dx, dy);


  // Mix texels - to work consistently it needs a more preceptual interpolation than mix()
  if (num_unique_neighbors != 0)
  {
     // Closest neighbor landclass
     vec4 texel_closest = lookup_ground_texture_array(index_n[0], tile_coord, lc_n[0], dx, dy);


     // Neighbor contributions
     vec4 texel_nc=texel_closest;

      if (num_unique_neighbors > 1)
      {
         // 2nd Closest neighbor landclass
         vec4 texel_2nd_closest = lookup_ground_texture_array(index_n[1], tile_coord, lc_n[1],
                                    dx, dy);


         texel_nc = mix(texel_closest, texel_2nd_closest, mfact[1]);
      }

     texel = mix(texel, texel_nc, mfact[0]);


  }

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
