// -*-C++-*-

// Shader that uses OpenGL state values to do per-pixel lighting
//
// The only light used is gl_LightSource[0], which is assumed to be
// directional.
//
// Diffuse and ambient colors come from the gl_Color. This is
// equivalent to osg::Material::AMBIENT_AND_DIFFUSE.

varying vec4 diffuse, constantColor;
varying vec3 normal, lightDir, halfVector;
varying float fogCoord, alpha;

void main()
{
    vec3 ecPosition = vec3(gl_ModelViewMatrix * gl_Vertex);
    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    normal = gl_NormalMatrix * gl_Normal;
    lightDir = normalize(vec3(gl_LightSource[0].position));
    halfVector = normalize(gl_LightSource[0].halfVector.xyz);
    diffuse = gl_Color * gl_LightSource[0].diffuse;
    alpha = gl_Color.a;
    constantColor =  gl_FrontMaterial.emission
        + gl_Color * (gl_LightModel.ambient + gl_LightSource[0].ambient);
    fogCoord = abs(ecPosition.z);
}
