import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: modelViewDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: modelViewDialog.id
    title: "Model View"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<")
                width: 20
                height: 20
                color: "#07774D"
                // binding*: " nasal view.model_view_handler.next(-1) "
            }

            Button {
                text: qsTr(">")
                width: 20
                height: 20
                color: "#07774D"
                // binding*: " nasal view.model_view_handler.next(1) "
            }

            Label {
                width: 0
                // live*: 1
                // property*: /sim/current-view/model-view
                color: "#FFFFFFFF"
                // font*: sim/gui/selected-style/fonts/model-view
            }

            Button {
                text: qsTr("")
                width: 200
                // border*: 0
                color: "#FFFFFF00"
                // binding*: " nasal if (size(view.model_view_handler.list) <= 1) return; var isopen = !!getprop("sim/gui/dialogs/model-view-select/open"); var toggle = isopen ? "dialog-close" : "dialog-show"; fgcommand(toggle, props.Node.new({ "dialog-name": "model-view-select" })); "
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
                modelViewDialog.closed(modelViewDialog.id);
            }
        }
    } // buttons
}
