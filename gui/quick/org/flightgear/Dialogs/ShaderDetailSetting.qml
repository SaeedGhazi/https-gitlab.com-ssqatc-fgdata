import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0


SettingControl
{
    id: root

    property bool enabled: true
    property int value: qualitySlider.value
    property alias label: qualitySlider.label
    property int steps: 5
    property var stepDescriptions: []

    implicitHeight: qualitySlider.height + Style.margin + description.height

    Slider {
        id: qualitySlider
        enabled: root.enabled
        width: root.width

    }

    SettingDescription {
        id: description
        enabled: root.enabled
        text: root.description
        anchors.top: qualitySlider.bottom
        anchors.topMargin: Style.margin
        width: root.width
    }

    function apply()
    {

    }

    function setValue(newValue)
    {
        qualitySlider.setValue(newValue)
    }

}
