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
uniform vec4 fg_ShadowDistances;
uniform int filtering;

varying vec3 ray;
varying vec4 eyePlaneS;
varying vec4 eyePlaneT;
varying vec4 eyePlaneR;
varying vec4 eyePlaneQ;

vec3 position( vec3 viewDir, vec2 coords, sampler2D depth_tex );
vec3 normal_decode(vec2 enc);

vec4 DynamicShadow( in vec4 ecPosition, out vec4 tint )
{
    vec4 coords;
    if (ecPosition.z > -fg_ShadowDistances.x) {
        tint = vec4(0.0,1.0,0.0,1.0);
        coords.s = dot( ecPosition, eyePlaneS );
        coords.t = dot( ecPosition, eyePlaneT );
        coords.p = dot( ecPosition, eyePlaneR );
        coords.q = dot( ecPosition, eyePlaneQ );
    } else {
        return vec4(1.1,1.1,0.0,1.0); // outside, clamp to border
    }
    return coords;
}
void main() {
    vec2 coords = gl_TexCoord[0].xy;
    vec4 spec_emis = texture2D( spec_emis_tex, coords );
    if ( spec_emis.a < 0.1 )
        discard;
    vec3 normal = normal_decode(texture2D( normal_tex, coords ).rg);
    float len = length(normal);
    normal /= len;
    vec3 viewDir = normalize(ray);
    vec3 pos = position( viewDir, coords, depth_tex );

    vec4 tint;
    float shadow;
    if (filtering == 2) {
        shadow += 0.333 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos, 1.0), tint ) ).r;
        shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3(-0.003 * pos.z, -0.002 * pos.z, 0), 1.0), tint ) ).r;
        shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3( 0.003 * pos.z,  0.002 * pos.z, 0), 1.0), tint ) ).r;
        shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3(-0.003 * pos.z,  0.002 * pos.z, 0), 1.0), tint ) ).r;
        shadow += 0.166 * shadow2DProj( shadow_tex, DynamicShadow( vec4(pos + vec3( 0.003 * pos.z, -0.002 * pos.z, 0), 1.0), tint ) ).r;
    } else {
        shadow = shadow2DProj( shadow_tex, DynamicShadow( vec4( pos, 1.0 ), tint ) ).r;
    }

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
        Ispec = pow( clamp( dot( halfDir, normal ), 0.0, 1.0 ), spec_emis.y * 128.0 ) * spec_emis.x * fg_SunSpecularColor.rgb;
    }

    float matID = texture2D( color_tex, coords ).a * 255.0;
    if (matID == 255.0)
        Idiff += Ispec * spec_emis.x;

    gl_FragColor = vec4(mix(vec3(0.0), Idiff + Ispec, shadow) + Iemis, 1.0);
//    gl_FragColor = mix(tint, vec4(mix(vec3(0.0), Idiff + Ispec, shadow) + Iemis, 1.0), 0.92);
}
