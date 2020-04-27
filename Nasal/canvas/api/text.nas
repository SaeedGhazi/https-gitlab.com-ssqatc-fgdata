#-------------------------------------------------------------------------------
# canvas.Text
#-------------------------------------------------------------------------------
# Class for a text element on a canvas
#
var Text = {
    new: func(ghost) {
        return { parents: [Text, Element.new(ghost)] };
    },

    # Set the text
    setText: func(text) {
        me.set("text", typeof(text) == "scalar" ? text : "");
    },

    getText: func() {
        return me.get("text");
    },

    # enable reduced property I/O update function
    enableUpdate: func () {
        me._lasttext = "INIT_BLANK";
        me.updateText = func (text)
        {
            if (text == me._lasttext) {return;}
            me._lasttext = text;
            me.set("text", typeof(text) == "scalar" ? text : "");
        };
    },

    # reduced property I/O text update template
    updateText: func (text) {
        die("updateText() requires enableUpdate() to be called first");
    },


    # enable fast setprop-based text writing
    enableFast: func () {
        me._node_path = me._node.getPath()~"/text";
        me.setTextFast = func(text) {
            setprop(me._node_path, text);
        };
    },

    # fast, setprop-based text writing template
    setTextFast: func (text) {
        die("setTextFast() requires enableFast() to be called first");
    },

    # append text to an existing string
    appendText: func(text) {
        me.set("text", (me.get("text") or "")~(typeof(text) == "scalar" ? text : ""));
    },

    # Set alignment
    #
    #    @param align String, one of:
    #     left-top
    #     left-center
    #     left-bottom
    #     center-top
    #     center-center
    #     center-bottom
    #     right-top
    #     right-center
    #     right-bottom
    #     left-baseline
    #     center-baseline
    #     right-baseline
    #     left-bottom-baseline
    #     center-bottom-baseline
    #     right-bottom-baseline
    #
    setAlignment: func(align) {
        me.set("alignment", align);
    },

    # Set the font size
    setFontSize: func(size, aspect = 1) {
        me.setDouble("character-size", size);
        me.setDouble("character-aspect-ratio", aspect);
    },

    # Set font (by name of font file)
    setFont: func(name) {
        me.set("font", name);
    },

    # Enumeration of values for drawing mode:
    TEXT:               0x01, # The text itself
    BOUNDINGBOX:        0x02, # A bounding box (only lines)
    FILLEDBOUNDINGBOX:  0x04, # A filled bounding box
    ALIGNMENT:          0x08, # Draw a marker (cross) at the position of the text
    # Set draw mode. Binary combination of the values above. Since I have not
    # found a bitwise "or" we have to use a "+" instead.
    # e.g. my_text.setDrawMode(Text.TEXT + Text.BOUNDINGBOX);
    setDrawMode: func(mode) {
        me.setInt("draw-mode", mode);
    },

    # Set bounding box padding
    setPadding: func(pad) {
        me.setDouble("padding", pad);
    },

    setMaxWidth: func(w) {
        me.setDouble("max-width", w);
    },

    setColor: func {
        me.set("fill", _getColor(arg));
    },

    getColor: func {
        me.get("fill");
    },

    setColorFill: func {
        me.set("background", _getColor(arg));
    },

    getColorFill: func {
        me.get("background");
    },
};
