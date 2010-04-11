#version 120
#extension GL_EXT_geometry_shader4 : enable

varying in vec4 rawposIn[];
varying in vec3 NormalIn[];
varying in vec3 VTangentIn[];
varying in vec3 VBinormalIn[];

varying out vec4 rawpos;
varying out vec4 ecPosition;
varying out vec3 VNormal;
varying out vec3 VTangent;
varying out vec3 VBinormal;
varying out vec3 Normal;
varying out vec4 constantColor;
varying out float bump;

uniform float canopy_height;

void createVertex(int i, int j, float offset, float s)
{
	rawpos = rawposIn[i] + offset * vec4(NormalIn[i], 0.0);
	ecPosition = gl_ModelViewMatrix * rawpos;
	if ( s == 0.0 )
	{
		vec4 v;
		if (j < i)
		{
			v = rawposIn[j] - rawposIn[i];
			Normal = normalize(cross( NormalIn[i], v.xyz ));
		}
		else
		{
			v = rawposIn[i] - rawposIn[j];
			Normal = normalize(cross( NormalIn[j], v.xyz ));
		}
	}
	else
	{
		Normal = NormalIn[i];
	}
	VNormal = normalize(gl_NormalMatrix * Normal);
	VTangent  = VTangentIn[i];
	VBinormal = VBinormalIn[i];
	bump = s;

	gl_FrontColor = gl_FrontColorIn[i];
	constantColor = gl_FrontMaterial.emission
		+ gl_FrontColorIn[i] * (gl_LightModel.ambient + gl_LightSource[0].ambient);  
	gl_Position = gl_ProjectionMatrix * ecPosition;
	gl_TexCoord[0] = gl_TexCoordIn[i][0];
	EmitVertex();
}

void main(void)
{
	if (canopy_height > 0.01) {
		createVertex(0, 1, canopy_height, 0.0);
		createVertex(0, 1, 0.0, 0.0);
		createVertex(1, 0, canopy_height, 0.0);
		createVertex(1, 0, 0.0, 0.0);
		EndPrimitive();
		createVertex(1, 2, canopy_height, 0.0);
		createVertex(1, 2, 0.0, 0.0);
		createVertex(2, 1, canopy_height, 0.0);
		createVertex(2, 1, 0.0, 0.0);
		EndPrimitive();
		createVertex(2, 0, canopy_height, 0.0);
		createVertex(2, 0, 0.0, 0.0);
		createVertex(0, 2, canopy_height, 0.0);
		createVertex(0, 2, 0.0, 0.0);
		EndPrimitive();
		createVertex(0, 1, 0.0, 0.0);
		createVertex(1, 2, 0.0, 0.0);
		createVertex(2, 0, 0.0, 0.0);
		EndPrimitive();
	}
	createVertex(0, 1, canopy_height, 1.0);
	createVertex(1, 2, canopy_height, 1.0);
	createVertex(2, 0, canopy_height, 1.0);
	EndPrimitive();
}
