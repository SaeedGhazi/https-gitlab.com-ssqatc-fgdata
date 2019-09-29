import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: localWeatherDialog

    width: 800
    height: 600
    position: Qt.point(80, 80)

    windowId: localWeatherDialog.id
    title: "Local Weather"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            x: 10
            y: 570
            text: qsTr("Place a single cloud")
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 550

            Label {
                x: 10
                y: 0
                text: qsTr("Type")
            }

            Label {
                x: 130
                y: 0
                text: qsTr("subtype")
            }

            Label {
                x: 203
                y: 0
                text: qsTr("lat (deg)")
            }

            Label {
                x: 276
                y: 0
                text: qsTr("lon (deg)")
            }

            Label {
                x: 349
                y: 0
                text: qsTr("alt (ft)")
            }

            Label {
                x: 422
                y: 0
                text: qsTr("dir (deg)")
            }
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 525

            ComboBox {
                x: 10
                y: 0
                width: 117
                height: 25
                // live*: true
                // property*: /local-weather/tmp/scloud-type
                // binding*: " dialog-apply "
            }

            ComboBox {
                x: 130
                y: 0
                width: 70
                height: 25
                // live*: true
                // property*: /local-weather/tmp/scloud-subtype
                // binding*: " dialog-apply "
            }

            TextInput {
                x: 203
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/scloud-lat
            }

            TextInput {
                x: 276
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/scloud-lon
            }

            TextInput {
                x: 349
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/scloud-alt
            }

            TextInput {
                x: 422
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/scloud-dir
            }

            Button {
                x: 500
                y: 0
                text: qsTr("Place")
                // default*: true
                // equal*: true
                // binding*: " dialog-apply "
                // binding*: " nasal local_weather.single_cloud_wrapper() "
            }
        }

        Label {
            x: 10
            y: 485
            text: qsTr("Place a cloud streak")
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 465

            Label {
                x: 10
                y: 0
                text: qsTr("Type")
            }

            Label {
                x: 130
                y: 0
                text: qsTr("alt. (ft)")
            }

            Label {
                x: 203
                y: 0
                text: qsTr("number x")
            }

            Label {
                x: 276
                y: 0
                text: qsTr("Delta x (m)")
            }

            Label {
                x: 349
                y: 0
                text: qsTr("x edge")
            }

            Label {
                x: 422
                y: 0
                text: qsTr("number y")
            }

            Label {
                x: 495
                y: 0
                text: qsTr("Delta y (m)")
            }

            Label {
                x: 568
                y: 0
                text: qsTr("y edge")
            }

            Label {
                x: 641
                y: 0
                text: qsTr("Dir. (deg)")
            }

            Label {
                x: 714
                y: 0
                text: qsTr("Triang.")
            }
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 440

            ComboBox {
                x: 10
                y: 0
                width: 117
                height: 25
                // live*: true
                // property*: /local-weather/tmp/cloud-type
                // binding*: " dialog-apply "
            }

            TextInput {
                x: 130
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/alt
            }

            TextInput {
                x: 203
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/nx
            }

            TextInput {
                x: 276
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/xoffset
            }

            TextInput {
                x: 349
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/xedge
            }

            TextInput {
                x: 422
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/ny
            }

            TextInput {
                x: 495
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/yoffset
            }

            TextInput {
                x: 568
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/yedge
            }

            TextInput {
                x: 641
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/dir
            }

            TextInput {
                x: 714
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/tri
            }
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 410

            Label {
                x: 10
                y: 0
                text: qsTr("rand. x (m)")
            }

            TextInput {
                x: 90
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/rnd-pos-x
            }

            Label {
                x: 165
                y: 0
                text: qsTr("rand. y (m)")
            }

            TextInput {
                x: 245
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/rnd-pos-y
            }

            Label {
                x: 320
                y: 0
                text: qsTr("rand. alt. (ft)")
            }

            TextInput {
                x: 410
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/rnd-alt
            }

            Button {
                x: 490
                y: 0
                text: qsTr("Draw streak")
                // default*: true
                // equal*: true
                // binding*: " dialog-apply "
                // binding*: " nasal local_weather.streak_wrapper() "
            }
        }

        Label {
            x: 10
            y: 370
            text: qsTr("Start the convective system")
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 345

            Label {
                x: 10
                y: 0
                text: qsTr("strength")
            }

            TextInput {
                x: 90
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/conv-strength
            }

            Label {
                x: 165
                y: 0
                text: qsTr("alt (ft)")
            }

            TextInput {
                x: 245
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/conv-alt
            }

            Label {
                x: 320
                y: 0
                text: qsTr("size (km)")
            }

            TextInput {
                x: 410
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/conv-size
            }

            Button {
                x: 490
                y: 0
                text: qsTr("Create")
                // default*: true
                // equal*: true
                // binding*: " dialog-apply "
                // binding*: " nasal local_weather.convection_wrapper() "
            }
        }

        Label {
            x: 10
            y: 305
            text: qsTr("Create barrier clouds")
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 280

            Label {
                x: 10
                y: 0
                text: qsTr("alt. (ft)")
            }

            TextInput {
                x: 80
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/bar-alt
            }

            Label {
                x: 155
                y: 0
                text: qsTr("number")
            }

            TextInput {
                x: 225
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/bar-n
            }

            Label {
                x: 300
                y: 0
                text: qsTr("wind (deg)")
            }

            TextInput {
                x: 370
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/bar-dir
            }

            Label {
                x: 445
                y: 0
                text: qsTr("dist (km)")
            }

            TextInput {
                x: 515
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/bar-dist
            }

            Label {
                x: 590
                y: 0
                text: qsTr("size (km)")
            }

            TextInput {
                x: 660
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/bar-size
            }

            Button {
                x: 735
                y: 0
                text: qsTr("Create")
                // default*: true
                // equal*: true
                // binding*: " dialog-apply "
                // binding*: " nasal local_weather.barrier_wrapper() "
            }
        }

        Label {
            x: 10
            y: 240
            text: qsTr("Place a cloud layer")
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 220

            Label {
                x: 10
                y: 0
                text: qsTr("Type")
            }

            Label {
                x: 130
                y: 0
                text: qsTr("rad. x (km)")
            }

            Label {
                x: 203
                y: 0
                text: qsTr("rad. y (km) ")
            }

            Label {
                x: 276
                y: 0
                text: qsTr("dir (deg)")
            }

            Label {
                x: 349
                y: 0
                text: qsTr("alt (ft)")
            }

            Label {
                x: 422
                y: 0
                text: qsTr("thick. (ft)")
            }

            Label {
                x: 495
                y: 0
                text: qsTr("density")
            }

            Label {
                x: 568
                y: 0
                text: qsTr("edge")
            }

            Label {
                x: 641
                y: 0
                text: qsTr("rain flag")
            }

            Label {
                x: 714
                y: 0
                text: qsTr("rain dens.")
            }
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 195

            ComboBox {
                x: 10
                y: 0
                width: 117
                height: 25
                // live*: true
                // property*: /local-weather/tmp/layer-type
                // binding*: " dialog-apply "
            }

            TextInput {
                x: 130
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-rx
            }

            TextInput {
                x: 203
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-ry
            }

            TextInput {
                x: 276
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-phi
            }

            TextInput {
                x: 349
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-alt
            }

            TextInput {
                x: 422
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-thickness
            }

            TextInput {
                x: 495
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-density
            }

            TextInput {
                x: 568
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-edge
            }

            TextInput {
                x: 641
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-rain-flag
            }

            TextInput {
                x: 714
                y: 0
                width: 70
                height: 25
                // property*: /local-weather/tmp/layer-rain-density
            }
        }

        Button {
            x: 10
            y: 160
            text: qsTr("Create")
            // default*: true
            // equal*: true
            // binding*: " dialog-apply "
            // binding*: " nasal local_weather.layer_wrapper() "
        }

        Label {
            x: 10
            y: 130
            text: qsTr("Make a cloud box")
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 110

            Label {
                x: 10
                y: 0
                text: qsTr("x [m]")
            }

            Label {
                x: 80
                y: 0
                text: qsTr("y [m]")
            }

            Label {
                x: 150
                y: 0
                text: qsTr("alt [ft]")
            }

            Label {
                x: 220
                y: 0
                text: qsTr("number")
            }

            Label {
                x: 290
                y: 0
                text: qsTr("core frac.")
            }

            Label {
                x: 360
                y: 0
                text: qsTr("core offset")
            }

            Label {
                x: 430
                y: 0
                text: qsTr("core height")
            }

            Label {
                x: 500
                y: 0
                text: qsTr("core num.")
            }

            Label {
                x: 570
                y: 0
                text: qsTr("bottom size")
            }

            Label {
                x: 640
                y: 0
                text: qsTr("bot. height")
            }

            Label {
                x: 710
                y: 0
                text: qsTr("bot. num.")
            }
        }

        Item {
            Layout.fillWidth: true
            x: 0
            y: 85

            TextInput {
                x: 10
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-x-m
            }

            TextInput {
                x: 80
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-y-m
            }

            TextInput {
                x: 150
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-alt-ft
            }

            TextInput {
                x: 220
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-n
            }

            TextInput {
                x: 290
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-core-fraction
            }

            TextInput {
                x: 360
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-core-offset
            }

            TextInput {
                x: 430
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-core-height
            }

            TextInput {
                x: 500
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-core-n
            }

            TextInput {
                x: 570
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-bottom-fraction
            }

            TextInput {
                x: 640
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-bottom-thickness
            }

            TextInput {
                x: 710
                y: 0
                width: 65
                height: 25
                // property*: /local-weather/tmp/box-bottom-n
            }
        }

        Button {
            x: 10
            y: 50
            text: qsTr("Create")
            // default*: true
            // equal*: true
            // binding*: " dialog-apply "
            // binding*: " nasal local_weather.box_wrapper() "
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            x: 0
            y: 0
            text: qsTr("OK")
            // binding*: " dialog-apply "
            // binding*: " reinit environment "

            onClicked: {
                localWeatherDialog.closed(localWeatherDialog.id);
            }
        }

        Button {
            x: 80
            y: 0
            text: qsTr("Clear clouds")
            // binding*: " nasal local_weather.clear_all() "
        }

        Button {
            x: 200
            y: 0
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                localWeatherDialog.closed(localWeatherDialog.id);
            }
        }
    } // buttons
}
