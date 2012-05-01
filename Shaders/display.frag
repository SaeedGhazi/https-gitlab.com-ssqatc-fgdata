uniform sampler2D depth_tex;
uniform sampler2D normal_tex;
uniform sampler2D color_tex;
uniform sampler2D specular_tex;
uniform sampler2D lighting_tex;
//uniform sampler2D bloom_tex;
//uniform sampler2D ao_tex;
uniform float exposure;
uniform bool showBuffers;
uniform bool fg_DepthInColor;

vec3 HDR(vec3 L) {
    L = L * exposure;
    L.r = L.r < 1.413 ? pow(L.r * 0.38317, 1.0 / 2.2) : 1.0 - exp(-L.r);
    L.g = L.g < 1.413 ? pow(L.g * 0.38317, 1.0 / 2.2) : 1.0 - exp(-L.g);
    L.b = L.b < 1.413 ? pow(L.b * 0.38317, 1.0 / 2.2) : 1.0 - exp(-L.b);
    return L;
}

void main() {
    vec2 coords = gl_TexCoord[0].xy;
    vec4 color;
    if (showBuffers) {
        if (coords.x < 0.2 && coords.y < 0.2) {
            color = texture2D( normal_tex, coords * 5.0 );
        } else if (coords.x >= 0.8 && coords.y >= 0.8) {
            color = texture2D( specular_tex, (coords - vec2( 0.8, 0.8 )) * 5.0 );
        } else if (coords.x >= 0.8 && coords.y < 0.2) {
            color = texture2D( color_tex, (coords - vec2( 0.8, 0.0 )) * 5.0 );
        } else if (coords.x < 0.2 && coords.y >= 0.8 && fg_DepthInColor) {
            color = texture2D( depth_tex, (coords - vec2( 0.0, 0.8 )) * 5.0 );
        } else {
            color = texture2D( lighting_tex, coords ) /* + texture2D( bloom_tex, coords ) */;
            //color = vec4( HDR( color.rgb ), 1.0 );
        }
    } else {
        color = texture2D( lighting_tex, coords ) /* + texture2D( bloom_tex, coords ) */;
        //color = vec4( HDR( color.rgb ), 1.0 );
    }
    gl_FragColor = color;
}
