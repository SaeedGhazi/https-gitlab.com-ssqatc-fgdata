$FG_GLSL_VERSION

layout(location = 0) out vec4 fragColor;

in float flogz;
in vec3 texcoord;
in vec3 vs_pos;

uniform sampler3D rough_tex;
uniform sampler3D detailed_tex;
uniform sampler3D noise_tex;

uniform float fg_viewOriginVoxelSpace;

// exposure.glsl
vec3 apply_exposure(vec3 color);
// logarithmic_depth.glsl
float logdepth_encode(float z);



const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.000;
const float MAX_DIST = 1.0;
const float EPSILON = 0.0001;

//
// Function to remap a value from one range to another. It is slightly cheaper than SetRange
//
#define ValueRemapFuncionDef(DATA_TYPE) \
	DATA_TYPE ValueRemap(DATA_TYPE inValue, DATA_TYPE inOldMin, DATA_TYPE inOldMax, DATA_TYPE inMin, DATA_TYPE inMax) \
	{ \
		DATA_TYPE old_min_max_range = (inOldMax - inOldMin); \
		DATA_TYPE clamped_normalized = clamp((inValue - inOldMin) / old_min_max_range, 0.0, 1.0); \
		return inMin + (clamped_normalized*(inMax - inMin)); \
	}

ValueRemapFuncionDef(float)
ValueRemapFuncionDef(vec2)
ValueRemapFuncionDef(vec3)
ValueRemapFuncionDef(vec4)

//
// Function to erode a value given an erosion amount. A simplified version of SetRange.
//
float ValueErosion(float inValue, float inOldMin)
{
	float old_min_max_range = (1.0 - inOldMin);
	float clamped_normalized = clamp((inValue - inOldMin, 0.0, 1.0) / old_min_max_range, 0.0, 1.0);
	return (clamped_normalized);
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
    return texture(rough_tex, samplePoint).a;
}

/**
 * Return the shortest distance from the eyepoint to the scene surface along
 * the marching direction. If no part of the surface is found between start and end,
 * return end.
 * 
 * eye: the eye point, acting as the origin of the ray
 * marchingDirection: the normalized direction to march in
 * start: the starting distance away from the eye
 * end: the max distance away from the ey to march before giving up
 */
float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(eye + depth * marchingDirection);
        if (dist < EPSILON) {
			return depth;
        }

        depth += dist;
        if (depth >= end) {
            return end;
        }
    }
    return end;
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

    float dist = shortestDistanceToSurface(eye, dir, MIN_DIST, MAX_DIST);
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    
    if (dist >= MAX_DIST) {
        // Didn't hit anything
        color = vec4(0.0, 0.0, 1.0, 0.5);
    } else {

        // We have a hit!

        vec3 pt = (eye + dist*dir);
        vec4 cloud = texture(rough_tex, pt);
        float cloudDimension = cloud.x;
        float cloudType = cloud.y;
        float cloudDensity = cloud.z;

        if (cloudDimension > 0.0) {
            vec4 noise = texture(noise_tex, pt);

            float wispy_noise = mix(noise.r, noise.g, cloudDimension);

            // Define billowy noise 
            float billowy_type_gradient = pow(cloudDimension, 0.25);
            float billowy_noise = mix(noise.b * 0.3, noise.a * 0.3, billowy_type_gradient);

            // Define Noise composite - blend to wispy as the density scale decreases.
            float noise_composite = mix(wispy_noise, billowy_noise, cloudType);

            // Composote Noises and use as a Value Erosion - this is going wrong!
            float uprezzed_density = ValueErosion(cloudDimension, noise_composite);

            // Modify User density scale
            float powered_density_scale = pow(clamp(cloudDensity, 0.0, 1.0), 4.0);

            // Apply User Density Scale Data to Result
            uprezzed_density *= powered_density_scale; 
                
            // Sharpen result
            uprezzed_density = pow(uprezzed_density, mix(0.3, 0.6, max(EPSILON, powered_density_scale)));

            float profile = cloudDimension * uprezzed_density;

            color = vec4(1.0,1.0,1.0, noise_composite);
            
            //color = noise;
            //color = vec4(pt, 1.0);
        } else {
            color = vec4(pt.xyz, 1.0);
        }

        //color = vec4(1.0, 0.0,0.0,1.0);
    }
    
    // Only pre-expose when not rendering to the environment map.
    // We want the non-exposed radiance values for IBL.
    color.rgb = apply_exposure(color.rgb);

    fragColor = color;
    gl_FragDepth = logdepth_encode(flogz);
}
