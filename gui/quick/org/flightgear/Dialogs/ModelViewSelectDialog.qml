import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: modelViewSelectDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: modelViewSelectDialog.id
    title: "Model View Select"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
		// <nasal>
		// 	<open>
		// 		var self = cmdarg();
		// 		var dlg = props.globals.getNode("sim/gui/dialogs/model-view-select", 1);
		// 		dlg.getNode("open", 1).setBoolValue(1);
		// 		var maxh = getprop("sim/startup/ysize") - 50;
		// 		var gui = getprop("sim/gui/current-style");
		// 		var baseline = getprop("/sim/gui/style[" ~ gui ~ "]/fonts/gui/baseline-height") or 21;
		// 		var list = cmdarg().getNode("list");

		// 		var data = view.model_view_handler.list;
		// 		var height = size(data) * baseline;
		// 		if (height > maxh)
		// 			height = maxh;
		// 		list.getNode("pref-height").setValue(height);
		// 		list.removeChildren("value");

		// 		var entries = {};
		// 		forindex (var i; data) {
		// 			if (i == 0) {
		// 				var ident = var myself = '[' ~ data[i].callsign ~ ']';
		// 				list.getChild("value", size(data), 1).setValue(ident);
		// 			} else {
		// 				var ident = '"' ~ data[i].callsign ~ '" (' ~ data[i].model ~ ')';
		// 				list.getChild("value", i - 1, 1).setValue(ident);
		// 			}
		// 			entries[ident] = data[i].callsign;
		// 		}

		// 		var select = func {
		// 			var e = dlg.initNode("choice", "").getValue();
		// 			if (e == myself or contains(multiplayer.model.callsign, entries[e]))
		// 				view.model_view_handler.select(which: entries[e], by_callsign: 1);
		// 			else
		// 				settimer(func fgcommand("dialog-show", self), 0);
		// 		}
		// 	</open>

		// 	<close>
		// 		dlg.getNode("open").setValue(0);
		// 	</close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0

            ListView {
                //text: qsTr("")
                height: 100
                width: 250
                // border*: 0
                // property*: /sim/gui/dialogs/model-view-select/choice
                // binding*: " dialog-apply "
                // binding*: " nasal select() "
                // onClicked: {
                //     modelViewSelectDialog.closed(modelViewSelectDialog.id);
                // }
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                modelViewSelectDialog.closed(modelViewSelectDialog.id);
            }
        }
    } // buttons
}
