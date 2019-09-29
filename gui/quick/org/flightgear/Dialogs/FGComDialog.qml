import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: fgcomDialog

    width: 640
    height: 350
    position: Qt.point(80, 80)

    windowId: fgcomDialog.id
    title: "FGCom Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var autofill = func {
        //             if ((getprop("/sim/fgcom/selected-server") == nil) or 
        //                 (getprop("/sim/fgcom/selected-server") == "" )){
        //                 var tx = getprop("/sim/fgcom/server");
        //                 var dlg = cmdarg();
        //                 #var servers = cmdarg().getChildren("group")[5].getChildren("combo")[0].getChildren("value");
        //                 var servers = props.globals.getNode("/sim/gui/dialogs/multiplay/fgcom-servers", 1);
        //                 foreach (var s; servers.getChildren("value")) {
        //                     var server = s.getValue();
        //                     var host = split(" ", server)[0];
        //                     if (host == tx) {
        //                         setprop("/sim/fgcom/selected-server", server);
        //                     }
        //                 }
        //             }
        //         }
                
        //         var servers = props.globals.getNode("/sim/gui/dialogs/multiplay/fgcom-servers", 1);
        //         var updateServers = func {
        //             servers.removeChildren("value");                
        //             # get the results list from the server
        //             var serverlist = props.globals.getNode("/sim/multiplay/server-list", 1);
                
        //             var i=0;
        //             foreach (var s; serverlist.getChildren("fgcom")) {
        //                 if (!s.getNode("online").getBoolValue()) {
        //                     continue; # skip offline servers
        //                 }
                    
        //                 # label is name and location, for the moment
        //                 # should we include the number of users? or wait until we
        //                 # have a better UI toolkit?
        //                 var nm = s.getNode("hostname").getValue() ~ " - " ~ s.getNode("location").getValue();
        //                 servers.getNode("value[" ~ i ~ "]", 1).setValue(nm);
        //                 i += 1;
        //             }

        //             autofill();
        //             gui.dialog_update("fgcom", "server");
        //         }
                
        //         var static_serverList = [
        //             ['fgcom.flightgear.org', 'Avignon, France']
        //         ];
                    
        //         var updateServersFailed = func {
        //             debug.dump("Failed to retrieve server list!");
        
        //             servers.removeChildren("value"); 
        //             var i=0;
        //             foreach (var s; static_serverList) {
        //                 # create the node the PUI combo
        //                 var nm = s[0] ~ " - " ~ s[1];
        //                 servers.getNode("value[" ~ i ~ "]", 1).setValue(nm);
        //                 i += 1;
        //             }
                    
        //             autofill();
        //             gui.dialog_update("fgcom", "server");
        //         }
                
        //         # listen for results arriving  
        //         setlistener("/sim/multiplay/got-servers", updateServers);
        //         setlistener("/sim/multiplay/get-servers-failure", updateServersFailed);
                
        //         fgcommand("xmlhttprequest",  props.Node.new({
        //             "url" : "http://liveries.flightgear.org/mpstatus/mpservers.xml",
        //             "targetnode" : "/sim/multiplay/server-list",
        //             "complete" : "/sim/multiplay/got-servers",
        //             "failure" : "/sim/multiplay/get-servers-failure"
        //         }));
        //     ]]></open>
        //     <close>
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 5
            //horizontalAlignment: Text.AlignLeft

            Label {
                text: qsTr("Enabled:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: _enabled
                text: qsTr("")
                //horizontalAlignment: Text.AlignLeft
                // live*: 1
                // property*: /sim/fgcom/enabled
                // binding*: " dialog-apply enabled "
            }

            Label {
                text: qsTr(" Display messages:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: showMessages
                text: qsTr("")
                //horizontalAlignment: Text.AlignLeft
                // live*: 1
                // property*: /sim/fgcom/show-messages
                // binding*: " dialog-apply showMessages "
            }

            Label {
                text: qsTr(" (for debug only)")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("Echo test:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: test
                text: qsTr("")
                //horizontalAlignment: Text.AlignLeft
                // live*: 1
                // property*: /sim/fgcom/test
                // binding*: " dialog-apply test "
            }

            Label {
                text: qsTr("PTT test:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: ptt_test
                text: qsTr("")
                //horizontalAlignment: Text.AlignLeft
                // live*: 1
                // property*: /controls/radios/comm-ptt
                // binding*: " dialog-apply ptt-test "
            }

            Label {
                text: qsTr(" 1")
                // format*: %.0f
                // live*: true
                horizontalAlignment: Text.AlignLeft
                // property*: /controls/radios/comm-ptt
            }

            Label {
                text: qsTr(" (/controls/radios/comm-ptt) ")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("Speaker volume:")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: speaker_vol
                //text: qsTr("")
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/fgcom/speaker-level
                // binding*: " dialog-apply speaker-vol "
            }

            Label {
                text: qsTr("1234 ")
                // format*: %.1f
                // live*: true
                horizontalAlignment: Text.AlignRight
                // property*: /sim/fgcom/speaker-level
            }

            Label {
                text: qsTr("Silence threshold:")
                horizontalAlignment: Text.AlignRight
            }

            Slider {
                id: silence_thd
                //text: qsTr("")
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/fgcom/silence-threshold
                // binding*: " dialog-apply silence-thd "
            }

            Label {
                text: qsTr("1234 dB ")
                // format*: %.1f dB
                // live*: true
                horizontalAlignment: Text.AlignRight
                // property*: /sim/fgcom/silence-threshold
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Server")
            }

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        GridLayout {
            width: parent.width
            columns: 5
            // padding*: 10

            ComboBox {
                id: server
                width: 350
                // property*: /sim/fgcom/selected-server
                // binding*: " dialog-apply server "
                // binding*: " nasal setprop("/sim/fgcom/enabled", 0); var server = getprop("/sim/fgcom/selected-server"); server = split(" ", server)[0]; setprop("/sim/fgcom/server", server); setprop("/sim/fgcom/enabled", 1); "
                // binding*: " dialog-apply test "
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                fgcomDialog.closed(fgcomDialog.id);
            }
        }
    } // buttons
}


