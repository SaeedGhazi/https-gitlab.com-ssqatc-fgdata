# FG1000 Base clearStyles

print("\n############");
print("#  FG1000  #");
print("############\n");

io.include("Constants.nas");
io.include("Commands.nas");

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";

io.load_nasal(nasal_dir ~ '/ConfigStore.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/MFDPage.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/MFDPageController.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/MFD.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/GUI.nas', "fg1000");

var FG1000 = {

new : func(EIS_Class = nil, EIS_SVG = nil) {
  var obj = {
    parents : [FG1000],
    displays : {}
  };

  if (EIS_Class == nil) {
    # Load the default EIS class.
    var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
    io.load_nasal(nasal_dir ~ '/EIS/EIS.nas', "fg1000");
    io.load_nasal(nasal_dir ~ '/EIS/EISController.nas', "fg1000");
    io.load_nasal(nasal_dir ~ '/EIS/EISStyles.nas', "fg1000");
    io.load_nasal(nasal_dir ~ '/EIS/EISOptions.nas', "fg1000");
    obj.EIS_Class = fg1000.EIS;
  } else {
    obj.EIS_Class = EIS_Class;
  }

  if (EIS_SVG == nil) {
    obj.EIS_SVG = "/Aircraft/Instruments-3d/FG1000/MFDPages/EIS.svg";
  } else {
    obj.EIS_SVG = EIS_SVG;
  }

  obj.ConfigStore = fg1000.ConfigStore.new();

  return obj;
},

setEIS : func(EIS_Class, EIS_SVG) {
  me.EIS_Class = EIS_Class;
  me.EIS_SVG = EIS.SVG;
},

addMFD : func(index, targetcanvas=nil, screenObject=nil) {
  if (me.displays[index] != nil) {
    print("FG1000 Index " ~ index ~ " already exists!");
    return
  }

  if (targetcanvas == nil) {
    targetcanvas = canvas.new({
            "name" : "MFD Canvas",
            "size" : [1024, 768],
            "view" : [1024, 768],
            "mipmapping": 0,
          });
  }

  var mfd = fg1000.MFD.new(me, me.EIS_Class, me.EIS_SVG, targetcanvas, index);
  me.displays[index] = mfd;
},

display : func(index, target_object=nil) {
  if (me.displays[index] == nil) {
    print("displayMFD: unknown display index " ~ index);
    return;
  }

  if (target_object == nil) target_object = "Screen" ~ index;

  var targetcanvas = me.displays[index].getCanvas();
  targetcanvas.addPlacement({"node": target_object});
},

displayGUI : func(index, scale=1.0) {
  if (me.displays[index] == nil) {
    print("displayMFD: unknown display index " ~ index);
    return;
  }

  var mfd_canvas = me.displays[index].getCanvas();
  var gui = fg1000.GUI.new(mfd_canvas, index, scale);
},

getConfigStore : func() {
  return me.ConfigStore;
},


};
