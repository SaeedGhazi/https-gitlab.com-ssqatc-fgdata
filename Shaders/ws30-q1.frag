// WS30 FRAGMENT SHADER

// -*-C++-*-
#version 130
#extension GL_EXT_texture_array : enable

varying vec3 normal;

uniform sampler2D landclass;
uniform sampler2DArray atlas;
uniform sampler1D dimensionsArray;
uniform sampler1D diffuseArray;
uniform sampler1D specularArray;
uniform sampler2D perlin;

// Passed from VPBTechnique, not the Effect
uniform float tile_width;
uniform float tile_height;
uniform bool photoScenery;

// See include_fog.frag
uniform int fogType;
vec3 fog_Func(vec3 color, int type);

void main()
{
	vec3 lightDir = gl_LightSource[0].position.xyz;
    vec3 halfVector = gl_LightSource[0].halfVector.xyz;
    vec4 texel;
    vec4 fragColor;
	vec4 color =    vec4(0.9, 0.9, 0.9, 1.0);
	vec4 specular = vec4(0.1, 0.1, 0.1, 1.0);

    // If gl_Color.a == 0, this is a back-facing polygon and the
    // normal should be reversed.
    vec3 n = (2.0 * gl_Color.a - 1.0) * normal;
    n = normalize(n);
    float NdotL = dot(n, lightDir);
	float NdotHV = max(dot(n, halfVector), 0.0);

	if (photoScenery) {
		texel = texture(landclass, vec2(gl_TexCoord[0].s, 1.0 - gl_TexCoord[0].t));
	} else {
		// The Landclass for this particular fragment.  This can be used to
		// index into the atlas textures.
		int lc = int(texture2D(landclass, gl_TexCoord[0].st).g * 255.0 + 0.5);

		// Different textures have different have different dimensions.
		// Dimensions array is scaled to fit in [0...1.0] in the texture1D, so has to be scaled back up here.
		//color = texture(diffuseArray, float(lc)/512.0) * (gl_LightSource[0].ambient + NdotL * gl_LightSource[0].diffuse);
		//specular = texture(specularArray, float(lc)/512.0);
		vec2 atlas_dimensions = 10000.0 * texture(dimensionsArray, float(lc)/512.0).st;
		vec2 atlas_scale =  vec2(tile_width / atlas_dimensions.s, tile_height / atlas_dimensions.t );
		vec2 st = atlas_scale * gl_TexCoord[0].st;

		// Rotate texture using the perlin texture as a mask to reduce tiling
		if (step(0.5, texture(perlin, atlas_scale * gl_TexCoord[0].st / 8.0).r) == 1.0) {
			st = vec2(atlas_scale.s * gl_TexCoord[0].t, atlas_scale.t * gl_TexCoord[0].s);
		}

		if (step(0.5, texture(perlin, - atlas_scale * gl_TexCoord[0].st / 16.0).r) == 1.0) {
			st = -st;
		}

		texel = texture(atlas, vec3(st, lc));
	}

    fragColor = color * texel + pow(NdotHV, gl_FrontMaterial.shininess) * gl_LightSource[0].specular * specular;

	fragColor.rgb = fog_Func(fragColor.rgb, fogType);
	gl_FragColor = fragColor;
}
