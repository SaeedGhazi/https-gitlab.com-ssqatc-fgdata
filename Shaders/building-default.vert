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
attribute vec3 rotPitchWtex0x; // (rotation, pitch height, wall texture x offset)
attribute vec3 wtex0yTex1xTex1y; // (wall texture y offset, wall/roof texture x gain, wall/roof texture y gain)
attribute vec3 rtex0xRtex0y; // (roof texture y offset, roof texture x gain, unused)
attribute vec3 rooftopscale; // (rooftop x scale, rooftop y scale)

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
    float sr = sin(6.28 * rotPitchWtex0x.x);
    float cr = cos(6.28 * rotPitchWtex0x.x);

    vec3 position = gl_Vertex.xyz;
    // Adjust the very top of the roof to match the rooftop scaling.  This shapes
    // the rooftop - gambled, gabled etc.  These vertices are identified by gl_Color.z
    position.x = (1.0 - gl_Color.z) * position.x + gl_Color.z * ((position.x + 0.5) * rooftopscale.x - 0.5);
    position.y = (1.0 - gl_Color.z) * position.y + gl_Color.z * (position.y * rooftopscale.y);

    // Adjust pitch of roof to the correct height. These vertices are identified by gl_Color.z
    // Scale down by the building height (instanceScaleRotate.z) because
    // immediately afterwards we will scale UP the vertex to the correct scale.
    position.z = position.z + gl_Color.z * rotPitchWtex0x.y / instanceScaleRotate.z;
    position = position * instanceScaleRotate.xyz;

    // Rotation of the building and movement into position
    position.xy = vec2(dot(position.xy, vec2(cr, sr)), dot(position.xy, vec2(-sr, cr)));
    position = position + instancePosition.xyz;

    gl_Position = gl_ModelViewProjectionMatrix * vec4(position,1.0);

    // Texture coordinates are stored as:
    // - a separate offset for the wall (wtex0x, wtex0y), and roof (rtex0x, rtex0y)
    // - a shared gain value (tex1x, tex1y)
    //
    // The vertex color value selects between them, with glColor.x=1 indicating walls
    // and glColor.y=1 indicating roofs.
    // Finally, the roof texture is on the left of the texture sheet
    float wtex0x = rotPitchWtex0x.z;
    float wtex0y = wtex0yTex1xTex1y.x;
    float rtex0x = rtex0xRtex0y.x;
    float rtex0y = rtex0xRtex0y.y;
    vec2 tex0 = vec2(sign(gl_MultiTexCoord0.x) * (gl_Color.x*wtex0x + gl_Color.y*rtex0x),
                     gl_Color.x*wtex0y + gl_Color.y*rtex0y);
    gl_TexCoord[0].x = tex0.x + gl_MultiTexCoord0.x * wtex0yTex1xTex1y.y;
    gl_TexCoord[0].y = tex0.y + gl_MultiTexCoord0.y * wtex0yTex1xTex1y.z;

    // Rotate the normal.
    normal = gl_Normal;
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
