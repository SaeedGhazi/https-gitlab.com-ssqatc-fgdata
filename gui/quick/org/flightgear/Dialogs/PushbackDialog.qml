import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: pushbackDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: pushbackDialog.id
    title: "Pushback"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var pushback_position = aircraft.door.new("sim/model/pushback", 10.0);
        //         pushback_position.setpos(pushback_position.getpos());
        //         props.globals.getNode("/sim/model/pushback/enabled", 1 ).setBoolValue(1);
        //         props.globals.initNode("/sim/model/pushback/target-speed-fps", 0.0  );
        //     </open>
        //     <close>
        //         pushback_position.setpos(0);
        //         setprop("/sim/model/pushback/enabled", 0 );
        //         setprop("/sim/model/pushback/target-speed-fps", 0 );
        //         setprop("/sim/model/pushback/force", 0);
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        CheckBox {
            //horizontalAlignment: Text.AlignLeft
            text: qsTr("(Dis)Connect pushback")
            // property*: /sim/model/pushback/position-norm
            // binding*: " nasal pushback_position.toggle(); "
        }

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("Speed:")
            }

            Slider {
                Layout.fillWidth: parent
                label: "Target FPS"
                // property*: /sim/model/pushback/target-speed-fps
                // binding*: " dialog-apply "
            }

            Label {
                width: 16
                // property*: /sim/model/pushback/target-speed-fps
                // format*: %2.0f
                // live*: true
            }

            Label {
                text: qsTr("fps")
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
                pushbackDialog.closed(pushbackDialog.id);
            }
        }
    } // buttons
}
