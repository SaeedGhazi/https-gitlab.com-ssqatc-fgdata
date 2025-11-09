$FG_GLSL_VERSION

layout(location = 0) out vec4 fragColor;

in float flogz;
in vec3 texcoord;
in vec3 vs_pos;
in vec3 ws_pos;

uniform sampler3D rough_tex;
uniform sampler3D detailed_tex;
uniform sampler3D noise_tex;

uniform float fg_viewOriginVoxelSpace;
uniform vec3 fg_SunDirection;

// math.glsl
float M_1_4PI();
float safe_sqrt(float x);

// exposure.glsl
vec3 apply_exposure(vec3 color);

// logarithmic_depth.glsl
float logdepth_prepare_vs_depth(float z);

// logarithmic_depth.glsl
float logdepth_encode(float z);

// sun.glsl
//vec3 get_sun_radiance(vec3 p);
vec3 get_sun_radiance_sea_level();


const int MAX_MARCHING_STEPS = 500;
const float MIN_DIST = 0.000;
const float MAX_DIST = 1.0;
const float EPSILON = 0.0001;
const float IN_CLOUD_STEP_SIZE = 0.01;
const float HENYEY_GREENSTEIN_ECCENTRICITY  = 0.2;

//
// Function to erode a value given an erosion amount. A simplified version of SetRange.
//
float ValueErosion(float inValue, float inOldMin)
{
	float old_min_max_range = (1.0 - inOldMin);
	return clamp((inValue - inOldMin) / old_min_max_range, 0.0, 1.0);
}

// HenyeyGreenstein forward phase scattering
float HenyeyGreenstein(float inCosAngle, float inG)
{


    float num = 1.0 - inG * inG;
    float denom = 1.0 + inG * inG - 2.0 * inG * inCosAngle;
    float rsqrt_denom = safe_sqrt(denom);
    return num * rsqrt_denom * rsqrt_denom * rsqrt_denom * M_1_4PI();
}

/**
 * Signed distance function describing the scene.
 * 
 * Absolute value of the return value indicates the distance to the surface.
 * Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside.
 */
float sceneSDF(vec3 samplePoint) {
    // Alpha channel contains an SDF
    return texture(detailed_tex, samplePoint).a;
}

/**
 * Calculate the density of a given samplePoint
 */
float calculateDensity(vec3 samplePoint) {
    vec4 cloud = texture(detailed_tex, samplePoint);
    float cloudDimension = cloud.x;
    float cloudType = cloud.y;
    float cloudDensity = cloud.z;

    if (cloudDimension > 0.0) {
        vec4 noise = texture(noise_tex, samplePoint * 3.7);

        float wispy_noise = mix(noise.r, noise.g, cloudDimension);

        // Define billowy noise 
        float billowy_type_gradient = pow(cloudDimension, 0.25);
        float billowy_noise = mix(noise.b * 0.3, noise.a * 0.3, billowy_type_gradient);

        // Define Noise composite - blend to wispy as the density scale decreases.
        float noise_composite = mix(wispy_noise, billowy_noise, cloudType);
        
        float uprezzed_density = noise_composite;

        // Composite Noises and use as a Value Erosion
        uprezzed_density = ValueErosion(cloudDimension, noise_composite);

        // Modify User density scale
        float powered_density_scale = pow(clamp(cloudDensity, 0.0, 1.0), 4.0);

        // Apply User Density Scale Data to Result
        uprezzed_density *= powered_density_scale; 
            
        // Sharpen result
        uprezzed_density = pow(uprezzed_density, mix(0.3, 0.6, max(EPSILON, powered_density_scale)));

        return uprezzed_density;
    } else {
        // This is an error case, and shouldn't happen.
        return 0.0;
    }
}

/**
 * Signed distance function describing the scene.
 * Returns a vec2 containing
 * .x - SDF for samplePoint.
 * .y - density of the samplePoint if SDF =< 0
 *
 * Absolute value of the SDF value indicates the distance to the surface.
 * Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside.
 */
vec2 sceneDensitySDF(vec3 samplePoint) {
    // Alpha channel contains an SDF
    float sdf = texture(detailed_tex, samplePoint).a;
    float d = 0.0;
    if (sdf < EPSILON) {
        // We're inside the cloud, so work out the density and march by
        // a fixed amount.
        d = calculateDensity(samplePoint);
        sdf = IN_CLOUD_STEP_SIZE;
    }

    return vec2(sdf, d);
}

/**
 * Return a vec2 containing  
 * .x - the distance from the eye point to the first intersection with some cloud density.to the start of the cloud.
 * .y - the summed density of the ray intersection with the cloudfield from that point
 * 
 * If no part of the surface is found between start and end, return end.
 * 
 * eye: the eye point, acting as the origin of the ray
 * marchingDirection: the normalized direction to march in
 * start: the starting distance away from the eye
 * end: the max distance away from the ey to march before giving up
 */
vec2 shortestDistanceToSurfaceAndDensity(vec3 eye, vec3 marchingDirection, float start, float end) {
    vec2 distanceAndDensity = vec2(start,0.0);
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        vec2 sdf = sceneDensitySDF(eye + distanceAndDensity.x * marchingDirection);
        distanceAndDensity += sdf;
        if (distanceAndDensity.y > 0.95) {
            // Reached maximum density, so no point in marching further.
			return distanceAndDensity;
        }
        if (distanceAndDensity.x >= end) {
            // Reached the end of the raymarch.
            return distanceAndDensity;
        }
    }
    return distanceAndDensity;
}


/**
 * Return the normalized direction to march in from the eye point
 */
vec3 rayDirection() {
    return normalize(texcoord - vec3(0.5,0.5,0.5));
}

void main()
{   
    vec3 dir = rayDirection();
    vec3 eye = vec3(0.5, 0.5, 0.5);
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);


    vec2 distanceAndDensity = shortestDistanceToSurfaceAndDensity(eye, dir, MIN_DIST, MAX_DIST);
    
    if (distanceAndDensity.x < MAX_DIST) {
        // We have a density, do use Beers-Lambert law to work out the transmittance at this sample point
        float transmittance = exp(-distanceAndDensity.y);
        float CoSSunAngle = dot(normalize(fg_SunDirection), vec3(0,0,-1));
        float phase = HenyeyGreenstein(CoSSunAngle, HENYEY_GREENSTEIN_ECCENTRICITY);
        float inScattering = 1 - exp(-distanceAndDensity.y);

        float directScattering = transmittance * phase * inScattering;    

        color = vec4(1.0,1.0,1.0, distanceAndDensity.y);
        color.xyz = directScattering * get_sun_radiance_sea_level();
    }
    
    // Only pre-expose when not rendering to the environment map.
    // We want the non-exposed radiance values for IBL.
    color.rgb = apply_exposure(color.rgb);

    fragColor = color;

    float z = logdepth_prepare_vs_depth(distanceAndDensity.x);
    gl_FragDepth = logdepth_encode(z);
}
