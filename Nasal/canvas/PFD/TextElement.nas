# PFD UI Element - Text UI Element. Can have values set and retrieved
var TextElement =
{
  new : func (pagename, svg, name, value="", style=nil)
  {
    var obj = {
      parents : [ TextElement, PFD.UIElement ],
      _name : pagename ~ name,
      _edit : 0,
      _style : style,
    };

    if (style == nil) obj._style = PFD.DefaultStyle;

    obj._symbol = svg.getElementById(obj._name);
    if (obj._symbol == nil) die("Unable to find element " ~ obj._name);
    obj.setValue(value);

    # State and timer for flashing highlighting of elements
    # We need a separate Enabled flag as the timers are in a separate thread.
    obj._highlightEnabled = 0;
    obj._highlighted = 0;
    obj._flashTimer = nil;

    return obj;
  },

  getName : func() { return me._name; },
  getValue : func() { return me._symbol.getText(); },
  setValue : func(value) { me._symbol.setText(value); },
  setVisible : func(vis) { me._symbol.setVisible(vis); },
  _flashElement : func() {
    if (me._highlightEnabled == 0) {
      me._symbol.setDrawMode(canvas.Text.TEXT);
      me._symbol.setColor(me._style.NORMAL_TEXT_COLOR);
      me._highlighted = 0;
    } else {
      if (me._highlighted == 0) {
        me._symbol.setDrawMode(canvas.Text.TEXT + canvas.Text.FILLEDBOUNDINGBOX);
        me._symbol.setColorFill(me._style.HIGHLIGHT_COLOR);
        me._symbol.setColor(me._style.HIGHLIGHT_TEXT_COLOR);
        me._highlighted = 1;
      } else {
        me._symbol.setDrawMode(canvas.Text.TEXT);
        me._symbol.setColor(me._style.NORMAL_TEXT_COLOR);
        me._highlighted = 0;
      }
    }
  },
  highlightElement : func() {
    me._highlightEnabled = 1;
    me._highlighted = 0;
    me._flashElement();
    me._flashTimer = maketimer(me._style.CURSOR_BLINK_PERIOD, me, me._flashElement);
    me._flashTimer.start();
  },
  unhighlightElement : func() {
    if (me._flashTimer != nil) me._flashTimer.stop();
    me._flashTimer = nil;
    me._highlightEnabled = 0;
    me._highlighted = 0;
    me._flashElement();
  },
  isEditable : func () { return 0; },
  isInEdit : func() { return 0; },
  isHighlighted : func() { return me._highlightEnabled; },
  enterElement : func() { return me.getValue(); },
  clearElement : func() { },
  editElement : func()  { },
  incrSmall : func(value) { },
  incrLarge : func(value) { },
};
