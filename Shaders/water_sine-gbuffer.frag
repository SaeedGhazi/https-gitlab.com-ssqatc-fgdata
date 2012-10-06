// This shader is mostly an adaptation of the shader found at
//  http://www.bonzaisoftware.com/water_tut.html and its glsl conversion
//  available at http://forum.bonzaisoftware.com/viewthread.php?tid=10
//   Michael Horsch - 2005
//  Major update and revisions - 2011-10-07
//   Emilian Huminiuc and Vivian Meazza
//  Optimisation - 2012-5-05
//  Based on ideas by Thorsten Renk
//   Emilian Huminiuc and Vivian Meazza

#version 120

uniform sampler2D   water_normalmap ;
uniform sampler2D   water_reflection ;
uniform sampler2D   water_dudvmap ;
uniform sampler2D   water_reflection_grey ;
uniform sampler2D   sea_foam ;
uniform sampler2D   perlin_normalmap ;

uniform sampler3D   Noise ;


uniform float   saturation ;
uniform float   Overcast ;
uniform float   WindE ;
uniform float   WindN ;
uniform float   CloudCover0 ;
uniform float   CloudCover1 ;
uniform float   CloudCover2 ;
uniform float   CloudCover3 ;
uniform float   CloudCover4 ;
uniform float   osg_SimulationTime ;
uniform float   WaveFreq ;
uniform float   WaveAmp ;
uniform float   WaveSharp ;
uniform float   WaveAngle ;
uniform float   WaveFactor ;
uniform float   WaveDAngle ;
uniform float   normalmap_dds ;
uniform int     Status ;


varying vec4    waterTex1 ; //moving texcoords
varying vec4    waterTex2 ; //moving texcoords

varying vec3    viewerdir ;
varying vec3    lightdir ;
varying vec3    normal ;
varying vec3    rawNormal ;
varying vec3    VTangent ;
varying vec3    VBinormal ;

const vec4 AllOnes = vec4(1.0);

/////// functions /////////
void encode_gbuffer(vec3 normal, vec3 color, int mId, float specular, float shininess, float emission, float depth);


void rotationmatrix(in float angle, out mat4 rotmat)
    {
    rotmat = mat4( cos( angle ), -sin( angle ), 0.0, 0.0,
        sin( angle ),  cos( angle ), 0.0, 0.0,
        0.0         ,  0.0         , 1.0, 0.0,
        0.0         ,  0.0         , 0.0, 1.0 );
    }

// wave functions ///////////////////////

struct Wave {
    float freq ;  // 2*PI / wavelength
    float amp ;   // amplitude
    float phase ; // speed * 2*PI / wavelength
    vec2 dir ;
    };

Wave wave0 = Wave(1.0, 1.0, 0.5, vec2(0.97, 0.25)) ;
Wave wave1 = Wave(2.0, 0.5, 1.3, vec2(0.97, -0.25)) ;
Wave wave2 = Wave(1.0, 1.0, 0.6, vec2(0.95, -0.3)) ;
Wave wave3 = Wave(2.0, 0.5, 1.4, vec2(0.99, 0.1)) ;

float evaluateWave(in Wave w, vec2 pos, float t)
    {
    return w.amp * sin( dot(w.dir, pos) * w.freq + t * w.phase) ;
    }

// derivative of wave function
float evaluateWaveDeriv(Wave w, vec2 pos, float t)
    {
    return w.freq * w.amp * cos( dot(w.dir, pos)*w.freq + t*w.phase) ;
    }

// sharp wave functions
float evaluateWaveSharp(Wave w, vec2 pos, float t, float k)
    {
    return w.amp * pow(sin( dot(w.dir, pos)*w.freq + t*w.phase)* 0.5 + 0.5 , k) ;
    }

float evaluateWaveDerivSharp(Wave w, vec2 pos, float t, float k)
    {
    return k*w.freq*w.amp * pow(sin( dot(w.dir, pos)*w.freq + t*w.phase)* 0.5 + 0.5 , k - 1.0) * cos( dot(w.dir, pos)*w.freq + t*w.phase) ;
    }

void sumWaves(float angle, float dangle, float windScale, float factor, out float ddx, float ddy)
    {
    mat4 RotationMatrix ;
    float deriv ;
    vec4 P = waterTex1 * 1024.0 ;

    rotationmatrix(radians(angle + dangle * windScale + 0.6 * sin(P.x * factor)), RotationMatrix) ;
    P *= RotationMatrix ;

    P.y += evaluateWave(wave0, P.xz, osg_SimulationTime) ;
    deriv = evaluateWaveDeriv(wave0, P.xz, osg_SimulationTime ) ;
    ddx = deriv * wave0.dir.x ;
    ddy = deriv * wave0.dir.y ;

    P.y += evaluateWave(wave1, P.xz, osg_SimulationTime) ;
    deriv = evaluateWaveDeriv(wave1, P.xz, osg_SimulationTime) ;
    ddx += deriv * wave1.dir.x ;
    ddy += deriv * wave1.dir.y ;

    P.y += evaluateWaveSharp(wave2, P.xz, osg_SimulationTime, WaveSharp) ;
    deriv = evaluateWaveDerivSharp(wave2, P.xz, osg_SimulationTime, WaveSharp) ;
    ddx += deriv * wave2.dir.x ;
    ddy += deriv * wave2.dir.y ;

    P.y += evaluateWaveSharp(wave3, P.xz, osg_SimulationTime, WaveSharp) ;
    deriv = evaluateWaveDerivSharp(wave3, P.xz, osg_SimulationTime, WaveSharp) ;
    ddx += deriv * wave3.dir.x ;
    ddy += deriv * wave3.dir.y ;
    }

void main(void)
    {
    const vec4 sca = vec4(0.005, 0.005, 0.005, 0.005) ;
    const vec4 sca2 = vec4(0.02, 0.02, 0.02, 0.02) ;
    const vec4 tscale = vec4(0.25, 0.25, 0.25, 0.25) ;

    mat4 RotationMatrix ;

    // compute direction to viewer
    vec3 E = normalize(viewerdir) ;

    // compute direction to light source
    //vec3 L = normalize(lightdir);
    // half vector
    //vec3 H = normalize(L + E);

    vec3 Normal = normalize(normal) ;
    vec3 vNormal = normalize(rawNormal) ;
    const float water_shininess = 240.0 ;

//  float range = gl_ProjectionMatrix[3].z/(gl_FragCoord.z * -2.0 + 1.0 - gl_ProjectionMatrix[2].z);

    // approximate cloud cover
    float cover = 0.0 ;
    //bool Status = true;

    float windEffect = sqrt( WindE*WindE + WindN*WindN ) * 0.6 ;            //wind speed in kt
    float windScale =  15.0/(3.0 + windEffect) ;                            //wave scale
    float windEffect_low = 0.3 + 0.7 * smoothstep(0.0, 5.0, windEffect) ;   //low windspeed wave filter
    float waveRoughness = 0.01 + smoothstep(0.0, 40.0, windEffect) ;        //wave roughness filter

    float mixFactor = 0.2 + 0.02 * smoothstep(0.0, 50.0, windEffect);
    mixFactor = clamp(mixFactor, 0.3, 0.8);

    // sine waves

    // Test data
    //float WaveFreq =1.0;
    //float WaveAmp = 1000.0;
    //float WaveSharp = 10.0;

    vec4 ddxVec = vec4(0.0) ;
    vec4 ddyVec = vec4(0.0) ;
    int detailFlag = 0 ;

    //uncomment to test
    //range = -20000;

//  if (range > -15000 || dot(Normal,H) > 0.95 ) {

        float ddx  = 0.0, ddy  = 0.0 ;
        float ddx1 = 0.0, ddy1 = 0.0 ;
        float ddx2 = 0.0, ddy2 = 0.0 ;
        float ddx3 = 0.0, ddy3 = 0.0 ;
        float waveamp ;

        float angle = 0.0 ;

        wave0.freq = WaveFreq ;
        wave0.amp = WaveAmp ;
        wave0.dir =  vec2(cos(radians(angle)), sin(radians(angle))) ;

        angle -= 45.0 ;
        wave1.freq = WaveFreq * 2.0 ;
        wave1.amp  = WaveAmp * 1.25 ;
        wave1.dir  = vec2(cos(radians(angle)), sin(radians(angle))) ;

        angle += 30.0;
        wave2.freq = WaveFreq * 3.5 ;
        wave2.amp  = WaveAmp * 0.75 ;
        wave2.dir  = vec2(cos(radians(angle)), sin(radians(angle))) ;

        angle -= 50.0 ;
        wave3.freq = WaveFreq * 3.0 ;
        wave3.amp = WaveAmp * 0.75 ;
        wave3.dir =  vec2(cos(radians(angle)), sin(radians(angle))) ;

        // sum waves

        ddx = 0.0, ddy = 0.0 ;
        sumWaves(WaveAngle, -1.5, windScale, WaveFactor, ddx, ddy) ;

        ddx1 = 0.0, ddy1 = 0.0 ;
        sumWaves(WaveAngle, 1.5, windScale, WaveFactor, ddx1, ddy1) ;

        //reset the waves
        angle = 0.0 ;
        waveamp = WaveAmp * 0.75 ;

        wave0.freq = WaveFreq ;
        wave0.amp  = waveamp ;
        wave0.dir  = vec2(cos(radians(angle)), sin(radians(angle))) ;

        angle -= 20.0 ;
        wave1.freq = WaveFreq * 2.0 ;
        wave1.amp  = waveamp * 1.25 ;
        wave1.dir  = vec2(cos(radians(angle)), sin(radians(angle))) ;

        angle += 35.0 ;
        wave2.freq = WaveFreq * 3.5 ;
        wave2.amp  = waveamp * 0.75 ;
        wave2.dir  = vec2(cos(radians(angle)), sin(radians(angle))) ;

        angle -= 45.0 ;
        wave3.freq = WaveFreq * 3.0 ;
        wave3.amp  = waveamp * 0.75 ;
        wave3.dir  = vec2(cos(radians(angle)), sin(radians(angle))) ;

        // sum waves
        ddx2 = 0.0, ddy2 = 0.0 ;
        sumWaves(WaveAngle + WaveDAngle, -1.5, windScale, WaveFactor, ddx2, ddy2) ;

        ddx3 = 0.0, ddy3 = 0.0 ;
        sumWaves(WaveAngle + WaveDAngle, 1.5, windScale, WaveFactor, ddx3, ddy3) ;

        ddxVec = vec4(ddx, ddx1, ddx2, ddx3) ;
        ddyVec = vec4(ddy, ddy1, ddy2, ddy3) ;

        //toggle detailFlag
        //detailFlag = 1 ;
//  }	// end sine stuff

    float ddxSum = dot(ddxVec, AllOnes) ;
    float ddySum = dot(ddyVec, AllOnes) ;

    if (Status == 1){
        cover = min(min(min(min(CloudCover0, CloudCover1),CloudCover2),CloudCover3),CloudCover4) ;
        } else {
            // hack to allow for Overcast not to be set by Local Weather
            if (Overcast == 0.0){
                cover = 5.0;
                } else {
                    cover = Overcast * 5.0;
                }
        }

//	vec4 viewt = normalize(waterTex4);
    vec4 viewt = vec4(-E, 0.0) * 0.6 ;

    vec4 disdis = texture2D(water_dudvmap, vec2(waterTex2 * tscale)* windScale) * 2.0 - 1.0 ;

    //normalmaps
    vec4 nmap   = texture2D(water_normalmap, vec2(waterTex1 + disdis * sca2) * windScale) * 2.0 - 1.0 ;
    vec4 nmap1  = texture2D(perlin_normalmap, vec2(waterTex1 + disdis * sca2) * windScale) * 2.0 - 1.0 ;

    rotationmatrix(radians(3.0 * sin(osg_SimulationTime * 0.0075)), RotationMatrix);
    nmap  += texture2D(water_normalmap, vec2(waterTex2 * RotationMatrix * tscale) * windScale) * 2.0 - 1.0 ;
    nmap1 += texture2D(perlin_normalmap, vec2(waterTex2 * RotationMatrix * tscale) * windScale) * 2.0 - 1.0 ;

    nmap  *= windEffect_low ;
    nmap1 *= windEffect_low ;

    // mix water and noise, modulated by factor
    vec4 vNorm = normalize(mix(nmap, nmap1, mixFactor) * waveRoughness) ;
    vNorm.r += ddxSum ;

    if (normalmap_dds > 0)//dds fix
        vNorm = -vNorm ;

    //load reflection
    //vec4 tmp = vec4(lightdir, 0.0);
    vec4 tmp = vec4(0.0);
    vec4 refTex = texture2D(water_reflection, vec2(tmp + waterTex1) * 32.0) ;
    vec4 refTexGrey = texture2D(water_reflection_grey, vec2(tmp + waterTex1) * 32.0) ;
    vec4 refl ;

    // Test data
    // cover = 0;

    if(cover >= 1.5){
        refl = normalize(refTex);
        refl.a = 1.0;
        }
    else
        {
        refl = normalize(refTexGrey);
        refl.r *= (0.75 + 0.15 * cover);
        refl.g *= (0.80 + 0.15 * cover);
        refl.b *= (0.875 + 0.125 * cover);
        refl.a  = 1.0;
        }

    vec3 N0 = vec3(texture2D(water_normalmap, vec2(waterTex1 + disdis * sca2) * windScale) * 2.0 - 1.0);
    vec3 N1 = vec3(texture2D(perlin_normalmap, vec2(waterTex1 + disdis * sca) * windScale) * 2.0 - 1.0);

    N0 += vec3(texture2D(water_normalmap, vec2(waterTex1 * tscale) * windScale) * 2.0 - 1.0);
    N1 += vec3(texture2D(perlin_normalmap, vec2(waterTex2 * tscale) * windScale) * 2.0 - 1.0);

    rotationmatrix(radians(2.0 * sin(osg_SimulationTime * 0.005)), RotationMatrix);
    N0 += vec3(texture2D(water_normalmap, vec2(waterTex2 * RotationMatrix * (tscale + sca2)) * windScale) * 2.0 - 1.0);
    N1 += vec3(texture2D(perlin_normalmap, vec2(waterTex2 * RotationMatrix * (tscale + sca2)) * windScale) * 2.0 - 1.0);

    rotationmatrix(radians(-4.0 * sin(osg_SimulationTime * 0.003)), RotationMatrix);
    N0 += vec3(texture2D(water_normalmap, vec2(waterTex1 * RotationMatrix + disdis * sca2) * windScale) * 2.0 - 1.0);
    N1 += vec3(texture2D(perlin_normalmap, vec2(waterTex1 * RotationMatrix + disdis * sca) * windScale) * 2.0 - 1.0);

//  if(detailFlag > 0)
//        {
            N0 *= windEffect_low;
            N1 *= windEffect_low;
            N0.r += ddxSum;
            N0.g += ddySum;
            vec3 N2 = normalize(mix(N0, N1, mixFactor) * waveRoughness);
            Normal = normalize(N2.x * VTangent + N2.y * VBinormal + N2.z * Normal);
            //vNormal = normalize(mix(vNormal + N0, vNormal + N1, mixFactor) * waveRoughness);
			vNormal = normalize(N2.x * vec3(1.0, 0.0, 0.0) + N2.y * vec3(0.0, 1., 0.0) + N2.z * vNormal);
            if (normalmap_dds > 0){ //dds fix
                Normal = -Normal;
                vNormal = -vNormal;
                }
//        }


    // specular
// 	vec3 specular_color = vec3(1.0) * pow(max(0.0, dot(Normal, H)), water_shininess) * 6.0;
// 	vec4 specular = vec4(specular_color, 0.5);
    //specular_color *= saturation * 0.3 ;
    //float specular = saturation * 0.3;

    //calculate fresnel
    vec4 invfres = vec4( dot(vNorm, viewt) );
    vec4 fres = vec4(1.0) + invfres;
    refl *= fres;

    //calculate final colour
    vec4 finalColor = refl;


//add foam
    vec4 foam_texel = texture2D(sea_foam, vec2(waterTex2 * tscale) * 25.0);

//     if (range > -10000.0){

        float foamSlope = 0.1 + 0.1 * windScale;
        float waveSlope = vNormal.g;
        if (windEffect >= 8.0)
            if (waveSlope >= foamSlope){
                finalColor = mix( finalColor,
                                  max(finalColor, finalColor + foam_texel),
                                  smoothstep(0.01, 0.50, vNormal.g)
                                );
            }

//     } // end range


    float emission = dot( gl_FrontLightModelProduct.sceneColor.rgb + gl_FrontMaterial.emission.rgb,
                          vec3( 0.3, 0.59, 0.11 )
                        );
    float specular = smoothstep(0.0, 3.5, cover);
	encode_gbuffer(Normal, finalColor.rgb, 254, specular, water_shininess, emission, gl_FragCoord.z);
    }
