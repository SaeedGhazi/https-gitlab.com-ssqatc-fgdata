import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: staticLodDialog

    width: 640
    height: 350
    position: Qt.point(80, 80)

    windowId: staticLodDialog.id
    title: "Adjust Level Of Detail Ranges"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
    //     <nasal>
    //         <open>
    //         <![CDATA[

    //             var reload_props = [
    //                 "/sim/rendering/static-lod/rough-delta",
    //                 "/sim/rendering/static-lod/bare-delta"];

    //             var reload_vals = {};
    //             foreach (var p; reload_props) {
    //                 reload_vals[p] = getprop(p);
    //             }
    //             check_for_reload = func{
    //                     var reinit = 0;
    //                     foreach (var p; reload_props) {
    //                     if (reload_vals[p] != getprop(p)) {
    //                         reinit = 1;
    //                     }
    //                     }

    //                     if (reinit) {
    //                     fgcommand("reload-materials", props.Node.new());
    //                     fgcommand("reinit", props.Node.new({"subsystem": "scenery"}));
    //                     }
    //             };
                
    //             var lodDIALOG = cmdarg();
    //             var dlgLOD = props.Node.new({"dialog-name": "static-lod"});

    //             var ai_mp_bare = gui.findElementByName(lodDIALOG, "aimp-bare");
    //             var ai_mp_bare_label = gui.findElementByName(lodDIALOG, "aimp-bare-label");
    //             var ai_mp_detailed = gui.findElementByName(lodDIALOG, "aimp-detailed");
    //             var ai_mp_detailed_label = gui.findElementByName(lodDIALOG, "aimp-detailed-label");
    //             var current_detailed = nil;
    //             var current_bare = nil;
    //             var current_ai_mp_mode = "";

    //             if (getprop("/sim/rendering/static-lod/aimp-detailed") < 0)
    //                 setprop("/sim/gui/dialogs/static-lod/aimp-mp-mode", "High Detail only");
    //             else if (getprop("/sim/rendering/static-lod/aimp-detailed") == getprop("/sim/rendering/static-lod/aimp-bare"))
    //                 setprop("/sim/gui/dialogs/static-lod/aimp-mp-mode", "Low Detail only");
    //             else
    //                 setprop("/sim/gui/dialogs/static-lod/aimp-mp-mode", "Specify Ranges");

    //             update_enabling = func{
    //                 var mode = getprop("/sim/gui/dialogs/static-lod/aimp-mp-mode");
    //                 if (mode == "Low Detail only") {
    //                     setprop("/sim/gui/dialogs/static-lod/aimp-mp-bare-enabled", 1);
    //                     setprop("/sim/gui/dialogs/static-lod/aimp-mp-detailed-enabled", 0);
    //                 } else if (mode == "High Detail only") {
    //                     setprop("/sim/gui/dialogs/static-lod/aimp-mp-bare-enabled", 0);
    //                     setprop("/sim/gui/dialogs/static-lod/aimp-mp-detailed-enabled", 0);
    //                 } else {
    //                     setprop("/sim/gui/dialogs/static-lod/aimp-mp-bare-enabled", 1);
    //                     setprop("/sim/gui/dialogs/static-lod/aimp-mp-detailed-enabled", 1);
    //                 }

    // #                if (!getprop("/sim/rendering/static-lod/aimp-bare") and !getprop("/sim/rendering/static-lod/aimp-detailed")) {
    // #                    setprop("/sim/rendering/static-lod/aimp-bare", 0);
    // #                    setprop("/sim/rendering/static-lod/aimp-detailed",100);
    // #                }
    //                 return mode;
    //             };

    //             reload_sliders = func(reload) {
    //                 if (!reload)
    //                     return ;
    //                 var current_dialog = getprop("/sim/gui/dialogs/current-dialog");
    //                 fgcommand("dialog-close", dlgLOD);
    //                 fgcommand("dialog-show", dlgLOD);
    //                 if (current_dialog != "") {
    //                     var show_node = props.Node.new({"dialog-name": current_dialog});
    //                     fgcommand("dialog-show", show_node);
    //                 }
    //             }
    //             ;

    //             update_scenery_text = func{
    //                 var detailed = getprop("/sim/rendering/static-lod/detailed");
    //                 var bare = getprop("/sim/rendering/static-lod/bare-delta");
    //                 var rough = getprop("/sim/rendering/static-lod/rough-delta");
    //                 setprop("/sim/rendering/static-lod/detailed-description", sprintf("from %5.0fm to %5.0fm",0, detailed));
    //                 setprop("/sim/rendering/static-lod/rough-delta-description", sprintf("from %5.0fm to %5.0fm",detailed, rough+detailed));
    //                 setprop("/sim/rendering/static-lod/bare-delta-description", sprintf("from %5.0fm to %5.0fm",rough+detailed,rough+bare+detailed));
    //             };

    //             update_description = func(mode){

    //                 var descD = "";
    //                 var descB = "";
    //                 var descW = "";

    //                 if (getprop("sim/rendering/static-lod/aimp-range-mode-distance")) {
    //                     if (mode == "Low Detail only") {
    //                         if (getprop("/sim/rendering/static-lod/aimp-bare")>0) {
    //                             descD = sprintf("visible when viewpoint within\n%.0f meters", getprop("/sim/rendering/static-lod/aimp-detailed"));
    //                         } else {
    //                             descB = "always visible";
    //                         }
    //                     } else if (mode == "High Detail only") {
    //                         descW = "Always visible regardless of distance";
    //                     } else {
    //                         descW = "";
    //                         descD = sprintf("0 to %.0fm from viewpoint", getprop("/sim/rendering/static-lod/aimp-detailed"));
    //                         descB = sprintf("%.0fm to %.0fm", getprop("/sim/rendering/static-lod/aimp-detailed"), getprop("/sim/rendering/static-lod/aimp-detailed")+getprop("/sim/rendering/static-lod/aimp-bare"));
    //                         var lowDetailRange = getprop("/sim/rendering/static-lod/aimp-detailed") + getprop("/sim/rendering/static-lod/aimp-bare") ;
    //                         if (lowDetailRange < 1000)
    //                             descW = sprintf("WARNING: Low Detail too close, nothing drawn over %.0fm", lowDetailRange);

    //                     }
    //                 } else {
    //                     if (mode == "Low Detail only") {
    //                         if (getprop("/sim/rendering/static-lod/aimp-bare")>0) {
    //                             descD = sprintf("visible when larger than\n%.0f pixels in size on screen", getprop("/sim/rendering/static-lod/aimp-detailed"));
    //                             descB = "";
    //                             descW = sprintf("WARNING: When smaller than %.0f pixels nothing will be drawn", getprop("/sim/rendering/static-lod/aimp-bare"));
    //                         } else {
    //                             descW = "";
    //                             descD = "";
    //                             descB = "always visible";
    //                         }
    //                     } else if (mode == "High Detail only") {
    //                         descW = "Always visible regardless of distance";
    //                     } else {
    //                         descW = "";
    //                         if (getprop("/sim/rendering/static-lod/aimp-bare")>0)
    //                             descW = sprintf("WARNING: Below %.0f pixels in size nothing will be drawn", getprop("/sim/rendering/static-lod/aimp-bare"));
    //                         descD = sprintf("above %.0f pixels in size", getprop("/sim/rendering/static-lod/aimp-detailed"));
    //                         descB = sprintf("above %.0f pixels in size", getprop("/sim/rendering/static-lod/aimp-bare"));
    //                     }
    //                 }
    //                 setprop("/sim/gui/dialogs/static-lod/aimp-detailed-description",  descD);
    //                 setprop("/sim/gui/dialogs/static-lod/aimp-bare-description", descB);
    //                 setprop("/sim/gui/dialogs/static-lod/aimp-bare-description1", descW);

    //             };
    //             # returns non zero if the value was adjusted and it can be adjusted (can_reload)
    //             adjustValue = func(id, nodeId, value, can_reload){
    //                 var node = nodeId.getNode(id);
    //                 if (node != nil) {
    //                     var cv = node.getValue();
    //                     if (cv != value) {
    //                         node.setValue(value);
    //                         if (can_reload)
    //                             reload_sliders(1);
    //                     }
    //                 }
    //                 return 0;                   # no need to reload.
    //             }

    //             update_ai_mp = func(can_reload) {
    //                 var mode = update_enabling ();  
    //                 var distance_mode = getprop("sim/rendering/static-lod/aimp-range-mode-distance");
    //                 update_description(mode);
    //                 if (mode == "Low Detail only") {
    //                     setprop("/sim/rendering/static-lod/aimp-detailed",getprop("/sim/rendering/static-lod/aimp-bare"));
    //                     can_reload = adjustValue("max", ai_mp_bare, 2000, can_reload);
    //                     reload_sliders(can_reload);
    //                 } else if (mode == "High Detail only") {
    // #                    setprop("/sim/rendering/static-lod/aimp-bare", 0);
    // #                    setprop("/sim/rendering/static-lod/aimp-detailed",-1);
    //                 } else {
    //                     if (!distance_mode) {
    //                         if (getprop("/sim/rendering/static-lod/aimp-bare") > getprop("/sim/rendering/static-lod/aimp-detailed")){
    //                             setprop("/sim/rendering/static-lod/aimp-bare", getprop("/sim/rendering/static-lod/aimp-detailed")-1 ) ;
    //                         }
    //                         can_reload = adjustValue("max", ai_mp_detailed, 2000, can_reload);
    //                         can_reload = adjustValue("max", ai_mp_bare, getprop("/sim/rendering/static-lod/aimp-detailed"), can_reload);
    //                     } else {
    //                         can_reload = adjustValue("max", ai_mp_detailed, 3000, can_reload);
    //                         can_reload = adjustValue("max", ai_mp_bare, 3000, can_reload);
    //                     }
    //                 }
    //             }
    //             update_aimp_mode = func{
    //                 var new_mode = getprop("/sim/gui/dialogs/static-lod/aimp-mp-mode");
    //                 if (new_mode != current_ai_mp_mode) {
                        
    //                     if (current_ai_mp_mode == "Specify Ranges") {
    //                         current_detailed = getprop("/sim/rendering/static-lod/aimp-detailed");
    //                         current_bare =getprop("/sim/rendering/static-lod/aimp-bare");
    //                     } 
    //                     if (current_ai_mp_mode == "Low Detail only" or current_ai_mp_mode == "High Detail only") {
    //                         if (current_detailed != nil)
    //                             setprop("/sim/rendering/static-lod/aimp-detailed", current_detailed );
    //                         if (current_bare != nil)
    //                             setprop("/sim/rendering/static-lod/aimp-bare",current_bare);
    //                     }
    //                     if (new_mode == "High Detail only") {
    //                         setprop("/sim/rendering/static-lod/aimp-detailed", -1);
    //                         setprop("/sim/rendering/static-lod/aimp-bare",0);
    //                     } else if (new_mode == "Low Detail only"){
    //                         setprop("/sim/rendering/static-lod/aimp-detailed", 0);
    //                         setprop("/sim/rendering/static-lod/aimp-bare",0);
    //                     }
    //                     current_ai_mp_mode = new_mode;
    //                 }
    //                 update_description(update_enabling());
    //             }
    // #            setlistener("/sim/gui/dialogs/static-lod/aimp-mp-mode", func(v){
    // #            },0 ,0);

    //             update_scenery_text ();
    //             update_ai_mp (0);


    //         ]]>
    //         </open>
    //     </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr("Scenery (Tiles, Buildings, Roads, Railways)")
        }

        GridLayout {
            width: parent.width
            columns: 3

            Label {
                text: qsTr("Detailed")
            }

            Slider {
                id: scenery_detailed
                width: 300
                // property*: /sim/rendering/static-lod/detailed
                // live*: 1
                // binding*: " dialog-apply scenery-detailed "
                // binding*: " nasal update_scenery_text(); "
            }

            Label {
                text: qsTr("xxxxxxxxxxxxxxxxxxx")
                horizontalAlignment: Text.AlignLeft
                // live*: true
                // property*: /sim/rendering/static-lod/detailed-description
            }

            Label {
                text: qsTr("Rough")
            }

            Slider {
                id: scenery_rough
                width: 300
                // property*: /sim/rendering/static-lod/rough-delta
                // live*: 1
                // binding*: " dialog-apply scenery-rough "
                // binding*: " nasal update_scenery_text(); "
            }

            Label {
                text: qsTr("xxxxxxxxxxxxxx")
                horizontalAlignment: Text.AlignLeft
                // live*: true
                // property*: /sim/rendering/static-lod/rough-delta-description
            }

            Label {
                text: qsTr("Bare")
            }

            Slider {
                id: scenery_bare
                width: 300
                // property*: /sim/rendering/static-lod/bare-delta
                // live*: 1
                // binding*: " dialog-apply scenery-bare "
                // binding*: " nasal update_scenery_text(); "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("xxxxxxxxxxxxxx")
                // live*: true
                // property*: /sim/rendering/static-lod/bare-delta-description
            }
        } // GridLayout

        HorizontalLine {}

        Label {
            text: qsTr("AI/MP Aircraft")
        }

        GridLayout {
            width: parent.width
            columns: 3

            Label {
                text: qsTr(" ")
            }

            ComboBox {
                id: aimp_mode
                width: 200
                // property*: /sim/gui/dialogs/static-lod/aimp-mp-mode
                // binding*: " dialog-apply aimp-mode "
                // binding*: " nasal update_aimp_mode(); "
            }

            CheckBox {
                id: distance
                text: qsTr("AI/MP in meters")
                //horizontalAlignment: Text.AlignLeft
                // property*: sim/rendering/static-lod/aimp-range-mode-distance
                // live*: true
                // binding*: " property-toggle sim/rendering/static-lod/aimp-range-mode-distance 0 "
                // binding*: " nasal update_ai_mp(0); "
            }

            Label {
                id: aimp_detailed_label
                text: qsTr("High Detail")
            }

            Slider {
                id: aimp_detailed
                width: 300
                // property*: /sim/rendering/static-lod/aimp-detailed
                // live*: 1
                // binding*: " dialog-apply aimp-detailed "
                // binding*: " nasal update_ai_mp(1); "
                // binding*: " dialog-update "
            }

            Label {
                text: qsTr("xxxxxxxxxxxxxxxxxxxxxxxxxx")
                horizontalAlignment: Text.AlignLeft
                // live*: true
                // property*: /sim/gui/dialogs/static-lod/aimp-detailed-description
            }

            Label {
                id: aimp_bare_label
                text: qsTr("Low Detail")
            }

            Slider {
                id: aimp_bare
                width: 300
                // property*: /sim/rendering/static-lod/aimp-bare
                // live*: 1
                // binding*: " dialog-apply aimp-bare "
                // binding*: " nasal update_ai_mp(1); "
                // binding*: " dialog-update "
            }

            Label {
                text: qsTr("xxxxxxxxxxxxxxxxxxxxxxxxxx")
                horizontalAlignment: Text.AlignLeft
                // live*: true
                // property*: /sim/gui/dialogs/static-lod/aimp-bare-description
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("xxxxxxxxxxxxxxxxxxxxxxxxxx")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
                // live*: true
                // property*: /sim/gui/dialogs/static-lod/aimp-bare-description1
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("AI/MP Interior")
            }

            Slider {
                id: aimp_interior
                width: 300
                // property*: /sim/rendering/static-lod/aimp-interior
                // live*: 1
                // binding*: " dialog-apply aimp-interior "
            }

            Label {
                text: qsTr("xxxxxxxxxxxxxxxxxxxxxxxxxx")
                horizontalAlignment: Text.AlignLeft
                // format*: %.0f
                // live*: true
                // property*: /sim/rendering/static-lod/aimp-interior
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "
            // binding*: " nasal check_for_reload(); "

            onClicked: {
                staticLodDialog.closed(staticLodDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // binding*: " dialog-apply "
            // binding*: " nasal check_for_reload(); "
        }

        Button {
            text: qsTr("Defaults")
            // binding*: " nasal setprop("/sim/gui/dialogs/static-lod/aimp-mp-mode", "Specify Ranges"); setprop("/sim/rendering/static-lod/detailed",1500); setprop("/sim/rendering/static-lod/rough-delta",7500); setprop("/sim/rendering/static-lod/bare-delta",21000); if (getprop("sim/rendering/static-lod/aimp-range-mode-distance")){ # Reset for meters setprop("/sim/rendering/static-lod/aimp-detailed",500); setprop("/sim/rendering/static-lod/aimp-bare",2000); setprop("/sim/rendering/static-lod/aimp-interior",50); } else { # Reset for pixel mode setprop("/sim/rendering/static-lod/aimp-detailed",400); setprop("/sim/rendering/static-lod/aimp-bare",0); setprop("/sim/rendering/static-lod/aimp-interior",200); } update_description(update_enabling()); reload_sliders(1); "
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                staticLodDialog.closed(staticLodDialog.id);
            }
        }
    } // buttons
}
