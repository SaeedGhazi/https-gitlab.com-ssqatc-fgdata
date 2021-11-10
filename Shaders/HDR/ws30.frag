#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 normalVS;
in vec2 texCoord;

uniform sampler2D landclass;
uniform sampler2DArray atlas;
uniform sampler2D perlin;

// Passed from VPBTechnique, not the Effect
uniform float tile_width;
uniform float tile_height;
uniform vec4 dimensionsArray[128];
uniform vec4 ambientArray[128];
uniform vec4 diffuseArray[128];
uniform vec4 specularArray[128];


vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
	vec3 texel;

	if (photoScenery) {
		texel = decodeSRGB(texture(landclass, vec2(gl_TexCoord[0].s, 1.0 - gl_TexCoord[0].t)).rgb);
	} else {

		// The Landclass for this particular fragment.  This can be used to
		// index into the atlas textures.
		int lc = int(texture2D(landclass, gl_TexCoord[0].st).g * 255.0 + 0.5);

		color = ambientArray[lc] + diffuseArray[lc] * NdotL * gl_LightSource[0].diffuse;
		specular = specularArray[lc];
		
		// Different textures have different have different dimensions.
		vec2 atlas_dimensions = dimensionsArray[lc].st;
		vec2 atlas_scale =  vec2(tile_width / atlas_dimensions.s, tile_height / atlas_dimensions.t );
		vec2 st = atlas_scale * gl_TexCoord[0].st;

		// Rotate texture using the perlin texture as a mask to reduce tiling
		if (step(0.5, texture(perlin, atlas_scale * gl_TexCoord[0].st / 8.0).r) == 1.0) {
			st = vec2(atlas_scale.s * gl_TexCoord[0].t, atlas_scale.t * gl_TexCoord[0].s);
		}

		if (step(0.5, texture(perlin, - atlas_scale * gl_TexCoord[0].st / 16.0).r) == 1.0) {
			st = -st;
		}

		texel = decodeSRGB(texture(atlas, vec3(st, lc)).rgb);
	}

    float specularity = clamp(dot(specular.rgb, vec3(0.333)), 0.0, 1.0);

    outGBuffer0.rg  = encodeNormal(normalVS);
    outGBuffer0.b   = 1.0 - specularity;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = texel;
    outGBuffer1.a   = 0.0;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
