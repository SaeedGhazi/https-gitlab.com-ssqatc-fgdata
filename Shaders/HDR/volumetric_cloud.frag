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
uniform vec4 ground_albedo;

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
vec3 get_sun_radiance_sea_level();

const int MAX_MARCHING_STEPS = 500;
const float MIN_DIST = 0.000;
const float MAX_DIST = 1.0;
const float EPSILON = 0.0001;
const float IN_CLOUD_STEP_SIZE = 0.001;
const float HENYEY_GREENSTEIN_ECCENTRICITY  = 0.3;
const float DIRECT_INTENSITY_SCALE = 10.0;
const float AMBIENT_INTENSITY_SCALE = 10.0;

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
        vec4 noise = texture(noise_tex, samplePoint * 7.7);

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

float getRayDensity(vec3 eye, vec3 marchingDirection, float start, float end) {
    float density = 0.0;
    float distance = start;
    
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        distance += texture(detailed_tex, eye + distance * marchingDirection).a;
        density  += texture(detailed_tex, eye + distance * marchingDirection).z;

        if (density > 0.99) {
            // Reached maximum density, so no point in marching further.
			return density;
        }
        if (distance >= end) {
            // Reached the end of the raymarch.
            return density;
        }
    }
    return density;
}

struct sample_information {
    float sdf;
    float density;
    float direct_scattering;
    float ambient_scattering;
};

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
sample_information sceneDensitySDF(vec3 samplePoint, vec3 eye) {
    sample_information lreturn;

    lreturn.sdf = texture(detailed_tex, samplePoint).a;  // Alpha channel contains an SDF
    lreturn.density = 0.0;
    if (lreturn.sdf < EPSILON) {
        // We're inside the cloud, so work out the density and lighting information
        lreturn.density = calculateDensity(samplePoint);
        lreturn.sdf = IN_CLOUD_STEP_SIZE; // SDF is set to a fixed amount for ray-marching

        // Determine the light energy at this point, made up of direct and ambient scattering

        // Use Beers-Lambert law to work out the transmittance at this sample point, based on the density from 
        // sample point to the sun.
        vec3 sundir = normalize(fg_SunDirection);
        vec3 eyedir = normalize(samplePoint - eye);
        float densityToSun = getRayDensity(samplePoint, sundir, 0.0, MAX_DIST);
        float transmittance = exp(- densityToSun);
        float CoSSunAngle = dot(sundir, eyedir);
        float phase = HenyeyGreenstein(CoSSunAngle, HENYEY_GREENSTEIN_ECCENTRICITY);
        float inScattering = 1 - exp(- lreturn.density);

        lreturn.direct_scattering = transmittance * phase * inScattering;    

        // Ambient scatter is approximated to the dimensional profile. TODO - include summed density towards the sky
        float dimensionalProfile = texture(detailed_tex, samplePoint).r;
        lreturn.ambient_scattering = pow(1.0 - dimensionalProfile, 0.5);
    }

    return lreturn;
}

struct ray_data {
    float light_absorption;
    float direct_intensity;
    float ambient_intensity;
    float distance;
};

ray_data cloudRayMarch(vec3 eye, vec3 marchingDirection, float start, float end) {
    ray_data lreturn; 
    lreturn.distance = start;
    
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        sample_information s = sceneDensitySDF(eye + lreturn.distance * marchingDirection, eye);
        lreturn.distance += s.sdf;

        if (s.density > 0.0) {
            // We have cloud data, so integrate

            // As the ray travels, the influence of each step reduces due to the amount of absorption infront.  E.g. the amount of cloud occluding the sample.
            float occlusion = (1.0 - clamp(lreturn.light_absorption, 0.0, 1.0));
            lreturn.light_absorption  += s.density * occlusion;
            lreturn.direct_intensity  += s.direct_scattering * s.density * occlusion;
            lreturn.ambient_intensity += s.ambient_scattering * s.density * occlusion;
        }

        if (lreturn.light_absorption > 0.99) {
            // Reached maximum density or end of ray so no point in marching further.
			return lreturn;
        }

        if (lreturn.distance >= end) {
            // Reached the end of the raymarch.
			return lreturn;
        }
    }
	return lreturn;
}

void main()
{   
    vec3 dir = normalize(texcoord - vec3(0.5,0.5,0.5));
    vec3 eye = vec3(0.5, 0.5, 0.5);
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);


    ray_data ray = cloudRayMarch(eye, dir, MIN_DIST, MAX_DIST);
    
    if (ray.light_absorption > 0.0) {
        // XXXX : Need some better value for the ambient lighting value than ground_albedo.
        color.xyz = DIRECT_INTENSITY_SCALE * ray.direct_intensity * get_sun_radiance_sea_level() + AMBIENT_INTENSITY_SCALE * ray.ambient_intensity * ground_albedo.xyz;
        color.a = ray.light_absorption;

        float z = logdepth_prepare_vs_depth(ray.distance);
        gl_FragDepth = logdepth_encode(z);
    }
    
    // Only pre-expose when not rendering to the environment map.
    // We want the non-exposed radiance values for IBL.
    color.rgb = apply_exposure(color.rgb);
    fragColor = color;
}
