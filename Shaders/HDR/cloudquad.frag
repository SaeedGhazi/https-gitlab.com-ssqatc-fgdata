$FG_GLSL_VERSION

layout(location = 0) out vec4 fragColor;

in vec2 texcoord;
in vec2 raw_texcoord; // QUAD_TEXCOORD_RAW
in vec3 w_pos;

uniform sampler3D detailed_tex;
uniform sampler3D rough_tex;
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
uniform vec4 fg_Viewport[FG_NUM_VIEWS];
uniform uint osg_FrameNumber;

uniform vec3 cloud_field_center;
uniform bool cloud_field_repeating;
uniform float voxel_resolution_m;
uniform int voxel_field_width;
uniform int voxel_field_height;
uniform int rough_field_factor;
uniform int rough_size_factor;
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

// aerial_perspective.glsl
vec3 add_aerial_perspective(vec3 color, vec2 raw_coord, vec3 P);

const float MIN_DIST = 0.000;
const float MAX_DIST = 4.0;
const float EPSILON = 0.000001;
const float NOISE_SCALE = 48.0;
const float HENYEY_GREENSTEIN_ECCENTRICITY  = 0.3;
const int MAX_LIGHT_STEPS = 5;

int MAX_MARCHING_STEPS = 4 * voxel_field_width;
float IN_CLOUD_STEP_SIZE = 0.1f / float(voxel_field_width);
float IN_CLOUD_SUN_RAY_STEP_SIZE = 1.0 / float(voxel_field_width);
float VOXEL_FIELD_WIDTH_M = float(voxel_field_width * voxel_resolution_m);
float VOXEL_FIELD_HEIGHT_M = float(voxel_field_height * voxel_resolution_m);

// Scaling factor to account for the voxel space not being a cube.
vec3 VOXEL_SCALE = vec3(1.0, 1.0, float(voxel_field_width) / float(voxel_field_height));
vec3 EYE_SCALE = vec3(VOXEL_FIELD_WIDTH_M, VOXEL_FIELD_WIDTH_M, VOXEL_FIELD_HEIGHT_M);

// Boundary where we use the detailed voxel space rather than the rough voxel space in UV coordinates
float DETAILED_X_Y_BOUNDARY = 0.5 / float(rough_field_factor);

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
 * Get cloud information for a given sample point, using either the detailed
 * or rough data as appropriate
 */
vec4 getCloud(vec3 samplePoint, vec3 dir)  {
    // If outside the voxel space then calculate an SDF directly.  This is basically the
    // z coordinate - 1.0, plus a little bit to ensure it ends up within the voxel space.
    if (samplePoint.z < 0.0) return vec4(0.0,0.0,0.0, -samplePoint.z / length(dir));
    if (samplePoint.z > 1.0) return vec4(0.0,0.0,0.0, (samplePoint.z - 1.0) / length(dir));

    if (cloud_field_repeating) return texture(detailed_tex, samplePoint);
    if ((abs(samplePoint.x - 0.5) < DETAILED_X_Y_BOUNDARY) && (abs(samplePoint.y - 0.5) < DETAILED_X_Y_BOUNDARY)) {
        // We're in the detailed space.  Scale the xy UV to the detailed voxel space
        vec3 uv = vec3((samplePoint.x - DETAILED_X_Y_BOUNDARY) * float(rough_field_factor),
                       (samplePoint.y - DETAILED_X_Y_BOUNDARY) * float(rough_field_factor),
                        samplePoint.z);
        return texture(detailed_tex, uv);
    } else {
        // We're in the rough space, so just use it as-is
        return texture(rough_tex, samplePoint);
    }
}

/**
 * Calculate the density of a given samplePoint
 */
float calculateDensity(vec3 samplePoint, vec3 dir) {
    vec4 cloud = getCloud(samplePoint, dir);
    float cloudDimension = cloud.x;
    float cloudType = cloud.y;
    float cloudDensity = cloud.z;

    if (cloudDimension > 0.0) {
        vec4 noise = texture(cloud_noise_tex, samplePoint * NOISE_SCALE / VOXEL_SCALE);

        float wispy_noise = mix(noise.r, noise.g, cloudDimension);

        // Define billowy noise 
        float billowy_type_gradient = pow(cloudDimension, 0.25);
        float billowy_noise = mix(noise.b * 0.3, noise.a * 0.3, billowy_type_gradient);

        // Define Noise composite: blend to wispy depending on the cloud type
        float noise_composite = mix(wispy_noise, billowy_noise, cloudType);        

        // Ultra-HF noise.
        //float hhf_wisps = 1.0 - pow(abs(abs(noise.g * 2.0 - 1.0) * 2.0 - 1.0), 4.0);
        //float hhf_billows = pow(abs(abs(noise.a * 2.0 - 1.0) * 2.0 - 1.0), 2.0);        
        //float hhf_noise_composite = mix(hhf_wisps, hhf_billows, cloudType);        
        //noise_composite = mix(hhf_noise_composite, noise_composite, depth * 10.0);

        float uprezzed_density = noise_composite;        

        // Composite Noises and use as a Value Erosion
        uprezzed_density = ValueErosion(cloudDimension*cloudDimension*cloudDimension, noise_composite);
        //uprezzed_density = ValueErosion(cloudDimension*cloudDensity, noise_composite);

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
    vec3 p = eye + distance * marchingDirection;

    //return texture(shade_tex, p).r;

    for (int i = 0; i < MAX_LIGHT_STEPS; i++) {
        p = eye + distance * marchingDirection;
        vec4 t = getCloud(p, marchingDirection);

        if (t.a < EPSILON) {
            // Inside a cloud, so add density
            density  += calculateDensity(p, marchingDirection);
            distance += IN_CLOUD_SUN_RAY_STEP_SIZE;
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

    // At this point just look up the pre-calculated shade texture
    p = eye + (distance + IN_CLOUD_SUN_RAY_STEP_SIZE) * marchingDirection;
    density = clamp(texture(shade_tex, p).r + density, 0.0, 1.0);
    return density;
}

struct sample_information {
    float sdf;
    float density;
    float direct_scattering;
    float ambient_scattering;
};

/**
 * Absolute value of the SDF value indicates the distance to the surface.
 * Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside.
 */
sample_information sceneDensitySDF(vec3 samplePoint, vec3 eye, vec3 dir) {
    sample_information lreturn;

    vec4 cloud = getCloud(samplePoint, dir);

    lreturn.sdf = cloud.a;  // Alpha channel contains an SDF
    lreturn.density = 0.0;
    lreturn.direct_scattering = 0.0;
    lreturn.ambient_scattering = 0.0;

    if (lreturn.sdf < EPSILON) {
        // Point is inside the cloud, so work out the density and lighting information
        lreturn.density = calculateDensity(samplePoint, dir);
        lreturn.sdf = IN_CLOUD_STEP_SIZE; // SDF is set to a fixed amount for ray-marching

        // Determine the light energy at this point, made up of direct and ambient scattering

        // Use Beers-Lambert law to work out the transmittance at this sample point, based on the density from 
        // sample point to the sun.

        // fg_SunDirectionWorld is in _normalized_ world space coordinates
        mat3 zup = mat3(fg_CameraZUpMatrix);
        vec3 sundir = normalize(zup * fg_SunDirectionWorld) * VOXEL_SCALE;

        vec3 eyedir = normalize(samplePoint - eye);
        float densityToSun = getRayDensity(samplePoint, sundir, IN_CLOUD_SUN_RAY_STEP_SIZE, 1.0);
        float transmittance = exp(- densityToSun);
        float CoSSunAngle = dot(normalize(sundir), eyedir);

        // TODO:  Have multiple of these phases?
        float phase = HenyeyGreenstein(CoSSunAngle, HENYEY_GREENSTEIN_ECCENTRICITY);
        float inScattering = 1 - exp(- lreturn.density);

        lreturn.direct_scattering = transmittance * phase  + inScattering * phase;

        // Ambient scatter is approximated to the dimensional profile and the density towards the sky.
        // Instead of an expensive ray march vertically, just read it straight from the shade texture
        float summedUpDensity = clamp(texture(shade_tex, samplePoint).g * ambient_intensity_scale, 0.0, 1.0);
        float dimensionalProfile = cloud.r;  // Red channel contains a cloud dimension
        lreturn.ambient_scattering = pow(1.0 - dimensionalProfile, 0.5) * exp(- summedUpDensity);
    }

    return lreturn;
}

struct ray_data {
    float light_absorption;
    float direct_intensity;
    float ambient_intensity;
    float first_hit;
};

ray_data cloudRayMarch(vec3 eye, vec3 marchingDirection, float start, float end) {
    ray_data lreturn;
    float distance = start;
    lreturn.first_hit = -1.0;

    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        vec3 p = eye + distance * marchingDirection;

        if ((distance >= end)) {
            // Reached the end of the raymarch
			return lreturn;
        }

        sample_information s = sceneDensitySDF(p, eye, marchingDirection);

        if (s.density > 0.0) {
            // As the ray travels, the influence of each step reduces due to the amount of absorption infront.  E.g. the amount of cloud occluding the sample.
            float occlusion = (1.0 - clamp(lreturn.light_absorption, 0.0, 1.0));
            lreturn.light_absorption  += s.density * occlusion;
            lreturn.direct_intensity  += s.direct_scattering * s.density * occlusion;
            lreturn.ambient_intensity += s.ambient_scattering * s.density * occlusion;

            if (lreturn.first_hit < EPSILON) lreturn.first_hit = distance;
        }

        if (lreturn.light_absorption > 0.99) {
            // Reached maximum density or end of ray so no point in marching further.
            lreturn.light_absorption = 1.0;
			return lreturn;
        }

        distance += s.sdf;
    }
	return lreturn;
}

void main()
{
    // Options to update 1/4 of the pixels each frame. Probably better to somehow mask instead of discard?
    //if (mod(uint(texcoord * fg_Viewport[FG_VIEW_ID].zw) + vec2(osg_FrameNumber, osg_FrameNumber), 4u) != vec2(0u,0u)) discard;
    //if (mod(osg_FrameNumber, 4) > 0u) discard;

    mat3 zup = mat3(fg_CameraZUpMatrix);
    vec3 wdir = w_pos - fg_CameraPositionCart;
    vec3 dir = normalize(zup * wdir) * VOXEL_SCALE; // Take into account that the voxel space is not a cube by increasing the Z-factor
    float zscaleFactor = length(dir);

    vec3 eye = (zup * (fg_CameraPositionCart - cloud_field_center)) / EYE_SCALE + vec3(0.5, 0.5, 0.0);
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    // Convert the logarithmic depth value into metres, and then scale to the voxel resolution 
    // so we know how far to search before we reach something solid.  This needs to take into account that the voxel space is not a cube by adjusting for the
    // actual length of the "normalized" direction.
    float max_depth_m = logdepth_decode(texture(depth_tex, texcoord).r);
    float max_depth_vx = min(max_depth_m / VOXEL_FIELD_WIDTH_M, MAX_DIST);

    ray_data ray = cloudRayMarch(eye, dir, MIN_DIST, max_depth_vx);
    
    if (ray.light_absorption > 0.01) {
        // XXXX : Need some better value for the ambient lighting value than ground_albedo.
        color.rgb = get_sun_radiance_sea_level() * ray.direct_intensity * direct_intensity_scale + ground_albedo.xyz * ray.ambient_intensity * ambient_intensity_scale;
        color.a = ray.light_absorption;

        float z = logdepth_prepare_vs_depth(ray.first_hit * VOXEL_FIELD_WIDTH_M / zscaleFactor);
        gl_FragDepth = logdepth_encode(z);

        // Add aerial perspective
        vec3 P = get_view_space_from_depth(texcoord, gl_FragDepth);
        color.rgb = add_aerial_perspective(color.rgb, raw_texcoord, P);
    }
    
    // Only pre-expose when not rendering to the environment map.
    // We want the non-exposed radiance values for IBL.
    color.rgb = apply_exposure(color.rgb);
    fragColor = color;
}