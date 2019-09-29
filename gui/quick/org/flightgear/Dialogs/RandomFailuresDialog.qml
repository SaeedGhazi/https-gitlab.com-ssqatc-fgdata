import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: randomFailuresDialog

    width: 400
    height: 800
    position: Qt.point(80, 80)

    windowId: randomFailuresDialog.id
    title: "Random Failures"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var groups = cmdarg().getChildren("group")[1].getChildren("group");
        //         var mtbfNodes = groups[0].getChildren("radio");
        //         var mcbfNodes = groups[1].getChildren("radio");

        //         var set_mtbf = func(m) {
        //             for (var i = 0; i < size(mtbfNodes); i +=1) {
        //                 var prop = mtbfNodes[i].getChild("property").getValue();
        //                 setprop(prop, (m == mtbfNodes[i].getChild("value").getValue()));
        //             }

        //             setprop("/sim/failure-manager/global-mtbf", m);
        //         };

        //         var set_mcbf = func(m) {
        //             for (var i = 0; i < size(mcbfNodes); i +=1) {
        //                 var prop = mcbfNodes[i].getChild("property").getValue();
        //                 setprop(prop, (m == mcbfNodes[i].getChild("value").getValue()));
        //             }

        //             setprop("/sim/failure-manager/global-mcbf", m);
        //         };

        //         props.globals.initNode("/sim/failure-manager/global-mtbf", 0);
        //         props.globals.initNode("/sim/failure-manager/global-mcbf", 0);

        //         set_mtbf(getprop("/sim/failure-manager/global-mtbf"));
        //         set_mcbf(getprop("/sim/failure-manager/global-mcbf"));
        //     ]]></open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            horizontalAlignment: Text.AlignLeft
            text: qsTr(" Configure MTBF/MCBF for all systems and instruments. ")
        }

        HorizontalLine {}


        ColumnLayout {
                width: parent.width
            // padding*: 1

            Label {
                text: qsTr(" ")
            }
        } // ColumnLayout


        ColumnLayout {
            width: parent.width

            Label {
                text: qsTr("Mean Time Between Failures")
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-60
                // live*: true
                text: qsTr("1 minute")
                // binding*: " nasal set_mtbf(60); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-300
                // live*: true
                text: qsTr("5 minutes")
                // binding*: " nasal set_mtbf(300); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-600
                // live*: true
                text: qsTr("10 minutes")
                // binding*: " nasal set_mtbf(600); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-1800
                // live*: true
                text: qsTr("30 minutes")
                // binding*: " nasal set_mtbf(1800); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-3600
                // live*: true
                text: qsTr("1 hour")
                // binding*: " nasal set_mtbf(3600); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-21600
                // live*: true
                text: qsTr("6 hours")
                // binding*: " nasal set_mtbf(21600); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-86400
                // live*: true
                text: qsTr("24 hours")
                // binding*: " nasal set_mtbf(86400); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mtbf-0
                text: qsTr("0 (Disabled)")
                // live*: true
                // binding*: " nasal set_mtbf(0); "
            }
        } // ColumnLayout

        Label {
            Layout.fillWidth: true
        }

        HorizontalLine {}

        Label {
            Layout.fillWidth: true
        }

        ColumnLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true

            Label {
                text: qsTr("Mean Cycles Between Failures ")
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-5
                text: qsTr("5")
                // live*: true
                // binding*: " nasal set_mcbf(5); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-10
                text: qsTr("10")
                // live*: true
                // binding*: " nasal set_mcbf(10); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-20
                text: qsTr("20")
                // live*: true
                // binding*: " nasal set_mcbf(20); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-50
                text: qsTr("50")
                // live*: true
                // binding*: " nasal set_mcbf(50); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-100
                text: qsTr("100")
                // live*: true
                // binding*: " nasal set_mcbf(100); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-200
                text: qsTr("200")
                // live*: true
                // binding*: " nasal set_mcbf(200); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-500
                text: qsTr("500")
                // live*: true
                // binding*: " nasal set_mcbf(500); "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/failure-manager/global-mcbf-0
                text: qsTr("0 (Disabled)")
                // live*: true
                // binding*: " nasal set_mcbf(0); "
            }
        } // ColumnLayout

        HorizontalLine {}

        CheckBox {
            id: onScreenMessages
            text: qsTr("Display failure messages on screen")
            width: 10
            height: 10
            // property*: /sim/failure-manager/display-on-screen
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "
            // binding*: " nasal compat_failure_modes.apply_global_mtbf(getprop("/sim/failure-manager/global-mtbf")); compat_failure_modes.apply_global_mcbf(getprop("/sim/failure-manager/global-mcbf")); "
            onClicked: {
                randomFailuresDialog.closed(randomFailuresDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // binding*: " dialog-apply "
            // binding*: " nasal compat_failure_modes.apply_global_mtbf(getprop("/sim/failure-manager/global-mtbf")); compat_failure_modes.apply_global_mcbf(getprop("/sim/failure-manager/global-mcbf")); "
        }

        Button {
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                randomFailuresDialog.closed(randomFailuresDialog.id);
            }
        }
    } // buttons
}
