# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# Foobar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# FG1000 MFD Page base class

# Load the PFD UI Elements
var mfd_dir = getprop("/sim/fg-root") ~ "/Nasal/canvas/PFD/";
var loadPFDFile = func(file) io.load_nasal(mfd_dir ~ file, "PFD");

loadPFDFile("DefaultStyle.nas");
loadPFDFile("UIElement.nas");
loadPFDFile("TextElement.nas");
loadPFDFile("HighlightElement.nas");
loadPFDFile("GroupElement.nas");
loadPFDFile("ScrollElement.nas");
loadPFDFile("DataEntryElement.nas");
loadPFDFile("PointerElement.nas");
loadPFDFile("RotatingElement.nas");

var MFDPage =
{

new : func (mfd, myCanvas, device, SVGGroup, pageName, title)
{
  var obj = {
    pageName : pageName,
    _group : myCanvas.createGroup(pageName ~ "Layer"),
    _SVGGroup : SVGGroup,
    parents : [ MFDPage, device.addPage(title, pageName ~ "Group") ],
    _symbols : {},
    _controller : nil,
  };

  obj.device = device;
  obj.mfd = mfd;

  # Pick up Style, Options and Controller
  var code = "obj.Styles  = fg1000." ~ pageName ~ "Styles.new(); " ~
             "obj.Options = fg1000." ~ pageName ~ "Options.new();";
  var createStylesAndOptions = compile(code);
  createStylesAndOptions();

  # Need to display this underneath the softkeys, EIS, header.
  obj._group.setInt("z-index", -10.0);
  obj._group.setVisible(0);

  return obj;
},

addTextElements : func(symbols) {
  foreach (var s; symbols) {
    me._symbols[s] = PFD.TextElement.new(me.pageName, me._SVGGroup, s);
  }
},

getTextElement : func(symbolName) {
  return me._symbols[symbolName];
},

highlightTextElement : func(symbolName) {
  me._symbols[symbolName].highlightElement();
},

unhighlightTextElement : func(symbolName) {
  me._symbols[symbolName].unhighlightElement();
},

getTextValue : func(symbolName) {
  var sym = me._symbols[symbolName];
  assert(sym != nil, "Unknown text element " ~ symbolName ~ " (check your addTextElements call?)");
  return sym.getValue();
},

setTextElement : func(symbolName, value) {
  var sym = me._symbols[symbolName];
  assert(sym != nil, "Unknown text element " ~ symbolName ~ " (check your addTextElements call?)");
  if (value == nil ) value = "";
  sym.setValue(value);
},

# Function to undo any colors set by display_toggle when loading a new menu
resetMenuColors : func() {
  for(var i = 0; i < 12; i +=1) {
    var name = sprintf("SoftKey%d",i);
    me.device.svg.getElementById(name ~ "-bg").setColorFill(0.0,0.0,0.0);
    me.device.svg.getElementById(name).setColor(1.0,1.0,1.0);
  }
},

getController : func() {
  return me._controller;
},
setController : func (controller) {
  me._controller = controller;
},

getDevice : func() {
  return me.device;
},
getMFD : func() {
  return me.mfd;
},

};
