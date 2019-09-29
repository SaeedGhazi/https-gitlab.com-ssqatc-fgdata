import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: environmentSettingsDialog

    width: 450
    height: 400
    position: Qt.point(80, 80)

    windowId: environmentSettingsDialog.id
    title: "Environment Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 3
            // padding*: 5

            Label {
                text: qsTr(" Ground Textures:")
                horizontalAlignment: Text.AlignLeft
            }

            ComboBox {
                id: season
                width: 90
                //horizontalAlignment: Text.AlignLeft
                // live*: true
                // property*: /sim/startup/season
                // binding*: " dialog-apply season "
            }

            Button {
                text: qsTr("Reload Scenery")
                // binding*: " reinit scenery "
            }
        } // GridLayout

        HorizontalLine {}

        Label {
            text: qsTr(" Ground conditions (require shader effects)")
        }

        CheckBox {
            text: qsTr(" Set maximum snow level from METAR")
            id: metar_snow
            // property*: /environment/params/metar-updates-snow-level
            // binding*: " dialog-apply metar-snow "
        }

        GridLayout {
            width: parent.width
            columns: 5

            Label {
                text: qsTr(" Snow line")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("-425m")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: snow_level
                width: 100
                // live*: true
                // property*: /environment/snow-level-m
                // binding*: " dialog-apply snow-level "
            }

            Label {
                text: qsTr("7500m")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("12345678")
                // format*: %.fm
                // live*: true
                // property*: /environment/snow-level-m
            }

            Label {
                text: qsTr(" Snow thickness")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("thin")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: snow_thickness
                width: 100
                // live*: true
                // property*: /environment/surface/snow-thickness-factor
                // binding*: " dialog-apply snow-thickness "
            }

            Label {
                text: qsTr("thick")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }

            Label {
                text: qsTr(" Ice cover")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("none")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: ice_cover
                width: 100
                // live*: true
                // property*: /environment/sea/surface/ice-cover
                // binding*: " dialog-apply ice-cover "
            }

            Label {
                text: qsTr("thick")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }

            Label {
                text: qsTr(" Dust cover")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("none")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: dust_level
                width: 100
                // live*: true
                // property*: /environment/surface/dust-cover-factor
                // binding*: " dialog-apply dust-level "
            }

            Label {
                text: qsTr("dusty")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }

            Label {
                text: qsTr(" Wetness")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dry")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: wetness
                width: 100
                // live*: true
                // property*: /environment/surface/wetness-set
                // binding*: " dialog-apply wetness "
            }

            Label {
                text: qsTr("wet")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }

            Label {
                text: qsTr(" Vegetation")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("none")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: lichen_level
                width: 100
                // live*: true
                // property*: /environment/surface/lichen-cover-factor
                // binding*: " dialog-apply lichen-level "
            }

            Label {
                text: qsTr("mossy")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }

            Label {
                text: qsTr(" Season (experimental)")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("summer")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: sldrSeason
                width: 100
                // live*: true
                // property*: /environment/season
                // binding*: " dialog-apply season "
            }

            Label {
                text: qsTr("late autumn")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }

            Label {
                text: qsTr(" Aurora Borealis")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("weak")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: aurora
                width: 100
                // live*: true
                // property*: /environment/aurora/set-strength
                // binding*: " dialog-apply aurora "
            }

            Label {
                text: qsTr("strong")
                horizontalAlignment: Text.AlignLeft
                Layout.columnSpan: 2
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                environmentSettingsDialog.closed(environmentSettingsDialog.id);
            }
        }
    } // buttons
}
