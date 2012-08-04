uniform sampler2D lighting_tex;
uniform sampler2D bloom_tex;

uniform bool colorShift;
uniform vec3 redShift;
uniform vec3 greenShift;
uniform vec3 blueShift;

uniform bool vignette;
uniform float innerCircle;
uniform float outerCircle;

uniform vec2 fg_BufferSize;
// uniform float osg_SimulationTime;
// uniform float shutterFreq;
// uniform float shutterDuration;

uniform bool bloomEnabled;
uniform float bloomStrength;
uniform bool bloomBuffers;

void main() {
    vec2 coords = gl_TexCoord[0].xy;
    vec4 color = texture2D( lighting_tex, coords );
	if (bloomEnabled && bloomBuffers)
		color = color + bloomStrength * texture2D( bloom_tex, coords );

	if (colorShift) {
		vec3 c2;
		c2.r = dot(color, redShift);
		c2.g = dot(color, greenShift);
		c2.b = dot(color, blueShift);
		color.rgb = c2;
	}

	if (vignette) {
		vec2 c = 2.0 * coords - vec2(1.,1.);
		c = c * vec2( 1.0, fg_BufferSize.y / fg_BufferSize.x );
		float l = length(c);
		float f = smoothstep( innerCircle, innerCircle * outerCircle, l );
		color.rgb = (1 - f) * color.rgb;
	}
	// if ((osg_FrameNumber % 6) == 0)
		// f = 1.0;

    gl_FragColor = color;
}
