import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: weatherDialog

    width: 700
    height: 400
    position: Qt.point(80, 80)

    windowId: weatherDialog.id
    title: "Weather Conditions"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //     <![CDATA[

        //         setprop("sim/gui/dialogs/metar/description[1]",
        //                     "Simple and fast weather engine that interprets METAR data " ~
        //                     "directly or a set of manually defined parameters. Recommended for use with Multiplayer.");
        //         setprop("sim/gui/dialogs/metar/description[2]",
        //                     "Advanced weather engine that gives more detailed and realistic results based on METAR " ~
        //                     "data and a set of predefined parameters. Click on 'Apply' to run the engine, as the engine " ~
        //                     "does not automatically load upon startup.");

        //         var normalize_string = func(src) {
        //         if( src == nil ) src = "";
        //         var dst = "";
        //         for( var i = 0; i < size(src); i+=1 ) {
        //             if( src[i] == `\n` or src[i] == `\r` )
        //             src[i] = ` `;

        //             if (i == 0 and src[i] == ` `)
        //             continue;

        //             if( i != 0 and src[i] == ` ` and src[i-1] == ` ` )
        //             continue;

        //             dst = dst ~ " ";
        //             dst[size(dst)-1] = src[i];
        //         }
        //         return dst;
        //         }

        //     var GlobalWeatherDialogController = {

        //         new : func( dlgRoot ) {
        //         var obj = { parents: [GlobalWeatherDialogController] };
        //         obj.dlgRoot = dlgRoot;
        //         obj.base = "sim/gui/dialogs/metar";
        //         obj.baseN = props.globals.getNode( obj.base, 1 );

        //         return obj;
        //         },

        //         refresh : func {

        //         var scenarioName = getprop( me.base ~ "/source-selection");

        //         if (getprop( me.base ~ "/mode/manual-weather")) {
        //             # In manual weather mode we have to disable live weather
        //             # fetch so the weather can be changed by the user in the
        //             # weather configuration dialog.

        //             setprop( "/environment/params/metar-updates-environment", 0 );
        //             setprop( "/environment/realwx/enabled", 0 );
        //             setprop( "/environment/config/enabled", 1 );
        //         } else if( scenarioName == "Live data" ) {
        //             # If we've selected Live Data we need to force
        //             # a refresh of the Live Data setting.
        //             setprop( "/environment/realwx/enabled", 1 );
        //         }
        //         },

        //         open : func {

        //         # Determine the weather mode.
        //         if ( getprop("/nasal/local_weather/enabled") == 1) {
        //             # Local weather mode
        //             setprop( me.base ~ "/mode/global-weather", "0" );
        //             setprop( me.base ~ "/mode/local-weather", "1" );
        //             setprop( me.base ~ "/mode/manual-weather", "0" );
        //         } else if ( getprop( "environment/params/metar-updates-environment" ) == 0 ) {
        //             # Manual weather mode
        //             setprop( me.base ~ "/mode/global-weather", "1" );
        //             setprop( me.base ~ "/mode/local-weather", "0" );
        //             setprop( me.base ~ "/mode/manual-weather", "1" );
        //         } else {
        //             # Global weather mode
        //             setprop( me.base ~ "/mode/global-weather", "1" );
        //             setprop( me.base ~ "/mode/local-weather", "0" );
        //             setprop( me.base ~ "/mode/manual-weather", "0" );
        //         }

        //         # initialize the METAR source selection
        //         if( getprop( "environment/realwx/enabled" ) ) {
        //             setprop( me.base ~ "/source-selection", "Live data" );
        //         } else {
        //             # preset configured scenario
        //             var wsn = props.globals.getNode( "/environment/weather-scenarios" );
        //             var current = getprop("/environment/weather-scenario", "");
        //             var found = 0;
        //             if( wsn != nil ) {
        //             var scenarios = wsn.getChildren("scenario");
        //             forindex (var i; scenarios ) {
        //                 var metarN = scenarios[i].getNode("metar");
        //                 metarN == nil and continue;
        //                 if( scenarios[i].getNode("name").getValue() == current ) {
        //                 setprop( me.base ~ "/source-selection", scenarios[i].getNode("name").getValue() );
        //                 found = 1;
        //                 break;
        //                 }
        //             }
        //             }
        //             if( found == 0 )
        //             setprop( me.base ~ "/source-selection", "Manual input" );
        //         }

        //         setprop( me.base ~ "/metar-string", normalize_string(getprop("environment/metar/data")) );
        //         gui.findElementByName( me.dlgRoot, "metar-string-input" ).getNode("legend", 1).setValue(normalize_string(getprop("environment/metar/data")));

        //         # fill the METAR source combo box
        //         var combo = gui.findElementByName( me.dlgRoot, "source-selection" );
        //         var wsn = props.globals.getNode( "/environment/weather-scenarios" );
        //         if( wsn != nil ) {
        //             var scenarios = wsn.getChildren("scenario");
        //             forindex (var i; scenarios ) {
        //             combo.getChild("value", i, 1).setValue(scenarios[i].getNode("name").getValue());
        //             }
        //         }

        //         me.scenarioListenerId = setlistener( me.base ~ "/source-selection", func(n) { me.scenarioListener(n); }, 1, 1 );
        //         me.metarListenerId = setlistener( "environment/metar/valid", func(n) { me.metarListener(n); }, 1, 1 );

        //         # Update the dialog itself
        //         me.refresh();
        //         },

        //         close : func {
        //         removelistener( me.scenarioListenerId );
        //         removelistener( me.metarListenerId );
        //         },

        //         apply : func {
        //         var scenarioName = getprop( me.base ~ "/source-selection");
        //         var metar = getprop( "environment/metar/data" );
        //         var global_weather_enabled = getprop( me.base ~ "/mode/global-weather");
        //         var local_weather_enabled = getprop( me.base ~ "/mode/local-weather");
        //         var manual_weather_enabled = getprop( me.base ~ "/mode/manual-weather");

        //         # General weather settings based on scenario
        //         if (manual_weather_enabled == 1) {
        //             setprop( "/environment/params/metar-updates-environment", 0 );
        //             setprop( "/environment/realwx/enabled", 0 );
        //             setprop( "/environment/config/enabled", 1 );
        //             metar = "";
        //         } else if( scenarioName == "Live data" ) {
        //             setprop( "/environment/params/metar-updates-environment", 1 );
        //             setprop( "/environment/realwx/enabled", 1 );
        //             setprop( "/environment/config/enabled", 1 );
        //         } else if( scenarioName == "Manual input" ) {
        //             setprop( "/environment/params/metar-updates-environment", 1 );
        //             setprop( "/environment/realwx/enabled", 0 );
        //             setprop( "/environment/config/enabled", 1 );
        //             metar = getprop( me.base ~ "/metar-string" );
        //             setprop("/environment/weather-scenario", scenarioName);
        //         } else {
        //             setprop( "/environment/params/metar-updates-environment", 1 );
        //             setprop( "/environment/realwx/enabled", 0 );
        //             setprop( "/environment/config/enabled", 1 );
        //             metar = getprop( me.base ~ "/metar-string" );
        //             setprop("/environment/weather-scenario", scenarioName);
        //         }

        //         if( metar != nil ) {
        //             setprop( "environment/metar/data", normalize_string(metar) );
        //         }

        //         # Clear any local weather that might be running
        //         if (getprop("/nasal/local_weather/loaded")) local_weather.clear_all();
        //         setprop("/nasal/local_weather/enabled", "false");

        //         if (local_weather_enabled) {
        //             # If Local Weather is enabled, re-initialize with updated
        //             # initial tile and tile selection.
        //             setprop("/nasal/local_weather/enabled", "true");

        //             # Re-initialize local weather.
        //             settimer( func {local_weather.set_tile();}, 0.2);
        //         }
        //         },

        //         findScenarioByName : func(name) {
        //         var wsn = props.globals.getNode( "/environment/weather-scenarios" );
        //         if( wsn != nil ) {
        //             var scenarios = wsn.getChildren("scenario");
        //             foreach (var scenario; scenarios ) {
        //             if( scenario.getNode("name").getValue() == name )
        //                 return scenario;
        //             }
        //         }
        //         return nil;
        //         },

        //         scenarioListener : func( n ) {
        //         var description = "";
        //         var metar = "nil";
        //         var local_weather_props = nil;

        //         var scenario = me.findScenarioByName( n.getValue() );
        //         if( scenario != nil ) {
        //             description = normalize_string(scenario.getNode("description", 1 ).getValue());
        //             metar = normalize_string(scenario.getNode("metar", 1 ).getValue());
        //             local_weather_props = scenario.getNode("local-weather");
        //         }

        //         if (n.getValue() == "Live data") {
        //             # Special case - retrieve live data
        //             var metar = getprop( "environment/metar/data" );
        //         }

        //         if (n.getValue() == "Manual input") {
        //             # Special case - retain current values
        //             var metar = getprop( me.base ~ "/metar-string" );
        //         }

        //         setprop(me.base ~ "/description", description );
        //         setprop(me.base ~ "/metar-string", metar );

        //         # Set the wind from the METAR string.
        //         var result = [];
        //         var msplit = split(" ", string.uc(metar));
        //         foreach (var word; msplit) {

        //             if ((size(word) > 6) and string.match(word, "*[0-9][0-9]KT")) {
        //             # We've got the wind definition word. Now to split it up.
        //             # Format is nnnmmKT or nnnmmGppKT
        //             # Direction is easy - the first 3 characters.
        //             var dir = chr(word[0]) ~ chr(word[1]) ~ chr(word[2]);

        //             if (dir == "VRB") {
        //                 setprop("/local-weather/tmp/tile-orientation-deg", 360.0 * rand());
        //                 setprop("/local-weather/tmp/gust-angular-variation-deg", 180.0);
        //                 setprop("/local-weather/tmp/gust-frequency-hz", 0.001);
        //             } else {
        //                 setprop("/local-weather/tmp/tile-orientation-deg", dir);
        //                 setprop("/local-weather/tmp/gust-angular-variation-deg", 0.0);
        //                 setprop("/local-weather/tmp/gust-frequency-hz", 0.0);
        //             }

        //             # Next two are the base wind
        //             var spd = chr(word[3]) ~ chr(word[4]);
        //             setprop("/local-weather/tmp/windspeed-kt", spd);

        //             var gst = 0;
        //             if ((size(word) > 7) and (chr(word[5]) == 'G')) {
        //                 # Gusty case
        //                 gst = chr(word[6]) ~ chr(word[7]);
        //             }

        //             if ((gst > spd) and (spd > 0)) {
        //                 setprop("/local-weather/tmp/gust-relative-strength", (gst - spd) / spd);
        //                 setprop("/local-weather/tmp/gust-frequency-hz", 0.7);
        //             } else {
        //                 setprop("/local-weather/tmp/gust-relative-strength", 0.0);
        //             }
        //             }
        //         }


        //         if (local_weather_props != nil) {
        //             # The local weather properties need to be set now, so they can
        //             # be configured by the user if they select Advanced Settings
        //             props.copy(local_weather_props, props.globals.getNode("/local-weather/tmp", 1));
        //         } else {
        //             # If no local weather properties have been set, we'll read from the scenario
        //             # METAR
        //             setprop("/local-weather/tmp/tile-type", "manual");
        //             setprop("/local-weather/tmp/tile-management", "METAR");
        //         }

        //         me.refresh();
        //         },

        //         metarListener : func( n ) {
        //         var metar = getprop("environment/metar/data");
        //         if( metar == nil or metar == "" ) metar = "NIL";
        //         metar = normalize_string(metar);
        //         printlog( "info", "new METAR: " ~ metar );
        //         setprop( me.base ~ "/metar-string", metar );
        //         gui.dialog_update( "weather-conditions", "metar-string" );
        //         },

        //     };

        //     var controller = GlobalWeatherDialogController.new( cmdarg() );
        //     controller.open();
        //     ]]>
        //     </open>

        //     <close>
        //     <![CDATA[
        //     controller.close();
        //     ]]>
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width
                // padding*: 1

                Label {
                    text: qsTr(" ")
                }
            } // ColumnLayout

            ColumnLayout {
                width: parent.width

                Label {
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Select Weather Engine")
                }

                RowLayout {
                    width: parent.width
                    //horizontalAlignment: Text.AlignLeft

                    GridLayout {
                        width: parent.width
                        //horizontalAlignment: Text.AlignLeft
                        id: simple_weather
                        // property*: sim/gui/dialogs/metar/mode/global-weather
                        // live*: true
                        //text: qsTr("Basic Weather")
                        // binding*: " property-assign sim/gui/dialogs/metar/mode/global-weather 1 "
                        // binding*: " property-assign sim/gui/dialogs/metar/mode/local-weather 0 "
                        // binding*: " property-assign sim/gui/dialogs/metar/mode/manual-weather 0 "
                        // binding*: " nasal controller.refresh(); "

                        CheckBox {
                            //horizontalAlignment: Text.AlignRight
                            id: manual_weather_config
                            // property*: sim/gui/dialogs/metar/mode/manual-weather
                            text: qsTr("Manual Configuration")
                            // live*: true
                            // binding*: " dialog-apply manual-weather-config "
                            // binding*: " nasal controller.refresh(); "
                        }

                        Label {
                            Layout.fillWidth: true
                        }

                        Button {
                            //horizontalAlignment: Text.AlignRight
                            text: qsTr("Manual Configuration ...")
                            // binding*: " dialog-show weather-configuration "
                        }
                    } // GridLayout
                } // RowLayout

                Label {
                    id: basic_description

                    Layout.fillWidth: true
                    height: 70

                    Slider {
                        //15
                    }
                    // live*: true
                    // property*: sim/gui/dialogs/metar/description[1]
                }

                RowLayout {
                    width: parent.width
                    //horizontalAlignment: Text.AlignLeft

                    GridLayout {
                        width: parent.width
                        //text: qsTr("Detailed Weather")
                        //horizontalAlignment: Text.AlignLeft
                        id: simple_weather2
                        // property*: sim/gui/dialogs/metar/mode/local-weather
                        // live*: true
                        // binding*: " property-assign sim/gui/dialogs/metar/mode/local-weather 1 "
                        // binding*: " property-assign sim/gui/dialogs/metar/mode/global-weather 0 "
                        // binding*: " property-assign sim/gui/dialogs/metar/mode/manual-weather 0 "
                        // binding*: " nasal controller.refresh(); "

                        Label {
                            text: qsTr(" ")
                        }

                        Label {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: qsTr(" Advanced Settings ...")
                            //horizontalAlignment: Text.AlignRight
                            // binding*: " dialog-show local-weather "
                        }
                    } // GridLayout
                } // RowLayout

                Label {
                    id: advance_description

                    Layout.fillWidth: true
                    height: 90

                    Slider {
                        //15
                    }

                    // live*: true
                    // property*: sim/gui/dialogs/metar/description[2]
                }

                Label {
                    Layout.fillWidth: true
                }
            } // ColumnLayout

            ColumnLayout {
                width: parent.width
                // padding*: 1

                Label {
                    text: qsTr(" ")
                }
            } // ColumnLayout
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width
                // padding*: 1

                Label {
                    text: qsTr(" ")
                }
            } // ColumnLayout

            ColumnLayout {
                width: parent.width
                //horizontalAlignment: Text.AlignLeft

                RowLayout {
                    width: parent.width
                    //horizontalAlignment: Text.AlignLeft

                    Item {
                        Layout.fillWidth: true

                        GridLayout {
                            width: parent.width
                        } // GridLayout

                        Label {
                            text: qsTr("Weather Conditions")
                            horizontalAlignment: Text.AlignLeft
                        }

                        Label {
                            text: qsTr(" ")
                            horizontalAlignment: Text.AlignLeft
                        }

                        ComboBox {
                            id: source_selection
                            Layout.fillWidth: true
                            width: 300
                            // property*: sim/gui/dialogs/metar/source-selection
                            // binding*: " dialog-apply source-selection "
                            // binding*: " dialog-update metar-string-input "
                        }
                    }
                } // RowLayout

                RowLayout {
                    width: parent.width

                    Label {
                        text: qsTr("METAR Data")
                    }

                    Label {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr(" ")
                    }

                    Label {
                        text: qsTr("Data is valid")
                    }

                    CheckBox {
                        // property*: /environment/metar/valid
                        text: qsTr("")
                        // live*: true
                    }
                } // RowLayout

                RowLayout {
                    width: parent.width

                    Label {
                        id: metar_string_input

                        Layout.fillWidth: true
                        height: 70

                        Slider {
                            //15
                        }

                        // property*: sim/gui/dialogs/metar/metar-string
                        // binding*: " dialog-apply metar-string-input "
                    }
                } // RowLayout

                RowLayout {
                    width: parent.width

                    Label {
                        text: qsTr("Description")
                    }

                    Label {
                        Layout.fillWidth: true
                    }
                } // RowLayout

                Label {
                    id: description

                    Layout.fillWidth: true
                    width: 450
                    height: 100

                    Slider {
                        //15
                    }

                    // live*: true
                    // property*: sim/gui/dialogs/metar/description[0]
                }
            } // ColumnLayout

            ColumnLayout {
                width: parent.width
                // padding*: 1

                Label {
                    text: qsTr(" ")
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
            text: qsTr("OK")
            // binding*: " dialog-apply metar-string-input "
            // binding*: " nasal controller.apply(); "

            onClicked: {
                weatherDialog.closed(weatherDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // binding*: " dialog-apply metar-string-input "
            // binding*: " nasal controller.apply(); "
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                weatherDialog.closed(weatherDialog.id);
            }
        }

    } // buttons
}
