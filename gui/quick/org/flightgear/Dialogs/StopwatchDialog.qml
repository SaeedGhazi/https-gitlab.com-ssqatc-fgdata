import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: stopwatchDialog

    width: 500
    height: 200
    position: Qt.point(80, 80)

    windowId: stopwatchDialog.id
    title: "Stopwatch"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var p = "/sim/gui/dialogs/stopwatch-dialog/";
        //         var display = props.globals.getNode(p ~ "display", 1);
        //         var time = props.globals.getNode("/sim/time/elapsed-sec");

        //         var start_time = props.globals.getNode(p ~ "start-time", 1).getValue();
        //         var accu = props.globals.getNode(p ~ "accu", 1).getValue();
        //         if (start_time == nil)
        //             start_time = 0;
        //         if (accu == nil)
        //             accu = 0;

        //         var r = props.globals.getNode(p ~ "running");
        //         var running = r != nil ? r.getBoolValue() : 0;

        //         var start = func {
        //             if (!running) {
        //                 start_time = time.getValue();
        //                 running = 1;
        //                 loop();
        //             }
        //         }

        //         var stop = func {
        //             if (running) {
        //                 running = 0;
        //                 show(accu += time.getValue() - start_time);
        //             }
        //         }

        //         var reset = func {
        //             accu = 0;
        //             if (running)
        //                 start_time = time.getValue();
        //             else
        //                 show(0);
        //         }

        //         var loop = func {
        //             if (running) {
        //                 show(time.getValue() - start_time + accu);
        //                 settimer(loop, 0.02);
        //             }
        //         }

        //         var show = func(s) {
        //             var hours = s / 3600;
        //             var minutes = int(math.mod(s / 60, 60));
        //             var seconds = int(math.mod(s, 60));
        //             var msec = int(math.mod(s * 1000, 1000) / 100);
        //             var d = sprintf("%3d : %02d : %02d.%d", hours, minutes, seconds, msec);
        //             display.setValue(d);
        //         }

        //         if (running) {
        //             loop();
        //         } else {
        //             if (accu == nil)
        //                 accu = 0;
        //             show(accu);
        //         }
        //     </open>

        //     <close>
        //         props.globals.getNode(p ~ "start-time", 1).setDoubleValue(start_time);
        //         props.globals.getNode(p ~ "running", 1).setBoolValue(running);
        //         props.globals.getNode(p ~ "accu", 1).setDoubleValue(accu);
        //         running = 0;	# stop display loop
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr("xxxxx000 : 00 : 00.0")
            // live*: true
            // property*: /sim/gui/dialogs/stopwatch-dialog/display
            // font*: sim/gui/selected-style/fonts/gui-large
            color: "#FFE600FF"
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Start")
            // equal*: true
            //color: "#CC"
            // binding*: " nasal start() "
        }

        Button {
            text: qsTr("Stop")
            // default*: true
            //color: "#CC"
            // binding*: " nasal stop() "
        }

        Button {
            text: qsTr("Reset")
            // key*: qsTr("Delete")
            //color: "#CC"
            // binding*: " nasal reset() "
        }

        Button {
            text: qsTr("Close")
            //color: "#CC"
            // key*: qsTr("Esc")

            onClicked: {
                stopwatchDialog.closed(stopwatchDialog.id);
            }
        }
    } // buttons
}
