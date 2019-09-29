import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: scenarioDialog

    width: 500
    height: 300
    position: Qt.point(80, 80)

    windowId: scenarioDialog.id
    title: "AI Traffic and Scenario Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var dlg_root = cmdarg();

        //         var isEnabledScenario = func(scenario) {
        //             foreach( var n; props.globals.getNode("sim/ai",1).getChildren("scenario") )
        //                 if( n.getValue() == scenario )
        //                     return 1;
        //             return 0;
        //         };

        //         var columns = [ "left-column", "right-column" ];

        //         var processScenario = func(nr, rootN) {
        //             var descriptionN = rootN.getNode("description");
        //             var nameN = rootN.getNode("name");
        //             var description = descriptionN != nil ? descriptionN.getValue() : "";
        //             var scenarioId = rootN.getNode("id").getValue();

        //             var propertyRoot = props.globals.getNode("sim/gui/dialogs/scenario",1).getChild( "scenario", nr, 1 );
        //             propertyRoot.getNode("selected",1).setBoolValue(isEnabledScenario(scenarioId));
        //             propertyRoot.getNode("name",1).setValue(scenarioId);

        //             var group = gui.findElementByName( dlg_root, columns[math.mod(nr,2)] ).getChild("group", nr, 1 );
        //             group.getNode("layout",1).setValue("hbox");
        //             var cb = group.getNode("checkbox",1);
        //             cb.getNode("property",1).setValue(propertyRoot.getNode("selected").getPath());
        //             var label = nameN.getValue();

        //             cb.getNode("label",1).setValue(label);
        //             cb.getNode("name",1).setValue(scenarioId);

        //             var applyBind = cb.addChild("binding", 0);
        //             applyBind.getNode("command", 1).setValue("dialog-apply");

        //             var bind = cb.addChild("binding", 1);
        //             bind.getNode("command", 1).setValue("load-scenario");
        //             bind.getNode("name", 1).setValue(scenarioId);
        //             bind.getNode("load-property", 1).setValue(propertyRoot.getNode("selected").getPath());

        //             #cb.getNode("enable/property",1).setValue("/sim/ai/scenarios-enabled");

        //             group.getNode("empty",1).getNode("stretch",1).setValue("true");
        //         }

        //         var path = getprop("/sim/fg-root") ~ "/AI";
        //         var i = -1;
        //         foreach(var s; props.globals.getNode("sim/ai/scenarios",1).getChildren("scenario"))
        //         processScenario( i+=1, s );
        //     ]]></open>

        //     <close><![CDATA[
        //     ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Item {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    Label {
                        text: qsTr(" ")
                    }
                } // ColumnLayout
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("Enable AI traffic")
                id: enable_ai_traffic
                // property*: /sim/traffic-manager/enabled
                // live*: true
                // binding*: " dialog-apply enable-ai-traffic "
            }
        } // RowLayout

        Label {
            text: qsTr("")
        }

        Label {
            text: qsTr("Aerodynamic interaction")
        }

        HorizontalLine {}

        GridLayout {
            width: parent.width
            //horizontalAlignment: Text.AlignLeft

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Enable AI aerodynamic wake")
            }

            CheckBox {
                id: enable_ai_wake
                //horizontalAlignment: Text.AlignLeft
                // property*: /fdm/ai-wake/enabled
                // binding*: " dialog-apply enable-ai-wake "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Max. radius of interaction (nm)")
            }

            TextInput {
                // property*: /fdm/ai-wake/max-radius-nm
                // binding*: " dialog-apply "
            }
        } // GridLayout

        Label {
            text: qsTr("")
        }

        Label {
            text: qsTr("Choose active scenario(s) ")
        }

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Item {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                } // ColumnLayout
                // padding*: 1

                Label {
                    text: qsTr(" ")
                }
            }

            Item {
                Layout.fillWidth: true
                id: left_column

                ColumnLayout {
                    width: parent.width
                } // ColumnLayout
            }

            Item {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                } // ColumnLayout
                id: right_column
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                scenarioDialog.closed(scenarioDialog.id);
            }
        }
    } // buttons
}
