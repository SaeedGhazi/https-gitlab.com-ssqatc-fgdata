import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0


SettingControl
{
    id: root

    property bool enabled: true
    property int value: toggle.enabled ? volumeSlider.value : 0

    implicitHeight: controlsRow.height + Style.margin + description.height

    Row {
        id: controlsRow
        width: root.width
        spacing: Style.margin
        height: Math.max(toggle.implictHeight, volumeSlider.implicitHeight)

        ToggleSwitch {
            id: toggle
            label: root.label
            enabled: root.enabled
        }

        Slider {
            id: volumeSlider
            enabled: toggle.enabled && toggle.checked
            width: 200
        }
    }


    SettingDescription {
        id: description
        enabled: root.enabled
        text: root.description
        anchors.top: controlsRow.bottom
        anchors.topMargin: Style.margin
        width: root.width
    }

    function apply()
    {

    }

    function setValue(newValue)
    {
        volumeSlider.setValue(newValue)
    }

}
