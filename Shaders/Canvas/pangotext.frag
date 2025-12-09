$FG_GLSL_VERSION

out vec4 fragColor;

in VS_OUT {
    vec2 texcoord;
    vec4 vertex_color;
} fs_in;

uniform sampler2D glyphTexture;

void main()
{
    vec4 texel = texture(glyphTexture, fs_in.texcoord);
    // Modulate by the fill color (stored in the vertex color)
    fragColor = texel;
}
