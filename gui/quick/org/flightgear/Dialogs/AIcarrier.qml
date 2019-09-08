import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: ai_carrier

    // modal*: false
    ColumnLayout {
        width: parent.width

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("AI Carrier Controls")
                }

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    width: 16
                    height: 16
                    text: qsTr("")
                    // keynum*: 27
                    // border*: 2
                    // binding*: " dialog-close "
                }
            } // RowLayout
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    width: 10
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Turn to launch course")
                            // property*: /ai/models/carrier/controls/turn-to-launch-hdg
                            // live*: true
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/ai/models/carrier/controls/turn-to-launch-hdg"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ c.getNode("controls/turn-to-launch-hdg").setBoolValue(v); c.getNode("controls/turn-to-recovery-hdg").setBoolValue(0); c.getNode("controls/turn-to-base-course").setBoolValue(0); } "
                        }
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Turn to recovery course")
                            // property*: /ai/models/carrier/controls/turn-to-recovery-hdg
                            // live*: true
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/ai/models/carrier/controls/turn-to-recovery-hdg"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ c.getNode("controls/turn-to-recovery-hdg").setBoolValue(v); c.getNode("controls/turn-to-launch-hdg").setBoolValue(0); c.getNode("controls/turn-to-base-course").setBoolValue(0); } "
                        }
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Turn to base course")

                            // property*: /ai/models/carrier/controls/turn-to-base-course
                            // live*: true
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/ai/models/carrier/controls/turn-to-base-course"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ c.getNode("controls/turn-to-base-course").setBoolValue(v); c.getNode("controls/turn-to-recovery-hdg").setBoolValue(0); c.getNode("controls/turn-to-launch-hdg").setBoolValue(0); } "
                        }
                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            text: qsTr("Operate Deck Elevators")
                            // property*: /ai/models/carrier/controls/elevators
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/ai/models/carrier/controls/elevators"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")) c.getNode("controls/elevators").setBoolValue(v); "
                        }

                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            text: qsTr("Enable LSO Communications")
                            // property*: /sim/current-view/lso-commentary
                            // binding*: " dialog-apply "
                        }

                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            text: qsTr("Enable Deck Park")
                            // property*: /sim/current-view/deck-park
                            // binding*: " dialog-apply "
                        }

                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            text: qsTr("Deck Lights")
                            // property*: /ai/models/carrier/controls/lighting/deck-lights
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/ai/models/carrier/controls/lighting/deck-lights"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")) c.getNode("controls/lighting/deck-lights",1).setBoolValue(v); "
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Discrete Flightdeck Floodlights (Red)")
                        }

                        Slider {
                            //horizontalAlignment: Text.AlignLeft
                            width: 75
                            height: 25
                            // property*: /ai/models/carrier/controls/lighting/flood-lights-red-norm
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/ai/models/carrier/controls/lighting/flood-lights-red-norm"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")) { c.getNode("controls/lighting/flood-lights-red-norm",1).setDoubleValue(v); } "
                        }
                    } // ColumnLayout
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                // padding*: 6
                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("OK")
                    // default*: true
                    // equal*: true
                    // binding*: " dialog-apply "
                    // binding*: " dialog-close "
                }

                Button {
                    text: qsTr("Apply")
                    // equal*: true
                    // binding*: " dialog-apply "
                }

                Button {
                    text: qsTr("Reset")
                    // equal*: true
                    // binding*: " dialog-update "
                }

                Button {
                    text: qsTr("Cancel")
                    // equal*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }
    } // ColumnLayout
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
