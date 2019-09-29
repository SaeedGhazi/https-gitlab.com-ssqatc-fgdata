import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: developmentExtensionsDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: developmentExtensionsDialog.id
    title: "Configure Development Extensions"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var osg_debug = [
        //             [0, "- Off"],
        //             [1, "- Show Frame Rate"],
        //             [2, "+ Viewer Graph"],
        //             [3, "+ Camera"],
        //             [4, "+ Viewer Scene"],
        //         ];
        //         var osg_stats = cmdarg().getChildren("group")[1].getChildren("combo")[0];
        //         var i = 0;

        //         foreach (var s; osg_debug) {
        //             var nm = s[0] ~ " " ~ s[1];
        //             # print("setting node to ",nm);
        //             osg_stats.getNode("value[" ~ i ~ "]", 1).setValue(nm);
        //             if (i == getprop("/sim/rendering/on-screen-statistics"))
        //                 setprop("/sim/gui/dialogs/devel-extensions/on-screen-statistics",nm);
        //             i += 1;
        //         }

        //         var updateOSG_stats = func(n) {
        //             var sel_mode = n.getValue();
        //             if( sel_mode == nil ) return;
        //             print("\nupdate OSG debug ",sel_mode);

        //             foreach (var s; osg_debug)
        //             {
        //                 if(s[0] == sel_mode)
        //                 {
        //                     print(" >> ",s[1]);
        //                     setprop("/sim/gui/dialogs/devel-extensions/on-screen-statistics", s[0] ~ " " ~ s[1]);
        //                     gui.dialog_update("devel-extensions", "OSGdebug");
        //                     break;
        //                 }
        //             }
        //             #  print("OSG Debug ",getprop("/sim/gui/dialogs/devel-extensions/on-screen-statistics"));
        //         };

        //         # listen for results arriving
        //         setlistener("/sim/rendering/on-screen-statistics", updateOSG_stats);
        //     ]]></open>

        //     <close>
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        ColumnLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("Enable development dialog widgets (HUD and rendering dialog)")
                // property*: /sim/gui/devel-widgets
                // binding*: " dialog-apply "
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("Enable '/'-key property handler (see $FG_ROOT/Nasal/prop_key_handler.nas)")
                // property*: /sim/input/property-key-handler
                // binding*: " dialog-apply "
            }
        } // ColumnLayout

        ColumnLayout {
            width: parent.width

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("Local loopback of model")
                // property*: /sim/gui/debug/multiplayer-loopback
                // binding*: " dialog-apply "
                // binding*: " nasal setprop("/sim/multiplay/debug-level", (getprop("/sim/multiplay/debug-level") or 0) ^ 1); setprop("/sim/gui/debug/multiplayer-loopback", getprop("/sim/multiplay/debug-level") & 1); "
            }

            ComboBox {
                width: 300
                //horizontalAlignment: Text.AlignLeft
                id: osg_debug
                //text: qsTr("OSG statistics")
                // property*: /sim/gui/dialogs/devel-extensions/on-screen-statistics
                // binding*: " dialog-apply "
                // binding*: " nasal print("OSG Debug ",getprop("/sim/gui/dialogs/devel-extensions/on-screen-statistics")); var selval = substr(getprop("/sim/gui/dialogs/devel-extensions/on-screen-statistics"),0,1); print("Set osg debug ",selval); setprop("/sim/rendering/on-screen-statistics", selval); "
            }

            ComboBox {
                width: 300
                //horizontalAlignment: Text.AlignLeft
                id: osg_log
                //text: qsTr("OSG log level")
                // property*: /sim/rendering/osg-notify-level
                // binding*: " dialog-apply OSGLog "
            }

            ComboBox {
                width: 300
                //horizontalAlignment: Text.AlignLeft
                id: sg_logging
                //text: qsTr("FG log")
                // property*: /sim/logging/priority
                // binding*: " dialog-apply SGLogging "
            }
        } // ColumnLayout

        RowLayout {
            width: parent.width

            Button {
                text: qsTr("New Canvas Map")
                // binding*: " nasal canvas.MapStructure_selfTest(); "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Button {
                text: qsTr("Reload GUI")
                id: reload_gui
                // binding*: " reinit gui "
            }

            Button {
                id: reload_input
                text: qsTr("Reload Input")
                // binding*: " reinit input "
            }

            Button {
                id: reload_hud
                text: qsTr("Reload Hud")
                // binding*: " reinit hud "
            }

            Button {
                id: reload_panel
                text: qsTr("Reload Panel")
                // binding*: " panel-load "
            }
        } // RowLayout

        RowLayout {
            width: parent.width

            Button {
                id: reload_autopilot
                text: qsTr("Reload Autopilot")
                // binding*: " reinit xml-autopilot "
            }

            Button {
                id: reload_network
                text: qsTr("Reload Network")
                // binding*: " reinit io "
            }

            Button {
                id: reload_model
                text: qsTr("Reload Aircraft Model")
                // binding*: " reinit aircraft-model "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Button {
                id: reload_shaders
                text: qsTr("Reload Shaders")
                // binding*: " reload-shaders "
            }

            Button {
                id: reload_materials
                text: qsTr("Reload Materials")
                // binding*: " reload-materials "
            }

            Button {
                width: 20
                id: reload_scenery
                text: qsTr("Reload Scenery")
                // binding*: " reinit scenery "
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
                developmentExtensionsDialog.closed(developmentExtensionsDialog.id);
            }
        }
    } // buttons
}
