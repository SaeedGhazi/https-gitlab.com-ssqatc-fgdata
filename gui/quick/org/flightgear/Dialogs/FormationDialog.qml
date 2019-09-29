import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: formationDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: formationDialog.id
    title: "AI Wingman Controls"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    width: 10
                }

                Item {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Formate")
                            horizontalAlignment: Text.AlignLeft
                            // property*: /sim/ai/models/wingman/controls/formate-to-ac
                            // live*: true
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/sim/ai/models/wingman/controls/formate-to-ac"); setprop("/sim/ai/models/wingman/controls/break",0); setprop("/sim/ai/models/wingman/controls/join",0); foreach (var c; props.globals.getNode("/ai/models").getChildren("wingman")){ c.getNode("controls/formate-to-ac").setBoolValue(v); c.getNode("controls/break").setBoolValue(0); c.getNode("controls/join").setBoolValue(0); } "
                        }

                        Label {
                            text: qsTr("Break Formation")
                            horizontalAlignment: Text.AlignLeft
                            // property*: /sim/ai/models/wingman/controls/break
                            // live*: true
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/sim/ai/models/wingman/controls/break"); setprop("/sim/ai/models/wingman/controls/formate-to-ac",0); setprop("/sim/ai/models/wingman/controls/join",0); foreach (var c; props.globals.getNode("/ai/models").getChildren("wingman")){ c.getNode("controls/break").setBoolValue(v); c.getNode("controls/formate-to-ac").setBoolValue(0); c.getNode("controls/join").setBoolValue(0); } "
                        }

                        Label {
                            text: qsTr("Join")
                            horizontalAlignment: Text.AlignLeft
                            // property*: /sim/ai/models/wingman/controls/join
                            // live*: true
                            // binding*: " dialog-apply "
                            // binding*: " nasal var v = getprop("/sim/ai/models/wingman/controls/join"); setprop("/sim/ai/models/wingman/controls/formate-to-ac",0); setprop("/sim/ai/models/wingman/controls/break",0); foreach (var c; props.globals.getNode("/ai/models").getChildren("wingman")){ c.getNode("controls/join").setBoolValue(v); c.getNode("controls/break").setBoolValue(0); c.getNode("controls/formate-to-ac").setBoolValue(0); } "
                        }
                    } // ColumnLayout
                }

                Item {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Break Heading Degrees Relative")
                            horizontalAlignment: Text.AlignLeft
                        }

                        Label {
                            text: qsTr("Left/Right")
                        }

                        Item {
                            Layout.fillWidth: true

                            RowLayout {
                                width: parent.width

                                Label {
                                    horizontalAlignment: Text.AlignLeft
                                    text: qsTr("-180")
                                }

                                Slider {
                                    width: 75
                                    height: 25
                                    // property*: /ai/models/wingman/controls/break-deg-rel
                                    // binding*: " dialog-apply "
                                    // binding*: " nasal var v = getprop("/ai/models/wingman/controls/break-deg-rel"); foreach (var c; props.globals.getNode("/ai/models").getChildren("wingman")){ print("FFF ", v, " ", c.getNode("name").getValue()); c.getNode("controls/break-deg-rel",1).setDoubleValue(v); } "
                                }

                                Label {
                                    horizontalAlignment: Text.AlignLeft
                                    text: qsTr("180")
                                }
                            } // RowLayout
                        }

                        Label {
                            text: qsTr("-100.00")
                            // format*: %-0.1f deg
                            // live*: true
                            // property*: /ai/models/wingman/controls/break-deg-rel
                        }
                    } // ColumnLayout
                }
            } // RowLayout
        }

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Target Heading Degrees True")
                    horizontalAlignment: Text.AlignLeft
                }

                Label {
                    text: qsTr("-100.00")
                    horizontalAlignment: Text.AlignLeft
                    // format*: %-0.1f deg
                    // live*: true
                    // property*: /ai/models/wingman/controls/tgt-heading-deg
                }
            } // RowLayout
        }

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Set Formation")
                    horizontalAlignment: Text.AlignLeft
                }

                Button {
                    text: qsTr("Open/Close")
                    x: 40
                    y: 10
                    // binding*: " nasal formation.formation_dialog.toggle() "
                }
            } // RowLayout
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // default*: true
            // equal*: true
            // binding*: " dialog-apply "

            onClicked: {
                formationDialog.closed(formationDialog.id);
            }
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

            onClicked: {
                formationDialog.closed(formationDialog.id);
            }
        }

    } // buttons
}
