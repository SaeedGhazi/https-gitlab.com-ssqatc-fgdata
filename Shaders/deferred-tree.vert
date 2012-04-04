// Tree instance scheme:
// vertex - local position of quad vertex.
// normal - x y scaling, z number of varieties
// fog coord - rotation
// color - xyz of tree quad origin, replicated 4 times.
#version 120

void main() {

    // Texture coordinates
    float numVarieties = gl_Normal.z;
    float texFract = floor(fract(gl_MultiTexCoord0.x) * numVarieties) / numVarieties;
    texFract += floor(gl_MultiTexCoord0.x) / numVarieties;
    gl_TexCoord[0] = vec4(texFract, gl_MultiTexCoord0.y, 0.0, 0.0);  
    
    // Position and scaling
    vec3 position = gl_Vertex.xyz * gl_Normal.xxy;
    float sr = sin(gl_FogCoord);
    float cr = cos(gl_FogCoord);

    // Rotation of the generic quad to specific one for the tree.
    position.xy = vec2(dot(position.xy, vec2(cr, sr)), dot(position.xy, vec2(-sr, cr)));
    position = position + gl_Color.xyz;
    gl_Position   = gl_ModelViewProjectionMatrix * vec4(position,1.0);

    // Color - white.
    gl_FrontColor = vec4(1.0, 1.0, 1.0,1.0);
    gl_BackColor = vec4(1.0, 1.0, 1.0,1.0);
}

