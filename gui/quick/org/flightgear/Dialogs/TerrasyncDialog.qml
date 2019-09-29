import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: terrasyncDialog

    width: 500
    height: 400
    position: Qt.point(80, 80)

    windowId: terrasyncDialog.id
    title: "TerraSync"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var computeStatusText = func {
        //             # first, check if the system is actually enabled
        //             if (!getprop('/sim/terrasync/enabled'))
        //                 return "Downloading disabled";

        //             # only happens if terrasync failed to activate, so
        //             # indicates a problem
        //             if (!getprop('/sim/terrasync/active'))
        //                 return "Automatic download inactive";

        //             var errCount = getprop('/sim/terrasync/error-count');
        //             if (errCount > 0)
        //                 return "Errors occurred during download";

        //             # we need to suggest some remedial action here!
        //             if (getprop('/sim/terrasync/stalled'))
        //                 return "Downloading has stalled. Check your network connection and settings";

        //             if (getprop('/sim/terrasync/busy')) {
        //                 var kbytesSec = getprop('/sim/terrasync/transfer-rate-bytes-sec') / 1024;
        //                 return sprintf('Downloading: %dKB/sec', int(kbytesSec));
        //             }

        //             # we are enabled but not busy, so idle
        //             return "Ready";
        //         }

        //         # timer function, update summary status string
        //         var updateStatusText = func {
        //             var s = computeStatusText();
        //             setprop("/sim/gui/dialogs/terrasync/status", s);

        //             var msg = "";
        //             if (getprop("/sim/terrasync/available")) {
        //                 if (getprop("/sim/terrasync/enabled"))
        //                     msg = "Automatic download active; monitor your bandwidth on metered connection.";
        //             } else {
        //                 if (getprop("/sim/terrasync/intialized"))
        //                     msg = "Automatic download not active.";
        //                 else
        //                     msg = "Automatic download not supported.";
        //             }
        //             setprop("/sim/terrasync/ui-message-node", msg);
        //         }

        //         # the TerraSync properties of interest are tied, so we can't use a
        //         # listener. Let's poll while the dialog is open; not ideal but not
        //         # a major problem.
        //         var statusTimer = maketimer(0.4, updateStatusText);     
        //         statusTimer.start();     
        //         updateStatusText();

        //         setprop("/sim/gui/dialogs/terrasync/display-mode", "0");
        //     ]]></open>

        //     <close>
        //         statusTimer.stop();
        //         statusTimer = nil;
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            id: message
            color: "#FF6666"
            horizontalAlignment: Text.AlignLeft
            // property*: /sim/terrasync/ui-message-node
            // live*: true
        }

        GridLayout {
            width: parent.width
            columns: 2
            //horizontalAlignment: Text.AlignLeft

            CheckBox {
                id: terrasync_enabled
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/terrasync/enabled
                text: qsTr("Enable automatic scenery download")
                // live*: true
                // binding*: " dialog-apply terrasync-enabled "
            }

            Label {
                text: qsTr(" ")
            }

            CheckBox {
                id: ai_data_enabled
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/terrasync/ai-data-enabled
                text: qsTr("Update AI Traffic during FG start")
                // live*: true
                // binding*: " dialog-apply ai-data-enabled "
            }

            Button {
                text: qsTr("Update Now")
                // border*: 2
                // equal*: true
                // binding*: " property-assign /sim/terrasync/ai-data-enabled 1 "
                // binding*: " property-assign /sim/terrasync/ai-data-update-now 1 "
            }

            Label {
                id: warning_text
                color: "#FF6666FF"
                text: qsTr("")
            }

            Label {
                text: qsTr(" ")
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft
            // padding*: 4

            Button {
                text: qsTr("Information")
                // binding*: " property-assign /sim/gui/dialogs/terrasync/display-mode 0 "
            }

            Label {
                text: qsTr("")
            }

            Button {
                text: qsTr(" Log ")
                // binding*: " property-assign /sim/gui/dialogs/terrasync/display-mode 1 "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("")
            }

            GridLayout {
                width: parent.width
                columns: 2
                //horizontalAlignment: Text.AlignLeft
                // equal*: false
                // visible*: /sim/gui/dialogs/terrasync/display-mode 0

                Label {
                    text: qsTr("Status: ")
                    horizontalAlignment: Text.AlignLeft
                    width: 200
                    color: "#878a8d"
                    // format*: Status: %s
                    // property*: /sim/gui/dialogs/terrasync/status
                    // live*: true
                }

                Label {
                    text: qsTr("")
                }

                Label {
                    text: qsTr("KBytes downloaded:")
                    horizontalAlignment: Text.AlignLeft
                    color: "#878a8d"
                }

                Label {
                    // format*: %d
                    // property*: /sim/terrasync/downloaded-kbytes
                    // live*: true
                    text: qsTr("0")
                    Layout.fillWidth: true
                    color: "#878a8d"
                }

                Label {
                    text: qsTr("Processed elements:")
                    horizontalAlignment: Text.AlignLeft
                    color: "#878a8d"
                }

                Label {
                    // format*: %s
                    // property*: /sim/terrasync/update-count
                    // live*: true
                    text: qsTr("0")
                    Layout.fillWidth: true
                    color: "#878a8d"
                }

                Label {
                    text: qsTr("Processed scenery tiles:")
                    horizontalAlignment: Text.AlignLeft
                    color: "#878a8d"
                }

                Label {
                    // format*: %s
                    // property*: /sim/terrasync/tile-count
                    // live*: true
                    text: qsTr("0")
                    Layout.fillWidth: true
                    color: "#878a8d"
                }
            } // GridLayout
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
                terrasyncDialog.closed(terrasyncDialog.id);
            }
        }
    } // buttons
}
