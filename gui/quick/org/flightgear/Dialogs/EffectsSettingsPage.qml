import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item
{
    id: settingsRoot

    Flickable
    {
        id: settingsFlick
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

            ShaderDetailSetting {
                label: qsTr("Urban areas shader");

                description: qsTr("Specify how urban areas such as towns and cities are drawn.")

                steps: 3
                stepDescriptions: [
                    qsTr("Flat appearance for urban areas"),
                    qsTr("Basic urban effect with some artefacts"),
                    qsTr("Complex urban effect with night lighting")
                ]
            }

            ShaderDetailSetting {
                label: qsTr("Vegeation shader");

                description: qsTr("Specify how vegetation such as fields and crops are drawn")

                steps: 5

                // descriptions for each quality level
            }

            ShaderDetailSetting {
                label: qsTr("Crop shader");

                description: qsTr("Specify how fields and agricultural areas are drawn")

                steps: 3
                stepDescriptions: [

                ]
            }

        } // of layout column
    } // of the flickable

    Scrollbar {
        id: scrollbar
        anchors.right: parent.right
        height: parent.height
        flickable: settingsFlick
        visible: settingsFlick.contentHeight > settingsFlick.height
    }
}

