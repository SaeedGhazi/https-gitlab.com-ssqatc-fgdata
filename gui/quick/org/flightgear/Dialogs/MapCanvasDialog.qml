import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: mapCanvasDialog

    width: 640
    height: 800
    position: Qt.point(80, 80)

    windowId: mapCanvasDialog.id
    title: "Map (Canvas)"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var self = cmdarg();
        //         var listeners = [];
        //         var setTransparency = func(updateDialog) {
        //             var alpha = (getprop("/sim/gui/dialogs/map-canvas/transparent") or 0);
        //             self.getNode("color/alpha").setValue(1-alpha*0.3);
        //             var n = props.Node.new({ "dialog-name": "map-canvas" });
        //             if (updateDialog)
        //             {
        //                 fgcommand("dialog-close", n);
        //                 fgcommand("dialog-show", n);
        //             }
        //         }
        //         setTransparency(0);
        //     ]]></open>

        //     <close><![CDATA[
        //         TestMap.del();
        //         foreach (var l; listeners)
        //             removelistener(l);
        //         setsize(listeners, 0);
        //     ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                //horizontalAlignment: Text.AlignLeft

                Label {
                    text: qsTr("Display:")
                }

                CheckBox {
                    text: qsTr("Airports")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-APT
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Fixes")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-FIX
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("VORs")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-VOR
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("DMEs")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-DME
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("NDBs")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-NDB
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Route")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-RTE
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Waypoints")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-WPT
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("APS")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-APS
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Traffic")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-TFC
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Data")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-data
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Flight History")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-FLT
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Weather")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-WXR
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("OSM")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-OSM
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("VFRChart")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-VFRChart
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("OpenAIP")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-OpenAIP
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("STAMEN")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/draw-STAMEN
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                Label {
                    Layout.fillWidth: true
                }

                CheckBox {
                    text: qsTr("Magnetic Hdgs")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/magnetic-headings
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Center on Acft")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/centre-on-aircraft
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Aircraft Hdg Up")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/aircraft-heading-up
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Transparent")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /sim/gui/dialogs/map-canvas/transparent
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                    // binding*: " nasal setTransparency(1); "
                }

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    id: close
                    text: qsTr("Close")
                    // default*: true
                    onClicked: {
                        mapCanvasDialog.closed(mapCanvasDialog.id);
                    }
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
            id: zoomout
            text: qsTr("out")
            width: 52
            height: 22
            // binding*: " nasal var range = TestMap.getRange(); if (range < 40) TestMap.setRange(range*range_step); "
        }

        Label {
            id: zoomdisplay
            text: qsTr("MMM")
            // format*: Zoom %0.1f NM
            // property*: /gui/radar-mapstructure/zoom
            // live*: true
        }

        Button {
            id: zoomin
            text: qsTr("in")
            width: 52
            height: 22
            // binding*: " nasal var range = TestMap.getRange(); if (range > 1) TestMap.setRange(range/range_step); "
        }
    } // buttons
}
