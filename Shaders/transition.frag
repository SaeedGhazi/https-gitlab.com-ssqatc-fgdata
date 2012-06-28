// -*-C++-*-
// Texture switching based on face slope and snow level
// based on earlier work by Frederic Bouvier, Tim Moore, and Yves Sablonier.
// � Emilian Huminiuc 2011

// Ambient term comes in gl_Color.rgb.
varying vec4	diffuse_term;
varying vec4    RawPos;
varying vec3	normal;
varying vec3    Vnormal;

uniform float	SnowLevel;
uniform float   Transitions;
uniform float   InverseSlope;
uniform float   RainNorm;

uniform float CloudCover0;
uniform float CloudCover1;
uniform float CloudCover2;
uniform float CloudCover3;
uniform float CloudCover4;

uniform sampler2D BaseTex;
uniform sampler2D SecondTex;
uniform sampler2D ThirdTex;
uniform sampler2D SnowTex;

uniform sampler3D NoiseTex;

////fog "include" /////
uniform int fogType;

vec3 fog_Func(vec3 color, int type);
//////////////////////

void main()
    {
    float MixFactor;
    float NdotL;
    float NdotHV;
    float fogFactor;
    float cover;
    float slope;
    float L1;
    float L2;
    float wetness;
	float pf;

    vec3 n;
    vec3 lightDir;
    vec3 halfVector;

    vec4 texel;
    vec4 fragColor;
    vec4 color;
    vec4 specular;
    vec4 Noise;

    lightDir = gl_LightSource[0].position.xyz;
    halfVector = gl_LightSource[0].halfVector.xyz;

    //color = gl_Color;
    specular = vec4(0.0);

    cover = min(min(min(min(CloudCover0, CloudCover1),CloudCover2),CloudCover3),CloudCover4);

    Noise =  texture3D(NoiseTex, RawPos.xyz*0.0011);
    MixFactor = Noise.r * Noise.g * Noise.b;	//Mixing Factor to create a more organic looking boundary
    MixFactor *= 300.0;
    MixFactor = clamp(MixFactor, 0.0, 1.0);
    L1 = 0.90 - 0.02 * MixFactor;			//first transition slope
    L2 = 0.78 + 0.04 * MixFactor;			//Second transition slope

    // If gl_Color.a == 0, this is a back-facing polygon and the
    // Vnormal should be reversed.
    n = (2.0 * gl_Color.a - 1.0) * Vnormal;
    n = normalize(n);

//     NdotL = dot(n, lightDir);
//     if (NdotL > 0.0) {
//         color += diffuse_term * NdotL;
//         NdotHV = max(dot(n, halfVector), 0.0);
//         if (gl_FrontMaterial.shininess > 0.0)
//             specular.rgb = (gl_FrontMaterial.specular.rgb
//             * gl_LightSource[0].specular.rgb
//             * pow(NdotHV, gl_FrontMaterial.shininess));
//         }

	float nDotVP = max(0.0, dot(n, normalize(gl_LightSource[0].position.xyz)));
	float nDotHV = max(0.0, dot(n, normalize(gl_LightSource[0].halfVector.xyz)));
	vec4 Diffuse  = gl_LightSource[0].diffuse * nDotVP;

	if (nDotVP == 0.0)
		pf = 0.0;
	else
		pf = pow(nDotHV, gl_FrontMaterial.shininess);

	if (gl_FrontMaterial.shininess > 0.0)
		specular = gl_FrontMaterial.specular * gl_LightSource[0].specular * pf;

	color = gl_FrontMaterial.emission +
			gl_Color * (gl_LightModel.ambient + gl_LightSource[0].ambient) +
			Diffuse * gl_FrontMaterial.diffuse;

	color += specular * gl_FrontMaterial.specular;




    color.a = diffuse_term.a;
    // This shouldn't be necessary, but our lighting becomes very
    // saturated. Clamping the color before modulating by the texture
    // is closer to what the OpenGL fixed function pipeline does.
    color = clamp(color, 0.0, 1.0);


    //Select texture based on slope
    slope = normalize(normal).z;

    //pull the texture fetch outside flow control to fix aliasing artefacts :(
    vec4 baseTexel = texture2D(BaseTex, gl_TexCoord[0].st);
    vec4 secondTexel = texture2D(SecondTex, gl_TexCoord[0].st);
    vec4 thirdTexel = texture2D(ThirdTex, gl_TexCoord[0].st);
    vec4 snowTexel = texture2D(SnowTex, gl_TexCoord[0].st);

    //Normal transition. For more abrupt faces apply another texture (or 2).
    if (InverseSlope == 0.0) {
        //Do we do an intermediate transition
        if (Transitions >= 1.5) {
            if (slope >= L1) {
                //texel = mix(texture2D(SecondTex, gl_TexCoord[0].st), texture2D(BaseTex, gl_TexCoord[0].st), smoothstep(L1, L1 + 0.03 * MixFactor, slope));
                texel = baseTexel;
                }
            if (slope >= L2  && slope < L1){
                texel = mix(secondTexel, baseTexel, smoothstep(L2, L1 - 0.06 * MixFactor, slope));
                }
            if (slope < L2){
                texel = mix(thirdTexel, secondTexel, smoothstep(L2 - 0.13 * MixFactor, L2, slope));
                }
            // Just one transition
            } else 	if (Transitions < 1.5) {
                if (slope >= L1) {
                    texel = baseTexel;
                    }
                if (slope < L1) {
                    texel = mix(thirdTexel, baseTexel, smoothstep(L2 - 0.13 * MixFactor, L1, slope));
                    }
            }

        //Invert the transition: keep original texture on abrupt slopes and switch to another on flatter terrain
        } else  if (InverseSlope > 0.0) {
            //Interemdiate transition ?
            if (Transitions >= 1.5) {
                if (slope >= L1 + 0.1) {
                    texel = thirdTexel;
                    }
                if (slope >= L2 && slope < L1 + 0.1){
                    texel = mix(secondTexel, thirdTexel, smoothstep(L2 + 0.06 * MixFactor, L1 + 0.1, slope));
                    }
                if (slope <= L2){
                    texel = mix(baseTexel, secondTexel, smoothstep(L2 - 0.06 * MixFactor, L2, slope));
                    }
                //just one
                } else if (Transitions < 1.5) {
                    if (slope > L1 + 0.1) {
                        texel = thirdTexel;
                        }
                    if (slope <= L1 + 0.1){
                        texel = mix(baseTexel, thirdTexel, smoothstep(L2 - 0.06 * MixFactor, L1 + 0.1, slope));
                        }
                }
        }

    //darken textures with wetness
    wetness = 1.0 - 0.3 * RainNorm;
    texel.rgb = texel.rgb * wetness;

    float altitude = RawPos.z;
    //Snow texture for areas higher than SnowLevel
    if (altitude >= SnowLevel - (1000.0 * slope + 300.0 * MixFactor) && slope > L2 - 0.12) {
        texel = mix(texel, mix(texel, snowTexel, smoothstep(L2 - 0.09 * MixFactor, L2, slope)),
                    smoothstep(SnowLevel - (1000.0 * slope + 300.0 * MixFactor),
                               SnowLevel - (1000.0 * slope - 150.0 * MixFactor),
                               altitude)
                               );
        }

    fragColor = color * texel + specular;

    if(cover >= 2.5){
        fragColor.rgb = fragColor.rgb * 1.2;
        } else {
            fragColor.rg = fragColor.rg * (0.6 + 0.2 * cover);
            fragColor.b = fragColor.b * (0.5 + 0.25 * cover);
        }

    //fogFactor = exp(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord);
    fragColor.rgb *= 1.2 - 0.4 * MixFactor;
    fragColor.rgb = fog_Func(fragColor.rgb, fogType);
    gl_FragColor = fragColor;
    }
