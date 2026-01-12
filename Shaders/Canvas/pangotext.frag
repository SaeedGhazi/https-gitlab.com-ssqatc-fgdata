$FG_GLSL_VERSION

out vec4 fragColor;

in VS_OUT {
	float render_part;
	vec2 texcoord;
	vec4 vertex_color;
} fs_in;

const int RENDER_PART_FOREGROUND = 0;
const int RENDER_PART_BACKGROUND = 1;
const int RENDER_PART_UNDERLINE = 2;
const int RENDER_PART_STRIKETHROUGH = 3;
const int RENDER_PART_OVERLINE = 4;

uniform sampler2D glyphTexture;

void main()
{
	int render_part = int(fs_in.render_part);
	if (render_part == RENDER_PART_FOREGROUND) {
		vec4 texel = texture(glyphTexture, fs_in.texcoord);
		fragColor.rgb = fs_in.vertex_color.rgb;
		fragColor.a = texel.r;
	} else {
		fragColor = fs_in.vertex_color;
	}
}
