import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: modelCockpitViewDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: modelCockpitViewDialog.id
    title: "Cockpit View"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        Button {
            text: qsTr("<")
            width: 20
            height: 20
            color: "#07774D"
            // binding*: " nasal model_cockpit_view.model_cockpit_view_handler.next(-1) "
        }

        Button {
            text: qsTr(">")
            width: 20
            height: 20
            color: "#07774D"
            // binding*: " nasal model_cockpit_view.model_cockpit_view_handler.next(1) "
        }

        Label {
            width: 0
            // live*: 1
            // property*: /sim/current-view/model-cockpit-view
            color: "#FFFFFFFF"
            // font*: sim/gui/selected-style/fonts/gui-large
        }

        Button {
            text: qsTr("")
            width: 200
            // border*: 0
            color: "#FFFFFF00"
            // binding*: " nasal if (size(lsoview.model_cockpit_view_handler.list) <= 1) return; var isopen = !!getprop("sim/gui/dialogs/model-cockpit-view/open"); var toggle = isopen ? "dialog-close" : "dialog-show"; fgcommand(toggle, props.Node.new({ "dialog-name": "model-cockpit-view" })); "
        }
    } // ColumnLayout

    // ======= content end
}
