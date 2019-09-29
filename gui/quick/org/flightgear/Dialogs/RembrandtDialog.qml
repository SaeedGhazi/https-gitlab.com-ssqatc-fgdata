import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: rembrandtDialog

    width: 640
    height: 800
    position: Qt.point(80, 80)

    windowId: rembrandtDialog.id
    title: "Rembrandt"

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
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("")
            }
        } // RowLayout

        GridLayout {
            width: parent.width
            columns: 4

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Bloom")
                id: bloom
                // property*: /sim/rendering/rembrandt/bloom
                // binding*: " dialog-apply bloom "
            }

            Label {
                text: qsTr("Strength")
            }

            Slider {
                id: bloom_strength
                // property*: /sim/rendering/rembrandt/bloom-strength
                // binding*: " dialog-apply bloom-strength "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/bloom-strength
            }

            CheckBox {
                text: qsTr(" Ambient occlusion")
                id: occlusion
                // property*: /sim/rendering/rembrandt/ambient-occlusion
                // binding*: " dialog-apply occlusion "
            }

            Label {
                text: qsTr("Strength")
            }

            Slider {
                id: ambient_occlusion_strength
                // property*: /sim/rendering/rembrandt/ambient-occlusion-strength
                // binding*: " dialog-apply ambient-occlusion-strength "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/ambient-occlusion-strength
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("")
            }
        } // RowLayout

        GridLayout {
            width: parent.width
            columns: 2

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Shadows")
                id: shadow
                // property*: /sim/rendering/shadows/enabled
                // binding*: " dialog-apply shadow "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Map size")
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: shadow_map_size
                // property*: /sim/rendering/shadows/map-size
                // binding*: " dialog-apply shadow-map-size "
            }

            Label {
                text: qsTr("")
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Filtering")
            }

            Slider {
                //horizontalAlignment: Text.AlignLeft
                id: filtering
                // property*: /sim/rendering/shadows/filtering
                // binding*: " dialog-apply filtering "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("MMMMMMMMMMMMMMM")
                // format*: %.0f
                // live*: true
                // property*: /sim/rendering/shadows/filtering
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Number of cascades")
            }

            Slider {
                //horizontalAlignment: Text.AlignLeft
                id: filtering2
                // property*: /sim/rendering/shadows/num-cascades
                // binding*: " dialog-apply filtering "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("MMMMMMMMMMMMMMM")
                // format*: %.0f
                // live*: true
                // property*: /sim/rendering/shadows/num-cascades
            }

            Label {
                text: qsTr("")
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Cascades")
            }

            RowLayout {
                width: parent.width
                //horizontalAlignment: Text.AlignLeft

                TextInput {
                    horizontalAlignment: Text.AlignLeft
                    id: shadow_cascade_1
                    width: 50
                    // property*: /sim/rendering/shadows/cascade-far-m
                    // binding*: " dialog-apply shadow-cascade-1 "
                }

                TextInput {
                    id: shadow_cascade_2
                    // visible*: /sim/rendering/shadows/num-cascades 1
                    width: 50
                    // property*: /sim/rendering/shadows/cascade-far-m[1]
                    // binding*: " dialog-apply shadow-cascade-2 "
                }

                TextInput {
                    id: shadow_cascade_3
                    // visible*: /sim/rendering/shadows/num-cascades 2
                    width: 50
                    // property*: /sim/rendering/shadows/cascade-far-m[2]
                    // binding*: " dialog-apply shadow-cascade-3 "
                }

                TextInput {
                    id: shadow_cascade_4
                    // visible*: /sim/rendering/shadows/num-cascades 3
                    width: 60
                    // property*: /sim/rendering/shadows/cascade-far-m[3]
                    // binding*: " dialog-apply shadow-cascade-4 "
                }
            } // RowLayout

            Label {
                Layout.fillWidth: true
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("")
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Night vision")
                id: night_vision
                // property*: /sim/rendering/rembrandt/night-vision
                // binding*: " dialog-apply night-vision "
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("")
            }
        } // RowLayout

        GridLayout {
            width: parent.width
            columns: 5

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Vignette")
                id: vignette
                // property*: /sim/rendering/rembrandt/cinema/vignette
                // binding*: " dialog-apply vignette "
            }

            Label {
                text: qsTr("Inner circle")
            }

            Slider {
                id: inner_circle
                // property*: /sim/rendering/rembrandt/cinema/inner-circle
                // binding*: " dialog-apply inner-circle "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/inner-circle
            }

            Label {
                text: qsTr("Outer circle")
            }

            Slider {
                id: outer_circle
                // property*: /sim/rendering/rembrandt/cinema/outer-circle
                // binding*: " dialog-apply outer-circle "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/outer-circle
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Color shift")
                id: color_shift
                // property*: /sim/rendering/rembrandt/cinema/color-shift
                // binding*: " dialog-apply color-shift "
            }

            Label {
                text: qsTr("Red shift")
            }

            Slider {
                id: red_shift_r
                // property*: /sim/rendering/rembrandt/cinema/red-shift/x
                // binding*: " dialog-apply red-shift-r "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/red-shift/x
            }

            Slider {
                id: red_shift_g
                // property*: /sim/rendering/rembrandt/cinema/red-shift/y
                // binding*: " dialog-apply red-shift-g "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/red-shift/y
            }

            Slider {
                id: red_shift_b
                // property*: /sim/rendering/rembrandt/cinema/red-shift/z
                // binding*: " dialog-apply red-shift-b "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/red-shift/z
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Green shift")
            }

            Slider {
                id: green_shift_r
                // property*: /sim/rendering/rembrandt/cinema/green-shift/x
                // binding*: " dialog-apply green-shift-r "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/green-shift/x
            }

            Slider {
                id: green_shift_g
                // property*: /sim/rendering/rembrandt/cinema/green-shift/y
                // binding*: " dialog-apply green-shift-g "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/green-shift/y
            }

            Slider {
                id: green_shift_b
                // property*: /sim/rendering/rembrandt/cinema/green-shift/z
                // binding*: " dialog-apply green-shift-b "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/green-shift/z
            }

            Label {
                text: qsTr("Blue shift")
            }

            Slider {
                id: blue_shift_r
                // property*: /sim/rendering/rembrandt/cinema/blue-shift/x
                // binding*: " dialog-apply blue-shift-r "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/blue-shift/x
            }

            Slider {
                id: blue_shift_g
                // property*: /sim/rendering/rembrandt/cinema/blue-shift/y
                // binding*: " dialog-apply blue-shift-g "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/blue-shift/y
            }

            Slider {
                id: blue_shift_b
                // property*: /sim/rendering/rembrandt/cinema/blue-shift/z
                // binding*: " dialog-apply blue-shift-b "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/blue-shift/z
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Distortion")
                id: distortion
                // property*: /sim/rendering/rembrandt/cinema/distortion
                // binding*: " dialog-apply distortion "
            }

            Label {
                text: qsTr("Factors")
            }

            Slider {
                id: distortion_factor_x
                // property*: /sim/rendering/rembrandt/cinema/distortion-factor/x
                // binding*: " dialog-apply distortion-factor-x "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/distortion-factor/x
            }

            Slider {
                id: distortion_factor_y
                // property*: /sim/rendering/rembrandt/cinema/distortion-factor/y
                // binding*: " dialog-apply distortion-factor-y "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/distortion-factor/y
            }

            Slider {
                id: distortion_factor_z
                // property*: /sim/rendering/rembrandt/cinema/distortion-factor/z
                // binding*: " dialog-apply distortion-factor-z "
            }

            Label {
                text: qsTr("1234")
                // format*: %.2f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/distortion-factor/z
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Color fringe")
                id: color_fringe
                // property*: /sim/rendering/rembrandt/cinema/color-fringe
                // binding*: " dialog-apply color-fringe "
            }

            Label {
                text: qsTr("Factor")
            }

            Slider {
                id: color_fringe_factor
                // property*: /sim/rendering/rembrandt/cinema/color-fringe-factor
                // binding*: " dialog-apply color-fringe-factor "
            }

            Label {
                text: qsTr("12345")
                // format*: %.3f
                // live*: true
                // property*: /sim/rendering/rembrandt/cinema/color-fringe-factor
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Film wear")
                id: film_wear
                // property*: /sim/rendering/rembrandt/cinema/film-wear
                // binding*: " dialog-apply film-wear "
            }
        } // GridLayout
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
                rembrandtDialog.closed(rembrandtDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // binding*: " dialog-apply "
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                rembrandtDialog.closed(rembrandtDialog.id);
            }
        }

    } // buttons
}
