# FG1000 MFD

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
io.load_nasal(nasal_dir ~ 'NavMap/NavMap.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'NavMap/NavMapStyles.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'NavMap/NavMapOptions.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'NavMap/NavMapController.nas', "fg1000");

io.load_nasal(nasal_dir ~ 'TrafficMap/TrafficMap.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'TrafficMap/TrafficMapStyles.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'TrafficMap/TrafficMapOptions.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'TrafficMap/TrafficMapController.nas', "fg1000");

io.load_nasal(nasal_dir ~ 'EIS.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Drivers/EISDriver.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'PageGroupController.nas', "fg1000");


var MFD =
{
  # Center of any maps
  MAP_CENTER : {
    X: (1024/2 + 60),
    Y: (768/2 + 20)
  },

  # Constants for the hard-buttons on the fascia
  FASCIA : {
    FMS_OUTER : 0,
    FMS_INNER : 1,
    RANGE     : 2,
  },



  new : func (myCanvas)
  {
    var obj = { parents : [ MFD ] };

    obj._svg = myCanvas.createGroup("softkeys");
    canvas.parsesvg(obj._svg, '/Aircraft/Instruments-3d/FG1000/Models/MFD.svg');

    obj._MFDDevice = canvas.PFD_Device.new(obj._svg, 12, "SoftKey", myCanvas, "MFD");
    obj._MFDDevice.RegisterWithEmesary();

    # Engine Information System
    obj._eisDriver = fg1000.EISDriver.new();
    obj._eis = fg1000.EIS.new(myCanvas, obj._eisDriver);

    # Controller for the display on the bottom left which allows selection
    # of page groups and individual pages using the FMS controller.
    obj._pageGroupController = fg1000.PageGroupController.new(myCanvas, obj._svg, obj._MFDDevice);
    obj._pageGroupController.RegisterWithEmesary();

    obj._pageGroupController.addPage("NavigationMap", fg1000.NavMap.new(myCanvas, obj._MFDDevice, obj._svg));
    obj._pageGroupController.addPage("TrafficMap", fg1000.TrafficMap.new(myCanvas, obj._MFDDevice, obj._svg));

    # Display the NavMap and the appropriate top level on startup.
    obj._MFDDevice.selectPage(obj._pageGroupController.getPage("NavigationMap"));

    # Add a wheel controller., which we will attach to the zoom.
    myCanvas.addEventListener("wheel", func(e)
    {
      if (e.deltaY >0) {
        obj._MFDDevice.current_page.controller.zoomIn();
      } else {
        obj._MFDDevice.current_page.controller.zoomOut();
      }
    });

    var updateTimer = func() {
      obj._eisDriver.update();
      obj._eis.update();
      settimer(updateTimer, 0.1);
    };

    updateTimer();

    return obj;
  },
  del: func()
  {
    me._pageGroupController.DeRegisterWithEmesary();
  }
};
