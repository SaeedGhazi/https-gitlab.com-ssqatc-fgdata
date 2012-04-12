uniform sampler2D depth_tex;
uniform sampler2D normal_tex;
uniform sampler2D color_tex;
uniform sampler2D spec_emis_tex;
uniform vec4 fg_FogColor;
uniform float fg_FogDensity;
uniform vec3 fg_Planes;
varying vec3 ray;

vec3 position( vec3 viewdir, float depth );

void main() {
    vec2 coords = gl_TexCoord[0].xy;
    float initialized = texture2D( spec_emis_tex, coords ).a;
    if ( initialized < 0.1 )
        discard;
    vec3 normal;
    normal.xy = texture2D( normal_tex, coords ).rg * 2.0 - vec2(1.0,1.0);
    normal.z = sqrt( 1.0 - dot( normal.xy, normal.xy ) );
    float len = length(normal);
    normal /= len;
    vec3 pos = position( normalize(ray), texture2D( depth_tex, coords ).r );

    float fogFactor = 0.0;
    const float LOG2 = 1.442695;
    fogFactor = exp2(-fg_FogDensity * fg_FogDensity * pos.z * pos.z * LOG2);
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    gl_FragColor = vec4(fg_FogColor.rgb, 1.0 - fogFactor);
}
