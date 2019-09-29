import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: earthviewDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: earthviewDialog.id
    title: "Earthview Orbital Rendering"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            Label {
                text: qsTr(" ")
            }

            ColumnLayout {
                width: parent.width

                CheckBox {
                    id: cloudsphere_flag
                    text: qsTr(" Show cloud layer")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /earthview/cloudsphere-flag
                    // binding*: " dialog-apply cloudsphere-flag "
                }

                CheckBox {
                    id: cloud_shadow_flag
                    text: qsTr(" Show cloud shadows")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /earthview/cloud-shadow-flag
                    // binding*: " dialog-apply cloud-shadow-flag if(getprop("/earthview/cloud-shadow-flag")==1) {setprop("/earthview/cloudsphere-angle",0.0);} "
                }

                CheckBox {
                    text: qsTr(" Automatic light scattering")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /earthview/mrd-flag
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    text: qsTr(" Overlay textures")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /earthview/overlay-texture-flag
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    text: qsTr(" Terrain normal mapping")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /earthview/normal-flag
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    text: qsTr(" Cloud normal mapping")
                    //horizontalAlignment: Text.AlignLeft
                    // property*: /earthview/cloud-normal-flag
                    // binding*: " dialog-apply "
                }
            } // ColumnLayout
        } // RowLayout

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("")
            }

            Label {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr(" Start ")
                // equal*: true
                // binding*: " nasal earthview.start() "
            }

            Button {
                text: qsTr(" Stop ")
                // equal*: true
                // binding*: " nasal earthview.stop() "
            }

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 1

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("")
            }

            Label {
                text: qsTr("Cloudsphere Rotation")
                horizontalAlignment: Text.AlignLeft
            }

            HorizontalLine {}
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr("")
            }

            Label {
                text: qsTr("Rotation angle")
            }

            Slider {
                id: cloud_rotation_angle
                // live*: true
                // property*: /earthview/cloudsphere-angle
                // binding*: " dialog-apply cloud-rotation-angle "
                // binding*: " nasal earthview.adjust_cloud_tiles() "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.3f
                // live*: true
                // property*: /earthview/cloudsphere-angle
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 1

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("")
            }

            Label {
                text: qsTr("Atmospheric Effects")
                horizontalAlignment: Text.AlignLeft
            }

            HorizontalLine {}
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Mie factor")
            }

            Slider {
                id: mie_factor
                // live*: true
                // property*: /sim/rendering/mie
                // binding*: " dialog-apply mie-factor "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.3f
                // live*: true
                // property*: /sim/rendering/mie
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Rayleigh factor")
            }

            Slider {
                id: rayleigh_factor
                // property*: /sim/rendering/rayleigh
                // binding*: " dialog-apply rayleigh-factor "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.5f
                // live*: true
                // property*: /sim/rendering/rayleigh
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Density factor")
            }

            Slider {
                id: density_factor
                // property*: /sim/rendering/dome-density
                // binding*: " dialog-apply density-factor "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.1f
                // live*: true
                // property*: /sim/rendering/dome-density
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Visibility")
            }

            Slider {
                id: visibility
                // property*: /environment/visibility-m
                // binding*: " dialog-apply visibility "
                // live*: true
            }

            Label {
                text: qsTr("12345678")
                // format*: %.1f
                // live*: true
                // property*: /environment/visibility-m
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Relative dust density")
            }

            Slider {
                id: air_pollution
                // property*: /environment/air-pollution-norm
                // binding*: " dialog-apply air_pollution "
                // live*: true
            }

            Label {
                text: qsTr("12345678")
                // format*: %.1f
                // live*: true
                // property*: /environment/air-pollution-norm
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignRight

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Cloudcover")
            }

            Slider {
                id: cloudcover
                // property*: /earthview/cloudcover-bias
                // binding*: " dialog-apply cloudcover "
                // live*: true
            }

            Label {
                text: qsTr("12345678")
                // format*: %.1f
                // live*: true
                // property*: /earthview/cloudcover-bias
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 1

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Cancel")

            onClicked: {
                earthviewDialog.closed(earthviewDialog.id);
            }
        }
    } // buttons
}
