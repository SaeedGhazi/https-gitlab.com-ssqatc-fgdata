// This shader is mostly an adaptation of the shader found at
//  http://www.bonzaisoftware.com/water_tut.html and its glsl conversion
//  available at http://forum.bonzaisoftware.com/viewthread.php?tid=10
//  © Michael Horsch - 2005

#version 120
#pragma debug(on)

uniform sampler2D water_normalmap;
uniform sampler2D water_reflection;
uniform sampler2D water_dudvmap;
uniform sampler2D water_reflection_grey;
uniform sampler2D sea_foam;

uniform float saturation, Overcast, WindE, WindN;
uniform float CloudCover0, CloudCover1, CloudCover2, CloudCover3, CloudCover4;
uniform int Status;

varying vec4 waterTex1; //moving texcoords
varying vec4 waterTex2; //moving texcoords
varying vec4 waterTex4; //viewts
varying vec4 ecPosition;
varying vec3 viewerdir;
varying vec3 lightdir;
varying vec3 normal;

void main(void)
{
    const vec4 sca = vec4(0.005, 0.005, 0.005, 0.005);
    const vec4 sca2 = vec4(0.02, 0.02, 0.02, 0.02);
    const vec4 tscale = vec4(0.25, 0.25, 0.25, 0.25);

    // compute direction to viewer
    vec3 E = normalize(viewerdir);

    // compute direction to light source
    vec3 L = normalize(lightdir);

    // half vector
    vec3 H = normalize(L + E);

    const float water_shininess = 240.0;

    // calculate wind effects
    float windEffect = sqrt(pow(abs(WindE),2)+pow(abs(WindN),2)) * 0.6;
    float windScale = 10.0/(6.0 + 8.0 * smoothstep(0.0,0.8,windEffect * 0.05));

    // approximate cloud cover
    float cover = 0.0;
    //bool Status = true;

    if (Status == 1){
        cover = min(min(min(min(CloudCover0, CloudCover1),CloudCover2),CloudCover3),CloudCover4);
    } else {
        // hack to allow for Overcast not to be set by Local Weather

        if (Overcast == 0){
            cover = 5;
        } else {
            cover = Overcast * 5;
        }

    }

    vec4 viewt = normalize(waterTex4);

    vec4 disdis = texture2D(water_dudvmap, vec2(waterTex2 * tscale)* windScale) * 2.0 - 1.0;
    vec4 dist = texture2D(water_dudvmap, vec2(waterTex1 + disdis*sca2)* windScale) * 2.0 - 1.0;
    vec4 fdist = normalize(dist);
    fdist *= sca;

    //normalmap
    vec4 nmap0 = texture2D(water_normalmap, vec2(waterTex1+ disdis*sca2) * windScale) * 2.0 - 1.0;
    vec4 nmap2 = texture2D(water_normalmap, vec2(waterTex2 * tscale) * windScale) * 2.0 - 1.0;
    vec4 vNorm = normalize(nmap0 + nmap2);

    //load reflection
    vec4 tmp = vec4(lightdir, 0.0);
    vec4 refTex;
    vec4 refl;
    //    cover = 0;

    if(cover >= 1.5){
        refTex = texture2D(water_reflection, vec2(tmp));
        refl= normalize(refTex);
    } else {
        refTex = texture2D(water_reflection_grey, vec2(tmp));
        refl = normalize(refTex);
        refl.r *= (0.75 + 0.15 * cover);
        refl.g *= (0.80 + 0.15 * cover);
        refl.b *= (0.875 + 0.125 * cover);
        refl.a  *= 1.0;
    }

    vec3 N0 = vec3(texture2D(water_normalmap, vec2(waterTex1+ disdis*sca2) * windScale) * 2.0 - 1.0);
    vec3 N1 = vec3(texture2D(water_normalmap, vec2(waterTex2 * tscale) * windScale) * 2.0 - 1.0);
    vec3 N = normalize(normal+N0+N1);

    // specular
    vec3 specular_color = vec3(gl_LightSource[0].diffuse)
        * pow(max(0.0, dot(N, H)), water_shininess) * 6.0;
    vec4 specular = vec4(specular_color, 0.5);

    specular = specular * saturation * 0.4;

    //calculate fresnel
    vec4 invfres = vec4( dot(vNorm, viewt) );
    vec4 fres = vec4(1.0) + invfres;
    refl *= fres;

    //calculate the fog factor
    float fogFactor;
    float fogCoord = ecPosition.z;
    const float LOG2 = 1.442695;
    fogFactor = exp2(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord * LOG2);

    if(gl_Fog.density == 1.0)
        fogFactor=1.0;

    //calculate final colour
    vec4 ambient_light = gl_LightSource[0].diffuse;
    vec4 finalColor;

    //    cover = 0;

    if(cover >= 1.5){
        finalColor = refl + specular;
    } else {
        finalColor = refl;
    }

    if (windEffect >= 10.0){
        float windScale3 = pow(windScale, 3);

        if (N.g >= 0.0005 + 0.085 * windScale3){
            vec4 foam_texel = texture2D(sea_foam, vec2(waterTex1+ disdis*sca2) * windScale3 * 50.0);
            finalColor = mix(finalColor, max(finalColor,  foam_texel), smoothstep(0.0005 + 0.085 * windScale3, 0.1, N.g));
        }

    }
    finalColor *= ambient_light;


    gl_FragColor = mix(gl_Fog.color, finalColor, fogFactor);
}
