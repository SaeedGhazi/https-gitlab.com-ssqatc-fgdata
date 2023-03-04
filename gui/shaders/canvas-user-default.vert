// -*-C++-*-
void shMain() {

    gl_Position = sh_Ortho * sh_View * sh_Model * sh_Vertex;

}
