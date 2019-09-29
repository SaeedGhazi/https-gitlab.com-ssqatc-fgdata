import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: localWeatherWindsDialog

    width: 640
    height: 200
    position: Qt.point(80, 80)

    windowId: localWeatherWindsDialog.id
    title: "Wind Configuration"

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
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("")
            }

            Label {
                text: qsTr("Specify Aloft Wind Layers:")
            }

            Label {
                text: qsTr(" Lat:")
            }

            TextInput {
                width: 80
                // property*: /local-weather/tmp/ipoint-latitude-deg
            }

            Label {
                text: qsTr(" Lon:")
            }

            TextInput {
                width: 80
                // property*: /local-weather/tmp/ipoint-longitude-deg
            }
        } // RowLayout

        GridLayout {
            width: parent.width
            columns: 10

            Label {
                width: 50
                text: qsTr(" ")
            }

            Label {
                width: 50
                text: qsTr(" 0 ")
            }

            Label {
                width: 50
                text: qsTr("FL50")
            }

            Label {
                width: 50
                text: qsTr("FL100")
            }

            Label {
                width: 50
                text: qsTr("FL180")
            }

            Label {
                width: 50
                text: qsTr("FL240")
            }

            Label {
                width: 50
                text: qsTr("FL300")
            }

            Label {
                width: 50
                text: qsTr("FL340")
            }

            Label {
                width: 50
                text: qsTr("FL390")
            }

            Label {
                width: 50
                text: qsTr("FL450")
            }

            Label {
                text: qsTr("Direction")
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL0-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL50-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL100-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL180-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL240-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL300-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL340-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL390-wind-from-heading-deg
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL450-wind-from-heading-deg
            }

            Label {
                text: qsTr("Speed (kt)")
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL0-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL50-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL100-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL180-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL240-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL300-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL340-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL390-windspeed-kt
            }

            TextInput {
                width: 50
                // property*: /local-weather/tmp/FL450-windspeed-kt
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr(" OK ")
                // equal*: true
                // binding*: " dialog-apply "
                onClicked: {
                    localWeatherWindsDialog.closed(localWeatherWindsDialog.id);
                }
            }

            Button {
                text: qsTr("Set Waypoint")
                // binding*: " dialog-apply "
                // binding*: " nasal if (local_weather.wind_model_flag == 5) {local_weather.set_aloft_wrapper();} "
            }

            Button {
                text: qsTr("Clear Waypoints")
                // binding*: " nasal props.globals.getNode("local-weather/interpolation", 1).removeChildren("wind"); setprop("/local-weather/interpolation/ipoint-number",0); "
            }

            Button {
                text: qsTr("Cancel")
                // default*: true
                // equal*: true
                // key*: qsTr("Esc")
                onClicked: {
                    localWeatherWindsDialog.closed(localWeatherWindsDialog.id);
                }
            }

            Label {
                text: qsTr(" Waypoints:")
            }

            Label {
                text: qsTr("MMMM")
                // live*: true
                // property*: /local-weather/interpolation/ipoint-number
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

}
