import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: sandbox_toolbar
    width: 600
    height: 500

    Rectangle {
        anchors.fill: parent
        border.width: 1
        border.color: Style.frameColor
        color: Style.windowColor
        opacity: Style.panelOpacity
    }

    GridLayout {
        columnSpacing: 10
        rows: 15
        flow: GridLayout.TopToBottom
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.fillWidth: true

        Button {
            text: qsTr("Air")
            onClicked: {
                air_dialog.visible = !air_dialog.visible
            }
        }

        Button {
            text: qsTr("Aircraft")
            onClicked: {
                aircraft_dialog.visible = !aircraft_dialog.visible
            }
        }

        Button {
            text: qsTr("ALS Filters")
            onClicked: {
                als_filters_dialog.visible = !als_filters_dialog.visible;
            }
        }

        Button {
            text: qsTr("ATC")
            onClicked: {
                atc_dialog.visible = !atc_dialog.visible;
            }
        }

        Button {
            text: qsTr("ATC AI")
            onClicked: {
                atc_ai_dialog.visible = !atc_ai_dialog.visible;
            }
        }

        Button {
            text: qsTr("ATC Frequencies")
            onClicked: {
                atc_freq_dialog.visible = !atc_freq_dialog.visible;
            }
        }

        Button {
            text: qsTr("Button Axis")
            onClicked: {
                button_axis_dialog.visible = !button_axis_dialog.visible;
            }
        }

        Button {
            text: qsTr("Button Config")
            onClicked: {
                button_config_dialog.visible = !button_config_dialog.visible;
            }
        }

        Button {
            text: qsTr("Eisenhower")
            onClicked: {
                carrier_eisenhower_dialog.visible = !carrier_eisenhower_dialog.visible;
            }
        }

        Button {
            text: qsTr("Nimitz")
            onClicked: {
                carrier_nimitz_dialog.visible = !carrier_nimitz_dialog.visible;
            }
        }

        Button {
            text: qsTr("San Antonio")
            onClicked: {
                carrier_sanantonio_dialog.visible = !carrier_sanantonio_dialog.visible;
            }
        }

        Button {
            text: qsTr("Truman")
            onClicked: {
                carrier_truman_dialog.visible = !carrier_truman_dialog.visible;
            }
        }

        Button {
            text: qsTr("Vinson")
            onClicked: {
                carrier_vinson_dialog.visible = !carrier_vinson_dialog.visible;
            }
        }

        Button {
            text: qsTr("Chat")
            onClicked: {
                chat_dialog.visible = !chat_dialog.visible;
            }
        }

        Button {
            text: qsTr("File Select")
            onClicked: {
                file_select_dialog.visible = !file_select_dialog.visible;
            }
        }

        Button {
            text: qsTr("FPS")
            onClicked: {
                fps_dialog.visible = !fps_dialog.visible;
            }
        }

        Button {
            text: qsTr("Frame Latency")
            onClicked: {
                frame_latency_dialog.visible = !frame_latency_dialog.visible;
            }
        }

        Button {
            text: qsTr("Jetways Adjust")
            onClicked: {
                jetways_adjust_dialog.visible = !jetways_adjust_dialog.visible;
            }
        }

        Button {
            text: qsTr("Joystick Info")
            onClicked: {
                joystick_info_dialog.visible = !joystick_info_dialog.visible;
            }
        }

        Button {
            text: qsTr("Local Weather Config")
            onClicked: {
                local_weather_config_dialog.visible = !local_weather_config_dialog.visible;
            }
        }

        Button {
            text: qsTr("Local Weather Tiles")
            onClicked: {
                local_weather_tiles_dialog.visible = !local_weather_tiles_dialog.visible;
            }
        }

        Button {
            text: qsTr("Local Weather Winds")
            onClicked: {
                local_weather_winds_dialog.visible = !local_weather_winds_dialog.visible;
            }
        }

        Button {
            text: qsTr("LSO View")
            onClicked: {
                lso_view_dialog.visible = !lso_view_dialog.visible;
            }
        }

        Button {
            text: qsTr("Message")
            onClicked: {
                message_dialog.visible = !message_dialog.visible;
            }
        }

        Button {
            text: qsTr("Model-Cockpit View")
            onClicked: {
                model_cockpit_view_dialog.visible = !model_cockpit_view_dialog.visible;
            }
        }

        Button {
            text: qsTr("Model-View")
            onClicked: {
                model_view_dialog.visible = !model_view_dialog.visible;
            }
        }

        Button {
            text: qsTr("Model-View Select")
            onClicked: {
                model_view_select_dialog.visible = !model_view_select_dialog.visible;
            }
        }

        Button {
            text: qsTr("NTPS Target Task")
            onClicked: {
                ntps_target_task_dialog.visible = !ntps_target_task_dialog.visible;
            }
        }

        Button {
            text: qsTr("Overlay Select")
            onClicked: {
                overlay_select_dialog.visible = !overlay_select_dialog.visible;
            }
        }

        Button {
            text: qsTr("Popup")
            onClicked: {
                popup_dialog.visible = !popup_dialog.visible;
            }
        }

        Button {
            text: qsTr("Property Browser")
            onClicked: {
                property_browser_dialog.visible = !property_browser_dialog.visible;
            }
        }

        Button {
            text: qsTr("Pushback")
            onClicked: {
                pushback_dialog.visible = !pushback_dialog.visible;
            }
        }

        Button {
            text: qsTr("Rembrandt")
            onClicked: {
                rembrandt_dialog.visible = !rembrandt_dialog.visible;
            }
        }

        Button {
            text: qsTr("Scenery Loading")
            onClicked: {
                scenery_loading_dialog.visible = !scenery_loading_dialog.visible;
            }
        }

        Button {
            text: qsTr("Seaport")
            onClicked: {
                seaport_dialog.visible = !seaport_dialog.visible;
            }
        }

        Button {
            text: qsTr("Shaders")
            onClicked: {
                shaders_dialog.visible = !shaders_dialog.visible;
            }
        }

        Button {
            text: qsTr("Shaders Lightfield")
            onClicked: {
                shaders_lightfield_dialog.visible = !shaders_lightfield_dialog.visible;
            }
        }

        Button {
            text: qsTr("Volcano Beerenberg")
            onClicked: {
                volcano_beerenberg_dialog.visible = !volcano_beerenberg_dialog.visible;
            }
        }

        Button {
            text: qsTr("Volcano Etna")
            onClicked: {
                volcano_etna_dialog.visible = !volcano_etna_dialog.visible;
            }
        }

        Button {
            text: qsTr("Volcano Eyjafjallajokull")
            onClicked: {
                volcano_eyjafjallajokull_dialog.visible = !volcano_eyjafjallajokull_dialog.visible;
            }
        }

        Button {
            text: qsTr("Volcano Katla")
            onClicked: {
                volcano_katla_dialog.visible = !volcano_katla_dialog.visible;
            }
        }

        Button {
            text: qsTr("Volcano Kilauea")
            onClicked: {
                volcano_kilauea_dialog.visible = !volcano_kilauea_dialog.visible;
            }
        }

        Button {
            text: qsTr("Volcano Stromboli")
            onClicked: {
                volcano_stromboli_dialog.visible = !volcano_stromboli_dialog.visible;
            }
        }

        Button {
            text: qsTr("Weather Configuration")
            onClicked: {
                weather_configuration_dialog.visible = !weather_configuration_dialog.visible;
            }
        }

        Button {
            text: qsTr("Winds")
            onClicked: {
                winds_dialog.visible = !winds_dialog.visible;
            }
        }

        Button {
            text: qsTr("")
        }
    }
}

