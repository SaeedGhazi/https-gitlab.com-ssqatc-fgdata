import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: multiplayerDialog

    width: 640
    height: 500
    position: Qt.point(80, 80)

    windowId: multiplayerDialog.id
    title: "Multiplayer Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         <![CDATA[
        //         if ((getprop("/sim/multiplay/selected-server") == nil) or 
        //             (getprop("/sim/multiplay/selected-server") == "" )   ){
        //             var tx = getprop("/sim/multiplay/txhost");
        //             var dlg = cmdarg();
        //             var servers = cmdarg().getChildren("group")[1].getChildren("combo")[0].getChildren("value");
        //             foreach (var s; servers) {
        //                 var server = s.getValue();
        //                 var host = split(" ", server)[0];
        //                 if (host == tx) {
        //                     setprop("/sim/multiplay/selected-server", server);
        //                 }
        //             }
        //         }
        //         if (getprop("/sim/multiplay/rxport") == nil or getprop("/sim/multiplay/rxport") == 0)
        //             setprop("/sim/multiplay/rxport",5000);

        //         if (getprop("/sim/multiplay/txport") == nil or getprop("/sim/multiplay/txport") == 0)
        //             setprop("/sim/multiplay/txport",5000);

        //         if (getprop("/sim/multiplay/protocol-version") == 2)
        //             setprop("/sim/gui/dialogs/multiplay/protocol-version", "Visible to only 2017+");
        //         else
        //             setprop("/sim/gui/dialogs/multiplay/protocol-version", "Visible to all");

        //         var servers = props.globals.getNode("/sim/gui/dialogs/multiplay/servers", 1);
        //         var updateServers = func(n) {
        //             if( !n.getValue() ) return;
        //             servers.removeChildren("value");                
        //             # get the results list from the server
        //             var serverlist = props.globals.getNode("/sim/multiplay/server-list", 1);
                
        //             var i=0;
        //             foreach (var s; serverlist.getChildren("server")) {
                        
        //                 # prepare some default values
        //                 s.initNode("online", 1, "BOOL" );
        //                 s.initNode("location", "unknown", "STRING" );
        //                 s.initNode("name", s.getNode("hostname").getValue(), "STRING" );
        //                 if (!s.getNode("online").getBoolValue()) {
        //                 continue; # skip offline servers
        //                 }
                    
        //             # label is name and location, for the moment
        //             # should we include the number of users? or wait until we
        //             # have a better UI toolkit?
        //                 var nm = s.getNode("hostname").getValue() ~ " - " ~ s.getNode("location").getValue();
        //                 servers.getNode("value[" ~ i ~ "]", 1).setValue(nm);
        //                 i += 1;
        //             }

        //             gui.dialog_update("multiplayer", "host");
        //         }
                
        //         var static_serverList = [
        //                 ['mpserver01.flightgear.org', 'Frankfurt, Germany'],
        //                 ['mpserver02.flightgear.org', 'Kansas, USA'],
        //                 ['mpserver03.flightgear.org', 'Germany'],
        //                 ['mpserver04.flightgear.org', 'United Kingdom'],
        //                 ['mpserver05.flightgear.org', 'Chicago, USA'],
        //                 ['mpserver07.flightgear.org', 'Wisconsin, USA'],
        //                 ['mpserver08.flightgear.org', 'Frankfurt am Main, Germany'],
        //                 ['mpserver09.flightgear.org', 'Koln, Germany'],
        //                 ['mpserver10.flightgear.org', 'Montpellier, France'],
        //                 ['mpserver11.flightgear.org', 'Vilnius, Lithuania'],
        //                 ['mpserver12.flightgear.org', 'Amsterdam, Netherlands'],
        //                 ['mpserver13.flightgear.org', 'Grenoble, France']
        //             ];
                    
        //         var updateServersFailed = func(n) {
        //             if( !n.getValue() ) return;
        //             debug.dump("Failed to retrieve server list!");
        
        //             servers.removeChildren("value"); 
        //             var i=0;
        //             foreach (var s; static_serverList) {
        //             # create the node the PUI combo
        //                 var nm = s[0] ~ " - " ~ s[1];
        //                 servers.getNode("value[" ~ i ~ "]", 1).setValue(nm);
        //                 i += 1;
        //             }
                    
        //             gui.dialog_update("multiplayer", "host");
        //         }
                
        //         # listen for results arriving
        //         setlistener("/sim/multiplay/got-servers", updateServers);
        //         setlistener("/sim/multiplay/get-servers-failure", updateServersFailed);
        //         fgcommand("multiplayer-refreshserverlist");
        //         ]]>
        //     </open>
            
        //     <close>
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 1

            Label {
                text: qsTr(" Options:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: hide_replay
                text: qsTr("Hide replay sessions over MP (less annoying to other players)")
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/multiplay/freeze-on-replay
                // binding*: " dialog-apply hide-replay "
            }

            CheckBox {
                id: ai_traffic
                text: qsTr("Show AI Traffic (mixing MP and AI traffic may be confusing)")
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/traffic-manager/enabled
                // binding*: " dialog-apply ai-traffic "
            }

            CheckBox {
                text: qsTr("Emesary only multiplayer mode")
                //horizontalAlignment: Text.AlignLeft
                // visible*: sim/multiplay/transmit-filter-property-base-available
                // property*: sim/multiplay/transmit-filter-property-base
                // live*: true
                // binding*: " property-toggle sim/multiplay/transmit-filter-property-base "
            }

            ComboBox {
                id: protocol_version
                width: 300
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/gui/dialogs/multiplay/protocol-version
                // binding*: " dialog-apply protocol-version "
                // binding*: " nasal var val = getprop("/sim/gui/dialogs/multiplay/protocol-version"); print("MP Version :",val,":"); if (val == "Visible to all") { setprop("/sim/multiplay/protocol-version", 1); } if (val == "Visible to only 2017+") { setprop("/sim/multiplay/protocol-version", 2); } "
            }

            Label {
                text: qsTr("Compatibility")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr(" Callsign:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                horizontalAlignment: Text.AlignLeft
                // property*: /sim/multiplay/callsign
            }

            Label {
                text: qsTr("Server:")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                id: host
                width: 350
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/multiplay/selected-server
            }

            RowLayout {
                width: parent.width

                Label {
                    width: 2
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("rxPort")
                }

                TextInput {
                    width: 50
                    horizontalAlignment: Text.AlignLeft
                    // property*: /sim/multiplay/rxport
                }
            } // RowLayout

            Label {
                text: qsTr("Not connected")
                horizontalAlignment: Text.AlignLeft
                // visible*: /sim/multiplay/online
            }

            Label {
                text: qsTr("MMMMMMMMMMMMMMMMM")
                horizontalAlignment: Text.AlignLeft
                // visible*: /sim/multiplay/online
                // format*: Connected to %s
                // property*: /sim/multiplay/txhost
                // live*: true
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Connect")
            // binding*: " dialog-apply "
            // binding*: " nasal fgcommand("multiplayer-connect", props.Node.new({ "servername": getprop("/sim/multiplay/selected-server"), "rxport": getprop("/sim/multiplay/rxport"), "txport": getprop("/sim/multiplay/txport") })); "
        }

        Button {
            text: qsTr("Disconnect")
            // binding*: " dialog-apply "
            // binding*: " multiplayer-disconnect mp "
        }

        Button {
            text: qsTr("Server Status")
            // binding*: " open-browser http://mpmap01.flightgear.org/mpstatus/ "
        }

        Button {
            text: qsTr("Close")

            onClicked: {
                multiplayerDialog.closed(multiplayerDialog.id);
            }
        }
    } // buttons
}
