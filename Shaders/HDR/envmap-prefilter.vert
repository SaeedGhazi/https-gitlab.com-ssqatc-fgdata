#version 330 core

out vec3 cubemapCoord0;
out vec3 cubemapCoord1;
out vec3 cubemapCoord2;
out vec3 cubemapCoord3;
out vec3 cubemapCoord4;
out vec3 cubemapCoord5;

void main()
{
    vec2 pos = vec2(gl_VertexID % 2, gl_VertexID / 2) * 4.0 - 1.0;
    gl_Position = vec4(pos, 0.0, 1.0);
    // Map the quad texture coordinates to a direction vector to sample
    // the cubemap. This assumes that we are using the weird left-handed
    // orientations given by the OpenGL spec.
    // See https://www.khronos.org/opengl/wiki/Cubemap_Texture#Upload_and_orientation
    cubemapCoord0 = vec3(1.0, -pos.y, -pos.x);
    cubemapCoord1 = vec3(-1.0, -pos.y, pos.x);
    cubemapCoord2 = vec3(pos.x, 1.0, pos.y);
    cubemapCoord3 = vec3(pos.x, -1.0, -pos.y);
    cubemapCoord4 = vec3(pos.x, -pos.y, 1.0);
    cubemapCoord5 = vec3(-pos.x, -pos.y, -1.0);
}
