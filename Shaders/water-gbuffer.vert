// This shader is mostly an adaptation of the shader found at
//  http://www.bonzaisoftware.com/water_tut.html and its glsl conversion
//  available at http://forum.bonzaisoftware.com/viewthread.php?tid=10
//  © Michael Horsch - 2005
//  Major update and revisions - 2011-10-07
//  © Emilian Huminiuc and Vivian Meazza

#version 120

varying vec4    waterTex1;
varying vec4    waterTex2;

varying vec3    viewerdir;
varying vec3    lightdir;
varying vec3    normal;

varying vec3    VTangent;
varying vec3    VBinormal;

uniform float   osg_SimulationTime;
uniform float   WindE, WindN;
uniform int     rembrandt_enabled;

attribute vec3    tangent;
attribute vec3    binormal;

/////// functions /////////

void rotationmatrix(in float angle, out mat4 rotmat)
    {
    rotmat = mat4( cos( angle ), -sin( angle ), 0.0, 0.0,
        sin( angle ),  cos( angle ), 0.0, 0.0,
        0.0         ,  0.0         , 1.0, 0.0,
        0.0         ,  0.0         , 0.0, 1.0 );
    }

void main(void)
    {
    mat4 RotationMatrix;
    normal = gl_NormalMatrix * gl_Normal;
    VTangent = normalize(gl_NormalMatrix * tangent);
    VBinormal = normalize(gl_NormalMatrix * binormal);

    viewerdir = vec3(gl_ModelViewMatrixInverse[3]) - vec3(gl_Vertex);

    vec4 t1 = vec4(0.0, osg_SimulationTime * 0.005217, 0.0, 0.0);
    vec4 t2 = vec4(0.0, osg_SimulationTime * -0.0012, 0.0, 0.0);

    float Angle;

    float windFactor = sqrt(pow(abs(WindE),2)+pow(abs(WindN),2)) * 0.05;

    if (WindN == 0.0 && WindE == 0.0) {
        Angle = 0.0;
        }else{
            Angle = atan(-WindN, WindE) - atan(1.0);
        }

    rotationmatrix(Angle, RotationMatrix);
    waterTex1 = gl_MultiTexCoord0 * RotationMatrix - t1 * windFactor;

    rotationmatrix(Angle, RotationMatrix);
    waterTex2 = gl_MultiTexCoord0 * RotationMatrix - t2 * windFactor;

    //     fog_Func(fogType);
    gl_Position = ftransform();
    }