import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: replayDialog

    width: 800
    height: 300
    position: Qt.point(80, 80)

    windowId: replayDialog.id
    title: "Replay"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
		// <nasal>
		// 	<open><![CDATA[
		// 		var ReplayDialogController = {

		// 		new : func( dlgRoot ) {
		// 			var obj = { parents: [ReplayDialogController] };
		// 			obj.dlgRoot = dlgRoot;
		// 			obj.initViews(1);
		// 			return obj;
		// 		},

		// 		# Populate the view combo box with a list of the available views
		// 		initViews : func(update) {
		// 			var combo = gui.findElementByName( me.dlgRoot, "view-selector" );
		// 			if (update)
		// 				combo.removeChildren("value");

		// 			var current_view = getprop("/sim/current-view/view-number");
		// 			var i = 0;
		// 			foreach (var v; view.views) {
		// 				if (v.getNode("name") == nil) {
		// 					continue;
		// 				}
		// 				var name = v.getNode("name").getValue();
		// 				if (name == nil) {
		// 					continue;
		// 				}

		// 				# Pre-populate the combo box selected value
		// 				if (i == current_view) {
		// 					setprop("/sim/replay/view-name", name);
		// 				}
		// 				if (update)
		// 					combo.getNode("value[" ~ i ~ "]", 1).setValue(name);
		// 				i += 1;
		// 			}
		// 		},

		// 		open : func {
		// 			var replaySlider = gui.findElementByName( me.dlgRoot, "replay-time-slider" );
		// 			me.maxProp = replaySlider.getChild("max");
		// 			me.minProp = replaySlider.getChild("min");
		// 			me.speedUpListenerId = setlistener( "/sim/speed-up", func(n) { me.updateListener(n); }, 1, 1 );
		// 			me.viewListenerId = setlistener( "/sim/current-view/view-number", func(n) { me.updateListener(n); }, 1, 1 );
		// 			if (getprop("/sim/replay/end-time")!=nil)
		// 			{
		// 				# update max/min range of replay-time slider
		// 				me.maxProp.setValue(getprop("/sim/replay/end-time"));
		// 				me.minProp.setValue(getprop("/sim/replay/start-time"));
		// 			}
		// 			me.updateListener(1);
		// 		},

		// 		updateListener : func( n ) {
		// 			var SpeedUp = getprop("/sim/speed-up");
		// 			if (SpeedUp<0.9)
		// 			{
		// 				SpeedUp=1/SpeedUp;
		// 				SpeedUp = "1/" ~ SpeedUp;
		// 			}
		// 			setprop("/sim/gui/dialogs/replay/time-factor","" ~ SpeedUp ~ "x");
		// 			me.initViews(0);
		// 		},

		// 		close : func {
		// 			removelistener( me.speedUpListenerId );
		// 			removelistener( me.viewListenerId );
		// 		},

		// 	};

		// 	var controller = ReplayDialogController.new( cmdarg() );
		// 	controller.open();
		// 	if (props.globals.getNode("/rotors",0)!=nil)
		// 		setprop("/sim/replay/disable-my-controls",1);
		// 	]]></open>

		// 	<close><![CDATA[
		// 	controller.close();
		// 	]]></close>
		// </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            height: 28

            Label {
                // font*: sim/gui/selected-style/fonts/replay
                text: qsTr("REPLAY")
                color: "#E6E6E6FF"
                width: 70
            }

            Label {
                text: qsTr("Loop:")
                color: "#B3B3B3FF"
            }

            CheckBox {
                id: replay_looped
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/replay/looped
                // binding*: " dialog-apply replay-looped "
            }

            TextInput {
                id: replay_duration
                width: 40
                //color: "#777CC"
                // property*: /sim/replay/duration
                // binding*: " dialog-apply replay-duration "
            }

            Label {
                width: 40
            }

            Label {
                text: qsTr("Time: 99:99:99.9")
                // format*: Time: %s
                color: "#B3B3B3FF"
                // live*: true
                // property*: /sim/replay/time-str
            }

            Label {
                width: 10
            }

            Label {
                text: qsTr("Size: 999.9MB")
                // format*: Size: %.1fMB
                color: "#B3B3B3FF"
                // property*: /sim/replay/buffer-size-mbyte
            }

            Label {
                width: 40
            }

            Label {
                text: qsTr("Speed:")
                color: "#B3B3B3FF"
            }

            Button {
                text: qsTr("-")
                width: 20
                // border*: 1
                color: "#4D4D4DCC"
                // binding*: " nasal controls.speedup(-1); "
            }

            Label {
                text: qsTr("1/16x")
                width: 28
                // format*: %s
                color: "#B3B3B3FF"
                // live*: true
                // property*: /sim/gui/dialogs/replay/time-factor
            }

            Button {
                text: qsTr("+")
                width: 20
                // border*: 1
                color: "#4D4D4DCC"
                // binding*: " nasal controls.speedup(1); "
            }

            Label {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Hide")
                // border*: 1
                color: "#4D4D4DCC"
                width: 40
                // binding*: " nasal setprop("/sim/messages/copilot", "Replay active. 'Esc' to stop. 'Ctrl-R' to show replay controls."); "
                onClicked: {
                    replayDialog.closed(replayDialog.id);
                }
            }
        } // RowLayout

        RowLayout {
            width: parent.width

            Button {
                text: qsTr("<<")
                width: 30
                // border*: 1
                color: "#4D4D4DCC"
                // binding*: " nasal controls.replaySkip(-30); "
            }

            Button {
                text: qsTr("<")
                width: 30
                // border*: 1
                color: "#4D4D4DCC"
                // binding*: " nasal controls.replaySkip(-5); "
            }

            Label {
                text: qsTr("9:99:99")
                color: "#B3B3B3FF"
                // format*: %8s
                horizontalAlignment: Text.AlignRight
                // live*: true
                // property*: /sim/replay/start-time-str
            }

            Slider {
                id: replay_time_slider
                // border*: 0
                //color: "#666666FF"
                //horizontalAlignment: Text.AlignLeft
                width: 350
                // property*: /sim/replay/time
                // live*: true
                // binding*: " dialog-apply replay-time-slider "
            }

            Label {
                text: qsTr("9:99:99")
                color: "#B3B3B3FF"
                // format*: %s
                horizontalAlignment: Text.AlignLeft
                // live*: true
                // property*: /sim/replay/end-time-str
            }

            Button {
                text: qsTr(">")
                width: 30
                // border*: 1
                color: "#4D4D4DCC"
                // binding*: " nasal controls.replaySkip(5); "
            }

            Button {
                text: qsTr(">>")
                width: 30
                // border*: 1
                color: "#4D4D4DCC"
                // binding*: " nasal controls.replaySkip(30); "
            }
        } // RowLayout


        RowLayout {
            width: parent.width

            Layout.fillWidth: true
            // padding*: 3

            Label {
                width: 26
            }

            Button {
                text: qsTr("Pause")
                // default*: true
                // border*: 2
                color: "#4D4D4DCC"
                // property*: /sim/freeze/master
                // live*: true
                width: 70
                // binding*: " property-toggle /sim/freeze/clock "
                // binding*: " property-toggle /sim/freeze/master "
            }

            Label {
                width: 80
            }

            Button {
                id: mute
                text: qsTr("Mute")
                // border*: 2
                width: 55
                color: "#4D4D4DCC"
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/replay/mute
                // live*: true
                // binding*: " nasal var mute = !getprop("/sim/replay/mute"); setprop("/sim/replay/mute",mute); setprop("/sim/sound/enabled",!mute); "
            }

            ComboBox {
                id: view_selector
                //horizontalAlignment: Text.AlignLeft
                width: 150
                //color: "#4D4D4DCC"
                // live*: true
                // property*: /sim/replay/view-name
                // binding*: " dialog-apply view-selector "
                // binding*: " nasal var index = view.indexof(getprop("/sim/replay/view-name")); setprop("/sim/current-view/view-number", index); "
            }

            Label {
                width: 30
            }

            Button {
                text: qsTr("My Controls!")
                // border*: 1
                color: "#FF4D4DCC"
                width: 90
                // binding*: " property-assign /sim/freeze/replay-state 3 "
                // binding*: " property-assign /sim/replay/disable true "
                onClicked: {
                    replayDialog.closed(replayDialog.id);
                }
            }

            Button {
                text: qsTr("End Replay")
                // key*: qsTr("Esc")
                // border*: 1
                width: 90
                color: "#4D4D4DCC"
                // binding*: " property-assign /sim/replay/disable true "
                onClicked: {
                    replayDialog.closed(replayDialog.id);
                }
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
                replayDialog.closed(replayDialog.id);
            }
        }
    } // buttons
}
