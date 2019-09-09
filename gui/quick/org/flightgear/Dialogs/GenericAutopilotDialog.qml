import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item
{
    id: autopilotRoot
    Column
    {
        anchors {
            margins: Style.margin
            fill: parent
        }


        SettingDescription {
            text: qsTr("Configure the standard autopilot. Each axis (lateral, vertical and speed) "
                + "can be configured seperately.")
        }

        ToggleSwitch {
            label: checked ? qsTr("Autopilot enabled") : qsTr("Autopilot disengaged, click to enable")
        }

        HorizontalLine {}

        TwoColumnLayout
        {


        }

        HorizontalLine {}

        ButtonBox {
            onAccept: WindowManager.close(autopilotRoot.windowId)
            onReject: WindowManager.close(autopilotRoot.windowId)
        }
    } // of top level column
}


