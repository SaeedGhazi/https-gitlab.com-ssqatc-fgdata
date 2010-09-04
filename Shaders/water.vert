varying vec4 waterTex0;
varying vec4 waterTex1;
varying vec4 waterTex2;
varying vec4 waterTex3;
varying vec4 waterTex4;
uniform float osg_SimulationTime;
varying vec3 lightVec;
varying float fogCoord;
varying vec4 ecPosition;

void main(void)
{

lightVec = normalize(gl_LightSource[0].position.xyz);
ecPosition = gl_ModelViewMatrix * gl_Vertex;
vec4 lightpos = vec4(lightVec, 1.0);

vec4 temp;
vec4 tangent = vec4(1.0, 0.0, 0.0, 0.0);
vec4 norm = vec4(0.0, 1.0, 0.0, 0.0);
vec4 binormal = vec4(0.0, 0.0, 1.0, 0.0);

temp = gl_ModelViewMatrix * gl_Vertex;
waterTex4.x = dot(temp, tangent);
waterTex4.y = dot(temp, binormal);
waterTex4.z = dot(temp, norm);
waterTex4.w = 0.0;

temp = lightpos;
waterTex0.x = dot(temp, tangent);
waterTex0.y = dot(temp, binormal);
waterTex0.z = dot(temp, norm);
waterTex0.w = 0.0;


vec4 t1 = vec4(0.0, osg_SimulationTime*0.035217, 0.0,0.0);
vec4 t2 = vec4(0.0, osg_SimulationTime*-0.0212, 0.0,0.0);

waterTex1 = gl_MultiTexCoord0 + t1;
waterTex2 = gl_MultiTexCoord0 + t2;

waterTex3 = gl_MultiTexCoord0;

fogCoord = abs(ecPosition.z / ecPosition.w);

gl_Position = ftransform();
}
