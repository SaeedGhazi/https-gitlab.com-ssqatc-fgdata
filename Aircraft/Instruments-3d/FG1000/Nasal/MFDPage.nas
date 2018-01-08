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
  };

  obj.device = device;
  obj.mfd = mfd;

  # Pick up Style, Options and Controller
  var code = "obj.Styles  = fg1000." ~ pageName ~ "Styles.new(); " ~
             "obj.Options = fg1000." ~ pageName ~ "Options.new();";
  var createStylesAndOptions = compile(code);
  createStylesAndOptions();

  # Need to display this underneath the softkeys, EIS, header.
  obj._group.set("z-index", -10.0);
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

};
