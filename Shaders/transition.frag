// -*-C++-*-
// Texture switching based on face slope and snow level
// default.frag (c) 2010 ??
// (c)2011 - Emilian Huminiuc, with ideas from crop.frag, forest.frag
// Ambient term comes in gl_Color.rgb.
varying vec4	diffuse_term, RawPos;
varying vec3	Vnormal, normal;
varying float	fogCoord;

uniform float	SnowLevel, Transitions, InverseSlope, RainNorm;
uniform sampler2D BaseTex, SecondTex, ThirdTex, SnowTex;
uniform sampler3D NoiseTex;

void main()
{
    float MixFactor, NdotL, NdotHV, fogFactor, slope, L1, L2, wetness;

    vec3 n, lightDir, halfVector;
    vec4 texel, fragColor, color, specular, Noise; // GNoise;

    lightDir = gl_LightSource[0].position.xyz;
    halfVector = gl_LightSource[0].halfVector.xyz;

    color = gl_Color;
    specular = vec4(0.0);

    Noise =  texture3D(NoiseTex, RawPos.xyz*0.0011);
    //GNoise = texture3D(NoiseTex, RawPos.xyz*0.00011);

    MixFactor = Noise.r * Noise.g * Noise.b;	//Mixing Factor to create a more organic looking boundary
    //AddedNoise = GNoise.r * GNoise.g * GNoise.b;	//Some added Noise to break the evenness on some textures
    MixFactor *= 50.0;
    L1 = 0.88 - 0.04 * MixFactor;			//first transition slope
    L2 = 0.80 + 0.04 * MixFactor;			//Second transition slope

    // If gl_Color.a == 0, this is a back-facing polygon and the
    // Vnormal should be reversed.
    n = (2.0 * gl_Color.a - 1.0) * Vnormal;
    n = normalize(n);

    NdotL = dot(n, lightDir);
    if (NdotL > 0.0) {
        color += diffuse_term * NdotL;
        NdotHV = max(dot(n, halfVector), 0.0);
        if (gl_FrontMaterial.shininess > 0.0)
            specular.rgb = (gl_FrontMaterial.specular.rgb
                            * gl_LightSource[0].specular.rgb
                            * pow(NdotHV, gl_FrontMaterial.shininess));
    }

    color.a = diffuse_term.a;
    // This shouldn't be necessary, but our lighting becomes very
    // saturated. Clamping the color before modulating by the texture
    // is closer to what the OpenGL fixed function pipeline does.
    color = clamp(color, 0.0, 1.0);


    //Select texture based on slope
    slope = normalize(normal).z;

    //Normal transition. For more abrupt faces apply another texture (or 2).
    if (InverseSlope == 0.0) {
	//Do we do an intermediate transition
	if (Transitions >= 1.5) {
	    if (slope > L1) {
		texel = mix(texture2D(SecondTex, gl_TexCoord[0].st), texture2D(BaseTex, gl_TexCoord[0].st), smoothstep(L1, L1 + 0.003*MixFactor, slope));
	    }
	    if (slope > L2  && slope <= L1){
		texel = mix(texture2D(SecondTex, gl_TexCoord[0].st), texture2D(BaseTex, gl_TexCoord[0].st), smoothstep(L2 + 0.01 * MixFactor, L1, slope));
	    }
	    if (slope <= L2){
		texel = mix(texture2D(ThirdTex, gl_TexCoord[0].st), texture2D(SecondTex, gl_TexCoord[0].st), smoothstep(L2 - 0.1 * MixFactor, L2, slope));
	    }
	// Just one transition
	} else 	if (Transitions < 1.5) {
	    if (slope > L1) {
		texel = texture2D(BaseTex, gl_TexCoord[0].st);
	    }
	    if (slope <= L1) {
		texel = mix(texture2D(ThirdTex, gl_TexCoord[0].st), texture2D(BaseTex, gl_TexCoord[0].st), smoothstep(L2 - 0.1 * MixFactor, L1, slope));
	    }
	}

    //Invert the transition: keep original texture on abrupt slopes and switch to another on flatter terrain
    } else  if (InverseSlope > 0.0) {
	//Interemdiate transition ?
	if (Transitions >= 1.5) {
	    if (slope > L1 + 0.16) {
		texel = texture2D(ThirdTex, gl_TexCoord[0].st);
	    }
	    if (slope > L2 && slope <= L1 + 0.16){
		texel = mix(texture2D(SecondTex, gl_TexCoord[0].st), texture2D(ThirdTex, gl_TexCoord[0].st), smoothstep(L2 + 0.01 * MixFactor, L1, slope));
	    }
	    if (slope <= L2){
		texel = mix(texture2D(BaseTex, gl_TexCoord[0].st), texture2D(SecondTex, gl_TexCoord[0].st), smoothstep(L2 - 0.05 * MixFactor, L2, slope));
	    }
	//just one
	} else if (Transitions < 1.5) {
	    if (slope > L1 + 0.16) {
		texel = texture2D(ThirdTex, gl_TexCoord[0].st);
	    }
	    if (slope <= L1 + 0.16){
		texel = mix(texture2D(BaseTex, gl_TexCoord[0].st), texture2D(ThirdTex, gl_TexCoord[0].st), smoothstep(L2 - 0.05 * MixFactor, L1 + 0.16, slope));
	    }
	}
    }

    //darken textures with wetness
    wetness = 1.0 - 0.3 * RainNorm;
    texel.rgb = texel.rgb * wetness;
    //texel.r = texel.r * wetness;
    //texel.g = texel.g * wetness;
    //texel.b = texel.b * wetness;

    //Snow texture for areas higher than SnowLevel
    if (RawPos.z >= SnowLevel - 6000.0 * MixFactor && slope > L2 - 0.4) {
	texel = mix(texel, mix(texel, texture2D(SnowTex, gl_TexCoord[0].st), smoothstep(L2 - 0.4 * MixFactor, L2, slope)), smoothstep(SnowLevel - 6000.0 * slope * MixFactor, SnowLevel - 1400.0 * slope * MixFactor, RawPos.z));
    }

    fragColor = color * texel + specular;

    fogFactor = exp(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord);
    gl_FragColor = mix(gl_Fog.color, fragColor, fogFactor);
}