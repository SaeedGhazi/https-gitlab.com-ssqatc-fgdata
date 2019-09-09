import QtQuick 2.4
import org.flightgear.UI 1.0

Item {
    id: root

    signal accept
    signal reject

    implicitWidth: parent.implicitWidth
    height: okayButton.implicitHeight + (Style.margin * 2)
    property alias canOkay: okayButton.enabled

    Row {
        anchors {
            margins: Style.margin
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: okayButton.implicitHeight

        Button {
            id: okayButton
            text: qsTr("Okay")
            onClicked: root.accept();
        }


        Button {
            qsTr("Cancel")
            onClicked: root.reject();
        }
    }

}