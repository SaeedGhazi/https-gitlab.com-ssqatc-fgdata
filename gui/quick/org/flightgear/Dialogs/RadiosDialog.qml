import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: radiosDialog

    width: 1000
    height: 450
    position: Qt.point(80, 80)

    windowId: radiosDialog.id
    title: "Radio Frequencies"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var modes = ['OFF', 'STANDBY', 'TEST', 'GROUND', 'ON', 'ALTITUDE'];
        //         var v = getprop('/instrumentation/transponder/inputs/knob-mode') or 0;
        //         setprop("/sim/gui/dialogs/radios/transponder-mode", modes[v]);

        //         var poweroften = [1, 10, 100, 1000];
        //         var idcode = getprop('/instrumentation/transponder/id-code');

        //         if (idcode != nil)
        //         {
        //             for (var i = 0; i < 4 ; i = i+1)
        //             {
        //                 setprop("/instrumentation/transponder/inputs/digit[" ~ i ~ "]", sprintf("%1d", math.mod(idcode/poweroften[i], 10)) );
        //             }
        //         }

        //         var updateTransponderCode = func {
        //             var goodcode = 1;
        //             var code = 0;
        //             for (var i = 3; i >= 0 ; i -= 1)
        //             {
        //                 goodcode = goodcode and (num(getprop("/instrumentation/transponder/inputs/digit[" ~ i ~ "]")) != nil) ;
        //                 code = code * 10 + (num(getprop("/instrumentation/transponder/inputs/digit[" ~ i ~ "]")) or 0);
        //             }
        //             setprop('/instrumentation/transponder/goodcode', goodcode);
        //             setprop('/instrumentation/transponder/id-code', code);
        //         }
        //     ]]></open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 5

            Label {
                text: qsTr("")
            }

            Label {
                text: qsTr("Selected")
            }

            Label {
                text: qsTr("")
            }

            Label {
                text: qsTr("Standby")
            }

            Label {
                text: qsTr("Radial")
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("COM1")
            }

            TextInput {
                id: com1_selected
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/comm[0]/frequencies/selected-mhz
                // binding*: " dialog-apply com1-selected "
            }

            Button {
                width: 35
                height: 26
                // border*: 1
                text: qsTr("<->")
                // binding*: " dialog-apply com1-selected "
                // binding*: " dialog-apply com1-standby "
                // binding*: " property-swap /instrumentation/comm[0]/frequencies/selected-mhz /instrumentation/comm[0]/frequencies/standby-mhz "
                // binding*: " dialog-update com1-selected "
                // binding*: " dialog-update com1-standby "
            }

            TextInput {
                id: com1_standby
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/comm[0]/frequencies/standby-mhz
                // binding*: " dialog-apply com1-standby "
            }

            Label {
                text: qsTr("")
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("COM2")
            }

            TextInput {
                id: com2_selected
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/comm[1]/frequencies/selected-mhz
                // binding*: " dialog-apply com2-selected "
            }

            Button {
                width: 35
                height: 26
                // border*: 1
                text: qsTr("<->")
                // binding*: " dialog-apply com2-selected "
                // binding*: " dialog-apply com2-standby "
                // binding*: " property-swap /instrumentation/comm[1]/frequencies/selected-mhz /instrumentation/comm[1]/frequencies/standby-mhz "
                // binding*: " dialog-update com2-selected "
                // binding*: " dialog-update com2-standby "
            }

            TextInput {
                id: com2_standby
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/comm[1]/frequencies/standby-mhz
                // binding*: " dialog-apply com2-standby "
            }

            Label {
                text: qsTr("")
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("NAV1")
            }

            TextInput {
                id: nav1_selected
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/nav[0]/frequencies/selected-mhz
                // binding*: " dialog-apply nav1-selected "
            }

            Button {
                width: 35
                height: 26
                // border*: 1
                text: qsTr("<->")
                // binding*: " dialog-apply nav1-selected "
                // binding*: " dialog-apply nav1-standby "
                // binding*: " property-swap /instrumentation/nav[0]/frequencies/selected-mhz /instrumentation/nav[0]/frequencies/standby-mhz "
                // binding*: " dialog-update nav1-selected "
                // binding*: " dialog-update nav1-standby "
            }

            TextInput {
                id: nav1_standby
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/nav[0]/frequencies/standby-mhz
                // binding*: " dialog-apply nav1-standby "
            }

            TextInput {
                id: nav1_radial
                width: 75
                text: qsTr("deg")
                // live*: true
                // property*: /instrumentation/nav[0]/radials/selected-deg
                // binding*: " dialog-apply nav1-radial "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("NAV2")
            }

            TextInput {
                id: nav2_selected
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/nav[1]/frequencies/selected-mhz
                // binding*: " dialog-apply nav2-selected "
            }

            Button {
                width: 35
                height: 26
                // border*: 1
                text: qsTr("<->")
                // binding*: " dialog-apply nav2-selected "
                // binding*: " dialog-apply nav2-standby "
                // binding*: " property-swap /instrumentation/nav[1]/frequencies/selected-mhz /instrumentation/nav[1]/frequencies/standby-mhz "
                // binding*: " dialog-update nav2-selected "
                // binding*: " dialog-update nav2-standby "
            }

            TextInput {
                id: nav2_standby
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/nav[1]/frequencies/standby-mhz
                // binding*: " dialog-apply nav2-standby "
            }

            TextInput {
                id: nav2_radial
                width: 75
                text: qsTr("deg")
                // live*: true
                // property*: /instrumentation/nav[1]/radials/selected-deg
                // binding*: " dialog-apply nav2-radial "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("ADF")
            }

            TextInput {
                id: adf_selected
                width: 75
                text: qsTr("kHz")
                // live*: true
                // property*: /instrumentation/adf/frequencies/selected-khz
                // binding*: " dialog-apply adf-selected "
            }

            Button {
                width: 35
                height: 26
                // border*: 1
                text: qsTr("<->")
                // binding*: " dialog-apply adf-selected "
                // binding*: " dialog-apply adf-standby "
                // binding*: " property-swap /instrumentation/adf/frequencies/selected-khz /instrumentation/adf/frequencies/standby-khz "
                // binding*: " dialog-update adf-selected "
                // binding*: " dialog-update adf-standby "
            }

            TextInput {
                id: adf_standby
                width: 75
                text: qsTr("kHz")
                // live*: true
                // property*: /instrumentation/adf/frequencies/standby-khz
                // binding*: " dialog-apply adf-standby "
            }

            TextInput {
                id: adf_radial
                width: 75
                text: qsTr("deg")
                // live*: true
                // property*: /instrumentation/adf/rotation-deg
                // binding*: " dialog-apply adf-radial "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("DME")
            }

            TextInput {
                id: dme_selected
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/dme/frequencies/selected-mhz
                // binding*: " dialog-apply dme-selected "
            }

            Label {
                text: qsTr("")
            }

            Button {
                text: qsTr("ATC Services in range")
                Layout.columnSpan: 2
                // binding*: " ATC-freq-search "
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                text: qsTr(" TACAN ")
            }

            ComboBox {
                id: tacan_1
                width: 55
                // live*: true
                // property*: /instrumentation/tacan/frequencies/selected-channel[1]
                // binding*: " dialog-apply tacan-1 "
            }

            ComboBox {
                id: tacan_2
                width: 55
                // live*: true
                // property*: /instrumentation/tacan/frequencies/selected-channel[2]
                // binding*: " dialog-apply tacan-2 "
            }

            ComboBox {
                id: tacan_3
                width: 55
                // live*: true
                // property*: /instrumentation/tacan/frequencies/selected-channel[3]
                // binding*: " dialog-apply tacan-3 "
            }

            ComboBox {
                id: tacan_4
                width: 55
                // live*: true
                // property*: /instrumentation/tacan/frequencies/selected-channel[4]
                // binding*: " dialog-apply tacan-4 "
            }

            Label {
                Layout.fillWidth: true
            }

            TextInput {
                id: tacan_freq
                width: 75
                text: qsTr("MHz")
                // live*: true
                // property*: /instrumentation/tacan/frequencies/selected-mhz
                // binding*: " dialog-apply tacan-freq "
            }

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                text: qsTr(" Transponder")
            }

            ComboBox {
                id: tponder_1
                model: 10
                currentIndex: 1
                // live*: true
                // property*: /instrumentation/transponder/inputs/digit[3]
                // binding*: " dialog-apply Tponder-1 "
                // binding*: " nasal updateTransponderCode(); "
            }

            ComboBox {
                id: tponder_2
                model: 10
                currentIndex: 2
                // live*: true
                // property*: /instrumentation/transponder/inputs/digit[2]
                // binding*: " dialog-apply Tponder-2 "
                // binding*: " nasal updateTransponderCode(); "
            }

            ComboBox {
                id: tponder_3
                model: 10
                // live*: true
                // property*: /instrumentation/transponder/inputs/digit[1]
                // binding*: " dialog-apply Tponder-3 "
                // binding*: " nasal updateTransponderCode(); "
            }

            ComboBox {
                id: tponder_4
                model: 10
                // live*: true
                // property*: /instrumentation/transponder/inputs/digit[0]
                // binding*: " dialog-apply Tponder-4 "
                // binding*: " nasal updateTransponderCode(); "
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Mode")
            }

            ComboBox {
                id: tponder_5
                width: 120
                // live*: true
                // property*: /sim/gui/dialogs/radios/transponder-mode
                // binding*: " dialog-apply Tponder-5 "
                // binding*: " nasal var v = getprop("/sim/gui/dialogs/radios/transponder-mode"); #var modes = ['OFF', 'STANDBY', 'TEST', 'GROUND', 'ON', 'ALTITUDE']; var index=0; for (; index<size(modes) and (v != modes[index]); index+=1) { } setprop("/instrumentation/transponder/inputs/knob-mode", index); "
            }

            Button {
                text: qsTr("IDENT")
                // property*: /instrumentation/transponder/inputs/ident-btn
                // binding*: " dialog-apply "
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
                radiosDialog.closed(radiosDialog.id);
            }
        }
    } // buttons
}
