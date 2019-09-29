import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: jetwaysDialog

    width: 400
    height: 350
    position: Qt.point(80, 80)

    windowId: jetwaysDialog.id
    title: "Jetway Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var self = cmdarg();
        //         var aptlist = props.globals.getNode(self.getNode("text/property").getValue(), 1);
        //         var loadedN = props.globals.getNode("/nasal/jetways/loaded", 1);
        //         var UPDATE_PERIOD = 5;
        //         var update = func
        //         {
        //             if (loadedN.getBoolValue())
        //             {
        //                 var list = "";
        //                 foreach (var apt; jetways.loaded_airports)
        //                 {
        //                     list ~= apt ~ " ";
        //                 }
        //                 aptlist.setValue(list == "" ? " No airports loaded" : " Loaded airports: " ~ list);
        //             }
        //             settimer(update, UPDATE_PERIOD);
        //         };
        //         settimer(update, 0);
        //     ]]></open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width
                // padding*: 1

                Label {
                    text: qsTr(" ")
                }
            } // ColumnLayout

            ColumnLayout {
                width: parent.width

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Enable animated jetways")
                    // property*: /nasal/jetways/enabled
                    // live*: true
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Connect to multiplayer aircraft")
                    // property*: /sim/jetways/interact-with-multiplay
                    // live*: true
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Enable jetway editor")
                    // property*: /nasal/jetways_edit/enabled
                    // live*: true
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Debug mode")
                    // property*: /sim/jetways/debug
                    // live*: true
                    // binding*: " dialog-apply "
                }

                RowLayout {
                    width: parent.width

                    Button {
                        text: qsTr("Open editor")
                        // binding*: " dialog-show jetways-adjust "
                    }
                } // RowLayout
            } // ColumnLayout
        } // RowLayout

        HorizontalLine {}

        Label {
            text: qsTr(" No airports loaded")
            horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/jetways/loaded-airports
            // live*: true
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                jetwaysDialog.closed(jetwaysDialog.id);
            }
        }
    } // buttons
}
