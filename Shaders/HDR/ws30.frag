#version 330 core

layout(location = 0) out vec4 outGBuffer0;
layout(location = 1) out vec4 outGBuffer1;
layout(location = 2) out vec4 outGBuffer2;

in vec3 normalVS;
in vec2 texCoord;

uniform sampler2D landclass;
uniform sampler2DArray atlas;
uniform sampler1D dimensionsArray;
uniform sampler1D diffuseArray;
uniform sampler1D specularArray;
uniform sampler2D perlin;

// Passed from VPBTechnique, not the Effect
uniform float tile_width;
uniform float tile_height;

vec2 encodeNormal(vec3 n);
vec3 decodeSRGB(vec3 screenRGB);

void main()
{
    // The Landclass for this particular fragment.  This can be used to
	// index into the atlas textures.
    int lc = int(texture(landclass, texCoord).g * 255.0 + 0.5);

	// Different textures have different have different dimensions.
	// Dimensions array is scaled to fit in [0...1.0] in the texture1D, so has to be scaled back up here.
	vec4 color = texture(diffuseArray, float(lc)/512.0);
	vec4 specular = texture(specularArray, float(lc)/512.0);
	vec2 atlas_dimensions = 10000.0 * texture(dimensionsArray, float(lc)/512.0).st;
	vec2 atlas_scale =  vec2(tile_width / atlas_dimensions.s, tile_height / atlas_dimensions.t );
	vec2 st = atlas_scale * texCoord;

	// Rotate texture using the perlin texture as a mask to reduce tiling
	if (step(0.5, texture(perlin, atlas_scale * texCoord / 8.0).r) == 1.0) {
		st = vec2(atlas_scale.s * texCoord.t, atlas_scale.t * texCoord.s);
	}

	if (step(0.5, texture(perlin, - atlas_scale * texCoord / 16.0).r) == 1.0) {
		st = -st;
	}

    vec3 texel = decodeSRGB(texture(atlas, vec3(st, lc)).rgb);
    float specularity = clamp(dot(specular.rgb, vec3(0.333)), 0.0, 1.0);

    outGBuffer0.rg  = encodeNormal(normalVS);
    outGBuffer0.b   = 1.0 - specularity;
    outGBuffer0.a   = 1.0;
    outGBuffer1.rgb = texel;
    outGBuffer1.a   = 0.0;
    outGBuffer2.rgb = vec3(0.0);
    outGBuffer2.a   = 1.0;
}
