uniform vec3 fg_Planes;

// normal compression functions from 
//   http://aras-p.info/texts/CompactNormalStorage.html#method04spheremap
vec2 normal_encode(vec3 n)
{
    float p = sqrt(n.z * 8.0 + 8.0);
    return n.xy / p + 0.5;
}

vec3 normal_decode(vec2 enc)
{
    vec2 fenc = enc * 4.0 - 2.0;
    float f = dot(fenc,fenc);
    float g = sqrt(1.0 - f / 4.0);
    vec3 n;
    n.xy = fenc * g;
    n.z = 1.0 - f / 2.0;
    return n;
}

vec3 position( vec3 viewDir, float depth )
{
    vec3 pos;
    pos.z = - fg_Planes.y / (fg_Planes.x + depth * fg_Planes.z);
    pos.xy = viewDir.xy / viewDir.z * pos.z;
	return pos;
}
