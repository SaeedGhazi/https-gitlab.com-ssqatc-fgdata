#-------------------------------------------------------------------------------
# canvas.PangoText
#-------------------------------------------------------------------------------
# Class for a text element on a canvas, with markup support through Pango
#

var PangoText = {
    new: func(ghost) {
        var obj = {
            parents: [PangoText, Element.new(ghost)],
        };
        return obj;
    },

    setMarkup: func(markup) {
        me.set("markup", markup);
    },

    getMarkup: func() {
        return me.get("markup");
    },

    # Set the text
    setText: func(text) {
        me.set("text", typeof(text) == "scalar" ? text : "");
    },

    getText: func() {
        return me.get("text");
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

    setForeground: func {
        me.set("foreground", _getColor(arg));
    },

    getForeground: func {
        me.get("foreground");
    },

    setBackground: func {
        me.set("background", _getColor(arg));
    },

    getBackground: func {
        me.get("background");
    },
};
