$FG_GLSL_VERSION

out vec4 fragColor;

in VS_OUT {
	vec2 texcoord;
	vec4 vertex_color;
	flat int renderPart;
	flat bool selected;
} fs_in;

const int RENDER_PART_FOREGROUND = 0;
const int RENDER_PART_BACKGROUND = 1;
const int RENDER_PART_UNDERLINE = 2;
const int RENDER_PART_STRIKETHROUGH = 3;
const int RENDER_PART_OVERLINE = 4;

const vec3 SELECTION_BACKGROUND_COLOR = vec3(0.1,0.4, 0.85);

uniform sampler2D glyphTexture;

void main() {
	if (fs_in.renderPart == RENDER_PART_FOREGROUND) {
		float alpha = texture(glyphTexture, fs_in.texcoord).r;
		fragColor.a = fs_in.vertex_color.a * alpha;
		vec3 fg = fs_in.vertex_color.rgb * fragColor.a;
		if (fs_in.selected) {
			fragColor.rgb = vec3(1, 1, 1) - fg;
		} else {
			fragColor.rgb = fg;
		}
	} else if (fs_in.renderPart == RENDER_PART_BACKGROUND) {
		if (fs_in.selected) {
			if (fs_in.vertex_color.a > 0) {
				fragColor.rgb = vec3(1, 1, 1) - fs_in.vertex_color.rgb;
			} else {
				fragColor.rgb = SELECTION_BACKGROUND_COLOR;
			}
			fragColor.a = 1;
		} else {
			fragColor = fs_in.vertex_color;
		}
	}
	if (fragColor.a == 0) {
		discard;
	}
}
