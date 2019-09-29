import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: localWeatherTilesDialog

    width: 640
    height: 800
    position: Qt.point(80, 80)

    windowId: localWeatherTilesDialog.id
    title: "Advanced Weather Configuration"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("")
            }

            ColumnLayout {
                width: parent.width

                Label {
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("General Settings")
                }

                GridLayout {
                    width: parent.width
                    columns: 2

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Tile Selection Mode")
                    }

                    ComboBox {
                        //horizontalAlignment: Text.AlignLeft
                        width: 150
                        // live*: true
                        // property*: /local-weather/tmp/tile-management
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Altitude Offset (ft)")
                    }

                    TextInput {
                        horizontalAlignment: Text.AlignLeft
                        // property*: /local-weather/tmp/tile-alt-offset-ft
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Temperature Offset (C)")
                    }

                    TextInput {
                        horizontalAlignment: Text.AlignLeft
                        // property*: /local-weather/config/temperature-offset-degc
                    }

                    CheckBox {
                        //horizontalAlignment: Text.AlignLeft
                        text: qsTr("Debug Output")
                        // property*: /local-weather/config/debug-output-flag
                        // binding*: " dialog-apply "
                    }

                    CheckBox {
                        //horizontalAlignment: Text.AlignLeft
                        text: qsTr("Terrain Effects")
                        // property*: /local-weather/config/detailed-terrain-interaction-flag
                        // binding*: " dialog-apply "
                    }

                    CheckBox {
                        //horizontalAlignment: Text.AlignLeft
                        text: qsTr("Terrain Presampling")
                        // property*: /local-weather/config/presampling-flag
                        // binding*: " dialog-apply "
                    }
                } // GridLayout
            } // ColumnLayout

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width

                Label {
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr(" Wind Settings")
                }

                RowLayout {
                    width: parent.width

                    Label {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("Wind:")
                    }

                    TextInput {
                        width: 50
                        // property*: /local-weather/tmp/tile-orientation-deg
                    }

                    Label {
                        text: qsTr("degrees at")
                    }

                    TextInput {
                        width: 30
                        // property*: /local-weather/tmp/windspeed-kt
                    }

                    Label {
                        text: qsTr("kts")
                    }

                    Label {
                        Layout.fillWidth: true
                    }
                } // RowLayout

                GridLayout {
                    width: parent.width
                    columns: 3

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Gust Frequency (Hz)")
                    }

                    Slider {
                        // property*: /local-weather/tmp/gust-frequency-hz
                        // binding*: " dialog-apply "
                    }

                    Label {
                        text: qsTr("1234")
                        horizontalAlignment: Text.AlignLeft
                        // format*: %.1f
                        // property*: /local-weather/tmp/gust-frequency-hz
                        // live*: true
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Gust Factor")
                    }

                    Slider {
                        // property*: /local-weather/tmp/gust-relative-strength
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("1234")
                        // format*: %.1f
                        // property*: /local-weather/tmp/gust-relative-strength
                        // live*: true
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr(" Gust Direction Variation")
                    }

                    Slider {
                        // property*: /local-weather/tmp/gust-angular-variation-deg
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("1234")
                        // format*: %.1f
                        // property*: /local-weather/tmp/gust-angular-variation-deg
                        // live*: true
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Wind Model")
                    }

                    ComboBox {
                        // live*: true
                        // property*: /local-weather/config/wind-model
                        // binding*: " dialog-apply "
                    }
                } // GridLayout
            } // ColumnLayout

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width

                Label {
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr(" Thermic and Visibility Settings")
                }

                RowLayout {
                    width: parent.width

                    Label {
                        text: qsTr("")
                    }

                    GridLayout {
                        width: parent.width

                        Label {
                            width: 5
                            text: qsTr("")
                        }

                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            // property*: /local-weather/config/generate-thermal-lift-flag
                            text: qsTr(" Generate Thermals ")
                            // binding*: " dialog-apply "
                        }

                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            text: qsTr(" Realistic Visibility")
                            // property*: /local-weather/config/realistic-visibility-flag
                            // binding*: " dialog-apply "
                        }

                        CheckBox {
                            //horizontalAlignment: Text.AlignLeft
                            text: qsTr(" Cloud Shadows ")
                            // property*: /local-weather/config/generate-cloud-shadows
                            // binding*: " dialog-apply "
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: qsTr(" (needs ALS shaders)")
                        }

                        Label {
                            text: qsTr(" ")
                        }
                    } // GridLayout
                } // RowLayout

                Label {
                    Layout.fillWidth: true
                }

                GridLayout {
                    width: parent.width
                    columns: 4

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr(" Convective Conditions:")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("rough day")
                    }

                    Slider {
                        // property*: /local-weather/config/thermal-properties
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("low convection")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr(" Turbulence:")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("weak")
                    }

                    Slider {
                        // property*: /local-weather/config/turbulence-scale
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("strong")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Ground Haze:")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("thick")
                    }

                    Slider {
                        // property*: /local-weather/config/ground-haze-factor
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("thin")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Air Pollution:")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("clean")
                    }

                    Slider {
                        // property*: /environment/air-pollution-norm
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("smog")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Fog Properties:")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("smooth")
                    }

                    Slider {
                        // property*: /environment/fog-structure
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("structured")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Max. Visibility:")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("20 km")
                    }

                    Slider {
                        // property*: /local-weather/config/aux-max-vis-range-m
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("12345678")
                        // format*: 250 km %.fm
                        // live*: true
                        // property*: /local-weather/config/max-vis-range-m
                    }
                } // GridLayout
            } // ColumnLayout

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("")
            }

            ColumnLayout {
                width: parent.width

                Label {
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Weather Pattern Scales")
                }

                GridLayout {
                    width: parent.width

                    Label {
                        text: qsTr(" ")
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("small")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("large")
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr("Airmass")
                    }

                    Slider {
                        // property*: /local-weather/config/large-scale-persistence
                        // binding*: " dialog-apply "
                    }

                    Label {
                        horizontalAlignment: Text.AlignRight
                        text: qsTr(" Cloud Patterns")
                    }

                    Slider {
                        // property*: /local-weather/config/small-scale-persistence
                        // binding*: " dialog-apply "
                    }
                } // GridLayout
            } // ColumnLayout

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
            text: qsTr(" OK ")
            // binding*: " dialog-apply "

            onClicked: {
                localWeatherTilesDialog.closed(localWeatherTilesDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                localWeatherTilesDialog.closed(localWeatherTilesDialog.id);
            }
        }

        Button {
            text: qsTr("Wind Configuration ...")
            // binding*: " dialog-show local_weather_winds "
            // binding*: " dialog-apply "
        }
    } // buttons
}
