#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multiTexCoord0;

out vec3 cubemapCoord0;
out vec3 cubemapCoord1;
out vec3 cubemapCoord2;
out vec3 cubemapCoord3;
out vec3 cubemapCoord4;
out vec3 cubemapCoord5;

uniform mat4 osg_ModelViewProjectionMatrix;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vec2 texCoord = multiTexCoord0.xy * 2.0 - 1.0;
    // Map the quad texture coordinates to a direction vector to sample
    // the cubemap. This assumes that we are using the weird left-handed
    // orientations given by the OpenGL spec.
    // See https://www.khronos.org/opengl/wiki/Cubemap_Texture#Upload_and_orientation
    cubemapCoord0 = vec3(1.0, -texCoord.y, -texCoord.x);
    cubemapCoord1 = vec3(-1.0, -texCoord.y, texCoord.x);
    cubemapCoord2 = vec3(texCoord.x, 1.0, texCoord.y);
    cubemapCoord3 = vec3(texCoord.x, -1.0, -texCoord.y);
    cubemapCoord4 = vec3(texCoord.x, -texCoord.y, 1.0);
    cubemapCoord5 = vec3(-texCoord.x, -texCoord.y, -1.0);
}
