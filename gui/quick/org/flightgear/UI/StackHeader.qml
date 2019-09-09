import QtQuick 2.4
import org.flightgear.UI 1.0

Item  {
    id: root
    width: parent.width
    height: header.height + Style.margin * 2
    property var controller;

    signal search;

    Row {
        id: header
        y: Style.margin
        width: parent.width
        height: headerText.height
        spacing: Style.margin

        // Back button+text when drilled-down
        Text {
            id: backText
            text: (controller != null) ? controller.previousPageTitle : ""
            font.pixelSize: Style.headingFontPixelSize
            visible: backButton.visible
        }

        Button {
            id: backButton
            text: qsTr("<<")
            visible: (controller != null) && controller.canGoBack
            onClicked: {
                controller.pop();
            }
        }

        // make this breadcrumbs when we have multiple pages
        Text {
            id: headerText
            text: (controller != null) ? controller.currentPageTitle : ""
            font.pixelSize: Style.headingFontPixelSize
        }

    } // of main row

    SearchButton {
        id: search
        width: Style.strutSize * 4
        anchors.right: parent.right
        anchors.rightMargin: Style.margin
        anchors.verticalCenter: parent.verticalCenter
        autoSubmitTimeout: 250
        onSearch: {
            root.search(term);
        }
    }
}
