uniform mat4 fg_ViewMatrix;
uniform sampler2D depth_tex;
uniform sampler2D normal_tex;
uniform sampler2D color_tex;
uniform sampler2D spec_emis_tex;
uniform sampler2DShadow shadow_tex;
uniform vec4 fg_SunDiffuseColor;
uniform vec4 fg_SunSpecularColor;
uniform vec3 fg_SunDirection;
uniform vec3 fg_Planes;
varying vec3 ray;
vec4 DynamicShadow( in vec4 ecPosition, out vec4 tint )
{
    vec4 coords;
    vec2 shift = vec2( 0.0 );
    int index = 4;
    if (ecPosition.z > -5.0) {
        index = 1;
        tint = vec4(0.0,1.0,0.0,1.0);
    } else if (ecPosition.z > -50.0) {
        index = 2;
        shift = vec2( 0.0, 0.5 );
        tint = vec4(0.0,0.0,1.0,1.0);
    } else if (ecPosition.z > -512.0) {
        index = 3;
        shift = vec2( 0.5, 0.0 );
        tint = vec4(1.0,1.0,0.0,1.0);
    } else if (ecPosition.z > -10000.0) {
        shift = vec2( 0.5, 0.5 );
        tint = vec4(1.0,0.0,0.0,1.0);
    } else {
        return vec4(1.1,1.1,0.0,1.0); // outside, clamp to border
    }
    coords.s = dot( ecPosition, gl_EyePlaneS[index] );
    coords.t = dot( ecPosition, gl_EyePlaneT[index] );
    coords.p = dot( ecPosition, gl_EyePlaneR[index] );
    coords.q = dot( ecPosition, gl_EyePlaneQ[index] );
    coords.st *= .5;
    coords.st += shift;
    return coords;
}
void main() {
    vec2 coords = gl_TexCoord[0].xy;
    vec4 spec_emis = texture2D( spec_emis_tex, coords );
    if ( spec_emis.a < 0.1 )
        discard;
    vec3 normal;
    normal.xy = texture2D( normal_tex, coords ).rg * 2.0 - vec2(1.0,1.0);
    normal.z = sqrt( 1.0 - dot( normal.xy, normal.xy ) );
    float len = length(normal);
    normal /= len;
    vec3 viewDir = normalize(ray);
    float depth = texture2D( depth_tex, coords ).r;
    vec3 pos;
    pos.z = - fg_Planes.y / (fg_Planes.x + depth * fg_Planes.z);
    pos.xy = viewDir.xy / viewDir.z * pos.z;

    vec4 tint;
#if 0
    float shadow = 1.0;
#elif 1
    float shadow = shadow2DProj( shadow_tex, DynamicShadow( vec4( pos, 1.0 ), tint ) ).r;
#elif 0
	float shadow = 0.0;
    shadow += 0.333 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos, 1.0), tint ) ).r;
    shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3(-0.003 * pos.z, -0.003 * pos.z, 0), 1.0), tint ) ).r;
    shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3( 0.003 * pos.z,  0.003 * pos.z, 0), 1.0), tint ) ).r;
    shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3(-0.003 * pos.z,  0.003 * pos.z, 0), 1.0), tint ) ).r;
    shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3( 0.003 * pos.z, -0.003 * pos.z, 0), 1.0), tint ) ).r;
#else
    float kernel[9] = float[]( 36/256.0, 24/256.0, 6/256.0,
                           24/256.0, 16/256.0, 4/256.0,
                           6/256.0,  4/256.0, 1/256.0 );
    float shadow = 0;
    for( int x = -2; x <= 2; ++x )
      for( int y = -2; y <= 2; ++y )
        shadow += kernel[abs(x)*3 + abs(y)] * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3(-0.005 * x * pos.z, -0.005 * y * pos.z, 0), 1.0), tint ) ).r;
#endif
    vec3 lightDir = (fg_ViewMatrix * vec4( fg_SunDirection, 0.0 )).xyz;
    lightDir = normalize( lightDir );
    vec3 color = texture2D( color_tex, coords ).rgb;
    vec3 Idiff = clamp( dot( lightDir, normal ), 0.0, 1.0 ) * color * fg_SunDiffuseColor.rgb;
    vec3 halfDir = lightDir - viewDir;
    len = length( halfDir );
    vec3 Ispec = vec3(0.0);
    vec3 Iemis = spec_emis.z * color;
    if (len > 0.0001) {
        halfDir /= len;
        Ispec = pow( clamp( dot( halfDir, normal ), 0.0, 1.0 ), spec_emis.y * 255.0 ) * spec_emis.x * fg_SunSpecularColor.rgb;
    }
    gl_FragColor = vec4(mix(vec3(0.0), Idiff + Ispec, shadow) + Iemis, 1.0);
//    gl_FragColor = mix(tint, vec4(mix(vec3(0.0), Idiff + Ispec, shadow) + Iemis, 1.0), 0.92);
}
