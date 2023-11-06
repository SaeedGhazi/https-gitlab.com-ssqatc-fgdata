#version 330 core

layout(location = 0) out vec4 fragColor;

in VS_OUT {
    vec4 color;
} fs_in;

uniform float max_radiance;

void main()
{
    fragColor = vec4(fs_in.color.rgb * max_radiance, fs_in.color.a);
}
