#
# canvas-efis loader
#
var EFIS_namespace = "canvas_efis";

var unload = func(module) {
    globals[EFIS_namespace].DisplayUnit.unload();
    globals[EFIS_namespace].EFISCanvas.unload();
    globals[EFIS_namespace].EFIS.unload();
}

var main = func(module) {
    io.load_nasal(module.getFilePath()~"efis-framework.nas", EFIS_namespace);
    io.load_nasal(module.getFilePath()~"eicas-message-sys.nas", EFIS_namespace);
}
