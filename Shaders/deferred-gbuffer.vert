//
// attachment 0:  normal.x  |  normal.x  |  normal.y  |  normal.y
// attachment 1: diffuse.r  | diffuse.g  | diffuse.b  | material Id
// attachment 2: specular.l | shininess  | emission.l |  unused
//
varying vec3 ecNormal;
varying float alpha;
void main() {
    ecNormal = gl_NormalMatrix * gl_Normal;
    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    gl_FrontColor.rgb = gl_Color.rgb;  gl_FrontColor.a = 1.0;
    gl_BackColor.rgb = gl_Color.rgb; gl_BackColor.a = 0.0;
    alpha = gl_Color.a;
}
