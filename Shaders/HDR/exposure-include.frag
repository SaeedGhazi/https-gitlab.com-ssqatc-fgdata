#version 330 core

uniform float exposure_compensation;

const float one_over_log10 = 1.0 / log(10.0);

float log10(float x)
{
    return one_over_log10 * log(x);
}

// Exposure curve from 'Perceptual Effects in Real-time Tone Mapping'.
// http://resources.mpi-inf.mpg.de/hdr/peffects/krawczyk05sccg.pdf
float keyValue(float L)
{
    return 1.03 - 2.0 / (log10(L + 1.0) + 2.0);
}

vec3 applyExposure(vec3 color, float avgLuminance, float threshold)
{
    avgLuminance = max(avgLuminance, 0.001);
    float linearExposure = keyValue(avgLuminance) / avgLuminance;
    float exposure = log2(max(linearExposure, 0.0001));
    exposure += exposure_compensation - threshold;
    return color * exp2(exposure);
}
