import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: nasalConsoleDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: nasalConsoleDialog.id
    title: "Nasal Console"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
		// <nasal>
		// 	<open>
		// 		var self = cmdarg();
		// 		var dlg = props.globals.getNode("/sim/gui/dialogs/nasal-console", 1);
		// 		var kbdctrl = props.globals.getNode("/devices/status/keyboard/ctrl", 1);
		// 		var edit = dlg.getNode("edit", 1);
		// 		if (!contains(globals, "__nasal_console"))
		// 			globals["__nasal_console"] = {};

		// 		var locals = globals["__nasal_console"];
		// 		var numtabs = size(dlg.getChildren("code"));
		// 		if (!numtabs)
		// 			numtabs = 10;

		// 		var dump = func {
		// 			gui.dialog_apply("nasal-console", "editfield");
		// 			select(active);
		// 			rule = "--------------------------------------------------------------------------------";
		// 			print(rule ~ "\n");
		// 			print(edit.getValue());
		// 			print(rule);
		// 		}

		// 		var clear = func {
		// 			edit.setValue("");
		// 			select(active);
		// 		}

		// 		var copy = func {
		// 			gui.dialog_apply("nasal-console", "editfield");
		// 			select(active);
		// 			clipboard.setText( edit.getValue() );
		// 		}

		// 		var paste = func {
		// 			edit.setValue( clipboard.getText() );
		// 			select(active);
		// 		}

		// 		var execute = func(what = nil) {
		// 			var num = what != nil ? what.getIndex() : active;
		// 			var tag = "&lt;nasal-console/#" ~ num ~ ">";
		// 			var err = [];
		// 			if (what == nil)
		// 				what = edit;

		// 			var f = call(func { compile(what.getValue(), tag) }, nil, nil, nil, err);
		// 			if (size(err)) {
		// 				print(tag ~ ": " ~ err[0]);
		// 				return;
		// 			}
		// 			f = bind(f, globals);
		// 			call(f, nil, nil, locals, err);
		// 			debug.printerror(err);
		// 		}

		// 		var tabs = self.getNode("group[1]");
		// 		var select = func(which, init = 0) {
		// 			if (active) { # false in help mode
		// 				dlg.getNode("active").setIntValue(active);
		// 				if (!init)
		// 					dlg.getChild("code", active).setValue(string.trim(edit.getValue()));
		// 			}
		// 			if (kbdctrl.getValue()) {
		// 				execute(dlg.getChild("code", which));
		// 				return;
		// 			}
		// 			active = which;
		// 			foreach (var c; dlg.getChildren("tab-down"))
		// 				c.setBoolValue(c.getIndex() == active);

		// 			dlg.getNode("active").setIntValue(active = which);
		// 			edit.setValue(dlg.getChild("code", active).getValue());
		// 		}
		// 		var get_button_desc = func (b) {
		// 			var sep = " ... ";
		// 			var key=b.getChild("key");
		// 			var desc=b.getChild("key-desc");
		// 			if( !isa(key, props.Node) or !isa(desc, props.Node) )
		// 			return "";
		// 			return    "  "~key.getValue() ~sep~desc.getValue() ~"\n";
		// 		}

		// 		var key_bindings = (func {
		// 			var desc = "";
		// 			var buttons = self.getNode("group[2]").getChildren("button");
		// 			foreach(var b; buttons) desc ~= get_button_desc(b);
		// 			return desc;
		// 		})();

		// 		var help = func {
		// 			active = 0;
		// 			foreach (var c; dlg.getChildren("tab-down"))
		// 				c.setBoolValue(0);

		// 			edit.setValue("Keys:\n"
		// 				~ "  tab    ... leave edit mode (visible text cursor)\n"
		// 				~ "  return ... execute active code\n"
		// 			~ key_bindings
		// 				~ "  esc    ... close dialog\n\n"
		// 				~ "Ctrl-click on tab buttons executes code without\n"
		// 				~ "switching to the tab. Add more &lt;code> properties\n"
		// 				~ "in ~/.fgfs/autosave.xml for more tab buttons.");
		// 		}

		// 		# setup tab buttons and properties from the template
		// 		tabs.removeChildren("button");
		// 		var template = tabs.getNode("button-template");
		// 		var d = dlg.getPath();
		// 		for (var i = 1; i &lt;= numtabs; i += 1) {
		// 			var button = tabs.getChild("button", i, 1);
		// 			var state = dlg.getChild("tab-down", i, 1);
		// 			state.setBoolValue(0);

		// 			props.copy(template, button);
		// 			button.getNode("enabled").setBoolValue(1);
		// 			button.getNode("legend").setIntValue(i);
		// 			button.getNode("binding[1]/script").setValue("select(" ~ i ~ ")");
		// 			button.getNode("property").setValue(state.getPath());
		// 			var c = dlg.getChild("code", i);
		// 			if (c == nil or c.getType() == "NONE") {
		// 				c = dlg.getChild("code", i, 1);
		// 				c.setValue("");
		// 				c.setAttribute("userarchive", 1);
		// 			}
		// 		}

		// 		edit.setValue("");
		// 		var active = dlg.getNode("active", 1).getValue();
		// 		if (active == nil)
		// 			active = 1;

		// 		select(active, 1);
		// 	</open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            id: editfield

            Layout.fillWidth: true
            width: 450
            height: 200
            padding: 6

            Slider {
                //20
            }

            // font*: sim/gui/selected-style/fonts/nasal-editor
            // property*: /sim/gui/dialogs/nasal-console/edit
            // binding*: " dialog-apply editfield "
            // binding*: " nasal select(active) "
        }

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width
                // padding*: 4
            } // RowLayout
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Copy to Clipboard")
            // key*: qsTr("Ctrl-c")
            // binding*: " nasal active and copy() "
            // binding*: " dialog-update editfield "
        }

        Button {
            text: qsTr("Paste from Clipboard")
            // key*: qsTr("Ctrl-v")
            // binding*: " nasal active and paste() "
            // binding*: " dialog-update editfield "
        }

        Button {
            text: qsTr("Clear")
            // key*: qsTr("Ctrl-x")
            // binding*: " nasal active and clear() "
            // binding*: " dialog-update editfield "
        }

        Button {
            text: qsTr("Dump")
            // key*: qsTr("Ctrl-d")
            // binding*: " dialog-apply editfield "
            // binding*: " nasal active and dump() "
        }

        Button {
            text: qsTr("Execute")
            // binding*: " dialog-apply editfield "
            // binding*: " nasal active and execute() "
        }
    } // buttons
}
