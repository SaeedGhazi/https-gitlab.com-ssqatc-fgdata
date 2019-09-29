import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: alsFiltersDialog

    width: 1024
    height: 300
    position: Qt.point(80, 80)

    windowId: alsFiltersDialog.id
    title: "ALS filter settings (experimental)"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        ColumnLayout {
            width: parent.width

            CheckBox {
                id: master
                text: qsTr("Enable filters")
                // horizontalAlignment: Text.AlignLeft
                // property*: /sim/rendering/als-filters/use-filtering
                // binding*: " property-assign /sim/rendering/als-filters/use-night-vision false "
                // binding*: " property-assign /sim/rendering/als-filters/use-IR-vision false "
                // binding*: " dialog-apply master "
            }

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Normal")
                    horizontalAlignment: Text.AlignLeft
                    // live*: true
                    // property*: /sim/rendering/als-filters/use-normal-filters
                    // binding*: " property-assign /sim/rendering/als-filters/use-night-vision false "
                    // binding*: " property-assign /sim/rendering/als-filters/use-IR-vision false "
                    // binding*: " property-assign /sim/rendering/als-filters/use-normal-filters true "
                }

                Label {
                    text: qsTr("Night vision")
                    horizontalAlignment: Text.AlignLeft
                    // live*: true
                    // property*: /sim/rendering/als-filters/use-night-vision
                    // binding*: " property-assign /sim/rendering/als-filters/use-night-vision true "
                    // binding*: " property-assign /sim/rendering/als-filters/use-normal-filters false "
                    // binding*: " property-assign /sim/rendering/als-filters/use-IR-vision false "
                }

                Label {
                    text: qsTr("Infrared vision")
                    horizontalAlignment: Text.AlignRight
                    // live*: true
                    // property*: /sim/rendering/als-filters/use-IR-vision
                    // binding*: " property-assign /sim/rendering/als-filters/use-IR-vision true "
                    // binding*: " property-assign /sim/rendering/als-filters/use-night-vision false "
                    // binding*: " property-assign /sim/rendering/als-filters/use-normal-filters false "
                }
            } // RowLayout
        } // ColumnLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Brightness")
            }

            GridLayout {
                width: parent.width

                Slider {
                    //horizontalAlignment: Text.AlignRight
                    id: brightness_default
                    // visible*: /sim/rendering/als-filters/use-night-vision /sim/rendering/als-filters/use-IR-vision
                    width: 250
                    // live*: true
                    // property*: /sim/rendering/als-filters/brightness
                    // binding*: " dialog-apply brightness-default "
                }

                Slider {
                    //horizontalAlignment: Text.AlignRight
                    id: brightness_night
                    // visible*: /sim/rendering/als-filters/use-night-vision
                    width: 250
                    // live*: true
                    // property*: /sim/rendering/als-filters/brightness
                    // binding*: " dialog-apply brightness-night "
                }

                Slider {
                    //horizontalAlignment: Text.AlignRight
                    id: brightness_IR
                    // visible*: /sim/rendering/als-filters/use-IR-vision
                    width: 250
                    // live*: true
                    // property*: /sim/rendering/als-filters/brightness
                    // binding*: " dialog-apply brightness-IR "
                }
            } // GridLayout
        } // RowLayout

        RowLayout {
            width: parent.width

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Gamma")
            }

            GridLayout {
                width: parent.width

                Slider {
                    //horizontalAlignment: Text.AlignRight
                    id: gamma_default
                    width: 250
                    // live*: true
                    // property*: /sim/rendering/als-filters/gamma
                    // binding*: " dialog-apply gamma-default "
                }

                Slider {
                    //horizontalAlignment: Text.AlignRight
                    id: gamma_night
                    width: 250
                    // live*: true
                    // property*: /sim/rendering/als-filters/gamma
                    // binding*: " dialog-apply gamma-night "
                }

                Slider {
                    //horizontalAlignment: Text.AlignRight
                    id: gamma_IR
                    width: 250
                    // live*: true
                    // property*: /sim/rendering/als-filters/gamma
                    // binding*: " dialog-apply gamma-IR "
                }
            } // GridLayout
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Reset filters")
            // binding*: " property-assign sim/rendering/als-filters/brightness 1.0 "
            // binding*: " property-assign sim/rendering/als-filters/gamma 0.0 "
        }

        Button {
            text: qsTr("Back")
            // binding*: " dialog-show rendering "
            onClicked: {
                alsFiltersDialog.closed(alsFiltersDialog.id);
            }
        }

        Button {
            text: qsTr("Close")

            onClicked: {
                alsFiltersDialog.closed(alsFiltersDialog.id);
            }
        }
    } // buttons
}
