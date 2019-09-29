import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: flightRecorderDialog_Save

    width: 640
    height: 300
    position: Qt.point(80, 80)

    windowId: flightRecorderDialog_Save.id
    title: "Save Flight Recorder Tape"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var setdefault = func (prop, value) { if (getprop(prop) == nil) setprop(prop, value);}
        //         setdefault("/sim/gui/dialogs/flightrecorder/start-time", "00:00:00");
        //         setdefault("/sim/gui/dialogs/flightrecorder/stop-time", "99:00:00");
        //         setdefault("/sim/gui/dialogs/flightrecorder/save-all", 1);
        //         setdefault("/sim/gui/dialogs/flightrecorder/author-name", "");
        //         props.globals.getNode("/sim/gui/dialogs/flightrecorder/author-name", 1).setAttribute("userarchive", 1);
        //     ]]></open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width
        Layout.fillWidth: true

        Row {
            id: row
            width: parent.width
            spacing: 15
            Layout.fillWidth: false

            Label {
                text: qsTr("Tape Directory:")
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("MMMMMMMMMMMMMMMMM")
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                // format*: %s
                // property*: /sim/replay/tape-directory
                // live*: true
                color: "#B3B3B3FF"
            }

            Button {
                text: qsTr("Change")

                onClicked: {
                    // binding*: " nasal #var set_tapedir_sel = nil; #var set_tapedir = func { #if (set_tapedir_sel == nil) var set_tapedir_sel = gui.DirSelector.new( func(result) { setprop("/sim/replay/tape-directory", result.getValue()); }, "Select Tape Directory", "Ok", getprop("/sim/replay/tape-directory")); set_tapedir_sel.open(); #} "
                    flightRecorderDialog_Save.closed(flightRecorderDialog_Save.id);
                }
            }
        }

        Row {
            id: row1
            spacing: 15
            Label {
                text: qsTr("Author/Pilot:")
                horizontalAlignment: Text.AlignLeft
            }

            TextInput {
                width: 270
                anchors.verticalCenter: parent.verticalCenter
                Layout.fillWidth: true
                // property*: /sim/gui/dialogs/flightrecorder/author-name
            }
        }

        Label {
            text: qsTr("Description:")
            horizontalAlignment: Text.AlignLeft
        }

        ColumnLayout {
            width: parent.width
            Layout.fillWidth: true

            TextEdit {
                // live*: false
                id: description_string
                height: 200
                Layout.fillWidth: true

                // property*: /sim/gui/dialogs/flightrecorder/description-string
                // binding*: " dialog-apply description-string "
            }
        } // ColumnLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Save")

            onClicked: {
                // binding*: " dialog-apply "
                // binding*: " nasal var descr = getprop("/sim/gui/dialogs/flightrecorder/description-string"); var author = getprop("/sim/gui/dialogs/flightrecorder/author-name"); var quality = getprop("/sim/gui/dialogs/flightrecorder/quality"); var rangeall = getprop("/sim/gui/dialogs/flightrecorder/save-all"); var starttime = getprop("/sim/gui/dialogs/flightrecorder/start-time"); var stoptime = getprop("/sim/gui/dialogs/flightrecorder/stop-time"); if (rangeall) { starttime="";stoptime=""; } var Config = props.Node.new({ "user-data":{ "description": descr, "author-name": author }, "tape-data": { "quality": quality, "start": starttime, "stop": stoptime } }); fgcommand("save-tape", Config); "
                flightRecorderDialog_Save.closed(flightRecorderDialog_Save.id);
            }
        }

        Button {
            text: qsTr("Cancel")
            onClicked: {
                flightRecorderDialog_Save.closed(flightRecorderDialog_Save.id);
            }
        }
    } // buttons
}
