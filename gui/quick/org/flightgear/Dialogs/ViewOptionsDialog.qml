import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: viewOptionsDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: viewOptionsDialog.id
    title: "View Options"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var group = gui.findElementByName(cmdarg(), "active-views");    
        //         var ac = getprop("/sim/aircraft");
        //         group.removeChildren("checkbox");
        //         group.removeChildren("hrule");
        //         group.removeChildren("text");

        //         var t = group.getChild("text", 0, 1);
        //         t.getNode("label", 1).setValue("Standard Views");
        //         t.getNode("halign", 1).setValue("left");

        //         var mode = 0;
        //         foreach (var v; view.views) {
        //             var index = v.getIndex();
        //             var enabled = v.initNode("enabled", 1, "BOOL");
        //             var name = v.getNode("name");
        //             if (name != nil) {
        //                 if (index >= 200) {
        //                     if (mode != 2) {
        //                         mode = 2;
        //                         group.getChild("empty", 1, 1).getChild("stretch", 0, 1).setValue(1);
        //                         var t = group.getChild("text", 1, 1);
        //                         t.getNode("label", 1).setValue("Other Views");
        //                     }
        //                 } elsif (index >= 100) {
        //                     aircraft.data.add(enabled);
        //                     if (mode != 1) {
        //                         mode = 1;
        //                         group.getChild("empty", 0, 1).getChild("stretch", 0, 1).setValue(1);
        //                         var t = group.getChild("text", 1, 1);
        //                         t.getNode("label", 1).setValue("\"" ~ ac ~ "\" Specific Views");
        //                         t.getNode("halign", 1).setValue("left");
        //                     }
        //                 }

        //                 var target = group.getChild("checkbox", index, 1);
        //                 props.copy(group.getNode("checkbox-template"), target);
        //                 target.getNode("label").setValue(name != nil ? name.getValue() : ("** unnamed view " ~ index ~ " **"));
        //                 target.getNode("property").setValue(enabled.getPath());
        //             }
        //         }
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width

                Label {
                    text: qsTr("Select Active Views")
                }

                ColumnLayout {
                    width: parent.width
                } // ColumnLayout

                id: active_views

                Label {
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Standard Views")
                }
            } // ColumnLayout

            HorizontalLine {}

            ColumnLayout {
                width: parent.width

                Label {
                    text: qsTr("Display Options")
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show frame rate")
                    // property*: /sim/rendering/fps-display
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show frame spacing")
                    // property*: /sim/rendering/frame-latency-display
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show chat messages")
                    // property*: /sim/multiplay/chat-display
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show popup messages")
                    // property*: /sim/view-name-popup
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show popup when cycling mouse behaviour")
                    // property*: /sim/mouse/cycle-mode-popup
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show tooltips")
                    // property*: /sim/mouse/tooltips-enabled
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show tooltip on mouse press")
                    // property*: /sim/mouse/click-shows-tooltip
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Show 2D panel")
                    // property*: /sim/panel/visibility
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Hide 2D panel in non-centered view")
                    // property*: /sim/panel/hide-nonzero-heading-offset
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Hide 2D panel in non-cockpit view")
                    // property*: /sim/panel/hide-nonzero-view
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Autohide menubar")
                    // property*: /sim/menubar/autovisibility/enabled
                    // binding*: " dialog-apply "
                }

                RowLayout {
                    width: parent.width
                    //horizontalAlignment: Text.AlignLeft
                    //padding: 0

                    CheckBox {
                        text: qsTr("Autohide cursor in")
                        // property*: /sim/mouse/hide-cursor
                        // binding*: " dialog-apply "
                    }

                    TextInput {
                        // live*: true
                        width: 40
                        height: 10
                        // property*: /sim/mouse/cursor-timeout-sec
                        // binding*: " dialog-apply "
                    }

                    Label {
                        text: qsTr("sec.")
                    }
                } // RowLayout

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Legacy multiplayer view selector")
                    // property*: /sim/menubar/legacy-multiplayer-view-selector/enabled
                    // binding*: " dialog-apply "
                }
            } // ColumnLayout
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            // binding*: " dialog-apply "
            onClicked: {
                viewOptionsDialog.closed(viewOptionsDialog.id);
            }
        }
    } // buttons
}
