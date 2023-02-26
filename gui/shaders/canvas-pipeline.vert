// -*-C++-*-
#version 330

/*** Input *******************/
in vec2 pos;
in vec2 textureUV;
uniform mat4 sh_Model;
uniform mat4 sh_Ortho;
uniform mat3 paintInverted;

/*** Output ******************/
out vec2 texImageCoord;
out vec2 paintCoord;

/*** Grobal variables ********************/
vec4 sh_Vertex;

/*** Functions ****************************************/

// User defined shader
void shMain(void);

/*** Main thread  **************************************************/
void main() {

    /* Stage 3: Transformation */
    sh_Vertex = vec4(pos, 0, 1);

    /* Extended Stage: User defined shader that affects gl_Position */
    shMain();

    /* 2D pos in texture space */
    texImageCoord = textureUV;

    /* 2D pos in paint space (Back to paint space) */
    paintCoord = (paintInverted * vec3(pos, 1)).xy;

}
