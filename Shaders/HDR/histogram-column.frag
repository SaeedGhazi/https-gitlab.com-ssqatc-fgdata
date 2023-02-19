#version 330 core

out uint fragHits;

uniform sampler2D hdr_tex;

uint luminance_to_bin_index(float luminance);

float srgb_to_luminance(vec3 color)
{
    return dot(color, vec3(0.2125, 0.7154, 0.0721));
}

void main()
{
    ivec2 hdr_tex_size = textureSize(hdr_tex, 0);
    int column = int(gl_FragCoord.x);
    uint target_bin = uint(gl_FragCoord.y); // [0, 255]

    uint hits = 0u;

    for (int row = 0; row < hdr_tex_size.y; ++row) {
        vec3 hdr_color = texelFetch(hdr_tex, ivec2(column, row), 0).rgb;
        // sRGB to relative luminance
        float lum = srgb_to_luminance(hdr_color);
        // Get the bin index corresponding to the given pixel luminance
        uint pixel_bin = luminance_to_bin_index(lum);
        // Check if this pixel should go in the bin
        if (pixel_bin == target_bin) {
            hits += 1u;
        }
    }

    fragHits = hits;
}
