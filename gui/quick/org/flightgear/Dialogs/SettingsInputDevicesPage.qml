import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item
{
    id: inputDevicesPage

    Flickable
    {
        id: flick
        contentHeight: contentColumn.height
        flickableDirection: Flickable.VerticalFlick
        height: parent.height
        width: parent.width - scrollbar.width

        Column
        {
            id: contentColumn
            width: parent.width

            Item {
                // top margin
                width: parent.width
                height: Style.margin
            }

            Repeater {
                // model of all the views we know about
            }

        } // of layout column
    } // of the flickable

    Scrollbar {
        id: scrollbar
        anchors.right: parent.right
        height: parent.height
        flickable: flick
        visible: flick.contentHeight > flick.height
    }
}

