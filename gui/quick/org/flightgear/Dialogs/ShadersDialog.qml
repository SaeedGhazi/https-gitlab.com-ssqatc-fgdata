import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: shadersDialog

    width: 640
    height: 550
    position: Qt.point(80, 80)

    windowId: shadersDialog.id
    title: "Shader Options"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         if (props.globals.getNode("/sim/rendering/shaders/aircraft") != nil) {
        //             var group = cmdarg().getChildren("group")[4];
        //             group.removeChildren("slider");
        //             group.removeChildren("hrule");
        //             group.removeChildren("text");
        //             var shaders = props.globals.getNode("/sim/rendering/shaders/aircraft").getChildren();

        //             for(i=0; size(shaders) > i; i+=1) {
        //                 var fraction 	= 0.5;
        //                 var min 		= 0;
        //                 var max 		= 1;
        //                 var step 		= 1;

        //                 var name 	= shaders[i].getNode("name");

        //                 if (shaders[i].getNode("step") != nil){
        //                     step	= shaders[i].getNode("step");
        //                 }
        //                 if (shaders[i].getNode("min") != nil){
        //                     min 	= shaders[i].getNode("min");
        //                 }
        //                 if (shaders[i].getNode("max") != nil){
        //                     max 	= shaders[i].getNode("max");
        //                 }

        //                 if (min != nil and max != nil and step != nil){
        //                     fraction = step/(max+step);
        //                 }

        //                 var target = group.getChild("slider", i, 1);
        //                 props.copy(group.getNode("slider-template"), target);
        //                 target.getNode("label").setValue(name != nil ? name.getValue() : (shaders[i].getName()));
        //                 target.getNode("name").setValue("aircraftshader"~i);
        //                 target.getNode("binding").getNode("object-name").setValue("aircraftshader"~i);
        //                 target.getNode("min").setValue(min);
        //                 target.getNode("max").setValue(max);
        //                 target.getNode("step").setValue(step);
        //                 target.getNode("fraction").setValue(fraction);
        //                 target.getNode("property").setValue(shaders[i].getPath()~"/quality-level");
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

            Label {
                text: qsTr("General")
                horizontalAlignment: Text.AlignLeft
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "#DFAC01"
            }
        } // RowLayout

        ColumnLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Generic")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Crop")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Landmass")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Persistent contrails")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Transition")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Model")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Urban")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Water")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Lights")
            }
        } // ColumnLayout

        ColumnLayout {
            width: parent.width

            Slider {
                id: generic
                // live*: true
                // property*: /sim/rendering/shaders/generic
                // binding*: " dialog-apply generic "
            }

            Slider {
                id: crop
                // live*: true
                // property*: /sim/rendering/shaders/crop
                // binding*: " dialog-apply crop "
            }

            Slider {
                id: landmass
                // live*: true
                // property*: /sim/rendering/shaders/landmass
                // binding*: " dialog-apply landmass "
            }

            Slider {
                id: contrails
                // live*: true
                // property*: /sim/rendering/shaders/contrails
                // binding*: " dialog-apply contrails "
            }

            Slider {
                id: transition
                // live*: true
                // property*: /sim/rendering/shaders/transition
                // binding*: " dialog-apply transition "
            }

            Slider {
                id: model
                // live*: true
                // property*: /sim/rendering/shaders/model
                // binding*: " dialog-apply model "
            }

            Slider {
                id: urban
                // live*: true
                // property*: /sim/rendering/shaders/urban
                // binding*: " dialog-apply urban "
            }

            Slider {
                id: water
                // live*: true
                // property*: /sim/rendering/shaders/water
                // binding*: " dialog-apply water "
            }

            Slider {
                id: lights
                // live*: true
                // property*: /sim/rendering/shaders/lights
                // binding*: " dialog-apply lights "
            }
        } // ColumnLayout

        Label {
            text: qsTr("Some shaders are disabled because")
            color: "#FF9999"
            // visible*: /sim/rendering/rembrandt/enabled
        }

        Label {
            horizontalAlignment: Text.AlignLeft
            text: qsTr("you have Rembrandt enabled.")
            color: "#FF9999"
            // visible*: /sim/rendering/rembrandt/enabled
        }

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("Aircraft")
                horizontalAlignment: Text.AlignLeft
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "#DFAC01"
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Back")
            // binding*: " dialog-show rendering "
            onClicked: {
                shadersDialog.closed(shadersDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                shadersDialog.closed(shadersDialog.id);
            }
        }
    } // buttons
}
