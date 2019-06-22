import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0


Item
{
    id: root

    property var tabs: []
    property bool equalSizeTabs: false
    property int __selected: 0

    signal requestSelect

    function select(index)
    {
        __selected = index;
        // scroll to it if not visible, and doing scrolling
    }

    clip: true

    // by default, be the natural size for our tab content
    implicitWidth: layoutRow.implicitWidth

    // TODO allow for margin
    readonly property int _equalWidth: root.width / tabs.length

//    ListView {
//       // model is the tabs data
//        layoutDirection: ListView.Horizontal
//        snapMode: ListView.SnapToItem

//        // header
//    }

    Row {
        id: layoutRow

        spacing: Style.margin

        Repeater {
            model: root.tabs

            delegate: TabButton {
                enabled: model.enabled
                active: root.__selected === model.index
                text: model.title
                // tooltip would be nice

                onSelected: root.requestSelect(model.index)
            }
        }
    }
}

