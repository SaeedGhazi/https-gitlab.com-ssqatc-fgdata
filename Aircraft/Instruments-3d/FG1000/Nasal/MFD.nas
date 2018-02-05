# FG1000 MFD

print("##############");
print("# FG1000 MFD #");
print("##############\n");

io.include("Constants.nas");
io.include("Commands.nas");

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";

io.load_nasal(nasal_dir ~ '/ConfigStore.nas', "fg1000");

io.load_nasal(nasal_dir ~ '/MFDPage.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/MFDPageController.nas', "fg1000");

io.load_nasal(nasal_dir ~ '/EIS/EIS.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/EIS/EISStyles.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/EIS/EISOptions.nas', "fg1000");
io.load_nasal(nasal_dir ~ '/EIS/EISController.nas', "fg1000");

var MFDPages = [
  "NavigationMap",
  "TrafficMap",
  "Stormscope",
  "WeatherDataLink",
  "TAWSB",
  "AirportInfo",
  "AirportDirectory",
  "AirportDeparture",
  "AirportArrival",
  "AirportApproach",
  "AirportWeather",
  "IntersectionInfo",
  "NDBInfo",
  "VORInfo",
  "UserWPTInfo",
  "TripPlanning",
  "Utility",
  "GPSStatus",
  "XMRadio",
  "XMInfo",
  "SystemStatus",
  "ActiveFlightPlanWide",
  "ActiveFlightPlanNarrow",
  "FlightPlanCatalog",
  "StoredFlightPlan",
  "Checklist1",
  "Checklist2",
  "Checklist3",
  "Checklist4",
  "Checklist5",
  "NearestAirports",
  "NearestIntersections",
  "NearestNDB",
  "NearestVOR",
  "NearestUserWPT",
  "NearestFrequencies",
  "NearestAirspaces",
  "DirectTo",   # display at the top of the stack
  "Surround",
];

foreach (var page; MFDPages) {
  io.load_nasal(nasal_dir ~ "MFDPages/" ~ page ~ '/' ~ page ~ '.nas', "fg1000");
  io.load_nasal(nasal_dir ~ "MFDPages/" ~ page ~ '/' ~ page ~ 'Styles.nas', "fg1000");
  io.load_nasal(nasal_dir ~ "MFDPages/" ~ page ~ '/' ~ page ~ 'Options.nas', "fg1000");
  io.load_nasal(nasal_dir ~ "MFDPages/" ~ page ~ '/' ~ page ~ 'Controller.nas', "fg1000");
}

var MFD =
{
  new : func (myCanvas, device_id=1)
  {
    var obj = {
      parents : [ MFD ],
      EIS : nil,
      NavigationMap: nil,
      Surround : nil,
      _pageList : {},
    };

    obj.ConfigStore = fg1000.ConfigStore.new();

    obj._svg = myCanvas.createGroup("softkeys");
    obj._svg.set("clip-frame", canvas.Element.LOCAL);
    obj._svg.set("clip", "rect(0px, 1024px, 768px, 0px)");

    var fontmapper = func (family, weight) {
      #if( family == "Liberation Sans" and weight == "narrow" ) {
        return "LiberationFonts/LiberationSansNarrow-Regular.ttf";
      #}
      # If we don't return anything the default font is used
    };

    canvas.parsesvg(obj._svg,
                    '/Aircraft/Instruments-3d/FG1000/MFDPages/EIS.svg',
                    {'font-mapper': fontmapper});

    foreach (var page; MFDPages) {
      var svg_file ='/Aircraft/Instruments-3d/FG1000/MFDPages/' ~ page ~ '.svg';
      if (resolvepath(svg_file) != "") {
        # Load an SVG file if available.
        canvas.parsesvg(obj._svg,
                        svg_file,
                        {'font-mapper': fontmapper});
      }
    }

    obj._MFDDevice = canvas.PFD_Device.new(obj._svg, 12, "SoftKey", myCanvas, "MFD");
    obj._MFDDevice.device_id = device_id;
    obj._MFDDevice.RegisterWithEmesary();

    # Surround dynamic elements
    obj._pageTitle = obj._svg.getElementById("PageTitle");

    # Controller for the header and display on the bottom left which allows selection
    # of page groups and individual pages using the FMS controller.
    obj.Surround = fg1000.Surround.new(obj, myCanvas, obj._MFDDevice, obj._svg);
    obj.SurroundController = obj.Surround.getController();

    # Engine Information System.  A special case as it's always displayed on the MFD.
    obj.EIS = fg1000.EIS.new(obj, myCanvas, obj._MFDDevice, obj._svg);
    obj.addPage("EIS", obj.EIS);

    # The NavigationMap page is a special case, as it is displayed with the Nearest... pages as an overlay
    obj.NavigationMap = fg1000.NavigationMap.new(obj, myCanvas, obj._MFDDevice, obj._svg);
    obj.addPage("NavigationMap", obj.NavigationMap);
    obj.NavigationMap.topMenu(obj._MFDDevice, obj.NavigationMap, nil);

    # Now load the other pages normally;
    foreach (var page; MFDPages) {
      if ((page != "NavigationMap") and (page != "EIS")) {
        #var code = "obj.Surround.addPage(\"" ~ page ~ "\", fg1000." ~ page ~ ".new(obj, myCanvas, obj._MFDDevice, obj._svg));";
        var code = "obj.addPage(\"" ~ page ~ "\", fg1000." ~ page ~ ".new(obj, myCanvas, obj._MFDDevice, obj._svg));";
        var addPageFn = compile(code);
        addPageFn();
      }
    }

    # Display the Surround, EIS and NavMap and the appropriate top level on startup.
    obj.Surround.setVisible(1);
    obj.EIS.setVisible(1);
    obj.EIS.ondisplay();
    obj._MFDDevice.selectPage(obj.NavigationMap);

    return obj;
  },
  getDevice : func () {
    return me._MFDDevice;
  },
  del: func()
  {
    me._MFDDevice.current_page.offdisplay();
    me._MFDDevice.DeRegisterWithEmesary();
    me.SurroundController.del();

  },
  setPageTitle: func(title)
  {
    me._pageTitle.setText(title);
  },
  addPage : func(name, page)
  {
    me._pageList[name] = page;
  },

  getPage : func(name)
  {
    return me._pageList[name];
  },

  getDeviceID : func() {
    return me._MFDDevice.device_id;
  },
};
