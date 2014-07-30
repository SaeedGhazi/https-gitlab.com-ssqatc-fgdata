
// -*-C++-*-

// Shader that uses OpenGL state values to do per-pixel lighting

uniform float size;

varying vec3 relPos;
varying vec2 rawPos;
varying float pixelSize;



void main()
{
    gl_FrontColor= gl_Color;
    gl_Position = ftransform();

    vec4 ep = gl_ModelViewMatrixInverse * vec4(0.0,0.0,0.0,1.0);
    relPos = gl_Vertex.xyz - ep.xyz;
    rawPos = gl_Vertex.xy;
    float dist = length(relPos);
    float lightScale = size * size * size * size * size/ 500.0;
    pixelSize = min(size * size/25.0,lightScale/dist);
    gl_PointSize = 2.0 * pixelSize;
}
