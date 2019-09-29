import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: localWeatherConfigDialog

    width: 400
    height: 440
    position: Qt.point(80, 80)

    windowId: localWeatherConfigDialog.id
    title: "Local Weather Config"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        CheckBox {
            x: 5
            y: 400
            width: 15
            height: 15
            text: qsTr("Enable local weather module")
            // property*: /nasal/local_weather/enabled
            // binding*: " dialog-apply "
        }

        Label {
            x: 5
            y: 370
            text: qsTr("Tile creation settings ")
        }

        Label {
            x: 60
            y: 345
            text: qsTr("loading distance")
        }

        Label {
            x: 10
            y: 325
            text: qsTr("25 km")
        }

        Slider {
            x: 60
            y: 325
            width: 100
            height: 20
            // property*: /local-weather/config/distance-to-load-tile-m
            // binding*: " dialog-apply "
        }

        Label {
            x: 170
            y: 325
            text: qsTr("55 km")
        }

        CheckBox {
            x: 250
            y: 355
            width: 15
            height: 15
            text: qsTr("asymmetric range")
            // property*: /local-weather/tmp/asymmetric-tile-loading-flag
            // binding*: " dialog-apply "
        }

        Label {
            x: 220
            y: 325
            text: qsTr("0.5")
        }

        Slider {
            x: 250
            y: 325
            width: 100
            height: 20
            // property*: /local-weather/config/asymmetric-reduction
            // binding*: " dialog-apply "
        }

        Label {
            x: 360
            y: 325
            text: qsTr("1.0")
        }

        Label {
            x: 5
            y: 285
            text: qsTr("Cloud buffering settings")
        }

        Label {
            x: 60
            y: 265
            text: qsTr("visible range")
        }

        Label {
            x: 10
            y: 245
            text: qsTr("15 km")
        }

        Slider {
            x: 60
            y: 245
            width: 100
            height: 20
            // property*: /local-weather/config/clouds-visible-range-m
            // binding*: " dialog-apply "
        }

        Label {
            x: 170
            y: 245
            text: qsTr("45 km")
        }

        CheckBox {
            x: 250
            y: 275
            width: 15
            height: 15
            text: qsTr("asymmetric buffering")
            // property*: /local-weather/config/asymmetric-buffering-flag
            // binding*: " dialog-apply "
        }

        Label {
            x: 220
            y: 245
            text: qsTr("0.2")
        }

        Slider {
            x: 250
            y: 245
            width: 100
            height: 20
            // property*: /local-weather/config/asymmetric-buffering-reduction
            // binding*: " dialog-apply "
        }

        Label {
            x: 360
            y: 245
            text: qsTr("1.0")
        }

        Label {
            x: 170
            y: 215
            text: qsTr("angle:")
        }

        Label {
            x: 220
            y: 215
            text: qsTr("0.0")
        }

        Slider {
            x: 250
            y: 215
            width: 100
            height: 20
            // property*: /local-weather/config/asymmetric-buffering-angle-deg
            // binding*: " dialog-apply "
        }

        Label {
            x: 360
            y: 215
            text: qsTr("180")
        }

        CheckBox {
            x: 30
            y: 185
            width: 15
            height: 15
            text: qsTr("tie range to framerate")
            // property*: /local-weather/config/fps-control-flag
            // binding*: " dialog-apply "
        }

        Label {
            x: 200
            y: 180
            text: qsTr("10 fps")
        }

        Slider {
            x: 250
            y: 180
            width: 100
            height: 20
            // property*: /local-weather/config/target-framerate
            // binding*: " dialog-apply "
        }

        Label {
            x: 355
            y: 180
            text: qsTr("40 fps")
        }

        Label {
            x: 5
            y: 150
            text: qsTr("Weather dynamics settings")
        }

        Label {
            x: 55
            y: 130
            text: qsTr("max. clouds in loop")
        }

        Label {
            x: 10
            y: 110
            text: qsTr("100")
        }

        Slider {
            x: 60
            y: 110
            width: 100
            height: 20
            // property*: /local-weather/config/clouds-in-dynamics-loop
            // binding*: " dialog-apply "
        }

        Label {
            x: 170
            y: 110
            text: qsTr("400")
        }

        Label {
            x: 5
            y: 80
            text: qsTr("Weather pattern scales")
        }

        Label {
            x: 15
            y: 45
            text: qsTr("small")
        }

        Label {
            x: 78
            y: 60
            text: qsTr("airmass")
        }

        Slider {
            x: 60
            y: 45
            width: 100
            height: 20
            // property*: /local-weather/config/large-scale-persistence
            // binding*: " dialog-apply "
        }

        Label {
            x: 165
            y: 45
            text: qsTr("large")
        }

        Label {
            x: 205
            y: 45
            text: qsTr("small")
        }

        Label {
            x: 257
            y: 60
            text: qsTr("cloud patterns")
        }

        Slider {
            x: 250
            y: 45
            width: 100
            height: 20
            // property*: /local-weather/config/small-scale-persistence
            // binding*: " dialog-apply "
        }

        Label {
            x: 355
            y: 45
            text: qsTr("large")
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")
        }
        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "

            onClicked: {
                localWeatherConfigDialog.closed(localWeatherConfigDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                localWeatherConfigDialog.closed(localWeatherConfigDialog.id);
            }
        }

    } // buttons
}
