$FG_GLSL_VERSION

out vec4 fragColor;

in VS_OUT {
	vec2 texcoord;
	vec4 vertex_color;
	flat int renderPart;
} fs_in;

const int RENDER_PART_FOREGROUND = 0;
const int RENDER_PART_BACKGROUND = 1;
const int RENDER_PART_UNDERLINE = 2;
const int RENDER_PART_STRIKETHROUGH = 3;
const int RENDER_PART_OVERLINE = 4;

uniform sampler2D glyphTexture;

void main() {
	if (fs_in.renderPart == 0) {
		float alpha = texture(glyphTexture, fs_in.texcoord).r;
		if (alpha == 0.0) {
			fragColor = vec4(0.0, 0.0, 0.0, 0.0);
		} else {
			fragColor.a = fs_in.vertex_color.a * alpha;
			vec3 fg = fs_in.vertex_color.rgb * fragColor.a;
			fragColor.rgb = fg;
		}
	} else {
		fragColor = fs_in.vertex_color;
	}
	if (fragColor.a == 0) {
		discard;
	}
}
