import QtQuick 2.9
import org.flightgear.UI 1.0

Item {
    id: root

    property string label: "" 
    property alias description: descriptionText.text

    Column {


        StyledText {
            id: descriptionText
            x: Style.margin
        }
        Text {
            x: 10 // left margin
        }
    }

    // bottom divider
}