varying vec4  rawpos;
varying vec4  ecPosition;
varying vec3  VNormal;
varying vec3  Normal;
varying vec3  VTangent;
varying vec3  VBinormal;
varying vec4  constantColor;

void main(void)
{
    rawpos     = gl_Vertex;
    ecPosition = gl_ModelViewMatrix * gl_Vertex;
    VNormal = normalize(gl_NormalMatrix * gl_Normal);
    Normal = normalize(gl_Normal);

    vec3 t = normalize(cross(gl_Normal, vec3(1.0,0.0,0.0)));
    VTangent = gl_NormalMatrix * t;
    vec3 b = normalize(cross(gl_Normal,t));
    VBinormal = gl_NormalMatrix * b;

    gl_FrontColor = gl_Color;
    constantColor = gl_FrontMaterial.emission
            + gl_Color * (gl_LightModel.ambient + gl_LightSource[0].ambient);  
    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}
