// -*-C++-*-
#version 330

in  vec2 step;
in  vec4 stepColor;
out vec4 interpolateColor;

void main()
{
    gl_Position = vec4(step.xy, 0, 1);
    interpolateColor = stepColor;
}
