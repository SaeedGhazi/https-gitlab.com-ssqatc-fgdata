import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: lsoViewDialog

    width: 350
    height: 200
    position: Qt.point(80, 80)

    windowId: lsoViewDialog.id
    title: "LSO View"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0
            //color: "#00000000"

            Button {
                text: qsTr("<")
                width: 20
                height: 20
                //color: "#7774D"
                // binding*: " nasal lsoview.lso_view_handler.next(-1) "
            }

            Button {
                text: qsTr(">")
                width: 20
                height: 20
                //color: "#7774D"
                // binding*: " nasal lsoview.lso_view_handler.next(1) "
            }

            Label {
                width: 0
                // live*: 1
                // property*: /sim/current-view/landing-signal-officer-view
                color: "#FFFFFFFF"
                // font*: sim/gui/selected-style/fonts/gui-large
            }

            Button {
                text: qsTr("")
                width: 200
                // border*: 0
                color: "#FFFFFF00"
                // binding*: " nasal if (size(lsoview.lso_view_handler.list) <= 1) return; var isopen = !!getprop("sim/gui/dialogs/model-view-select/open"); var toggle = isopen ? "dialog-close" : "dialog-show"; fgcommand(toggle, props.Node.new({ "dialog-name": "lso-view-select" })); "
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end
}




