// -*-C++-*-

// Ambient term comes in gl_Color.rgb.
#version 120

varying vec4 diffuse_term;
varying vec3 normal;
varying vec3 ecViewDir;
varying vec3 VTangent;

uniform bool use_overlay;

uniform sampler2D texture;
uniform sampler2D structure_texture;

float Noise2D(in vec2 coord, in float wavelength);


void main()
{
    vec3 n;
    float NdotL, NdotHV;
    vec4 color = gl_Color;
    vec3 lightDir = gl_LightSource[0].position.xyz;

	vec3 halfVector = normalize(normalize(lightDir) + normalize(ecViewDir));
    vec4 texel;
    vec4 structureTexel;

    vec4 fragColor;
    vec4 specular = vec4(0.0);

    // If gl_Color.a == 0, this is a back-facing polygon and the
    // normal should be reversed.
    n = (2.0 * gl_Color.a - 1.0) * normal;
    n = normalize(n);

	
    vec3 light_specular = vec3 (1.0, 1.0, 1.0);
    NdotL = dot(n, lightDir);
    NdotL = smoothstep(-0.2,0.2,NdotL);	

    float intensity = length(diffuse_term);
    vec4 dawn = intensity * normalize (vec4 (1.0,0.4,0.4,1.0));
	
    vec4 diff_term = mix(dawn, diffuse_term, smoothstep(0.0, 0.2, NdotL));

    if (NdotL > 0.0) {
        color += diffuse_term * NdotL ;
        NdotHV = max(dot(n, halfVector), 0.0);
        if (gl_FrontMaterial.shininess > 0.0)
            specular.rgb = (gl_FrontMaterial.specular.rgb
                            * light_specular 
                            * pow(NdotHV, gl_FrontMaterial.shininess));
    }
    color.a = diffuse_term.a;
    // This shouldn't be necessary, but our lighting becomes very
    // saturated. Clamping the color before modulating by the texture
    // is closer to what the OpenGL fixed function pipeline does.
    color = clamp(color, 0.0, 1.0);
    texel = texture2D(texture, gl_TexCoord[0].st);
    structureTexel = texture2D(structure_texture, 20.0 * gl_TexCoord[0].st);

    float noise = Noise2D( gl_TexCoord[0].st, 0.01);
    noise += Noise2D( gl_TexCoord[0].st, 0.005);
    noise += Noise2D( gl_TexCoord[0].st, 0.002);
	
    //vec4 noiseTexel = vec4 (1.0,1.0,1.0,  smoothstep(0.3,1.2,noise) * texel.a);
    vec4 noiseTexel = vec4 (1.0,1.0,1.0, 0.5* noise * texel.a);
    structureTexel = mix(structureTexel, noiseTexel,noiseTexel.a);


    if (use_overlay) 
	{
	texel = vec4(structureTexel.rgb, texel.a * structureTexel.a);
	}	

    fragColor = color * texel + specular;
	
    gl_FragColor = fragColor;
}
