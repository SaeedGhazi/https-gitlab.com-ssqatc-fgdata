// -*- mode: C; -*-
// Licence: GPL v2
// Authors: Original code by Thorsten Jordan, Luis Barrancos and others (dangerdeep.sf.net)
//      Modified by Emilian Huminiuc (emilianh@gmail.com) (i4dnf on the flightgear forums).

/* input:
gl_Vertex
gl_Normal      (tangentz)
gl_MultiTexCoord0   (texcoord)
tangentx_righthanded   (tangentx,righthanded-factor)
*/

/* can we give names to default attributes? or do we need to use named attributes for that?
how to give named attributes with vertex buffer objects?
we could assign them to a variable, but would that be efficient? an unnecessary copy.
but the shader compiler should be able to optimize that...
the way should be to use vertex attributes (together with vertex arrays or VBOs),
that have a name and use that name here.
until then, access sources directly or via a special variable.
*/

varying vec4  ecPosition;
varying vec3 lightdir, halfangle;
attribute vec4 tangent, binormal;

void main()
{
    ecPosition = gl_ModelViewMatrix * gl_Vertex;

    // compute direction to light in object space (L)
    vec3 lightpos_obj = vec3(gl_ModelViewMatrixInverse * gl_LightSource[0].position);
    vec3 lightdir_obj = normalize(lightpos_obj);

    // direction to viewer (E)
    // compute direction to viewer (E) in object space (mvinv*(0,0,0,1) - inputpos)
    vec3 viewerdir_obj = normalize(vec3(gl_ModelViewMatrixInverse[3]) - vec3(gl_Vertex));

    // compute halfangle vector (H = ||L+E||)
    vec3 halfangle_obj = normalize(viewerdir_obj + lightdir_obj);

    // transform light direction to tangent space
    lightdir.x = dot(tangent, lightdir_obj);
    lightdir.y = dot(binormal, lightdir_obj);
    lightdir.z = dot(gl_Normal, lightdir_obj);

    halfangle.x = dot(tangent, halfangle_obj);
    halfangle.y = dot(binormal, halfangle_obj);
    halfangle.z = dot(gl_Normal, halfangle_obj);

    // finally compute position
    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}
