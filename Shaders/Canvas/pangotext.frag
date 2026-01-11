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
    fragColor.rgb = fs_in.vertex_color.rgb;
    fragColor.a = texel.r;
}
