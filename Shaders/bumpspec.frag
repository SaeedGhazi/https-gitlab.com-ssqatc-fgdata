// -*- mode: C; -*-
// Licence: GPL v2
// Authors: Original code by Thorsten Jordan, Luis Barrancos and others (dangerdeep.sf.net)
//      Modified by Emilian Huminiuc (emilianh@gmail.com) (i4dnf on the flightgear forums).
// fixme: maybe lookup texmap is faster than pow(). Quick tests showed that this is not the case...

uniform sampler2D tex_color;   // (diffuse) color map, RGB
uniform sampler2D tex_normal;   // normal map, RGB + A Specular


varying vec4  ecPosition;
varying vec3 lightdir, halfangle;

void main()
{
    // get and normalize vector to light source
    vec3 L = normalize(lightdir);

    // get and normalize normal vector from texmap
    vec4 v = texture2D(tex_normal, gl_TexCoord[0].st);
    vec3 N = normalize(vec3(v.xyz * 2.0 - 1.0));
    N.y = -N.y;
    if (!gl_FrontFacing)
        N = -N;

    // compute specular color
    // get and normalize half angle vector
    vec3 H = normalize(halfangle);

    // compute resulting specular color
    vec3 specular_color = vec3(gl_FrontMaterial.specular) *
      pow(max(dot(H, N), 0.0), gl_FrontMaterial.shininess);

    // compute diffuse color
    vec3 diffuse_color = vec3(texture2D(tex_color, gl_TexCoord[0].st));

    // handle ambient
    diffuse_color = diffuse_color * mix(max(dot(L, N), 0.0), 0.6, gl_LightSource[0].ambient.r);

    specular_color = specular_color * v.a;

    // final color of fragment
    vec3 final_color = clamp((diffuse_color + specular_color) * vec3(gl_LightSource[0].diffuse /*light_color*/), 0.0, 1.0);

    float fog_factor;
    float fogCoord = ecPosition.z;
    const float LOG2 = 1.442695;
    fog_factor = exp2(-gl_Fog.density * gl_Fog.density * fogCoord * fogCoord * LOG2);
    fog_factor = clamp(fog_factor, 0.0, 1.0);

    // output color is a mix between fog and final color
    gl_FragColor = vec4(mix(vec3(gl_Fog.color), final_color, fog_factor), 1.0);
}
