#extension GL_EXT_gpu_shader4 : enable
//
// attachment 0:  normal.x  |  normal.x  |  normal.y  |  normal.y
// attachment 1: diffuse.r  | diffuse.g  | diffuse.b  | material Id
// attachment 2: specular.l | shininess  | emission.l |  unused
//
varying vec3 ecNormal;
varying float alpha;
uniform int materialID;
uniform sampler2D texture;
void main() {
    vec4 texel = texture2D(texture, gl_TexCoord[0].st);
    if (texel.a * alpha < 0.1)
        discard;
    float specular = dot( gl_FrontMaterial.specular.rgb, vec3( 0.3, 0.59, 0.11 ) );
    float shininess = gl_FrontMaterial.shininess;
    float emission = dot( gl_FrontLightModelProduct.sceneColor.rgb, vec3( 0.3, 0.59, 0.11 ) );
    
	vec3 normal2 = normalize( (2.0 * gl_Color.a - 1.0) * ecNormal );
    gl_FragData[0] = vec4( (normal2.xy + vec2(1.0,1.0)) * 0.5, 0.0, 1.0 );
    gl_FragData[1] = vec4( gl_Color.rgb * texel.rgb, float( materialID ) / 255.0 );
    gl_FragData[2] = vec4( specular, shininess / 255.0, emission, 1.0 );
}
