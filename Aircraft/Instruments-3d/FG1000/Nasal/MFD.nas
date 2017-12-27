# FG1000 MFD

print("##############");
print("# FG1000 MFD #");
print("##############\n");

io.include("constants.nas");

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";

io.load_nasal(nasal_dir ~ '/MFDPage.nas', "fg1000");

var MFDPages = [
  "NavigationMap",
  "TrafficMap",
  "Stormscope",
  "WeatherDataLink",
  "TAWS",
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
  "NearestAirspaces"
];

foreach (var page; MFDPages) {
  io.load_nasal(nasal_dir ~ page ~ '/' ~ page ~ '.nas', "fg1000");
  io.load_nasal(nasal_dir ~ page ~ '/' ~ page ~ 'Styles.nas', "fg1000");
  io.load_nasal(nasal_dir ~ page ~ '/' ~ page ~ 'Options.nas', "fg1000");
  io.load_nasal(nasal_dir ~ page ~ '/' ~ page ~ 'Controller.nas', "fg1000");
}

io.load_nasal(nasal_dir ~ 'EIS.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Drivers/EISDriver.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'PageGroupController.nas', "fg1000");


var MFD =
{
  new : func (myCanvas)
  {
    var obj = { parents : [ MFD ] };

    obj._svg = myCanvas.createGroup("softkeys");

    var fontmapper = func (family, weight) {
      #if( family == "Liberation Sans" and weight == "narrow" ) {
        return "LiberationFonts/LiberationSansNarrow-Regular.ttf";
      #}
      # If we don't return anything the default font is used
    };

    foreach (var page; MFDPages) {
      var svg_file ='/Aircraft/Instruments-3d/FG1000/Models/' ~ page ~ '.svg';
      if (resolvepath(svg_file) != "") {
        # Load an SVG file if available.
        canvas.parsesvg(obj._svg,
                        svg_file,
                        {'font-mapper': fontmapper});
      }
    }

    canvas.parsesvg(obj._svg,
                    '/Aircraft/Instruments-3d/FG1000/Models/MFD.svg',
                    {'font-mapper': fontmapper});

    obj._MFDDevice = canvas.PFD_Device.new(obj._svg, 12, "SoftKey", myCanvas, "MFD");
    obj._MFDDevice.RegisterWithEmesary();

    # Surround dynamic elements
    obj._pageTitle = obj._svg.getElementById("PageTitle");

    # Engine Information System
    obj._eisDriver = fg1000.EISDriver.new();
    obj._eis = fg1000.EIS.new(myCanvas, obj._eisDriver);

    # Controller for the display on the bottom left which allows selection
    # of page groups and individual pages using the FMS controller.
    obj._pageGroupController = fg1000.PageGroupController.new(myCanvas, obj._svg, obj._MFDDevice);

    foreach (var page; MFDPages) {
      var code = "obj._pageGroupController.addPage(\"" ~ page ~ "\", fg1000." ~ page ~ ".new(obj, myCanvas, obj._MFDDevice, obj._svg));";
      var addPageFn = compile(code);
      addPageFn();
    }

    # The NavigationMap page is a special case, as it is displayed with the Nearest... pages as an overlay
    obj.NavigationMap = obj._pageGroupController.getPage("NavigationMap");

    # Display the NavMap and the appropriate top level on startup.
    obj._MFDDevice.selectPage(obj.NavigationMap);

    # Add a wheel controller., which we will attach to the zoom.
    myCanvas.addEventListener("wheel", func(e)
    {
      if (e.deltaY >0) {
        obj._MFDDevice.current_page.controller.handleFMSInner(1);
      } else {
        obj._MFDDevice.current_page.controller.handleFMSInner(-1);
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
    me._MFDDevice.current_page.offdisplay();
    me._MFDDevice.DeRegisterWithEmesary();

  },
  setPageTitle: func(title)
  {
    me._pageTitle.setText(title);
  }
};
