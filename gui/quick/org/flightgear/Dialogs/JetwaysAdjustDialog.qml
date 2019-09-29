import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: jetwaysAdjustDialog

    width: 500
    height: 400
    position: Qt.point(80, 80)

    windowId: jetwaysAdjustDialog.id
    title: "Jetway Editor"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var self = cmdarg();
        //         var dlgname = self.getNode("name").getValue();
        //         var root = getprop("/sim/fg-root");
        //         var modelfiles = directory(root ~ "/Models/Airport/Jetway");
        //         var modelcombo = self.getNode("group[9]/combo[0]");
        //         var models = [];
        //         foreach (var file; modelfiles)
        //         {
        //             if (substr(file, -3) == "xml")
        //             {
        //                 var tree = io.read_properties("Models/Airport/Jetway/" ~ file);
        //                 if (tree.getNode("is-animated-jetway", 1).getBoolValue()) append(models, substr(file, 0, size(file) - 4));
        //             }
        //         }
        //         for (var i = 0; i < size(models); i += 1)
        //         {
        //             modelcombo.getNode("value[" ~ i ~ "]", 1).setValue(models[i]);
        //         }

        //         var airlinefiles = directory(root ~ "/Models/Airport/Jetway/Airlines");
        //         var airlinecombo = self.getNode("group[9]/combo[2]");
        //         var airlines = [];
        //         foreach (var file; airlinefiles)
        //         {
        //             append(airlines, substr(file, 0, size(file) - 4));
        //         }
        //         for (var i = 0; i < size(airlines); i += 1)
        //         {
        //             airlinecombo.getNode("value[" ~ i ~ "]", 1).setValue(airlines[i]);
        //         }

        //         var Value =
        //         {
        //             new: func(name)
        //             {
        //                 var m = { parents: [Value] };
        //                 m.name = name;
        //                 var n = props.globals.getNode("/sim/jetways/adjust/" ~ m.name, 1);
        //                 m.sliderN = n.getNode("slider", 1);
        //                 m.offsetN = n.getNode("offset", 1);
        //                 m.offsetN.setDoubleValue(0);
        //                 m.sliderN.setDoubleValue(0);
        //                 m.last_slider = 0;
        //                 m.center();
        //                 m.sliderL = setlistener(m.sliderN, func m.update());
        //                 return m;
        //             },
        //             update: func
        //             {
        //                 var offset = me.sliderN.getValue();
        //                 var value = me.offsetN.getValue() + me.sliderN.getValue() - me.last_slider;
        //                 jetways_edit.adjust(me.name, value);
        //                 me.offsetN.setDoubleValue(0);
        //                 me.last_slider = offset;
        //             },
        //             center : func
        //             {
        //                 me.offsetN.setValue(me.offsetN.getValue() + me.sliderN.getValue());
        //                 me.sliderN.setDoubleValue(0);
        //             },
        //             remove: func
        //             {
        //                 removelistener(me.sliderL);
        //             }
        //         };
        //         var values =
        //         [
        //             Value.new("longitudinal"),
        //             Value.new("transversal"),
        //             Value.new("altitude"),
        //             Value.new("heading"),
        //             Value.new("initial-extension"),
        //             Value.new("initial-heading"),
        //             Value.new("initial-pitch"),
        //             Value.new("initial-entrance-heading")
        //         ];
        //         var center_sliders = func
        //         {
        //             foreach (var v; values)
        //             {
        //                 v.center();
        //             }
        //         };
        //         var update = func(w)
        //         {
        //             self.setValues({"dialog-name": dlgname, "object-name": w});
        //             fgcommand("dialog-update", self);
        //             center_sliders();
        //         };
        //     ]]></open>

        //     <close>
        //         foreach (var v; values)
        //         {
        //             v.remove();
        //         }
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/longitudinal/offset -10 "
                // binding*: " nasal update("longitudinal") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/longitudinal/offset -1 "
                // binding*: " nasal update("longitudinal") "
            }

            Slider {
                id: longitudinal
                // property*: /sim/jetways/adjust/longitudinal/slider
                //text: qsTr("near/far")
                width: 250
                // live*: 1
                //color: "#FF9999FF"
                // binding*: " dialog-apply longitudinal "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/longitudinal/offset 1 "
                // binding*: " nasal update("longitudinal") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/longitudinal/offset 10 "
                // binding*: " nasal update("longitudinal") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/transversal/offset -10 "
                // binding*: " nasal update("transversal") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/transversal/offset -1 "
                // binding*: " nasal update("transversal") "
            }

            Slider {
                id: transversal
                // property*: /sim/jetways/adjust/transversal/slider
                //text: qsTr("left/right")
                width: 250
                // live*: 1
                //color: "#99FF99FF"
                // binding*: " dialog-apply transversal "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/transversal/offset 1 "
                // binding*: " nasal update("transversal") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/transversal/offset 10 "
                // binding*: " nasal update("transversal") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/altitude/offset -10 "
                // binding*: " nasal update("altitude") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/altitude/offset -1 "
                // binding*: " nasal update("altitude") "
            }

            Slider {
                id: altitude
                // property*: /sim/jetways/adjust/altitude/slider
                //text: qsTr("altitude")
                width: 250
                // live*: 1
                //color: "#9999FFFF"
                // binding*: " dialog-apply altitude "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/altitude/offset 1 "
                // binding*: " nasal update("altitude") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/altitude/offset 10 "
                // binding*: " nasal update("altitude") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/heading/offset -6 "
                // binding*: " nasal update("heading") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/heading/offset -1 "
                // binding*: " nasal update("heading") "
            }

            Slider {
                id: heading
                // property*: /sim/jetways/adjust/heading/slider
                //text: qsTr("heading")
                width: 250
                // live*: 1
                //color: "#FFFF99FF"
                // binding*: " dialog-apply heading "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/heading/offset 1 "
                // binding*: " nasal update("heading") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/heading/offset 6 "
                // binding*: " nasal update("heading") "
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-extension/offset -3 "
                // binding*: " nasal update("initial-extension") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-extension/offset -1 "
                // binding*: " nasal update("initial-extension") "
            }

            Slider {
                id: initial_extension
                // property*: /sim/jetways/adjust/initial-extension/slider
                //text: qsTr("extension offset")
                width: 250
                // live*: 1
                //color: "#FFFFFFFF"
                // binding*: " dialog-apply initial-extension "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-extension/offset 1 "
                // binding*: " nasal update("initial-extension") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-extension/offset 3 "
                // binding*: " nasal update("initial-extension") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-pitch/offset -2 "
                // binding*: " nasal update("initial-pitch") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-pitch/offset -1 "
                // binding*: " nasal update("initial-pitch") "
            }

            Slider {
                id: initial_pitch
                // property*: /sim/jetways/adjust/initial-pitch/slider
                //text: qsTr("pitch offset")
                width: 250
                // live*: 1
                //color: "#CCCCCCCC"
                // binding*: " dialog-apply initial-pitch "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-pitch/offset 1 "
                // binding*: " nasal update("initial-pitch") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-pitch/offset 2 "
                // binding*: " nasal update("initial-pitch") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-heading/offset -2 "
                // binding*: " nasal update("initial-heading") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-heading/offset -1 "
                // binding*: " nasal update("initial-heading") "
            }

            Slider {
                id: initial_heading
                // property*: /sim/jetways/adjust/initial-heading/slider
                //text: qsTr("rotation offset")
                width: 250
                // live*: 1
                //color: "#99999999"
                // binding*: " dialog-apply initial-heading "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-heading/offset 1 "
                // binding*: " nasal update("initial-heading") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-heading/offset 2 "
                // binding*: " nasal update("initial-heading") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-entrance-heading/offset -6 "
                // binding*: " nasal update("initial-entrance-heading") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-entrance-heading/offset -1 "
                // binding*: " nasal update("initial-entrance-heading") "
            }

            Slider {
                id: initial_entrance_heading
                // property*: /sim/jetways/adjust/initial-entrance-heading/slider
                //text: qsTr("entrance rotation offset")
                width: 250
                // live*: 1
                //color: "#66666666"
                // binding*: " dialog-apply initial-entrance-heading "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-entrance-heading/offset 1 "
                // binding*: " nasal update("initial-entrance-heading") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/jetways/adjust/initial-entrance-heading/offset 6 "
                // binding*: " nasal update("initial-entrance-heading") "
            }
        } // RowLayout

        GridLayout {
            width: parent.width
            columns: 4

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Model:")
            }

            ComboBox {
                id: model
                // property*: /sim/jetways/adjust/model
                // live*: true
                // binding*: " dialog-apply model "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Door:")
            }

            ComboBox {
                id: door
                // property*: /sim/jetways/adjust/door
                // live*: true
                // binding*: " dialog-apply door "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Airline sign:")
            }

            ComboBox {
                id: airline
                // property*: /sim/jetways/adjust/airline
                // live*: true
                // binding*: " dialog-apply airline "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Gate:")
            }

            TextInput {
                id: gate
                // property*: /sim/jetways/adjust/gate
                // live*: true
                // binding*: " dialog-apply gate "
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            height: 24
            text: qsTr("Center sliders")
            // binding*: " nasal center_sliders(); "
        }

        Button {
            height: 24
            text: qsTr("Export")
            // border*: 2
            // binding*: " nasal jetways_edit.export(); "
        }

        Button {
            height: 24
            text: qsTr("STG converter")
            // border*: 2
            // binding*: " nasal jetways_edit.convert_stg(); "
        }

        Button {
            height: 24
            text: qsTr("?")
            // border*: 2
            // binding*: " nasal jetways_edit.print_help(); "
        }

    } // buttons
}
