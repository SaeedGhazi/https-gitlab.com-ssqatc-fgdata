# PFD UI Element - Arrow UI Element. Can have values set and retrieved
# and has a separate arrow icon to indicate selection
var ArrowElement =
{
  new : func (pagename, svg, name, value, style=nil)
  {
    var obj = {
      parents : [ ArrowElement, PFD.UIElement ],
      _name : pagename ~ name,
      _value : value,
      _style : style,
    };

    if (style == nil) obj._style = PFD.DefaultStyle;

    obj._symbol = svg.getElementById(obj._name);
    assert(obj._symbol != nil, "Unable to find element " ~ obj._name);

    obj.unhighlightElement();

    return obj;
  },

  getName : func() { return me._name; },
  getValue : func() { return me._value; },
  setValue : func(value) { me._value = value; },
  setVisible : func(vis) { me._symbol.setVisible(vis); },
  highlightElement : func() {
    me._symbol.setVisible(1);
  },
  unhighlightElement : func() {
    me._symbol.setVisible(0);
  },
  isEditable : func () { return 0; },
  isInEdit : func() { return 0; },
  enterElement : func() { return me.getValue(); },
  clearElement : func() { },
  editElement : func()  { },
  incrSmall : func(value) { },
  incrLarge : func(value) { },
};
