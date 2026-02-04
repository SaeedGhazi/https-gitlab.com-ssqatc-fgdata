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
        return me.set("text", typeof(text) == "scalar" ? text : "");
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
    setAlignment: func(align) {
        return me.set("alignment", align);
    },

    # Set font family, weight, style and size
	# Any unset arguments will be reused from the currently applied font, or if no font is applied yet, a default font of 
	# LiberationSans Normal Normal 14px will be used.
    setFont: func(family = nil, weight = nil, style = nil, size = nil) {
        var currentFamily = nil;
        var currentWeight = "Normal";
        var currentStyle = "Normal";
        var currentSize = 14;
        var fontStringParts = split(" ", me.get("font", ""));
        foreach (var part; fontStringParts) {
			var scannedSize = [];
            if (string.scanf(part, "%dpx", scannedSize)) {
                currentSize = scannedSize[0];
            } elsif (contains(["Normal", "Italic"], part)) {
                currentStyle = part;
            } elsif (contains(["Thin", "Light", "Normal", "Medium", "Bold"], part)) {
                currentWeight = part;
            } else {
				if (currentFamily == nil) {
					currentFamily = part;
				} else {
					currentFamily = string.join(" ", [currentFamily, part]);
				}
			}
        }
		if (currentFamily == nil) {
			currentFamily = "LiberationSans"
		}

        if (!family) {
            family = currentFamily;
        }
        if (!weight) {
            weight = currentWeight;
        }
        if (!style) {
            style = currentStyle;
        }
        if (!size) {
            size = currentSize;
        }

        return me.set("font", sprintf("%s %s %s %dpx", family, weight, style, size));
    },

    ## Enumeration of values for drawing mode:
    #TEXT:               0x01, # The text itself
    #BOUNDINGBOX:        0x02, # A bounding box (only lines)
    #FILLEDBOUNDINGBOX:  0x04, # A filled bounding box
    #ALIGNMENT:          0x08, # Draw a marker (cross) at the position of the text
    ## Set draw mode. Binary combination of the values above. Since I have not
    ## found a bitwise "or" we have to use a "+" instead.
    ## e.g. my_text.setDrawMode(Text.TEXT + Text.BOUNDINGBOX);
    #setDrawMode: func(mode) {
    #    me.setInt("draw-mode", mode);
    #},

    ## Set bounding box padding
    #setPadding: func(pad) {
    #    me.setDouble("padding", pad);
    #},

    setMaxWidth: func(w) {
        return me.setInt("max-width", w);
    },
    
    setMaxHeight: func(h) {
        return me.setInt("max-height", h);
    }

    setForeground: func {
        return me.set("foreground", _getColor(arg));
    },

    getForeground: func {
        return me.get("foreground");
    },

    setBackground: func {
        return me.set("background", _getColor(arg));
    },

    getBackground: func {
        return me.get("background");
    },

    setLineSpacing: func(spacing) {
        return me.setDouble("line-spacing", spacing);
    },

    getLineSpacing: func {
        return me.get("line-spacing");
    }
};
