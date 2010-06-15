// -*-C++-*-

// Shader that uses OpenGL state values to do per-pixel lighting
//
// The only light used is gl_LightSource[0], which is assumed to be
// directional.
//
// Diffuse colors come from the gl_Color, ambient from the material. This is
// equivalent to osg::Material::DIFFUSE.

varying vec4 diffuse, constantColor;
varying vec3 normal, lightDir, halfVector;
varying float alpha, fogCoord;

uniform bool twoSideHack;

void main()
{
    vec4 ecPosition = gl_ModelViewMatrix * gl_Vertex;
    vec3 ecPosition3 = vec3(gl_ModelViewMatrix * gl_Vertex) / ecPosition.w;
    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    normal = gl_NormalMatrix * gl_Normal;
    lightDir = normalize(vec3(gl_LightSource[0].position));
    halfVector = normalize(gl_LightSource[0].halfVector.xyz);
    diffuse = gl_Color * gl_LightSource[0].diffuse;
    // Super hack: if diffuse material alpha is less than 1, assume a
    // transparency animation is at work
    if (gl_FrontMaterial.diffuse.a < 1.0)
        alpha = gl_FrontMaterial.diffuse.a;
    else
        alpha = gl_Color.a;
    // Another hack for supporting two-sided lighting without using
    // gl_FrontFacing in the fragment shader.
    if (twoSideHack) {
        gl_FrontColor = vec4(0.0, 0.0, 0.0, 1.0);
        gl_BackColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
    constantColor =  gl_FrontLightModelProduct.sceneColor
        + gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
    fogCoord = abs(ecPosition3.z);
}
