import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: flightRecorderDialog_Load

    width: 640
    height: 500
    position: Qt.point(80, 80)

    windowId: flightRecorderDialog_Load.id
    title: "Load Flight Recorder Tape"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Row {
            id: row2
            spacing: 15
            width: parent.width
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            anchors.verticalCenter: btnChange.verticalCenter

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
                id: btnChange
                text: qsTr("Change")
                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    // binding*: " nasal var set_tapedir_sel = gui.DirSelector.new( func(result) { setprop("/sim/replay/tape-directory", result.getValue()); controller.updateCombo();controller.redraw(); }, "Select Tape Directory", "Ok", getprop("/sim/replay/tape-directory")); set_tapedir_sel.open(); "
                    flightRecorderDialog_Load.closed(flightRecorderDialog_Load.id);
                }
            }
        } // Row

        Row {
            id: row1
            spacing: 15
            width: parent.width
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            anchors.verticalCenter: matching_aircraft.verticalCenter

            Label {
                text: qsTr("Hide Mismatching Tapes:")
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
            }

            CheckBox {
                id: matching_aircraft
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/gui/dialogs/flightrecorder/show-matching-aircraft-only
                // live*: true
                // binding*: " dialog-apply matching-aircraft "
                // binding*: " nasal controller.updateCombo();controller.redraw(); "
                text: qsTr("(Don't show tapes from other aircraft)")
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            spacing: 15
            width: parent.width
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

           Label {
                text: qsTr("Selected Tape:")
                horizontalAlignment: Text.AlignLeft
            }

            ComboBox {
                id: selected_tape
                //horizontalAlignment: Text.AlignLeft
                width: 300
                // property*: /sim/gui/dialogs/flightrecorder/selected-tape
                // live*: true
                // binding*: " dialog-apply selected-tape "
                // binding*: " nasal controller.preview();controller.redraw(); "
            }
        }

        HorizontalLine { }

        Row {
            id: row
            spacing: 15
            width: parent.width
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: false
            Layout.fillWidth: true

            Label {
                text: qsTr("Tape Recording Details")
                anchors.horizontalCenterOffset: -1
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Row {
            spacing: 15
            width: parent.width
            Layout.topMargin: 20

            Label {
                text: qsTr("Author/Pilot:")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.fillWidth: true
                // format*: %s
                // property*: /sim/gui/dialogs/flightrecorder/preview/user-data/author-name
                // live*: true
                horizontalAlignment: Text.AlignLeft
                color: "#CCCC00FF"
            }
        }

        Row {
            spacing: 15
            width: parent.width

            Label {
                text: qsTr("Aircraft:")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.fillWidth: true
                // format*: %s
                // property*: /sim/gui/dialogs/flightrecorder/preview/aircraft-description
                // live*: true
                horizontalAlignment: Text.AlignLeft
                color: "#CCCC00FF"
            }
        }

        Row {
            spacing: 15
            width: parent.width

            Label {
                text: qsTr("Aircraft Version:")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.fillWidth: true
                // format*: %s
                // property*: /sim/gui/dialogs/flightrecorder/preview/aircraft-version
                // live*: true
                horizontalAlignment: Text.AlignLeft
                color: "#CCCC00FF"
            }
        }

        Row {
            spacing: 15
            width: parent.width

            Label {
                text: qsTr("Airport (nearby):")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.fillWidth: true
                // format*: %s
                // property*: /sim/gui/dialogs/flightrecorder/preview/closest-airport-id
                // live*: true
                horizontalAlignment: Text.AlignLeft
                color: "#CCCC00FF"
            }
        }

        Row {
            spacing: 15
            width: parent.width

            Label {
                text: qsTr("Tape Duration:")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.fillWidth: true
                // property*: /sim/gui/dialogs/flightrecorder/preview/tape-duration-str
                horizontalAlignment: Text.AlignLeft
                // live*: true
                color: "#CCCC00FF"
            }
        }

        Row {
            spacing: 15
            width: parent.width

            Label {
                text: qsTr("FG Version (recorder):")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.fillWidth: true
                // property*: /sim/gui/dialogs/flightrecorder/preview/version/flightgear
                horizontalAlignment: Text.AlignLeft
                // live*: true
                color: "#CCCC00FF"
            }
        }

        Label {
            text: qsTr("Description:")
            horizontalAlignment: Text.AlignLeft
        }

        ColumnLayout {
            width: parent.width
            Layout.fillWidth: true

            Label {
                // live*: true
                id: description_string

                width: 550
                height: 150
                Layout.fillWidth: true

                // property*: /sim/gui/dialogs/flightrecorder/preview/user-data/description
                // binding*: " dialog-apply description-string "
            }

            Label {
                Layout.fillWidth: true
                // property*: /sim/gui/dialogs/flightrecorder/warning
                horizontalAlignment: Text.AlignLeft
                // live*: true
                color: "#FF6666FF"
            }
        } // ColumnLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight


        Button {
            text: qsTr("Load")

            onClicked: {
                // binding*: " dialog-apply "
                // binding*: " nasal # close old replay dialog and delay loading - until current replay was properly stopped fgcommand("dialog-close", props.Node.new({ "dialog-name": "replay" })); setprop("/sim/replay/disable", 0); settimer(func { var Config = props.Node.new({ "tape": getprop("/sim/gui/dialogs/flightrecorder/selected-tape", ""), "same-aircraft": 0 }); if (fgcommand("load-tape", Config)) gui.showDialog("replay"); }, 0.2); "
                flightRecorderDialog_Load.closed(flightRecorderDialog_Load.id);
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                flightRecorderDialog_Load.closed(flightRecorderDialog_Load.id);
            }
        }
    } // buttons
}
