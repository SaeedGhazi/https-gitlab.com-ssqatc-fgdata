# UIGroup.nas.  A group of UI Elements that can be scrolled through
var GroupElement =
{

new : func (pageName, svg, elementNames, size, highlightElement, arrow=0, style=nil)
{
  var obj = {
    parents : [ GroupElement ],
    _pageName : pageName,
    _svg : svg,
    _style : style,

    # A hash mapping keys to the element name prefix of an SVG element
    _elementNames : elementNames,

    # The size of the group.  For each of the ._elementNames hash values there
    # must be an SVG Element [pageName][elementName]{0...pageSize}
    _size : size,

    # Current size of the selectable elements.
    _currentSize : 0,

    # ElementName to be highlighted.  Must be an hash value from ._elementNames
    _highlightElement : highlightElement,

    # Whether this is an arrow'd list.  If so then highlightElement will be
    # hidden/shown for highlighting purposes.
    _arrow : arrow,

    _elements : [],
    _crsrIndex : -1,       # Cursor index into the elements array
  };

  if (style == nil) obj._style = PFD.DefaultStyle;

  for (var i = 0; i < size; i = i + 1) {
    if (obj._arrow == 1) {
      append(obj._elements, PFD.ArrowElement.new(pageName, svg, highlightElement ~ i, i, obj._style));
    } else {
      append(obj._elements, PFD.TextElement.new(pageName, svg, highlightElement ~ i, i, obj._style));
    }
  }

  return obj;
},

# Set the values of the group. values_array is an array of hashes, each of which
# has keys that match those of ._elementNames
setValues : func (values_array) {

  # Determine how many of these we display
  me._currentSize = math.min(me._size, size(values_array));

  for (var i = 0; i < me._currentSize; i = i + 1) {
    var values = values_array[i];
    foreach (var k; keys(values)) {
      if (k == me._highlightElement) {
        me._elements[i].unhighlightElement();
        me._elements[i].setValue(values[k]);
      } else {
        var name = me._pageName ~ k ~ i;
        var element  = me._svg.getElementById(name);
        assert(element != nil, "Unable to find element " ~ name);
        element.setVisible(1);
        element.setText(values[k]);
      }
    }
  }

  # Hide any further elements
  if (me._currentSize < me._size) {
    for (var i = me._currentSize; i < me._size; i = i + 1)  {
      foreach (var k; me._elementNames) {
        if (k == me._highlightElement) {
          me._elements[i].setVisible(0);
        } else {
          me._svg.getElementById(k ~ i).setVisible(0);
        }
      }
    }
  }
},


# Methods to add dynamic elements to the group.  Must be called in the
# scroll order, as they are simply appended to the end of the list of elements!
addArrowElement : func(name, value) {
  append(me._elements, ArrowElement.new(me._pageName, me._svg, name, value));
},
addTextElement : func(name, value) {
  append(me._elements, TextElement.new(me._pageName, me._svg, name, value));
},

showCRSR : func() {
  if (me._currentSize == 0) return;
  me._crsrIndex = 0;
  me._elements[me._crsrIndex].highlightElement();
},
hideCRSR : func() {
  if (me._crsrIndex == -1) return;
  me._elements[me._crsrIndex].unhighlightElement();
  me.setCRSR(-1);
},
setCRSR : func(index) {
  me._crsrIndex = math.min(index, me._currentSize -1);
},
getCursorElementName : func() {
  if (me._crsrIndex == -1) return nil;
  return me._elements[me._crsrIndex].name;
},
isCursorOnDataEntryElement : func() {
  if (me._crsrIndex == -1) return 0;
  return isa(me._elements[me._crsrIndex], DataEntryElement);
},
enterElement : func() {
  if (me._crsrIndex == -1) return;
  return me._elements[me._crsrIndex].enterElement();
},
getValue : func() {
  if (me._crsrIndex == -1) return nil;
  return me._elements[me._crsrIndex].getValue();
},
clearElement : func() {
  if (me._crsrIndex == -1) return;
  me._elements[me._crsrIndex].clearElement();
},
incrSmall : func(value) {
  if (me._crsrIndex == -1) return;
  var incr_or_decr = (value > 0) ? 1 : -1;
  if (me._elements[me._crsrIndex].isInEdit()) {
    # We're editing, so pass to the element.
    #print("Moving cursor to next character entry");
    me._elements[me._crsrIndex].incrSmall();
  } else {
    # Move to next selection element
    me._elements[me._crsrIndex].unhighlightElement();
    me._crsrIndex = math.mod(me._crsrIndex + incr_or_decr, me._currentSize);
    me._elements[me._crsrIndex].highlightElement();
  }
},
incrLarge : func(val) {
  if (me._crsrIndex == -1) return;
  var incr_or_decr = (val > 0) ? 1 : -1;
  if (me._elements[me._crsrIndex].isInEdit()) {
    # We're editing, so pass to the element.
    #print("Moving cursor to next character entry");
    me._elements[me._crsrIndex].incrLarge();
  } else {
    # Move to next selection element
    me._elements[me._crsrIndex].unhighlightElement();
    me._crsrIndex = math.mod(me._crsrIndex + incr_or_decr, me._currentSize);
    me._elements[me._crsrIndex].highlightElement();
  }
},
};
