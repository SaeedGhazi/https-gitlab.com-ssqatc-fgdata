import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: tutorialDialog

    width: 640
    height: 550
    position: Qt.point(80, 80)

    windowId: TutorialDialog.id
    title: "Select Tutorial"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
		// <nasal>
		// 	<open>
		// 		var list = cmdarg().getNode("group[2]/group/list");
		// 		var node = props.globals.getNode("/sim/tutorials", 1);
		// 		var tut = node.getChildren("tutorial");
		// 		var current = node.getNode("current-tutorial", 1);

		// 		# fill listbox
		// 		list.removeChildren("value");
		// 		forindex (var i; tut) {
		// 			var name = tut[i].getNode("name");
		// 			if (name == nil) {
		// 				die("tutorial #" ~ i ~ " has no &lt;name>");
		// 			}
		// 			name = name.getValue();
		// 			list.getChild("value", i, 1).setValue(name);
		// 		}

		// 		var select = func {
		// 			var name = current.getValue();
		// 			foreach (var t; tut) {
		// 				if (t.getNode("name").getValue() == name) {
		// 					setprop("/sim/tutorials/current-description",
		// 						string.trim(t.getNode("description").getValue()));
		// 					break;
		// 				}
		// 			}
		// 			fgcommand("dialog-update", props.Node.new({"object-name": "textbox",
		// 					"dialog-name": "tutorial"}));
		// 		}

		// 		if (current.getType() == "NONE" or current.getValue() == "") {
		// 			current.setValue(tut[0].getNode("name").getValue());
		// 			select();
		// 		}
		// 	</open>
		// </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0

            Label {
                width: 7
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("")
                // property*: /sim/tutorials/current-tutorial
                // live*: 1
            }

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            Layout.fillWidth: true

            Label {
                id: textbox
                Layout.fillWidth: true
                width: 600
                height: 480

                Slider {
                    label: "Description"
                    //20
                }
                // live*: 1
                // property*: /sim/tutorials/current-description
            }

            ColumnLayout {
                width: parent.width

                ListView {
                    id: list
                    Layout.fillWidth: true
                    width: 170
                    height: 400
                    // property*: /sim/tutorials/current-tutorial
                    // binding*: " dialog-apply list "
                    // binding*: " nasal select() "
                }
            } // ColumnLayout
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Start Tutorial")
            // equal*: true
            // default*: true
            // binding*: " nasal setprop("/nasal/tutorial/enabled",1); # load module on demand tutorial.startTutorial(); "

            onClicked: {
                TutorialDialog.closed(TutorialDialog.id);
            }
        }

        Button {
            text: qsTr("Stop Tutorial")
            // equal*: true
            // binding*: " nasal tutorial.stopTutorial() "
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                TutorialDialog.closed(TutorialDialog.id);
            }
        }

    } // buttons
}
