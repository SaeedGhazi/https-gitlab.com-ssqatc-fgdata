#version 330 core

layout(location = 0) out vec3 fragColor0;
layout(location = 1) out vec3 fragColor1;
layout(location = 2) out vec3 fragColor2;
layout(location = 3) out vec3 fragColor3;
layout(location = 4) out vec3 fragColor4;
layout(location = 5) out vec3 fragColor5;

in vec3 cubemapCoord0;
in vec3 cubemapCoord1;
in vec3 cubemapCoord2;
in vec3 cubemapCoord3;
in vec3 cubemapCoord4;
in vec3 cubemapCoord5;

uniform samplerCube envmap;

void main()
{
    fragColor0 = textureLod(envmap, cubemapCoord0, 0.0).rgb;
    fragColor1 = textureLod(envmap, cubemapCoord1, 0.0).rgb;
    fragColor2 = textureLod(envmap, cubemapCoord2, 0.0).rgb;
    fragColor3 = textureLod(envmap, cubemapCoord3, 0.0).rgb;
    fragColor4 = textureLod(envmap, cubemapCoord4, 0.0).rgb;
    fragColor5 = textureLod(envmap, cubemapCoord5, 0.0).rgb;
}
