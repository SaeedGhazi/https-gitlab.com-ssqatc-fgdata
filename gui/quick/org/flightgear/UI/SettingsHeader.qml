import QtQuick 2.4
import org.flightgear.UI 1.0

HeaderBox {
    id: root
    property bool haveAdvancedSettings: true
    property alias showAdvanced: advancedToggle.open

    AdvancedSettingsToggle
    {
        id: advancedToggle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        visible: root.haveAdvancedSettings
    }
}