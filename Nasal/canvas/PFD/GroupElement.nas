# UIGroup.nas.  A group of UI Elements that can be scrolled through
var GroupElement =
{

new : func (pageName, svg, elementNames, size, highlightElement, arrow=0, scrollTroughElement=nil, scrollThumbElement=nil, scrollHeight=0, style=nil)
{
  var obj = {
    parents : [ GroupElement ],
    _pageName : pageName,
    _svg : svg,
    _style : style,
    _scrollTroughElement : nil,
    _scrollThumbElement : nil,
    _scrollBaseTransform : nil,

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

    # Length of the scroll bar.
    _scrollHeight : scrollHeight,

    # List of values to display
    _values : [],

    # List of SVG elements to display the values
    _elements : [],

    # Cursor index into the elements array
    _crsrIndex : 0,

    # Whether the CRSR is enabled
    _crsrEnabled : 0,

    # Page index
    _pageIndex : 0,
  };

  # Optional scroll bar elements, consisting of the Thumb and the Trough *,
  # which will be used to display the scroll position.
  # * Yes, these are the terms of art for the elements.
  assert(((scrollTroughElement == nil) and (scrollThumbElement == nil)) or
         ((scrollTroughElement != nil) and (scrollThumbElement != nil)),
         "Both the scroll trough element and the scroll thumb element must be defined, or neither");

  if (scrollTroughElement != nil) {
    obj._scrollTroughElement = svg.getElementById(pageName ~ scrollTroughElement);
    assert(obj._scrollTroughElement != nil, "Unable to find scroll element " ~ pageName ~ scrollTroughElement);
  }
  if (scrollThumbElement != nil) {
    obj._scrollThumbElement = svg.getElementById(pageName ~ scrollThumbElement);
    assert(obj._scrollThumbElement != nil, "Unable to find scroll element " ~ pageName ~ scrollThumbElement);
    obj._scrollBaseTransform = obj._scrollThumbElement.getTranslation();
  }

  if (style == nil) obj._style = PFD.DefaultStyle;

  for (var i = 0; i < size; i = i + 1) {
    if (obj._arrow == 1) {
      append(obj._elements, PFD.HighlightElement.new(pageName, svg, highlightElement ~ i, i, obj._style));
    } else {
      append(obj._elements, PFD.TextElement.new(pageName, svg, highlightElement ~ i, i, obj._style));
    }
  }

  return obj;
},

# Set the values of the group. values_array is an array of hashes, each of which
# has keys that match those of ._elementNames
setValues : func (values_array) {
  me._values = values_array;
  me._pageIndex = 0;
  me._crsrIndex = 0;

  if (size(me._values) > me._size) {
    # Number of elements exceeds our ability to display them, so enable
    # the scroll bar.
    me._scrollThumbElement.setVisible(1);
    me._scrollTroughElement.setVisible(1);
  } else {
    # There is no scrolling to do, so hide the scrollbar.
    me._scrollThumbElement.setVisible(0);
    me._scrollTroughElement.setVisible(0);
  }

  me.displayPage();
},

nextPage : func() {
  if (size(me._values) > ((me._pageIndex +1) * me._size)) {
    me._pageIndex = me._pageIndex + 1;
    me._crsrIndex = 0;
    me.displayPage();
  } else {
    me._crsrIndex = me._currentSize -1;
  }
},

previousPage : func() {
  if (me._pageIndex > 0) {
    me._pageIndex = me._pageIndex - 1;
    me._crsrIndex = me._size -1;
    me.displayPage();
  } else {
    me._crsrIndex = 0;
  }
},

displayPage : func () {
  # Determine how many elements to display in this page
  me._currentSize = math.min(me._size, size(me._values) - me._size * me._pageIndex);

  for (var i = 0; i < me._currentSize; i = i + 1) {
    var value = me._values[i + me._size * me._pageIndex];
    foreach (var k; keys(value)) {
      if (k == me._highlightElement) {
        me._elements[i].unhighlightElement();

        if (me._arrow) {
          # If we're using a HighlightElement, then we only show the element
          # the cursor is on.
          if (i == me._crsrIndex) {
            me._elements[i].setVisible(1);
          } else {
            me._elements[i].setVisible(0);
          }
        } else {
          me._elements[i].setVisible(1);
        }
        me._elements[i].setValue(value[k]);
      } else {
        var name = me._pageName ~ k ~ i;
        var element  = me._svg.getElementById(name);
        assert(element != nil, "Unable to find element " ~ name);
        element.setVisible(1);
        element.setText(value[k]);
      }
    }
  }

  # Hide any further elements
  if (me._currentSize < me._size) {
    for (var i = me._currentSize; i < me._size; i = i + 1)  {
      foreach (var k; me._elementNames) {
        if (k == me._highlightElement) {
          me._elements[i].setVisible(0);
          me._elements[i].setValue("");
        } else {
          var name = me._pageName ~ k ~ i;
          var element  = me._svg.getElementById(name);
          assert(element != nil, "Unable to find element " ~ name);
          element.setVisible(0);
          element.setText("");
        }
      }
    }
  }

  if ((me._scrollThumbElement != nil) and (me._size < size(me._values))) {
    # Shift the scrollbar if it's relevant
    var numScrollPositions = math.ceil(size(me._values) / me._size) -1;
    me._scrollThumbElement.setTranslation([
      me._scrollBaseTransform[0],
      me._scrollBaseTransform[1] + me._scrollHeight * (me._pageIndex / numScrollPositions)
    ]);
  }
},

# Methods to add dynamic elements to the group.  Must be called in the
# scroll order, as they are simply appended to the end of the list of elements!
addHighlightElement : func(name, value) {
  append(me._elements, HighlightElement.new(me._pageName, me._svg, name, value));
},
addTextElement : func(name, value) {
  append(me._elements, TextElement.new(me._pageName, me._svg, name, value));
},

showCRSR : func() {
  if (me._currentSize == 0) return;
  me._crsrEnabled = 1;
  me._elements[me._crsrIndex].highlightElement();
},
hideCRSR : func() {
  if (me._crsrEnabled == 0) return;
  me._elements[me._crsrIndex].unhighlightElement();

  # If we're using a HighlightElement, then we need to make the cursor position visible
  if (me._arrow) me._elements[me._crsrIndex].setVisible(1);
  me._crsrEnabled = 0;
},
setCRSR : func(index) {
  me._crsrIndex = math.min(index, me._currentSize -1);
},
getCursorElementName : func() {
  if (me._crsrEnabled == -1) return nil;
  return me._elements[me._crsrIndex].name;
},
isCursorOnDataEntryElement : func() {
  if (me._crsrEnabled == -1) return 0;
  return isa(me._elements[me._crsrIndex], DataEntryElement);
},
enterElement : func() {
  if (me._crsrEnabled == 0) return;
  return me._elements[me._crsrIndex].enterElement();
},
getValue : func() {
  if (me._crsrEnabled == -1) return nil;
  return me._elements[me._crsrIndex].getValue();
},
clearElement : func() {
  if (me._crsrEnabled == 0) return;
  me._elements[me._crsrIndex].clearElement();
},
incrSmall : func(value) {
  if (me._crsrEnabled == 0) return;

  var incr_or_decr = (value > 0) ? 1 : -1;
  if (me._elements[me._crsrIndex].isInEdit()) {
    # We're editing, so pass to the element.
    #print("Moving cursor to next character entry");
    me._elements[me._crsrIndex].incrSmall();
  } else {
    # Move to next selection element
    me._elements[me._crsrIndex].unhighlightElement();

    me._crsrIndex = me._crsrIndex + incr_or_decr;

    if (me._crsrIndex <  0              ) me.previousPage();
    if (me._crsrIndex == me._currentSize) me.nextPage();

    me._elements[me._crsrIndex].highlightElement();
  }
},
incrLarge : func(val) {
  if (me._crsrEnabled == 0) return;
  var incr_or_decr = (val > 0) ? 1 : -1;
  if (me._elements[me._crsrIndex].isInEdit()) {
    # We're editing, so pass to the element.
    #print("Moving cursor to next character entry");
    me._elements[me._crsrIndex].incrLarge();
  } else {
    # Move to next selection element
    me._elements[me._crsrIndex].unhighlightElement();
    me._crsrIndex = me._crsrIndex + incr_or_decr;

    if (me._crsrIndex <  0              ) me.previousPage();
    if (me._crsrIndex == me._currentSize) me.nextPage();

    me._elements[me._crsrIndex].highlightElement();
  }
},
};
