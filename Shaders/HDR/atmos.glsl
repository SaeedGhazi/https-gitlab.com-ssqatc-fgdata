#version 330 core

// math.glsl
float M_PI();
float M_1_PI();
float M_1_4PI();

const float RAYLEIGH_PHASE_SCALE = 0.05968310365946075091; // 3/(16*pi)
const float HENYEY_ASYMMETRY = 0.8;
const float HENYEY_ASYMMETRY2 = HENYEY_ASYMMETRY*HENYEY_ASYMMETRY;

// Rayleigh scattering coefficient at sea level, units m^-1
// "Rayleigh-scattering calculations for the terrestrial atmosphere"
// by Anthony Bucholtz (1995).
const vec4 molecular_scattering_coefficient_base =
    vec4(6.605e-6, 1.067e-5, 1.842e-5, 3.156e-5);

// Ozone absorption cross section, units m^2 / molecules
// "High spectral resolution ozone absorption cross-sections"
// by V. Gorshelev et al. (2014).
const vec4 ozone_cross_section =
    vec4(3.472e-21, 3.914e-21, 1.349e-21, 11.03e-23) * 1e-4f;

const float ozone_mean_monthly_dobson[] = float[](
    347.0, // January
    370.0, // February
    381.0, // March
    384.0, // April
    372.0, // May
    352.0, // June
    333.0, // July
    317.0, // August
    298.0, // September
    285.0, // October
    290.0, // November
    315.0  // December
    );
const float ozone_height_distribution[] = float[](
    9.0   / 210.0,
    14.0  / 210.0,
    111.0 / 210.0,
    64.0  / 210.0,
    6.0   / 210.0,
    6.0   / 210.0,
    0.0
    );

/*
 * Every aerosol type expects 5 parameters:
 * - Scattering cross section
 * - Absorption cross section
 * - Base density (km^-3)
 * - Background density (km^-3)
 * - Height scaling parameter
 * These parameters can be sent as uniforms.
 *
 * This model for aerosols and their corresponding parameters come from
 * "A Physically-Based Spatio-Temporal Sky Model"
 * by Guimera et al. (2018).
 */
// Urban
uniform vec4 aerosol_absorption_cross_section =
    vec4(2.8722e-24, 4.6168e-24, 7.9706e-24, 1.3578e-23);
uniform vec4 aerosol_scattering_cross_section =
    vec4(1.5908e-22, 1.7711e-22, 2.0942e-22, 2.4033e-22);
uniform float aerosol_base_density = 1.3681e20;
uniform float aerosol_relative_background_density = 2e6 / 1.3681e20;
uniform float aerosol_height_scale = 0.73;

uniform float aerosol_turbidity = 1.0;

uniform int month_of_the_year = 0;
uniform vec4 ground_albedo = vec4(0.3);

uniform float fg_EarthRadius;

//------------------------------------------------------------------------------

float get_earth_radius()
{
    return fg_EarthRadius;
}

float get_atmosphere_radius()
{
    return 6471e3; // m
}

/*
 * Helper function to obtain the transmittance to the top of the atmosphere
 * from the precomputed transmittance LUT.
 */
vec4 transmittance_from_lut(sampler2D lut, float cos_theta, float normalized_altitude)
{
    float u = clamp(cos_theta * 0.5 + 0.5, 0.0, 1.0);
    float v = clamp(normalized_altitude, 0.0, 1.0);
    return texture(lut, vec2(u, v));
}

/*
 * Returns the distance between ro and the first intersection with the sphere
 * or -1.0 if there is no intersection. The sphere's origin is (0,0,0).
 * -1.0 is also returned if the ray is pointing away from the sphere.
 */
float ray_sphere_intersection(vec3 ro, vec3 rd, float radius)
{
    float b = dot(ro, rd);
    float c = dot(ro, ro) - radius*radius;
    if (c > 0.0 && b > 0.0) return -1.0;
    float d = b*b - c;
    if (d < 0.0) return -1.0;
    if (d > b*b) return (-b+sqrt(d));
    return (-b-sqrt(d));
}

/*
 * Rayleigh phase function.
 */
float molecular_phase_function(float cos_theta)
{
    return RAYLEIGH_PHASE_SCALE * (1.0 + cos_theta*cos_theta);
}

/*
 * Henyey-Greenstrein phase function.
 */
float aerosol_phase_function(float cos_theta)
{
    float den = 1.0 + HENYEY_ASYMMETRY2 + 2.0 * HENYEY_ASYMMETRY * cos_theta;
    return M_1_4PI() * (1.0 - HENYEY_ASYMMETRY2) / (den * sqrt(den));
}

/*
 * Get the approximated multiple scattering contribution for a given point
 * within the atmosphere.
 */
vec4 get_multiple_scattering(sampler2D transmittance_lut,
                             float cos_theta,
                             float normalized_height,
                             float d)
{
    // Solid angle subtended by the planet from a point at d distance
    // from the planet center.
    float omega = 2.0 * M_PI() * (1.0 - sqrt(d*d - get_earth_radius()*fg_EarthRadius) / d);
    omega = max(0.0, omega);

    vec4 T_to_ground = transmittance_from_lut(transmittance_lut, cos_theta, 0.0);

    vec4 T_ground_to_sample =
        transmittance_from_lut(transmittance_lut, 1.0, 0.0) /
        transmittance_from_lut(transmittance_lut, 1.0, normalized_height);

    // 2nd order scattering from the ground
    vec4 L_ground = M_1_4PI() * omega * (ground_albedo * M_1_PI())
        * T_to_ground * T_ground_to_sample * max(0.0, cos_theta);

    // Fit of Earth's multiple scattering coming from other points in the atmosphere
    vec4 L_ms = 0.02 * vec4(0.217, 0.347, 0.594, 1.0)
        * (1.0 / (1.0 + 5.0 * exp(-17.92 * cos_theta)));

    return L_ms + L_ground;
}

/*
 * Return the molecular volume scattering coefficient (m^-1) for a given altitude
 * in kilometers.
 */
vec4 get_molecular_scattering_coefficient(float h)
{
    return molecular_scattering_coefficient_base
        * exp(-0.07771971 * pow(h, 1.16364243));
}

/*
 * Return the molecular volume absorption coefficient (km^-1) for a given altitude
 * in kilometers.
 */
vec4 get_molecular_absorption_coefficient(float h)
{
    int i = int(clamp(h / 9.0, 0.0, 6.0));
    float density = ozone_height_distribution[i] *
        ozone_mean_monthly_dobson[month_of_the_year] * 2.6867e20f; // molecules / m^2
    density /= 9e3; // m^-3
    return ozone_cross_section * density; // m^-1
}

/*
 * Return the aerosol density for a given altitude in kilometers.
 */
float get_aerosol_density(float h)
{
    return aerosol_base_density * (exp(-h / aerosol_height_scale)
                                   + aerosol_relative_background_density);
}

/*
 * Get the collision coefficients (scattering and absorption) of the
 * atmospheric medium for a given point at an altitude h.
 */
void get_atmosphere_collision_coefficients(in float h,
                                           out vec4 aerosol_absorption,
                                           out vec4 aerosol_scattering,
                                           out vec4 molecular_absorption,
                                           out vec4 molecular_scattering,
                                           out vec4 extinction)
{
    h = max(h, 0.0); // In case height is negative
    float aerosol_density = get_aerosol_density(h * 1e-3) * aerosol_turbidity;
    aerosol_absorption = aerosol_absorption_cross_section * aerosol_density * 1e-3;
    aerosol_scattering = aerosol_scattering_cross_section * aerosol_density * 1e-3;
    molecular_absorption = get_molecular_absorption_coefficient(h * 1e-3);
    molecular_scattering = get_molecular_scattering_coefficient(h * 1e-3);
    extinction =
        aerosol_absorption + aerosol_scattering +
        molecular_absorption + molecular_scattering;
}

/*
 * Any given ray inside the atmospheric medium can end in one of 3 places:
 * 1. The Earth's surface.
 * 2. Outer space. We define the boundary between space and the atmosphere
 *    at the Kármán line (100 km above sea level).
 * 3. Any object within the atmosphere.
 */
float get_ray_end(vec3 ray_origin, vec3 ray_dir, float t_max)
{
    float ray_altitude = length(ray_origin);
    // Handle the camera being underground
    float earth_radius = min(ray_altitude, get_earth_radius());
    float atmos_dist  = ray_sphere_intersection(ray_origin, ray_dir, get_atmosphere_radius());
    float ground_dist = ray_sphere_intersection(ray_origin, ray_dir, earth_radius);
    float t_d;
    if (ray_altitude < get_atmosphere_radius()) {
        // We are inside the atmosphere
        if (ground_dist < 0.0) {
            // No ground collision, use the distance to the outer atmosphere
            t_d = atmos_dist;
        } else {
            // We have a collision with the ground, use the distance to it
            t_d = ground_dist;
        }
    } else {
        // We are in outer space
        // XXX: For now this is a flight simulator, not a space simulator
        t_d = -1.0;
    }
    return min(t_d, t_max);
}

/*
 * Compute the in-scattering integral of the volume rendering equation (VRE)
 *
 * The integral is solved numerically by ray marching. The final in-scattering
 * returned by this function is a 4D vector of the spectral radiance sampled for
 * the 4 wavelengths at the top of this file. To obtain an RGB triplet, the
 * spectral radiance must be multiplied by the spectral irradiance of the Sun
 * and converted to sRGB.
 */
vec4 compute_inscattering(in vec3 ray_origin,
                          in vec3 ray_dir,
                          in float t_max,
                          in vec3 sun_dir,
                          in int steps,
                          in sampler2D transmittance_lut,
                          out vec4 transmittance)
{
    float cos_theta = dot(-ray_dir, sun_dir);

    float molecular_phase = molecular_phase_function(cos_theta);
    float aerosol_phase = aerosol_phase_function(cos_theta);

    float dt = t_max / float(steps);

    vec4 L_inscattering = vec4(0.0);
    transmittance = vec4(1.0);

    for (int i = 0; i < steps; ++i) {
        float t = (float(i) + 0.5) * dt;
        vec3 x_t = ray_origin + ray_dir * t;

        float distance_to_earth_center = length(x_t);
        vec3 zenith_dir = x_t / distance_to_earth_center;
        float altitude = distance_to_earth_center - get_earth_radius();
        float normalized_altitude = altitude / (get_atmosphere_radius() - get_earth_radius());

        float sample_cos_theta = dot(zenith_dir, sun_dir);

        vec4 aerosol_absorption, aerosol_scattering;
        vec4 molecular_absorption, molecular_scattering;
        vec4 extinction;
        get_atmosphere_collision_coefficients(
            altitude,
            aerosol_absorption, aerosol_scattering,
            molecular_absorption, molecular_scattering,
            extinction);

        vec4 transmittance_to_sun = transmittance_from_lut(
            transmittance_lut, sample_cos_theta, normalized_altitude);

        vec4 ms = get_multiple_scattering(
            transmittance_lut, sample_cos_theta, normalized_altitude,
            distance_to_earth_center);

        vec4 S =
            molecular_scattering * (molecular_phase * transmittance_to_sun + ms) +
            aerosol_scattering   * (aerosol_phase   * transmittance_to_sun + ms);

        vec4 step_transmittance = exp(-dt * extinction);

        // Energy-conserving analytical integration
        // "Physically Based Sky, Atmosphere and Cloud Rendering in Frostbite"
        // by Sébastien Hillaire
        vec4 S_int = (S - S * step_transmittance) / max(extinction, 1e-7);
        L_inscattering += transmittance * S_int;
        transmittance *= step_transmittance;
    }

    return L_inscattering;
}
