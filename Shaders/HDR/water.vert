#version 330 core

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multiTexCoord0;

out vec4 waterTex1;
out vec4 waterTex2;
out mat3 TBN;
out vec3 relpos;
out vec2 TopoUV;

uniform float WindE, WindN;

uniform float osg_SimulationTime;
uniform mat4 osg_ModelViewMatrix;
uniform mat4 osg_ModelViewMatrixInverse;
uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat4 osg_ViewMatrixInverse;
uniform mat3 osg_NormalMatrix;

// constants for the cartesian to geodetic conversion.
const float a = 6378137.0;                  //float a = equRad;
const float squash = 0.9966471893352525192801545;
const float latAdjust = 0.9999074159800018; //geotiff source for the depth map
const float lonAdjust = 0.9999537058469516; //actual extents: +-180.008333333333326/+-90.008333333333340

void rotationmatrix(float angle, out mat4 rotmat)
{
    rotmat = mat4( cos( angle ), -sin( angle ), 0.0, 0.0,
                   sin( angle ),  cos( angle ), 0.0, 0.0,
                   0.0         ,  0.0         , 1.0, 0.0,
                   0.0         ,  0.0         , 0.0, 1.0 );
}

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;

    // first current altitude of eye position in model space
    vec4 ep = osg_ModelViewMatrixInverse * vec4(0.0, 0.0, 0.0, 1.0);
    // and relative position to vector
    relpos = pos.xyz - ep.xyz;

    vec3 rawPos = (osg_ViewMatrixInverse * osg_ModelViewMatrix * pos).xyz;

    // Using precalculated vectors
    // vec3 T = normalize(osg_NormalMatrix * tangent);
    // vec3 B = normalize(osg_NormalMatrix * binormal);
    // vec3 N = normalize(osg_NormalMatrix * normal);

    vec3 T = normalize(osg_NormalMatrix * vec3(0.0, -1.0, 0.0));
    vec3 B = normalize(osg_NormalMatrix * vec3(1.0,  0.0, 0.0));
    vec3 N = normalize(osg_NormalMatrix * vec3(0.0,  0.0, 1.0));
    TBN = mat3(T, B, N);

    mat4 RotationMatrix;

    vec4 t1 = vec4(0.0, osg_SimulationTime * 0.005217, 0.0, 0.0);
    vec4 t2 = vec4(0.0, osg_SimulationTime * -0.0012, 0.0, 0.0);

    float Angle;
    float windFactor = sqrt(WindE * WindE + WindN * WindN) * 0.05;

    if (WindN == 0.0 && WindE == 0.0) {
        Angle = 0.0;
    }else{
        Angle = atan(-WindN, WindE) - atan(1.0);
    }

    rotationmatrix(Angle, RotationMatrix);
    waterTex1 = multiTexCoord0 * RotationMatrix - t1 * windFactor;

    rotationmatrix(Angle, RotationMatrix);
    waterTex2 = multiTexCoord0 * RotationMatrix - t2 * windFactor;

    // Geodesy lookup for depth map
    float e2 = abs(1.0 - squash * squash);
    float ra2 = 1.0/(a * a);
    float e4 = e2 * e2;
    float XXpYY = rawPos.x * rawPos.x + rawPos.y * rawPos.y;
    float Z = rawPos.z;
    float sqrtXXpYY = sqrt(XXpYY);
    float p = XXpYY * ra2;
    float q = Z*Z*(1.0-e2)*ra2;
    float r = 1.0/6.0*(p + q - e4);
    float s = e4 * p * q/(4.0*r*r*r);
    if ( s >= 2.0 && s <= 0.0)
        s = 0.0;
    float t = pow(1.0+s+sqrt(s*2.0+s*s), 1.0/3.0);
    float u = r + r*t + r/t;
    float v = sqrt(u*u + e4*q);
    float w = (e2*u+ e2*v-e2*q)/(2.0*v);
    float k = sqrt(u+v+w*w)-w;
    float D = k*sqrtXXpYY/(k+e2);

    vec2 NormPosXY = normalize(rawPos.xy);
    vec2 NormPosXZ = normalize(vec2(D, rawPos.z));
    float signS = sign(rawPos.y);
    if (-0.00015 <= rawPos.y && rawPos.y<=.00015)
        signS = 1.0;
    float signT = sign(rawPos.z);
    if (-0.0002 <= rawPos.z && rawPos.z<=.0002)
        signT = 1.0;
    float cosLon = dot(NormPosXY, vec2(1.0,0.0));
    float cosLat = dot(abs(NormPosXZ), vec2(1.0,0.0));
    TopoUV.s = signS * lonAdjust * degrees(acos(cosLon))/180.;
    TopoUV.t = signT * latAdjust * degrees(acos(cosLat))/90.;
    TopoUV.s = TopoUV.s * 0.5 + 0.5;
    TopoUV.t = TopoUV.t * 0.5 + 0.5;
}
