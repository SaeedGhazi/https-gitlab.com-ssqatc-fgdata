# FG1000 Engine Information Display

# A mapping from names of elements to specific elements of the SVG.
# These names mapped to values by the provided EISDriver.
var DynamicTextElementMap =
{
  new : func(svg, name, element_id, format)
  {
    var obj = { parents : [ DynamicTextElementMap ] };
    obj._name = name;
    obj._element_id = element_id;
    obj._element = svg.getElementById(element_id);
    obj._format = format;
    return obj;
  },

  update : func(driver)
  {
    me._element.setText(sprintf(me._format, driver.getValue(me._name)));
  },
};

var DynamicSliderElementMap =
{
  new : func(svg, name, element_id, min=0.0, max=1.0)
  {
    var obj = { parents : [ DynamicSliderElementMap ] };
    obj._name = name;
    obj._element_id = element_id;
    obj._element = svg.getElementById(element_id);
    obj._baseTranslation = obj._element.getTranslation();
    obj._min = min;
    obj._max = max;
    return obj;
  },

  update : func(driver)
  {
    var value = driver.getValue(me._name);
    if (value == nil) value = 0.0;

    #  Bound value to the minimum and maximum values.
    value = math.max(me._min, value);
    value = math.min(me._max, value);

    # Convert to normalized value
    value = (value - me._min) / (me._max - me._min);

    # Simply shift the slider along.  All sliders have a 0 value
    # at x=3.5, and a maximum value at x=138.0.
    me._element.setTranslation([
      me._baseTranslation[0] + (value * (138.0 - 3.5)),
      me._baseTranslation[1]
    ]);
  },
};


var DynamicRotatingElementMap =
{
  new : func(svg, name, element_id, min=0.0, max=1.0, range=360.0)
  {
    var obj = { parents : [ DynamicRotatingElementMap ] };
    obj._name = name;
    obj._element_id = element_id;
    obj._element = svg.getElementById(element_id);
    obj._baseTranslation = obj._element.getTranslation();
    obj._min = min;
    obj._max = max;
    obj._range = range;
    return obj;
  },

  update : func(driver)
  {
    var value = driver.getValue(me._name);
    if (value == nil) value = 0.0;

    #  Bound value to the minimum and maximum values.
    value = math.max(me._min, value);
    value = math.min(me._max, value);

    # Convert to normalized value
    value = (value - me._min) / (me._max - me._min);
    me._element.setRotation(value * me._range * D2R, [100.0, 100.0]);
  },
};

var EIS =
{
  new : func (myCanvas, EISDriver)
  {
    var obj = { parents : [ EIS ] };
    obj._canvas = myCanvas;
    obj._EISDriver = EISDriver;

    obj._svg= obj._canvas.createGroup("EIS");
    canvas.parsesvg(obj._svg, '/Aircraft/Instruments-3d/FG1000/Models/EIS_c172s.svg');

    # Objects to display as straight text
    obj._textElements = [
      DynamicTextElementMap.new(obj._svg, "RPM", "RPMDisplay", "%i"),
      DynamicTextElementMap.new(obj._svg, "MBusVolts" , "MBusVolts", "%.01f"),
      DynamicTextElementMap.new(obj._svg, "MBusVolts" , "EBusVolts", "%.01f"),
      DynamicTextElementMap.new(obj._svg, "EngineHours" , "EngineHours", "%.01f"),
    ];

    obj._sliderElements = [
      DynamicSliderElementMap.new(obj._svg, "FuelFlowGPH", "FuelFlowPointer", 0.0, 20.0),
      DynamicSliderElementMap.new(obj._svg, "OilPressurePSI", "OilPressurePointer", 0.0, 115.0),
      DynamicSliderElementMap.new(obj._svg, "OilTemperatureF", "OilTempPointer", 0.0, 245.0),
      DynamicSliderElementMap.new(obj._svg, "EGTNorm", "EGTPointer", 0.0, 1.0),
      DynamicSliderElementMap.new(obj._svg, "EGTNorm", "EGTCylinder", 0.0, 1.0),
      DynamicSliderElementMap.new(obj._svg, "VacuumSuctionInHG", "VacPointer", 3.0, 7.0),

      DynamicSliderElementMap.new(obj._svg, "LeftFuelUSGal", "LeftFuelPointer", 0.0, 30.0),
      DynamicSliderElementMap.new(obj._svg, "RightFuelUSGal", "RightFuelPointer", 0.0, 30.0),
    ];

    obj._rotationElements = [
      DynamicRotatingElementMap.new(obj._svg, "RPM", "RPMPointer", 0.0, 3000.0, 260.0),
    ];

    obj._svg.getElementById("RPMPointer").set("center-offset-x", 150.0);
    obj._svg.getElementById("RPMPointer").set("center-offset-y", 100.0);

    return obj;
  },

  update : func()
  {
    foreach(var te; me._textElements) {
      te.update(me._EISDriver);
    }

    foreach(var se; me._sliderElements) {
      se.update(me._EISDriver);
    }

    foreach(var se; me._rotationElements) {
      se.update(me._EISDriver);
    }

  }

};
