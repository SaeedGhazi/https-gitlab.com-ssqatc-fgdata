uniform sampler2D lighting_tex;
uniform sampler2D bloom_tex;

uniform sampler2D bufferNW_tex;
uniform sampler2D bufferNE_tex;
uniform sampler2D bufferSW_tex;
uniform sampler2D bufferSE_tex;

uniform float exposure;
uniform bool showBuffers;

uniform bool bloomEnabled;
uniform bool bloomBuffers;

uniform bool bufferNW_enabled;
uniform bool bufferNE_enabled;
uniform bool bufferSW_enabled;
uniform bool bufferSE_enabled;

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
        if (coords.x < 0.2 && coords.y < 0.2 && bufferSW_enabled) {
            color = texture2D( bufferSW_tex, coords * 5.0 );
        } else if (coords.x >= 0.8 && coords.y >= 0.8 && bufferNE_enabled) {
            color = texture2D( bufferNE_tex, (coords - vec2( 0.8, 0.8 )) * 5.0 );
        } else if (coords.x >= 0.8 && coords.y < 0.2 && bufferSE_enabled) {
            color = texture2D( bufferSE_tex, (coords - vec2( 0.8, 0.0 )) * 5.0 );
        } else if (coords.x < 0.2 && coords.y >= 0.8 && bufferNW_enabled) {
            color = texture2D( bufferNW_tex, (coords - vec2( 0.0, 0.8 )) * 5.0 );
        } else {
            color = texture2D( lighting_tex, coords );
            if (bloomEnabled && bloomBuffers)
                color = color + texture2D( bloom_tex, coords );
            //color = vec4( HDR( color.rgb ), 1.0 );
        }
    } else {
        color = texture2D( lighting_tex, coords );
        if (bloomEnabled && bloomBuffers)
            color = color + texture2D( bloom_tex, coords );
        //color = vec4( HDR( color.rgb ), 1.0 );
    }
    gl_FragColor = color;
}
