import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: shadersLightfieldDialog

    width: 400
    height: 400
    position: Qt.point(80, 80)

    windowId: shadersLightfieldDialog.id
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
        //             var group = cmdarg().getChildren("group")[11];
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

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Clouds")
            }

            Slider {
                id: cloud
                // live*: true
                // property*: /sim/rendering/shaders/clouds
                // binding*: " dialog-apply cloud "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Landmass")
            }

            Slider {
                id: landmass
                // live*: true
                // property*: /sim/rendering/shaders/landmass
                // binding*: " dialog-apply landmass "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Transition")
            }

            Slider {
                id: transition
                // live*: true
                // property*: /sim/rendering/shaders/transition
                // binding*: " dialog-apply transition "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Urban")
            }

            Slider {
                id: urban
                // live*: true
                // property*: /sim/rendering/shaders/urban
                // binding*: " dialog-apply urban "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Agriculture")
            }

            Slider {
                id: agriculture
                // live*: true
                // property*: /sim/rendering/shaders/crop
                // binding*: " dialog-apply agriculture "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr("Water")
            }

            Slider {
                id: water
                // live*: true
                // property*: /sim/rendering/shaders/water
                // binding*: " dialog-apply water "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr("Model")
            }

            Slider {
                id: model
                // live*: true
                // property*: /sim/rendering/shaders/model
                // binding*: " dialog-apply model "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr("Forest")
            }

            Slider {
                id: forest
                // live*: true
                // property*: /sim/rendering/shaders/forest
                // binding*: " dialog-apply forest "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr("Wind Effects")
            }

            Slider {
                id: wind
                // live*: true
                // property*: /sim/rendering/shaders/wind-effects
                // binding*: " dialog-apply wind "
            }

            Label {
                width: 55
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr("Overlay")
            }

            Slider {
                id: vegetation
                // live*: true
                // property*: /sim/rendering/shaders/vegetation-effects
                // binding*: " dialog-apply vegetation "
            }

            Label {
                width: 55
            }
        } // RowLayout

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
                shadersLightfieldDialog.closed(shadersLightfieldDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                shadersLightfieldDialog.closed(shadersLightfieldDialog.id);
            }
        }
    } // buttons
}
