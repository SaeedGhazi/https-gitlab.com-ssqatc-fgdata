#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;

in vec4 waterTex1;
in vec4 waterTex2;
in mat3 TBN;
in vec3 relpos;
in vec2 TopoUV;

uniform sampler2D perlin_normalmap;
uniform sampler2D water_dudvmap;
uniform sampler2D water_normalmap;
uniform sampler2D water_colormap;

uniform float WindE;
uniform float WindN;
uniform float WaveFreq;
uniform float WaveAmp;
uniform float WaveSharp;
uniform float WaveAngle;
uniform float WaveFactor;
uniform float WaveDAngle;

uniform float osg_SimulationTime;
uniform vec3 fg_SunDirection;

// normal_encoding.glsl
vec2 encode_normal(vec3 n);
// color.glsl
vec3 eotf_inverse_sRGB(vec3 srgb);

void rotationmatrix(float angle, out mat4 rotmat)
{
    rotmat = mat4( cos( angle ), -sin( angle ), 0.0, 0.0,
                   sin( angle ),  cos( angle ), 0.0, 0.0,
                   0.0         ,  0.0         , 1.0, 0.0,
                   0.0         ,  0.0         , 0.0, 1.0 );
}

// wave functions ///////////////////////

struct Wave {
    float freq;  // 2*PI / wavelength
    float amp;   // amplitude
    float phase; // speed * 2*PI / wavelength
    vec2 dir;
};

Wave wave0 = Wave(1.0, 1.0, 0.5, vec2(0.97, 0.25));
Wave wave1 = Wave(2.0, 0.5, 1.3, vec2(0.97, -0.25));
Wave wave2 = Wave(1.0, 1.0, 0.6, vec2(0.95, -0.3));
Wave wave3 = Wave(2.0, 0.5, 1.4, vec2(0.99, 0.1));

float evaluateWave(in Wave w, vec2 pos, float t)
{
    return w.amp * sin( dot(w.dir, pos) * w.freq + t * w.phase);
}

// derivative of wave function
float evaluateWaveDeriv(Wave w, vec2 pos, float t)
{
    return w.freq * w.amp * cos( dot(w.dir, pos)*w.freq + t*w.phase);
}

// sharp wave functions
float evaluateWaveSharp(Wave w, vec2 pos, float t, float k)
{
    return w.amp * pow(sin( dot(w.dir, pos)*w.freq + t*w.phase)* 0.5 + 0.5 , k);
}

float evaluateWaveDerivSharp(Wave w, vec2 pos, float t, float k)
{
    return k*w.freq*w.amp * pow(sin( dot(w.dir, pos)*w.freq + t*w.phase)* 0.5 + 0.5 , k - 1) * cos( dot(w.dir, pos)*w.freq + t*w.phase);
}

void sumWaves(float angle, float dangle, float windScale, float factor, out float ddx, float ddy)
{
    mat4 RotationMatrix;
    float deriv;
    vec4 P = waterTex1 * 1024;

    rotationmatrix(radians(angle + dangle * windScale + 0.6 * sin(P.x * factor)), RotationMatrix);
    P *= RotationMatrix;

    P.y += evaluateWave(wave0, P.xz, osg_SimulationTime);
    deriv = evaluateWaveDeriv(wave0, P.xz, osg_SimulationTime );
    ddx = deriv * wave0.dir.x;
    ddy = deriv * wave0.dir.y;

    P.y += evaluateWave(wave1, P.xz, osg_SimulationTime);
    deriv = evaluateWaveDeriv(wave1, P.xz, osg_SimulationTime);
    ddx += deriv * wave1.dir.x;
    ddy += deriv * wave1.dir.y;

    P.y += evaluateWaveSharp(wave2, P.xz, osg_SimulationTime, WaveSharp);
    deriv = evaluateWaveDerivSharp(wave2, P.xz, osg_SimulationTime, WaveSharp);
    ddx += deriv * wave2.dir.x;
    ddy += deriv * wave2.dir.y;

    P.y += evaluateWaveSharp(wave3, P.xz, osg_SimulationTime, WaveSharp);
    deriv = evaluateWaveDerivSharp(wave3, P.xz, osg_SimulationTime, WaveSharp);
    ddx += deriv * wave3.dir.x;
    ddy += deriv * wave3.dir.y;
}

void main()
{
    const vec4 sca = vec4(0.005, 0.005, 0.005, 0.005);
    const vec4 sca2 = vec4(0.02, 0.02, 0.02, 0.02);
    const vec4 tscale = vec4(0.25, 0.25, 0.25, 0.25);

    mat4 RotationMatrix;

    float windEffect = sqrt(WindE*WindE + WindN*WindN) * 0.6;
    float windScale = 15.0/(3.0 + windEffect);
    float windEffect_low = 0.3 + 0.7 * smoothstep(0.0, 5.0, windEffect);
    float waveRoughness = 0.01 + smoothstep(0.0, 40.0, windEffect);

    float mixFactor = 0.2 + 0.02 * smoothstep(0.0, 50.0, windEffect);
    mixFactor = clamp(mixFactor, 0.3, 0.8);

    // sine waves
    float ddx, ddx1, ddx2, ddx3, ddy, ddy1, ddy2, ddy3;
    float angle;
    ddx = 0.0, ddy = 0.0;
    ddx1 = 0.0, ddy1 = 0.0;
    ddx2 = 0.0, ddy2 = 0.0;
    ddx3 = 0.0, ddy3 = 0.0;

    // there's no need to do wave patterns or foam for pixels which are so
    // far away that we can't actually see them
    // we only need detail in the near zone or where the sun reflection is
	int detail_flag;
    float dist = length(relpos);
	if ((dist > 15000.0) && (dot(normalize(vec3(fg_SunDirection.x, fg_SunDirection.y, 0.0) ), normalize(relpos)) < 0.7 ))  {detail_flag = 0;}
	else {detail_flag = 1;}
    if (detail_flag == 1) {
        angle = 0.0;
        wave0.freq = WaveFreq ;
        wave0.amp = WaveAmp;
        wave0.dir =  vec2 (0.0, 1.0); //vec2(cos(radians(angle)), sin(radians(angle)));

        angle -= 45;
        wave1.freq = WaveFreq * 2.0 ;
        wave1.amp = WaveAmp * 1.25;
        wave1.dir =  vec2(0.70710, -0.7071); //vec2(cos(radians(angle)), sin(radians(angle)));

        angle += 30;
        wave2.freq = WaveFreq * 3.5;
        wave2.amp = WaveAmp * 0.75;
        wave2.dir =  vec2(0.96592, -0.2588);// vec2(cos(radians(angle)), sin(radians(angle)));

        angle -= 50;
        wave3.freq = WaveFreq * 3.0 ;
        wave3.amp = WaveAmp * 0.75;
        wave3.dir =  vec2(0.42261, -0.9063); //vec2(cos(radians(angle)), sin(radians(angle)));

        sumWaves(WaveAngle, -1.5, windScale, WaveFactor, ddx, ddy);
        sumWaves(WaveAngle, 1.5, windScale, WaveFactor, ddx1, ddy1);

        //reset the waves
        angle = 0.0;
        float waveamp = WaveAmp * 0.75;

        wave0.freq = WaveFreq ;
        wave0.amp = waveamp;
        wave0.dir =  vec2 (0.0, 1.0); //vec2(cos(radians(angle)), sin(radians(angle)));

        angle -= 20;
        wave1.freq = WaveFreq * 2.0 ;
        wave1.amp = waveamp * 1.25;
        wave1.dir =  vec2(0.93969, -0.34202);// vec2(cos(radians(angle)), sin(radians(angle)));

        angle += 35;
        wave2.freq = WaveFreq * 3.5;
        wave2.amp = waveamp * 0.75;
        wave2.dir =  vec2(0.965925, 0.25881);  //vec2(cos(radians(angle)), sin(radians(angle)));

        angle -= 45;
        wave3.freq = WaveFreq * 3.0 ;
        wave3.amp = waveamp * 0.75;
        wave3.dir =  vec2(0.866025, -0.5); //vec2(cos(radians(angle)), sin(radians(angle)));

        sumWaves(WaveAngle + WaveDAngle, -1.5, windScale, WaveFactor, ddx2, ddy2);
        sumWaves(WaveAngle + WaveDAngle, 1.5, windScale, WaveFactor, ddx3, ddy3);
    }

    vec4 disdis = texture(water_dudvmap, vec2(waterTex2 * tscale)* windScale) * 2.0 - 1.0;

    vec3 N0 = vec3(texture(water_normalmap, vec2(waterTex1 + disdis * sca2) * windScale) * 2.0 - 1.0);
    vec3 N1 = vec3(texture(perlin_normalmap, vec2(waterTex1 + disdis * sca) * windScale) * 2.0 - 1.0);

    N0 += vec3(texture(water_normalmap, vec2(waterTex1 * tscale) * windScale) * 2.0 - 1.0);
    N1 += vec3(texture(perlin_normalmap, vec2(waterTex2 * tscale) * windScale) * 2.0 - 1.0);

    rotationmatrix(radians(2.0 * sin(osg_SimulationTime * 0.005)), RotationMatrix);
    N0 += vec3(texture(water_normalmap, vec2(waterTex2 * RotationMatrix * (tscale + sca2)) * windScale) * 2.0 - 1.0);
    N1 += vec3(texture(perlin_normalmap, vec2(waterTex2 * RotationMatrix * (tscale + sca2)) * windScale) * 2.0 - 1.0);

    rotationmatrix(radians(-4.0 * sin(osg_SimulationTime * 0.003)), RotationMatrix);
    N0 += vec3(texture(water_normalmap, vec2(waterTex1 * RotationMatrix + disdis * sca2) * windScale) * 2.0 - 1.0);
    N1 += vec3(texture(perlin_normalmap, vec2(waterTex1 * RotationMatrix + disdis * sca) * windScale) * 2.0 - 1.0);

    N0 *= windEffect_low;
    N1 *= windEffect_low;

    N0.r += (ddx + ddx1 + ddx2 + ddx3);
    N0.g += (ddy + ddy1 + ddy2 + ddy3);

    vec3 N = normalize(mix(N0, N1, mixFactor) * waveRoughness);

    vec3 floorColor = eotf_inverse_sRGB(texture(water_colormap, TopoUV).rgb);

    outGBuffer0.rg  = encode_normal(TBN * N);
    outGBuffer1.rgb = floorColor;
}
