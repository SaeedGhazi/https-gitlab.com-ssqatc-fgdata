#
# Configuration variant manager for input devices
# Created: 09/2024
# Author: Henning Stahlke
#
# Example: check Honeycomb Bravo XML
# Todo:
# -Write documentation in wiki
# -handle duplicate devices; currently only one device per (vendor, model) is supported

config_manager = {
    prefix: "/input/",
    vendor: "",
    model: "",
    variants: {},
    mappings: {},
    _mapped_inputs: [],

    # creat new config_manager object
    # config: XML config as props; use cmdarg() in the <nasal><open> block of the device config XML
    new: func(config) {
        var vendor = config.getNode("vendor-id", 1).getValue() or "";
        var model = config.getNode("model-id", 1).getValue() or "";
        if (vendor == "" or model == "") {
            logprint(LOG_ALERT, "input_helpers.config_manager: Error! XML file must contain vendor-id and model-id.");
            gui.popupTip("input_helpers.config_manager: Error!\nXML file must contain vendor-id and model-id.", 30);
            return;
        }
        var m = {
            parents: [me],
            vendor: vendor,
            model: model,
            prefix: me.prefix~vendor~'/'~model~'/',
        };

        # add node objects for the device raw config
        m.deviceN = config;

        # add node objects for predictable path
        m.prefixN = props.getNode(m.prefix, 1);

        # get/create node for the selected config variant (likely in /input/event/device[i])
        m.selectedN = config.getNode("_selected-variant", 1);
        if (!m.selectedN.getValue()) {
            m.selectedN.setValue("");
        }

        # alias the node to a more predictable path /input/<vendor>/<model>/
        # to store it in aircraft.data
        m.selectedAlias = m.prefixN.getNode("_selected-variant", 1);
        var stored = m.selectedAlias.getValue() or '';
        logprint(LOG_INFO, "Last used config variant for "~m.vendor~" "~m.model~": ", stored);
        m.selectedAlias.alias(m.selectedN);
        m.selectedAlias.setValue(stored);
        aircraft.data.add(m.prefix~"_selected-variant");

        # load mappings
        var variants = config.getNode("config-variants");
        if (variants) {
            foreach (var variant; variants.getChildren("variant")) {
                var id = variant.getNode("id").getValue();
                var description = variant.getNode("description").getValue();
                me.variants[id] = description;
                me.mappings[id] = variant.getChildren("mapping");
            }
        }
        # add listener for config selection node
        setlistener(m.selectedN, func(n) {
            m.configure(n.getValue() or "");
        }, 1, 0);

        return m;
    },

    close: func() {
        logprint(LOG_INFO, "input_helpers.config_manager.close "~me.vendor~" "~me.model);
        me._unalias();
        me.selectedAlias.unalias();
    },

    _unalias: func() {
        foreach (var input; me._mapped_inputs) {
            props.getNode(input).unalias();
        }
        me._mapped_inputs = [];
    },

    getMappings: func(variant_id) {
        if (!contains(me.variants, variant_id)) {
            logprint(LOG_WARN, me.vendor~" "~me.model~": unknown config variant '"~variant_id~"'");
            return {}
        }
        return me.mappings[variant_id];
    },

    # load a config variant
    # input props are aliased with the corresponding control props
    configure: func(variant_id) {
        if (!contains(me.variants, variant_id)) {
            logprint(LOG_WARN, me.vendor~" "~me.model~": unknown config variant '"~variant_id~"'");
            return;
        }
        logprint(LOG_INFO,"config_manager "~me.vendor~" "~me.model~" configure("~me.variants[variant_id]~")");
        me._unalias();
        foreach (var mapping; me.prefixN.getNode("mappings", 1).getChildren()) {
            mapping.setValue("");
        };
        foreach (var mapping; me.getMappings(variant_id)) {
            var input = mapping.getNode("input").getValue();
            var output = mapping.getNode("output").getValue();
            props.getNode(input, 1).alias(output);
            append(me._mapped_inputs, input);
            me.prefixN.getNode("mappings/"~mapping.getNode("id").getValue(), 1).setValue(output);
        }
        aircraft.data.save();
    },

    #static methods
    devicesWithVariants: func() {
        var devices = [];
        foreach (var input_system; ["event", "hid"]) {
            foreach (var device; props.getNode("/input/"~input_system, 1).getChildren("device")) {
                if (device.getNode("config-variants")) {
                    append(devices, device);
                }
            }
        }
        foreach (var device; props.getNode("/input/joysticks", 1).getChildren("js")) {
            if (device.getNode("config-variants")) {
                append(devices, device);
            }
        }
        return devices;
    },
};

# inform user about devices that support config variants
var timer = maketimer(5, func {
    var devices = config_manager.devicesWithVariants();
    if (size(devices)) {
        gui.popupTip("There are "~size(devices)~" input devices supporting config variants.");
        gui.showDialog("input-config-select");
    }
});
timer.singleShot=1;
timer.start();
