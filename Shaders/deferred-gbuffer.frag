#extension GL_EXT_gpu_shader4 : enable
//
// attachment 0:  normal.x  |  normal.x  |  normal.y  |  normal.y
// attachment 1: diffuse.r  | diffuse.g  | diffuse.b  | material Id
// attachment 2: specular.l | shininess  | emission.l |  unused
//
varying vec3 ecNormal;
varying vec4 color;
uniform int materialID;
uniform sampler2D texture;
void main() {
	float specular = dot( gl_FrontMaterial.specular.rgb, vec3( 0.3, 0.59, 0.11 ) );
	float shininess = gl_FrontMaterial.shininess;
	float emission = dot( gl_FrontLightModelProduct.sceneColor.rgb, vec3( 0.3, 0.59, 0.11 ) );
    vec4 texel = texture2D(texture, gl_TexCoord[0].st);
	if (texel.a * color.a < 0.1)
		discard;
    gl_FragData[0] = vec4( ecNormal.xy, 0.0, 1.0 );
    gl_FragData[1] = vec4( color.rgb * texel.rgb, float( materialID ) / 255.0 );
    gl_FragData[2] = vec4( specular, shininess / 255.0, emission, 1.0 );
}
