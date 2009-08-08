varying vec4  rawpos;
varying vec4  ecPosition;
varying vec3  VNormal;
varying vec3  Normal;

void main(void)
{
    rawpos     = gl_Vertex;
    ecPosition = gl_ModelViewMatrix * gl_Vertex;
    VNormal = normalize(gl_NormalMatrix * gl_Normal);
    Normal = normalize(gl_Normal);

    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}
