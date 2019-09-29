import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: mapDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: mapDialog.id
    title: "Map"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var mapDialog = cmdarg();
        //         var setTransparency = func(updateDialog) {
        //             var alpha = (getprop("/gui/map/transparent") or 0);
        //             mapDialog.getNode("color/alpha").setValue(1-alpha*0.3);
        //             # mhab commented out
        //             #mapDialog.getNode("color/red").setValue(0.41-alpha*0.2);
        //             #mapDialog.getNode("color/green").setValue(0.4-alpha*0.2);
        //             #mapDialog.getNode("color/blue").setValue(0.42-alpha*0.2);
        //             var n = props.Node.new({ "dialog-name": "map" });
        //             if (updateDialog) {
        //                 fgcommand("dialog-close", n);
        //                 fgcommand("dialog-show", n);
        //             }
        //         }
        //         setTransparency(0);
        //     </open>

        //     <close>
        //     </close>
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

                Label {
                    text: qsTr("Display:")
                }

                CheckBox {
                    text: qsTr("Heliports")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/draw-heliports
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Fixes")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/draw-fixes
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Navaids")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/draw-navaids
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Traffic")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/draw-traffic
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Data")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/draw-data
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Flight History")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/draw-flight-history
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
                    // property*: /gui/map/magnetic-headings
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Center on Acft")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/centre-on-aircraft
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Aircraft Hdg Up")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/aircraft-heading-up
                    // live*: true
                    // binding*: " dialog-apply "
                    // binding*: " property-toggle "
                }

                CheckBox {
                    text: qsTr("Transparent")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /gui/map/transparent
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
                    width: 100
                    // default*: true
                    onClicked: {
                        mapDialog.closed(mapDialog.id);
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
            text: qsTr("-")
            width: 22
            height: 22
            // binding*: " property-adjust /gui/map/zoom 0 -1 "
        }

        Label {
            text: qsTr("MMM")
            // format*: Zoom %d
            // property*: /gui/map/zoom
            // live*: true
        }

        Button {
            id: zoomin
            text: qsTr("+")
            width: 22
            height: 22
            // binding*: " property-adjust /gui/map/zoom 1 12 "
        }
    } // buttons
}
