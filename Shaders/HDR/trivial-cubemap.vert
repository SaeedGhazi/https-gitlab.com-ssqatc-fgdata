#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multiTexCoord0;

out vec3 cubemapCoord;

uniform mat4 osg_ModelViewProjectionMatrix;

uniform int fg_CubemapFace;

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    vec2 texCoord = multiTexCoord0.xy * 2.0 - 1.0;
    // Map the quad texture coordinates to a direction vector to sample
    // the cubemap. This assumes that we are using the weird left-handed
    // orientations given by the OpenGL spec.
    // See https://www.khronos.org/opengl/wiki/Cubemap_Texture#Upload_and_orientation
    switch(fg_CubemapFace) {
    case 0: // +X
        cubemapCoord = vec3(1.0, -texCoord.y, -texCoord.x);
        break;
    case 1: // -X
        cubemapCoord = vec3(-1.0, -texCoord.y, texCoord.x);
        break;
    case 2: // +Y
        cubemapCoord = vec3(texCoord.x, 1.0, texCoord.y);
        break;
    case 3: // -Y
        cubemapCoord = vec3(texCoord.x, -1.0, -texCoord.y);
        break;
    case 4: // +Z
        cubemapCoord = vec3(texCoord.x, -texCoord.y, 1.0);
        break;
    case 5: // -Z
        cubemapCoord = vec3(-texCoord.x, -texCoord.y, -1.0);
        break;
    }
}
