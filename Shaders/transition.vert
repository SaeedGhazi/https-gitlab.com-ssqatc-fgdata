// -*-C++-*-
// -*-C++-*-
// Texture switching based on face slope and snow level
// based on earlier work by Frederic Bouvier, Tim Moore, and Yves Sablonier.
// © Emilian Huminiuc 2011


#version 120

varying vec4 RawPos;
varying vec3 normal;
varying vec3 Vnormal;

void main()
    {
    RawPos = gl_Vertex;
    gl_Position = ftransform();
    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    normal = normalize(gl_Normal);
    Vnormal = normalize(gl_NormalMatrix * gl_Normal);
    }
