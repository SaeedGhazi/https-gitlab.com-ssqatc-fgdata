#extension GL_EXT_gpu_shader4 : enable
//
// attachment 0:  normal.x  |  normal.x  |  normal.y  |  normal.y
// attachment 1: diffuse.r  | diffuse.g  | diffuse.b  | material Id
// attachment 2: specular.l | shininess  | emission.l |  unused
//
uniform int materialID;
uniform sampler2D texture;
void main() {
    vec4 texel = texture2D(texture, gl_TexCoord[0].st);
    if (texel.a < 0.1)
        discard;
    float specular = 0.0;
    float shininess = 0.1;
    float emission = 0.0;
        
	  // Normal is straight towards the viewer.
	  vec3 normal2 = (0.0, 0.0, 0.0);
    gl_FragData[0] = vec4( 0.5, 0.5, 0.0, 1.0 );
    gl_FragData[1] = vec4( gl_Color.rgb * texel.rgb, float( materialID ) / 255.0 );
    gl_FragData[2] = vec4( specular, shininess / 255.0, emission, 1.0 );
}
