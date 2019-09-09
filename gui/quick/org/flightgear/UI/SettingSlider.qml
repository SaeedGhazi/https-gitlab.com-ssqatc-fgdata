import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0

SettingControl
{
    id: root

    property bool enabled: true
    property alias value: slider.value
    property alias label: slider.label
    property alias max: slider.max

    implicitHeight: slider.height + Style.margin + description.height

    Slider {
        id: slider
        enabled:root.enabled
        width: root.width
    }

    SettingDescription {
        id: description
        enabled: root.enabled
        text: root.description
        anchors.top: slider.bottom
        anchors.topMargin: Style.margin
        width: root.width
    }

    function apply()
    {

    }

    function setValue(newValue)
    {
        slider.setValue(newValue)
    }
}
