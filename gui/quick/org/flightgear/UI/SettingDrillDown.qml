import QtQuick 2.4
import FlightGear 1.0 as FG
import org.flightgear.UI 1.0


SettingControl {
    id: root
    implicitHeight: drillButton.height

    property alias label: labelText.text
// default target label is our label, but can be overridden
    property string targetLabel: label

    property url drillDownTarget

   // property alias value: root.path // needed for save + restore
   // property string defaultValue: "" // needed for correct save/restore typing

    function apply()
    {
    }

    StyledText {
        id: labelText
        text: root.label
        anchors.verticalCenter: drillButton.verticalCenter
        enabled: root.enabled
    }

    Button {
        id: drillButton
        text: qsTr(">")
        anchors.right: parent.right
        anchors.rightMargin: Style.margin
        enabled: root.enabled

        onClicked: {
            stack.push(root.drillDownTarget, root.targetLabel);
        }
    }

}
