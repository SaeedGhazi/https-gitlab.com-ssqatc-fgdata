// -*-C++-*-

varying vec4 diffuse, constantColor;
varying vec3 normal, lightDir, halfVector;
varying float alpha, fogCoord;

uniform sampler2D texture;

void main()
{
    vec3 n, halfV;
    float NdotL, NdotHV, fogFactor;
    vec4 color = constantColor;
    vec4 texel;
    vec4 fragColor;

    n = normalize(normal);
    NdotL = max(dot(n, lightDir), 0.0);
    if (NdotL > 0.0) {
        color += diffuse * NdotL;
        halfV = normalize(halfVector);
        NdotHV = max(dot(n, halfV), 0.0);
        if (gl_FrontMaterial.shininess > 0.0)
            color += gl_FrontMaterial.specular * gl_LightSource[0].specular
                * pow(NdotHV, gl_FrontMaterial.shininess);
    }
    color.a = alpha;
    texel = texture2D(texture, gl_TexCoord[0].st);
    fragColor = color * texel;
    fogFactor = exp(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord);
    gl_FragColor = mix(gl_Fog.color, fragColor, fogFactor);
}
