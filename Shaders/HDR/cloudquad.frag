$FG_GLSL_VERSION

layout(location = 0) out vec4 fragColor;

in vec2 texcoord;
in vec3 w_pos;

uniform sampler3D detailed_tex;
uniform sampler3D shade_tex;
uniform sampler2D depth_tex;
uniform sampler3D cloud_noise_tex;

uniform vec3 fg_SunDirectionWorld;
uniform vec3 fg_CameraPositionCart;
uniform float fg_AspectRatio;
uniform mat4 fg_CameraZUpMatrix;
uniform mat4 fg_ViewMatrix[FG_NUM_VIEWS];

FG_VIEW_GLOBAL
uniform mat4 fg_ViewMatrixInverse[FG_NUM_VIEWS];

uniform vec3 cloud_field_center;
uniform float voxel_resolution_m;
uniform float voxel_field_size;
uniform float ambient_intensity_scale;
uniform float direct_intensity_scale;

uniform vec4 ground_albedo;

// math.glsl
float M_1_4PI();
float safe_sqrt(float x);
mat3 getRotateRollPitchYaw(vec3 rpw);

// exposure.glsl
vec3 apply_exposure(vec3 color);

// logarithmic_depth.glsl
float logdepth_prepare_vs_depth(float z);
float logdepth_decode(float z);
float logdepth_encode(float z);

// sun.glsl
vec3 get_sun_radiance_sea_level();

// pos_from_depth.glsl
vec3 get_view_space_from_depth(vec2 uv, float depth);
vec3 get_world_space_from_depth(vec2 uv, float depth);


const int MAX_MARCHING_STEPS = 500;
const float MIN_DIST = 0.000;
const float MAX_DIST = 2.0;
const float EPSILON = 0.0001;
const float IN_CLOUD_STEPS = 1;
const float IN_CLOUD_STEP_SIZE = 1 / IN_CLOUD_STEPS / voxel_field_size;

const float IN_CLOUD_SUN_RAY_STEPS = 1;
const float IN_CLOUD_SUN_RAY_STEP_SIZE = 1 / IN_CLOUD_SUN_RAY_STEPS / voxel_field_size;

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
        vec4 noise = texture(cloud_noise_tex, samplePoint * 5.7);

        float wispy_noise = mix(noise.r, noise.g, cloudDimension);

        // Define billowy noise 
        float billowy_type_gradient = pow(cloudDimension, 0.25);
        float billowy_noise = mix(noise.b * 0.3, noise.a * 0.3, billowy_type_gradient);

        // Define Noise composite: blend to wispy depending on the cloud type
        float noise_composite = mix(wispy_noise, billowy_noise, cloudType);
        
        float uprezzed_density = noise_composite;

        // Composite Noises and use as a Value Erosion
        uprezzed_density = ValueErosion(cloudDimension, noise_composite);

        // Apply User Density Scale Data to Result
        uprezzed_density *= cloudDensity; 
            
        // Sharpen result
        float powered_density_scale = pow(clamp(cloudDensity, 0.0, 1.0), 4.0);
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
        vec4 t = texture(detailed_tex, eye + distance * marchingDirection);

        if (t.a < EPSILON) {
            // Inside a cloud, so integrate the density, but with increasing distances
            density  += t.z; // * in_cloud_steps * IN_CLOUD_SUN_RAY_STEP_SIZE * voxel_field_size;
            distance += IN_CLOUD_SUN_RAY_STEP_SIZE; // * in_cloud_steps;
        } else {
            distance += t.a;
        }

        if (density > 0.99) {
            // Reached maximum density, so no point in marching further.
			return 1.0;
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
    // debug
    // vec3 sundir;
    // end debug
};

/**
 * Absolute value of the SDF value indicates the distance to the surface.
 * Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside.
 */
sample_information sceneDensitySDF(vec3 samplePoint, vec3 eye) {
    sample_information lreturn;

    lreturn.sdf = texture(detailed_tex, samplePoint).a;  // Alpha channel contains an SDF
    lreturn.density = 0.0;
    lreturn.direct_scattering = 0.0;
    lreturn.ambient_scattering = 0.0;

    if (lreturn.sdf < EPSILON) {
        // Point is inside the cloud, so work out the density and lighting information
        lreturn.density = calculateDensity(samplePoint);
        lreturn.sdf = IN_CLOUD_STEP_SIZE; // SDF is set to a fixed amount for ray-marching

        // Determine the light energy at this point, made up of direct and ambient scattering

        // Use Beers-Lambert law to work out the transmittance at this sample point, based on the density from 
        // sample point to the sun.

        // fg_SunDirectionWorld is in _normalized_ world space coordinates
        mat3 zup = mat3(fg_CameraZUpMatrix);
        vec3 sundir = zup * fg_SunDirectionWorld;

        vec3 eyedir = normalize(samplePoint - eye);
        //float densityToSun = getRayDensity(samplePoint, sundir, IN_CLOUD_SUN_RAY_STEP_SIZE, 1.0);
        float densityToSun = clamp(0.0,1.0, texture(shade_tex, samplePoint).r);
        float transmittance = exp(- densityToSun);
        float CoSSunAngle = dot(sundir, eyedir);

        // TODO:  Have multiple of these phases?
        float phase = HenyeyGreenstein(CoSSunAngle, HENYEY_GREENSTEIN_ECCENTRICITY);
        float inScattering = 1 - exp(- lreturn.density);

        lreturn.direct_scattering = transmittance * phase  + inScattering * phase;

        // Debug
        //lreturn.sundir = sundir;
        // end debug


        // Ambient scatter is approximated to the dimensional profile and the density towards the sky.
        //float summedUpDensity = getRayDensity(samplePoint, vec3(0.0,0.0,1.0), IN_CLOUD_SUN_RAY_STEP_SIZE, 1.0);
        float summedUpDensity = clamp(0.0, 1.0, texture(shade_tex, samplePoint).g);
        float dimensionalProfile = texture(detailed_tex, samplePoint).r;  // Red channel contains a cloud dimension
        lreturn.ambient_scattering = pow(1.0 - dimensionalProfile, 0.5) * exp(- summedUpDensity);
    }

    return lreturn;
}

struct ray_data {
    float light_absorption;
    float direct_intensity;
    float ambient_intensity;
    float distance;
    vec3 sundir;
};

ray_data cloudRayMarch(vec3 eye, vec3 marchingDirection, float start, float end) {
    ray_data lreturn; 
    lreturn.distance = start;

    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        vec3 p = eye + lreturn.distance * marchingDirection;

        if ((lreturn.distance >= end)) {
            // Reached the end of the raymarch
			return lreturn;
        }

        sample_information s = sceneDensitySDF(p, eye);

        if (s.density > 0.0) {
            // As the ray travels, the influence of each step reduces due to the amount of absorption infront.  E.g. the amount of cloud occluding the sample.
            float occlusion = (1.0 - clamp(lreturn.light_absorption, 0.0, 1.0));
            lreturn.light_absorption  += s.density * occlusion;
            lreturn.direct_intensity  += s.direct_scattering * s.density * occlusion;
            lreturn.ambient_intensity += s.ambient_scattering * s.density * occlusion;

            // debug
            // lreturn.sundir = s.sundir;
            // return lreturn;
            // end debug
            
        }

        if (lreturn.light_absorption > 0.99) {
            // Reached maximum density or end of ray so no point in marching further.
            lreturn.light_absorption = 1.0;
			return lreturn;
        }

        lreturn.distance += s.sdf;
    }
	return lreturn;
}

void main()
{
    float voxel_field_size_m = voxel_field_size * voxel_resolution_m;

    mat3 zup = mat3(fg_CameraZUpMatrix);
    vec3 wdir = normalize(w_pos - fg_CameraPositionCart);
    vec3 dir = zup * wdir;
    vec3 eye = (zup * (fg_CameraPositionCart - cloud_field_center)) / voxel_field_size_m + vec3(0.5, 0.5, 0.0);

    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    // Convert the logarithmic depth value into metres, and then scale to the voxel resolution 
    // so we know how far to search before we reach something solid
    float max_depth_m = logdepth_decode(texture(depth_tex, texcoord).r);
    float max_depth_vx = min(max_depth_m / voxel_field_size_m, MAX_DIST);
    
    ray_data ray = cloudRayMarch(eye, dir, MIN_DIST, max_depth_vx);
    
    if (ray.light_absorption > 0.01) {
        // XXXX : Need some better value for the ambient lighting value than ground_albedo.
        vec3 sun_intensity = get_sun_radiance_sea_level();
        //color.rgb = get_sun_radiance_sea_level() * ray.direct_intensity * direct_intensity_scale + ground_albedo.xyz * ray.ambient_intensity * ambient_intensity_scale;
        color.rgb = sun_intensity * ray.direct_intensity * direct_intensity_scale + ground_albedo.xyz * ray.ambient_intensity * ambient_intensity_scale;
        //color.rgb = vec3(0, ray.direct_intensity, 0);

        color.a = ray.light_absorption;

        float z = logdepth_prepare_vs_depth(ray.distance * voxel_field_size_m);
        gl_FragDepth = logdepth_encode(z);

        // debug
        //color.rgb = ray.sundir;
        // end debug
        
    }
    
    // Only pre-expose when not rendering to the environment map.
    // We want the non-exposed radiance values for IBL.
    color.rgb = apply_exposure(color.rgb);
    fragColor = color;
    
}