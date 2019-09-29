import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: lagAdjustDialog

    width: 400
    height: 350
    position: Qt.point(80, 80)

    windowId: lagAdjustDialog.id
    title: "Lag Correction Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 2

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Master switch:")
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                id: master
                // property*: /sim/multiplay/lag/master
                // binding*: " dialog-apply master "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Lag adjustment:")
            }

            Slider {
                id: lag_adjustment
                // property*: /sim/multiplay/lag/offset
                // binding*: " dialog-apply lag-adjustment "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("MMMMMMMMMMMMMMMMMM")
                // format*: %.3f s
                // property*: /sim/multiplay/lag/offset
                // live*: true
            }

            Label {
                text: qsTr("Apply to close mp")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                id: apply_close
                // property*: /sim/multiplay/lag/apply-close
                // binding*: " dialog-apply apply-close "
            }

            Slider {
                id: range
                // property*: /sim/multiplay/lag/range
                // binding*: " dialog-apply range "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("MMMMMMMMMMMMMMMMMMMMM")
                // format*: %.1f nm
                // property*: /sim/multiplay/lag/range
                // live*: true
            }

            Label {
                text: qsTr("Spectator mode")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                id: spectator
                // property*: /sim/multiplay/lag/spectator
                // binding*: " dialog-apply spectator "
            }

            Slider {
                id: spectator_offset
                // property*: /sim/multiplay/lag/spectator-offset
                // binding*: " dialog-apply spectator-offset "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("MMMMMMMMMMMMMMMMMMMMM")
                // format*: %.2f s
                // property*: /sim/multiplay/lag/spectator-offset
                // live*: true
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end
}
