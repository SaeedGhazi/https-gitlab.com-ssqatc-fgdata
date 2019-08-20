// -*-C++-*-

// Shader that uses OpenGL state values to do per-pixel lighting
//
// The only light used is gl_LightSource[0], which is assumed to be
// directional.
//
// Diffuse colors come from the gl_Color, ambient from the material. This is
// equivalent to osg::Material::DIFFUSE.
#version 120
#extension GL_EXT_draw_instanced : enable
#define MODE_OFF 0
#define MODE_DIFFUSE 1
#define MODE_AMBIENT_AND_DIFFUSE 2

attribute vec3 instancePosition; // (x,y,z)
attribute vec3 instanceScaleRotate; // (width, depth, height)
attribute vec3 rotPitchTex0x; // (rotation, pitch height, texture x offset)
attribute vec3 tex0yTex1xTex1y; // (texture y offset, texture x gain, texture y gain)

// The constant term of the lighting equation that doesn't depend on
// the surface normal is passed in gl_{Front,Back}Color. The alpha
// component is set to 1 for front, 0 for back in order to work around
// bugs with gl_FrontFacing in the fragment shader.
varying vec4 diffuse_term;
varying vec3 normal;

uniform int colorMode;

////fog "include"////////
//uniform int fogType;
//
//void fog_Func(int type);
/////////////////////////

void main()
{
    // Determine the rotation for the building.
    float sr = sin(6.28 * rotPitchTex0x.x);
    float cr = cos(6.28 * rotPitchTex0x.x);

    // Adjust pitch of roof to the correct height.
    // The top roof vertices are the only ones that have fractional z values (1.5),
    // so we can use this to identify them and scale up any pitched roof vertex to
    // the correct pitch (rotPitchTex0x.y * 2.0 because of the fractional z value),
    // then scale down by the building height (instanceScaleRotate.z) because
    // immediately afterwards we will scale UP the vertex to the correct scale.
    vec3 position = gl_Vertex.xyz;
    position.z = position.z + fract(position.z) * 2.0 * rotPitchTex0x.y / instanceScaleRotate.z - fract(position.z);
    position = position * instanceScaleRotate.xyz;

    // Rotation of the building and movement into position
    position.xy = vec2(dot(position.xy, vec2(cr, sr)), dot(position.xy, vec2(-sr, cr)));
    position = position + instancePosition.xyz;

    gl_Position = gl_ModelViewProjectionMatrix * vec4(position,1.0);

    // Texture coordinates are stored as tex0 and tex1 across two attributes.
    // tex0 contains the bottom leftmost point, and tex1 contains (w,h).
    gl_TexCoord[0].x = sign(gl_MultiTexCoord0.x) * rotPitchTex0x.z + gl_MultiTexCoord0.x * tex0yTex1xTex1y.y;
    gl_TexCoord[0].y = tex0yTex1xTex1y.x + gl_MultiTexCoord0.y * tex0yTex1xTex1y.z;

    // Rotate the normal.
    normal = gl_Normal;

    // The roof pieces have a normal of (+/-0.7, 0.0, 0.7)
    // If the roof is flat, then we need to change it to (0,0,1).
    // First term evaluates for normals without a +z component (all except roof)
    // Second term evaluates for roof normals with a pitch
    // Third term evaluates for flat roofs
    normal = step(0.5, 1.0 - normal.z) * normal + step(0.5, normal.z) * clamp(rotPitchTex0x.y, 0.0, 1.0) * normal + step(0.5, normal.z) * (1.0 - clamp(rotPitchTex0x.y, 0.0, 1.0)) * vec3(0,0,1);

    // Rotate the normal as per the building.
    normal.xy = vec2(dot(normal.xy, vec2(cr, sr)), dot(normal.xy, vec2(-sr, cr)));
    normal = gl_NormalMatrix * normal;

    vec4 ambient_color, diffuse_color;
    if (colorMode == MODE_DIFFUSE) {
        diffuse_color = vec4(1.0,1.0,1.0,1.0);
        ambient_color = gl_FrontMaterial.ambient;
    } else if (colorMode == MODE_AMBIENT_AND_DIFFUSE) {
        diffuse_color = vec4(1.0,1.0,1.0,1.0);
        ambient_color = vec4(1.0,1.0,1.0,1.0);
    } else {
        diffuse_color = gl_FrontMaterial.diffuse;
        ambient_color = gl_FrontMaterial.ambient;
    }

    diffuse_term = diffuse_color * gl_LightSource[0].diffuse;
    vec4 constant_term = gl_FrontMaterial.emission + ambient_color *
        (gl_LightModel.ambient +  gl_LightSource[0].ambient);
    // Super hack: if diffuse material alpha is less than 1, assume a
    // transparency animation is at work
    if (gl_FrontMaterial.diffuse.a < 1.0)
        diffuse_term.a = gl_FrontMaterial.diffuse.a;
    else
        diffuse_term.a = 1.0;
    // Another hack for supporting two-sided lighting without using
    // gl_FrontFacing in the fragment shader.
    gl_FrontColor.rgb = constant_term.rgb;  gl_FrontColor.a = 1.0;
    gl_BackColor.rgb = constant_term.rgb; gl_BackColor.a = 0.0;
    //fogCoord = abs(ecPosition.z / ecPosition.w);
		//fog_Func(fogType);
}
