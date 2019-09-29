import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: airportsDialog

    width: 1024
    height: 800
    position: Qt.point(80, 80)

    windowId: airportsDialog.id
    title: "Select an Airport"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <!-- Generalize all this, turn into helpers and load defaults via XML -->
        //     <open><![CDATA[
        //     var MAX_RUNWAYS = 28; # number of entries at KEDW

        //     var DIALOG = cmdarg();
        //     var listeners = [];

        //     ## "prologue" currently required by the canvas-generic-map
        //     var dialog_name ="airports"; #TODO: use substr() and cmdarg() to get this dynamically
        //     var dialog_property = func(p) return "/sim/gui/dialogs/airports/"~p; #TODO: generalize using cmdarg
        //     var DIALOG_CANVAS = gui.findElementByName(DIALOG, "airport-selection");


        //     setprop("/sim/gui/dialogs/airports/selected-airport/lat", 0);
        //     setprop("/sim/gui/dialogs/airports/selected-airport/lon", 0);
        //     setprop("/sim/gui/dialogs/airports/selected-airport/rwy", "");
        //     setprop("/sim/gui/dialogs/airports/selected-airport/parkpos", "");
        //     setprop("/sim/gui/dialogs/airports/mode", "search");
        //     setprop("/sim/gui/dialogs/airports/display-mode", "0");
        //     setprop("/sim/gui/dialogs/airports/list", "");

        //     if (getprop("/sim/gui/dialogs/airports/display-taxiways") == "") {
        //         setprop("/sim/gui/dialogs/airports/display-taxiways", "1");
        //     }

        //     if (getprop("/sim/gui/dialogs/airports/display-parking") == "") {
        //         setprop("/sim/gui/dialogs/airports/display-parking", "0");
        //     }

        //     if (getprop("/sim/gui/dialogs/airports/display-tower") == "") {
        //         setprop("/sim/gui/dialogs/airports/display-tower", "1");
        //     }

        //     if (getprop("/sim/gui/dialogs/airports/show-helipads") == "") {
        //         setprop("/sim/gui/dialogs/airports/show-helipads", "1");
        //     }

        //     # Start with the closest airport
        //     var airport_id = airportinfo().id;

        //     # Retrieve METAR
        //     fgcommand("request-metar", var n = props.Node.new({ "path": "/sim/gui/dialogs/airports/selected-airport/metar",
        //                                                         "station": airport_id}));

        //     var dlg = props.globals.getNode("/sim/gui/dialogs/airports", 1);
        //     var avail_runways = dlg.getNode("available-runways", 1);
        //     var avail_parking = {};

        //     if (dlg.getNode("list") == nil)
        //         dlg.getNode("list", 1).setValue("");

        //     var airportlist = dlg.getNode("list");

        //     var mode = {
        //         runway:     dlg.getNode("use_runway", 1),
        //         bestrunway: dlg.getNode("use_best_runway", 1),
        //         parkpos:    dlg.getNode("use_parkpos", 1)
        //     };

        //     var set_radio = func(m) {
        //         foreach (k; keys(mode)) {
        //         mode[k].setBoolValue(m == k);
        //         }
        //     }

        //     var initialized = 0;
        //     foreach (k; keys(mode)) {
        //         if (mode[k].getType() == "NONE" or initialized) {
        //         mode[k].setBoolValue(0);
        //         } else {
        //         initialized += mode[k].getBoolValue();
        //         }
        //     }
        //     if (!initialized) {
        //         set_radio("bestrunway");
        //     }

        //     var update_info = func {
        //         var info = airportinfo(airport_id);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/id", airport_id);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/name", info.name);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/location", sprintf("%.3f / %.3f", info.lat, info.lon));
        //         setprop("/sim/gui/dialogs/airports/selected-airport/lon", info.lon);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/lat", info.lat);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/elevation-ft", 3.28 * info.elevation);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/rwy", "");
        //         setprop("/sim/gui/dialogs/airports/selected-airport/parkpos", "");
        //         AirportChart.getController().setPosition(info.lat, info.lon);

        //         if (info.has_metar) {
        //             # Retrieve an updated METAR, and indicate that we've not got one currently.
        //             fgcommand("request-metar", var n = props.Node.new({ "path": "/sim/gui/dialogs/airports/selected-airport/metar",
        //                                                         "station": airport_id}));
        //         } else {
        //             # This airport has no METAR. Rather than cancelling the retrieve-metar command, simply set the TTL
        //             # to a very long time so it won't over-ride our message.
        //             setprop("/sim/gui/dialogs/airports/selected-airport/metar/time-to-live", 9999);
        //         }


        //         # Display the comms frequencies for this airport
        //         var fcount = 0;

        //         if (size(info.comms()) > 0) {
        //             # Airport has one or more frequencies assigned to it.
        //             var freqs = {};
        //             var comms = info.comms();

        //             foreach (var c; comms) {
        //             var f = sprintf("%.3f", c.frequency);
        //             if (freqs[c.ident] == nil) {
        //                 freqs[c.ident] = f;
        //             } else {
        //                 freqs[c.ident] = freqs[c.ident] ~ " " ~ f;
        //             }
        //             }

        //             foreach (var c; sort(keys(freqs), string.icmp)) {
        //             setprop("sim/gui/dialogs/airports/selected-airport/comms/freq[" ~ fcount ~ "]/label", c);
        //             setprop("sim/gui/dialogs/airports/selected-airport/comms/freq[" ~ fcount ~ "]/value", freqs[c]);
        //             fcount += 1;
        //             }
        //         }

        //         while (fcount < 13) {
        //             # zero remaining comms channels
        //             setprop("sim/gui/dialogs/airports/selected-airport/comms/freq[" ~ fcount ~ "]/label", "");
        //             setprop("sim/gui/dialogs/airports/selected-airport/comms/freq[" ~ fcount ~ "]/value", "");
        //             fcount += 1;
        //         }

        //         var longest_runway = 0;
        //         var runways = info.runways;
        //         var infoAboutRunways = [];   # list of strings for display

        //         avail_runways.removeChildren("value");
        //         var runway_keys = sort(keys(runways), string.icmp);
        //         var i = 0;

        //         foreach(var rwy; runway_keys) {
        //             var r = runways[rwy];
        //             longest_runway = math.max(longest_runway, r.length * 3.28);
        //             avail_runways.getNode("value[" ~ i ~ "]", 1).setValue(rwy);
        //             var rwyInfo = sprintf("%5s %12d' / %03d deg", rwy, r.length * 3.28,
        //                                     r.heading);

        //             if (r.ils != nil) {
        //                 rwyInfo = sprintf("%s %20.3f Mhz", rwyInfo,
        //                                     r.ils.frequency / 100);
        //             }

        //             append(infoAboutRunways, rwyInfo);

        //             i += 1;
        //             if (i == MAX_RUNWAYS)
        //                 break;
        //         }

        //         var runwayInfoNode = dlg.getNode("selected-airport/runways-info", 1);
        //         runwayInfoNode.setValue(string.join("\n", infoAboutRunways));
        //         fgcommand("dialog-update", props.Node.new({"object-name": "runways-info", "dialog-name": "airports"}));

        //         # Update the list of available parking positions
        //         avail_parking = {};
        //         foreach (var park; info.parking()) {
        //             avail_parking[park.name] = 1;
        //         }

        //         setprop("/sim/gui/dialogs/airports/selected-airport/longest-runway", longest_runway);

        //         var airport_pos = geo.Coord.new();
        //         airport_pos.set_latlon(info.lat, info.lon);

        //         var pos = geo.aircraft_position();
        //         var dst = pos.distance_to(airport_pos) / 1852.0;
        //         var crs = pos.course_to(airport_pos);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/distance-nm", dst);
        //         setprop("/sim/gui/dialogs/airports/selected-airport/course-deg", crs);

        //         gui.dialog_update("airports", "runway-list");
        //     }

        //     var listbox = func {
        //         airport_id = pop(split(" ", airportlist.getValue()));
        //         airport_id = substr(airport_id, 1, size(airport_id) - 2);  # strip parentheses

        //         update_info();
        //     }

        //     var apply = func {
        //         setprop("/sim/presets/airport-id", airport_id);
        //         setprop("/sim/presets/longitude-deg", -9999);
        //         setprop("/sim/presets/latitude-deg", -9999);
        //         setprop("/sim/presets/altitude-ft", -9999);
        //         setprop("/sim/presets/airspeed-kt", 0);
        //         setprop("/sim/presets/offset-distance-nm", 0);
        //         setprop("/sim/presets/offset-azimuth-deg", 0);
        //         setprop("/sim/presets/glideslope-deg", 0);
        //         setprop("/sim/presets/heading-deg", 0);

        //         if (mode["bestrunway"].getBoolValue()) {
        //             setprop("/sim/presets/runway", "");
        //             setprop("/sim/presets/parkpos", "");
        //             setprop("/sim/presets/runway-requested", 0);
        //         } else if (mode["runway"].getBoolValue()) {
        //             setprop("/sim/presets/runway", getprop("/sim/gui/dialogs/airports/selected-airport/rwy"));
        //             setprop("/sim/presets/parkpos", "");
        //             setprop("/sim/presets/runway-requested", 1);
        //         } else {
        //             setprop("/sim/presets/runway", "");
        //             setprop("/sim/presets/parkpos", getprop("/sim/gui/dialogs/airports/selected-airport/parkpos"));
        //         }
        //     }

        //     canvas.register_callback(update_info); # FIXME: this is a workaround to run dialog-specific code in the canvas block
        //     ]]>
        //     </open>
        //     <close><![CDATA[
        //     fgcommand("clear-metar", var n = props.Node.new({ "path": "/sim/gui/dialogs/airports/selected-airport/metar",
        //                                                             "station": airport_id}));
        //         #map.cleanup_listeners(); #TODO: We should be setting a signal when closing the dialog, so that cleanup code can be invoked automatically
        //         AirportChart.del();
        //         foreach (var l; listeners)
        //             removelistener(l);
        //         setsize(listeners, 0);
        //     ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                // padding*: 4
                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        GroupBox {
                            Layout.fillWidth: true

                            RowLayout {
                                width: parent.width

                                // padding*: 4
                                Label {
                                    text: qsTr("Airport:")
                                }

                                TextInput {
                                    id: input
                                    width: 120

                                    Layout.fillWidth: true
                                    // property*: /sim/gui/dialogs/airports/list
                                    // binding*: " dialog-apply input "
                                }

                                Button {
                                    text: qsTr("Search")
                                    // default*: true
                                    // binding*: " property-assign /sim/gui/dialogs/airports/mode search "
                                    // binding*: " dialog-apply input "
                                    // binding*: " nasal var apt_type = "airport:"; var heli_type = "heliport:"; var search_term = getprop("/sim/gui/dialogs/airports/list"); # strip off airport type prefix if (string.match(search_term,heli_type)) { search_term = string.substr(search_term,size(heli_type)); } else if (string.match(search_term,apt_type)) { search_term = string.substr(search_term,size(apt_type)); } var new_value = ""; # add new airport type prefix based off helipad checkbox if (getprop("/sim/gui/dialogs/airports/show-helipads")) { new_value = heli_type ~ search_term; } else { new_value = apt_type ~ search_term; } setprop("/sim/gui/dialogs/airports/list", new_value); "
                                    // binding*: " dialog-update airport-list "
                                }

                                Button {
                                    text: qsTr("<100nm")
                                    // binding*: " property-assign /sim/gui/dialogs/airports/mode 100nm "
                                    // binding*: " nasal # change airport type to heliport if checkbox is set var apt_type = "airport"; if (getprop("/sim/gui/dialogs/airports/show-helipads")) { apt_type = "heliport"; } var airports = findAirportsWithinRange(100,apt_type); var list = dlg.getNode("close-airports", 1); list.removeChildren("value"); forindex (var idx; airports) { list.getNode("value["~ idx ~ "]", 1).setValue(airports[idx].name ~ " (" ~ airports[idx].id ~ ")"); } "
                                    // binding*: " dialog-update close-airport-list "
                                }

                                CheckBox {
                                    id: show_helipads
                                    text: qsTr("Helipads")
                                    // property*: /sim/gui/dialogs/airports/show-helipads
                                    // binding*: " dialog-apply show-helipads "
                                }
                            } // RowLayout
                        }
                    } // ColumnLayout

                   GroupBox {
                       Layout.fillWidth: true

                       GridLayout {
                           width: parent.width
                       } // GridLayout

                       // padding*: 0
                       ListView {

                           // visible*: /sim/gui/dialogs/airports/mode 100nm
                           id: close_airport_list
                           width: 260
                           height: 260

                           Layout.fillWidth: true
                           // property*: /sim/gui/dialogs/airports/list

                           // binding*: " dialog-apply close-airport-list "
                           // binding*: " nasal listbox() "
                       }
                   }

                   GroupBox {
                       Layout.fillWidth: true

                       RowLayout {
                           width: parent.width
                       } // RowLayout

                       Label {
                           text: qsTr("METAR")
                       }

                       Rectangle {
                           width: parent.width
                           height: 2
                           color: "#DFAC01"
                       }
                   }

                   Label {
                       id: metar

                       Layout.fillWidth: true
                       width: 260
                       height: 70

                       Slider {}

                       // live*: true
                       // property*: /sim/gui/dialogs/airports/selected-airport/metar/data
                   }

                   GroupBox {
                       Layout.fillWidth: true

                       ColumnLayout {
                           width: parent.width

                           GroupBox {
                               Layout.fillWidth: true

                               RowLayout {
                                   width: parent.width

                                   Label {
                                       text: qsTr("Aircraft Position")
                                   }

                                   Rectangle {
                                       width: parent.width
                                       height: 2
                                       color: "#DFAC01"
                                   }
                               } // RowLayout
                           }

                           GroupBox {
                               Layout.fillWidth: true

                               GridLayout {
                                   width: parent.width
                               } // GridLayout

                               // property*: /sim/gui/dialogs/airports/use_best_runway
                               // live*: true
                               // binding*: " nasal set_radio("bestrunway") "
                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Best runway")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("(based on wind)")
                               }

                               // property*: /sim/gui/dialogs/airports/use_runway
                               // live*: true
                               // binding*: " nasal set_radio("runway") "
                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Runway:")
                               }

                               ComboBox {
                                   id: runway_list

                                   width: 85
                                   //horizontalAlignment: Text.AlignLeft

                                   // property*: /sim/gui/dialogs/airports/selected-airport/rwy

                                   // binding*: " dialog-apply runway-list "
                               }

                               // property*: /sim/gui/dialogs/airports/use_parkpos
                               // live*: true
                               // binding*: " nasal set_radio("parkpos") "
                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Parking:")
                               }

                               Text {

                                   id: parking_list
                                   width: 120

                                   Layout.fillWidth: true
                                   // property*: /sim/gui/dialogs/airports/selected-airport/parkpos
                                   // binding*: " dialog-apply parking-list "
                                   // binding*: " nasal var pos = getprop("/sim/gui/dialogs/airports/selected-airport/parkpos"); setprop( "/sim/gui/dialogs/airports/selected-airport/parkpos-invalid", contains(avail_parking, pos) == 0); "
                                   // binding*: " dialog-update parking-list-valid "
                               }

                               Label {

                                   id: parking_list_valid
                                   horizontalAlignment: Text.AlignLeft
                                   text: qsTr("Parking position not found")
                                   // visible*: /sim/gui/dialogs/airports/selected-airport/parkpos-invalid
                               }
                           }
                       } // ColumnLayout
                   }
                }
            } // RowLayout

            HorizontalLine {}

           GroupBox {
               Layout.fillWidth: true

               ColumnLayout {
                   width: parent.width

                   // padding*: 0
                   GroupBox {
                       Layout.fillWidth: true

                       RowLayout {
                           width: parent.width

                           //horizontalAlignment: Text.AlignLeft
                           // padding*: 2
                           Button {
                               text: qsTr("Airfield Information")
                               // binding*: " property-assign /sim/gui/dialogs/airports/display-mode 0 "
                           }

                           Button {
                               text: qsTr("Airfield Chart")
                               // binding*: " property-assign /sim/gui/dialogs/airports/display-mode 1 "
                           }
                       } // RowLayout
                   }

                   GroupBox {
                       Layout.fillWidth: true

                       GridLayout {
                           width: parent.width
                       } // GridLayout

                       // padding*: 0
                       GroupBox {
                           Layout.fillWidth: true

                           ColumnLayout {
                               width: parent.width

                               // visible*: /sim/gui/dialogs/airports/display-mode 1
                               GroupBox {
                                   Layout.fillWidth: true

                                   ColumnLayout {
                                       width: parent.width

                                       GroupBox {
                                           Layout.fillWidth: true

                                           RowLayout {
                                               width: parent.width

                                               Label {
                                                   text: qsTr("Airfield Chart")
                                               }

                                               Rectangle {
                                                   width: parent.width
                                                   height: 2
                                                   color: "#DFAC01"
                                               }

                                                // <canvas>
                                                //     <name>canvas-map</name>
                                                //     <valign>fill</valign>
                                                //     <halign>fill</halign>
                                                //     <stretch>true</stretch>
                                                //     <pref-width>600</pref-width>
                                                //     <pref-height>400</pref-height>
                                                //     <nasal><load><![CDATA[
                                                //         var myCanvas = canvas.get( cmdarg() );
                                                //         var mapGrp = myCanvas.createGroup();
                                                //         var AirportChart = mapGrp.createChild("map");

                                                //         # Initialize the controller:
                                                //         AirportChart.setController("Static position", "main");
                                                //         var controller = AirportChart.getController();

                                                //         # Initialize a range and screen resolution.  Setting a range
                                                //         # to 4nm means we pick up a good set of surrounding fixes
                                                //         # We will use the screen range for zooming.  If we use range
                                                //         # then as we zoom in the airport center goes out of range
                                                //         # and all the runways disappear.
                                                //         AirportChart.setRange(4.0);
                                                //         AirportChart.setScreenRange(500);

                                                //         var range_step = 1.5;

                                                //         # Center the map's origin: FIXME: move to api.nas, i.e. allow maps to have a size/view that differs from the actual canvas ??
                                                //         AirportChart.setTranslation(
                                                //             myCanvas.get("view[0]")/2,
                                                //             myCanvas.get("view[1]")/2
                                                //         );

                                                //         ##
                                                //         # Styling: This is a bit crude at the moment, i.e. no dedicated APIs yet - but it's
                                                //         # just there to prototype things for now
                                                //         var Styles = {};
                                                //         Styles.get = func(type) return Styles[type];
                                                //         var Options = {};
                                                //         Options.get = func(type) return Options[type];

                                                //         ## set up a few keys supported by the DME.symbol file to customize appearance:
                                                //         Styles.DME = {};
                                                //         Styles.DME.debug = 1; # HACK for benchmarking/debugging purposes
                                                //         Styles.DME.animation_test = 0; # for prototyping animated symbols

                                                //         Styles.DME.scale_factor = 0.4; # 40% (applied to whole group)
                                                //         Styles.DME.line_width = 3.0;
                                                //         Styles.DME.color_tuned = [0,1,0]; #rgb
                                                //         Styles.DME.color_default = [1,1,0];  #rgb

                                                //         Styles.APT = {};
                                                //         Styles.APT.scale_factor = 0.4; # 40% (applied to whole group)
                                                //         Styles.APT.line_width = 3.0;
                                                //         Styles.APT.color_default = [0,0.6,0.85];  #rgb
                                                //         Styles.APT.label_font_color = Styles.APT.color_default;
                                                //         Styles.APT.label_font_size=28;

                                                //         Styles.PARKING = {};
                                                //         Styles.PARKING.scale_factor = 0.4; # 40% (applied to whole group)
                                                //         Styles.PARKING.line_width = 3.0;
                                                //         Styles.PARKING.color_default = [0,0.85,0.6];  #rgb
                                                //         Styles.PARKING.label_font_color = Styles.APT.color_default;
                                                //         Styles.PARKING.label_font_size=28;

                                                //         Styles.FLT = {};
                                                //         Styles.FLT.line_width = 3;

                                                //         Styles.FIX = {};
                                                //         Styles.FIX.color = [1,0,0];
                                                //         Styles.FIX.scale_factor = 0.4; # 40%

                                                //         Styles.VOR = {};
                                                //         Styles.VOR.range_line_width = 2;
                                                //         Styles.VOR.radial_line_width = 1;
                                                //         Styles.VOR.scale_factor = 0.6; # 60%

                                                //         var ToggleLayerVisible = func(name) {
                                                //             (var l = AirportChart.getLayer(name)).setVisible(l.getVisible());
                                                //         };
                                                //         var SetLayerVisible = func(name,n=1) {
                                                //             AirportChart.getLayer(name).setVisible(n);
                                                //         };

                                                //         Styles.APS = {};
                                                //         Styles.APS.scale_factor = 0.25;

                                                //         var r = func(name,vis=1,zindex=nil) return caller(0)[0];
                                                //         # TODO: we'll need some z-indexing here, right now it's in the layer order
                                                //         foreach(var type; [r('TAXI',1,0),r('RWY',1,1),r('TWR',1,2),r('DME',0,3),r('VOR',0,4),r('NDB',0,5),r('FIX',0,6),r('PARKING',0,7)] ) {
                                                //             AirportChart.addLayer(factory: canvas.SymbolLayer, type_arg: type.name,
                                                //                              visible: type.vis, priority: 4,
                                                //                              style: Styles.get(type.name),
                                                //                              options: Options.get(type.name) );
                                                //             (func {
                                                //                 # Notify MapStructure about layer visibility changes:
                                                //                 var name = type.name;
                                                //                 props.globals.initNode("/sim/gui/dialogs/map-canvas/draw-"~name, type.vis, "BOOL");
                                                //                 append(listeners,
                                                //                     setlistener("/sim/gui/dialogs/map-canvas/draw-"~name,
                                                //                         func(n) SetLayerVisible(name,n.getValue()))
                                                //                 );


                                                //             })();
                                                //         }

                                                //         # Add some event listeners to handle mouse interactions
                                                //         myCanvas.addEventListener("drag", func(e)
                                                //         {
                                                //           (func {
                                                //           controller.applyOffset(-e.deltaX, -e.deltaY); })();
                                                //         });

                                                //         myCanvas.addEventListener("click", func(e)
                                                //         {
                                                //           (func {
                                                //           controller.applyOffset(e.localX - myCanvas.get("view[0]")/2,
                                                //                                  e.localY - myCanvas.get("view[1]")/2); })();
                                                //         });

                                                //         myCanvas.addEventListener("wheel", func(e)
                                                //         {
                                                //           var range = AirportChart.getScreenRange();
                                                //           if (e.deltaY >0) {
                                                //             if (range < 10000)
                                                //                 AirportChart.setScreenRange(range*range_step);
                                                //           } else {
                                                //             if (range > 100)
                                                //               AirportChart.setScreenRange(range/range_step);
                                                //           }
                                                //           setprop("/sim/gui/dialogs/airports/zoom-range", AirportChart.getScreenRange());
                                                //         });

                                                //         if ((getprop("/sim/gui/dialogs/airports/selected-airport/lat") != nil) and
                                                //             (getprop("/sim/gui/dialogs/airports/selected-airport/lon") != nil)    )
                                                //         {
                                                //           # If we've got some values from a previous instantiation of the dialog
                                                //           # then use them to display the correct position, consistent with the
                                                //           # rest of the dialog.
                                                //           AirportChart.getController().setPosition(
                                                //             getprop("/sim/gui/dialogs/airports/selected-airport/lat"),
                                                //             getprop("/sim/gui/dialogs/airports/selected-airport/lon"));
                                                //         }
                                                //     ]]></load></nasal>
                                                // </canvas>
                                           } // RowLayout
                                       }

                                       GroupBox {
                                           Layout.fillWidth: true

                                           RowLayout {
                                               width: parent.width

                                               CheckBox {
                                                   text: qsTr("Nav data")
                                                   //horizontalAlignment: Text.AlignLeft
                                                   // property*: /sim/gui/dialogs/map-canvas/draw-DME
                                                   // live*: true
                                                   // binding*: " property-toggle "
                                                   // binding*: " nasal var visible = ! getprop("/sim/gui/dialogs/map-canvas/draw-DME"); setprop("/sim/gui/dialogs/map-canvas/draw-DME", visible); setprop("/sim/gui/dialogs/map-canvas/draw-VOR", visible); setprop("/sim/gui/dialogs/map-canvas/draw-NDB", visible); setprop("/sim/gui/dialogs/map-canvas/draw-FIX", visible); dialog-apply "
                                               }

                                               CheckBox {
                                                   text: qsTr("Parking")
                                                   //horizontalAlignment: Text.AlignLeft
                                                   // property*: /sim/gui/dialogs/map-canvas/draw-PARKING
                                                   // live*: true
                                                   // binding*: " dialog-apply "
                                                   // binding*: " property-toggle "
                                               }

                                               Label {
                                                   Layout.fillWidth: true
                                               }

                                               Button {
                                                   id: zoomout
                                                   text: qsTr("+")
                                                   width: 52
                                                   height: 22
                                                   // binding*: " nasal var range = AirportChart.getScreenRange(); if (range < 10000) AirportChart.setScreenRange(range*range_step); setprop("/sim/gui/dialogs/airports/zoom-range", AirportChart.getScreenRange()); "
                                               }

                                               Label {
                                                   id: zoomdisplay
                                                   text: qsTr("MMMMMMMMMMMMM")
                                                   // format*: Zoom %d
                                                   // property*: /sim/gui/dialogs/airports/zoom-range
                                                   // live*: true
                                               }

                                               Button {
                                                   id: zoomin
                                                   text: qsTr("-")
                                                   width: 52
                                                   height: 22
                                                   // binding*: " nasal var range = AirportChart.getScreenRange(); if (range > 100) AirportChart.setScreenRange(range/range_step); setprop("/sim/gui/dialogs/airports/zoom-range", AirportChart.getScreenRange()); "
                                               }
                                           } // RowLayout
                                       }
                                   } // ColumnLayout
                               }
                           } // ColumnLayout
                       }

                       GroupBox {
                           Layout.fillWidth: true

                           GridLayout {
                               width: parent.width
                           } // GridLayout

                           // visible*: /sim/gui/dialogs/airports/display-mode 0
                           GroupBox {
                               Layout.fillWidth: true

                               GridLayout {
                                   width: parent.width
                               } // GridLayout

                               GroupBox {
                                   Layout.fillWidth: true

                                   RowLayout {
                                       width: parent.width

                                       Label {
                                           text: qsTr("Airfield Information")
                                       }

                                       Rectangle {
                                           width: parent.width
                                           height: 2
                                           color: "#DFAC01"
                                       }
                                   } // RowLayout
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Name:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("Athens Intl Airport Elefterios Venizel")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/name
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("ICAO:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("AAAA")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/id
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Lat / Lon:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("XXXXXXXXXXXX")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/location
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Elevation:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   // format*: %.0f ft
                                   // property*: /sim/gui/dialogs/airports/selected-airport/elevation-ft
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Longest runway:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   // format*: %.0f ft
                                   // property*: /sim/gui/dialogs/airports/selected-airport/longest-runway
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Distance:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   // format*: %.1f nm
                                   // property*: /sim/gui/dialogs/airports/selected-airport/distance-nm
                               }

                               Label {

                                   horizontalAlignment: Text.AlignRight
                                   text: qsTr("Course:")
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   // format*: %.0f deg
                                   // property*: /sim/gui/dialogs/airports/selected-airport/course-deg
                               }
                           }

                           GroupBox {
                               Layout.fillWidth: true

                               GridLayout {
                                   width: parent.width
                               } // GridLayout

                               // padding*: 2
                               GroupBox {
                                   Layout.fillWidth: true

                                   RowLayout {
                                       width: parent.width

                                       Label {
                                           text: qsTr("Communications Frequencies")
                                       }

                                       Rectangle {
                                           width: parent.width
                                           height: 2
                                           color: "#DFAC01"
                                       }
                                   } // RowLayout
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[0]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[0]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[1]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[1]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[2]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[2]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[3]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[3]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[4]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[4]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[5]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[5]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[6]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[6]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[7]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[7]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[8]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[8]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[9]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[9]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[10]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[10]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[11]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[11]/value
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("ACTIVATE LIGHTS")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[12]/label
                               }

                               Label {

                                   horizontalAlignment: Text.AlignLeft
                                   // live*: true
                                   text: qsTr("123.456 123.456")
                                   // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[12]/value
                               }
                           }

                           GroupBox {
                               Layout.fillWidth: true

                               GridLayout {
                                   width: parent.width
                               } // GridLayout

                               // padding*: 2
                               GroupBox {
                                   Layout.fillWidth: true

                                   RowLayout {
                                       width: parent.width

                                       Label {
                                           text: qsTr("Runways")
                                       }

                                       Rectangle {
                                           width: parent.width
                                           height: 2
                                           color: "#DFAC01"
                                       }
                                   } // RowLayout
                               }

                               Label {

                                   id: runways_info

                                   Layout.fillWidth: true
                                   width: 260
                                   height: 250

                                   Slider {}

                                   // property*: /sim/gui/dialogs/airports/selected-airport/runways-info
                               }
                           }
                       }
                   }
               } // ColumnLayout
           }
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Go To Airport")

            onClicked: {
                // binding*: " dialog-apply airport-list "
                // binding*: " nasal apply() "
                // binding*: " reposition "
                airportsDialog.closed(airportsDialog.id);
            }
        }

        Button {
            text: qsTr("Close")

            onClicked: {
                // binding*: " dialog-apply input "
                airportsDialog.closed(airportsDialog.id);
            } 
        }
    } // buttons
}
