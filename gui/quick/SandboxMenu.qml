import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

MenuBar {
    Menu {
        id: menuFile
        title: "File"

        MenuItem {
            id: reset
            text: "Reset"
            // shortcut: "Shift-Esc"
            onTriggered: {
                // command -> reset
            }
        }

        MenuSeparator { }

        MenuItem {
            id: load_tape
            text: "Load Flight Recorder Tape"
            // shortcut: "Shift-F1"
            onTriggered: {
                recorder_load_dialog.visible = true
            }
        }
        MenuItem {
            id: save_tape
            text: "Save Flight Recorder Tape"
            // shortcut: "Shift-F2"
            onTriggered: {
                recorder_save_dialog.visible = true
            }
        }

        MenuSeparator { }

        MenuItem {
            id: snap_shot
            text: "Screenshot"
            // shortcut: "F3"
            onTriggered: {
                // command -> nasal
                // script -> gui.popdown(); fgcommand("screen-capture");
            }
        }
        MenuItem {
            id: snap_shot_dir
            text: "Screenshot Directory"
            onTriggered: {
                // command -> nasal
                // script -> gui.set_screenshotdir()
            }
        }

        MenuSeparator { }

        MenuItem {
            id: sound_config
            text: "Sound Configuration"
            onTriggered: {
                sound_config_dialog.visible = true
            }
        }
        MenuItem {
            id: input_config
            text: "Mouse Configuration"
            onTriggered: {
                mouse_config_dialog.visible = true
            }
        }
        MenuItem {
            id: joystick_config
            text: "Joystick Configuration"
            onTriggered: {
                joystick_config_dialog.visible = true
            }
        }

        MenuSeparator { }

        MenuItem {
            id: terrasync
            text: "Scenery Download"
            onTriggered: {
                terrasync_dialog.visible = true
            }
        }
        MenuItem {
            id: aircraft_center
            text: "Aircraft Center (Experimental)"
            onTriggered: {
                // command -> open-launcher
            }
        }

        MenuSeparator { }

        MenuItem {
            id: exit
            text: "Quit"
            // shortcut: "Esc"
            onTriggered: {
                exit_dialog.visible = true
            }
        }
    }

    Menu {
        title: "View"

        MenuItem {
            id: toggle_fullscreen
            text: "Toggle Fullscreen"
            // shortcut: "Shift-F10"
            onTriggered: {
                // command -> toggle-fullscreen
            }
        }
        MenuItem {
            id: rendering_options
            text: "Rendering Options"
            onTriggered: {
                rendering_dialog.visible = true
            }
        }
        MenuItem {
            id: view_options
            text: "View Options"
            onTriggered: {
                view_options_dialog.visible = true
            }
        }
        MenuItem {
            id: cockpit_view_options
            text: "Cockpit View Options"
            onTriggered: {
                cockpit_view_dialog.visible = true
            }
        }
        MenuItem {
            id: adjust_lod
            text: "Adjust LOD Ranges"
            onTriggered: {
                static_lod_dialog.visible = true
            }
        }
        MenuItem {
            id: pilot_offset
            text: "Adjust View Position"
            onTriggered: {
                pilot_offset_dialog.visible = true
            }
        }
        MenuItem {
            id: adjust_hud
            text: "Adjust HUD Properties"
            onTriggered: {
                hud_dialog.visible = true
            }
        }
        MenuItem {
            id: toggle_glide_slope
            text: "Toggle Glide Slope Tunnel"
            onTriggered: {
                // command -> nasal
                // script -> var p = "/sim/rendering/glide-slope-tunnel"; setprop(p, var i = !getprop(p)); gui.popupTip("Glide slope tunnel " ~ (i ? "enabled" : "disabled"));
            }
        }
        MenuItem {
            id: replay
            text: "Instant Replay"
            // shortcut: "Ctrl-R"
            onTriggered: {
                replay_dialog.visible = true
                // command -> replay
            }
        }
        MenuItem {
            id: earthview
            text: "Earthview orbital rendering"
            onTriggered: {
                earthview_dialog.visible = true
            }
            enabled: true
        }
        MenuItem {
            id: stereoscopic_options
            text: "Stereoscopic View Options"
            onTriggered: {
                stereoscopic_view_options_dialog.visible = true
            }
            enabled: false
        }
    }

    Menu {
        title: "Location"

        MenuItem {
            id: position_in_air
            text: "Position Aircraft In Air"
            onTriggered: {
                location_inair_dialog.visible = true
            }
        }
        MenuItem {
            id: goto_airport
            text: "Select Airport"
            onTriggered: {
                airports_dialog.visible = true
            }
        }
        MenuItem {
            id: random_attitude
            text: "Random Attitude"
            onTriggered: {
                // command -> property-assign
                // property -> /sim/presets/trim
                // value -> false

                // command -> property-randomize
                // property -> /orientation/pitch-deg
                // min -> 0
                // max -> 360

                // command -> property-randomize
                // property -> /orientation/roll-deg
                // min -> 0
                // max -> 360

                // command -> property-randomize
                // property -> /orientation/heading-deg
                // min -> 0
                // max -> 360
            }
        }
        MenuItem {
            id: tower_position
            text: "Tower Position"
            onTriggered: {
                location_oftower_dialog.visible = true
            }
        }
    }

    Menu {
        title: "Autopilot"

        MenuItem {
            // shortcut: "F11"
            id: autopilot_settings
            text: "Autopilot Settings"
            onTriggered: {

                // command -> dialog-show
                // dialog -> autopilot
            }
        }
        MenuItem {
            id: route_manager
            text: "Route Manager"
            onTriggered: {
                route_manager_dialog.visible = true
            }
        }
        MenuItem {
            id: previous_waypoint
            text: "Previous Waypoint"
            onTriggered: {
                // command -> nasal
                // script -> setprop("/autopilot/route-manager/input", "@previous")
            }
        }
        MenuItem {
            id: next_waypoint
            text: "Next Waypoint"
            onTriggered: {
                // command -> nasal
                // script -> setprop("/autopilot/route-manager/input", "@next")
            }
        }
    }

    Menu {
        title: "Environment"

        MenuItem {
            id: global_weather
            text: "Weather"
            onTriggered: {
                weather_dialog.visible = true
            }
        }
        MenuItem {
            id: environment_settings
            text: "Environment Settings"
            onTriggered: {
                env_settings_dialog.visible = true
            }
        }
        MenuItem {
            id: time_settings
            text: "Time Settings"
            onTriggered: {
                time_ofday_dialog.visible = true
            }
        }
        MenuItem {
            id: wildfire_settings
            text: "Wildfire Settings"
            onTriggered: {
                // command -> nasal
                // script -> wildfire.dialog.show()
            }
        }
        MenuItem {
            id: volcanoes
            text: "Volcanoes"
            onTriggered: {
                volcanoes_dialog.visible = true
                // command -> nasal
                // script -> var varray = volcano.volcano_manager.volcano_array; var n = size(varray); var aircraft_pos = geo.aircraft_position(); var j = 0; for (var i = 0; i< n; i=i+1) { #print(i, " ", varray[i].name); var distance = aircraft_pos.distance_to(varray[i].pos); if (distance < 150000.0) # only add nearby objects { var name = varray[i].name; setprop("/environment/volcanoes/volcanoes-nearby/value["~j~"]", name); if (j==0) {setprop("/environment/volcanoes/volcano-selected", name);} j=j+1; } }
            }
        }
    }

    Menu {
        title: "Equipment"

        MenuItem {
            id: map
            text: "Map"
            // shortcut: "Ctrl-M"
            onTriggered: {
                map_dialog.visible = true
            }
        }
        MenuItem {
            id: map_canvas
            text: "Map (Canvas)"
            onTriggered: {
                map_canvas_dialog.visible = true
            }
        }
        MenuItem {
            id: map_browser
            text: "Map (opens in browser)"
            onTriggered: {
                // command -> nasal
                // script -> var n = props.globals.getNode("/sim/http/running"); if( props.globals.getNode("/").getValue("sim/http/running",0) != 1 ) { gui.popupTip("Internal webserver not running. Restart FlightGear with -httpd=8080", 5.0); } else { var _url = "http://localhost:" ~ getprop("/sim/http/options/listening-port") ~ "#Map"; fgcommand("open-browser", props.Node.new({ "url": _url })); }
            }
        }
        MenuItem {
            id: stopwatch
            text: "Stopwatch"
            onTriggered: {
                stopwatch_dialog.visible = true
            }
        }
        MenuItem {
            id: fuel_and_payload
            text: "Fuel and Payload"
            onTriggered: {
                // command -> nasal
                // script -> gui.showWeightDialog()
            }
        }
        MenuItem {
            // shortcut: "F12"
            id: radio
            text: "Radio Settings"
            onTriggered: {
                radios_dialog.visible = true
            }
        }
        MenuItem {
            id: gps
            text: "GPS Settings"
            onTriggered: {
                gps_dialog.visible = true
            }
        }
        MenuItem {
            id: instrument_settings
            text: "Instrument Settings"
            onTriggered: {
                instruments_dialog.visible = true
            }
        }
        MenuItem {
            id: failure_submenu
            text: "--- Failures ---"
            enabled: false
        }
        MenuItem {
            id: random_failures
            text: "Random Failures"
            onTriggered: {
                random_failures_dialog.visible = true
            }
        }
        MenuItem {
            id: system_failures
            text: "System Failures"
            onTriggered: {
                system_failures_dialog.visible = true
            }
        }
        MenuItem {
            id: instrument_failures
            text: "Instrument Failures"
            onTriggered: {
                instrument_failures_dialog.visible = true
            }
        }
    }

    Menu {
        title: "AI"

        MenuItem {
            id: scenario
            text: "Traffic and Scenario Settings"
            onTriggered: {
                scenario_dialog.visible = true
            }
        }
        MenuItem {
            id: atc_in_range
            text: "ATC Services in Range"
            onTriggered: {
                atc_freq_search_dialog.visible = true
            }
        }
        MenuItem {
            id: wingman
            text: "Wingman Controls"
            onTriggered: {
                formation_dialog.visible = true
            }
        }
        MenuItem {
            id: tanker
            text: "Tanker Controls"
            onTriggered: {
                tanker_dialog.visible = true
            }
        }
        MenuItem {
            id: jetway
            text: "Jetway Settings"
            onTriggered: {
                jetways_dialog.visible = true
            }
        }
        MenuItem {
            id: ai_objects
            text: "AI Objects"
            onTriggered: {
                ai_objects_dialog.visible = true
                // command -> nasal
                // script -> var carriers = props.globals.getNode("/ai/models").getChildren("carrier"); var i = 0; foreach(c; carriers) { var name = c.getNode("dlg-name",1).getValue(); if (name != nil) # check whether a dialog is defined at all { var aircraft_pos = geo.aircraft_position(); var carrier_lat = c.getNode("position").getNode("latitude-deg").getValue(); var carrier_lon = c.getNode("position").getNode("longitude-deg").getValue(); var carrier_pos = geo.Coord.new(); carrier_pos.set_latlon(carrier_lat, carrier_lon); var distance = aircraft_pos.distance_to(carrier_pos); if (distance < 50000.0) # only add nearby objects { setprop("/ai/control/objects-nearby/value["~i~"]", name); if (i==0) {setprop("/ai/control/object-selected", name);} i=i+1; } } }
            }
        }
    }

    Menu {
        title: "Multiplayer"

        MenuItem {
            id: mp_settings
            text: "Multiplayer Settings"
            onTriggered: {
                multiplayer_dialog.visible = true
            }
        }
        MenuItem {
            id: fgcom_settings
            text: "FGCom Settings"
            onTriggered: {
                fgcom_dialog.visible = true
            }
        }
        MenuItem {
            id: mp_chat
            text: "Chat Dialog"
            onTriggered: {
                chat_full_dialog.visible = true
            }
        }
        MenuItem {
            // shortcut: "-"
            id: mp_chat_menu
            text: "Chat Menu"
            onTriggered: {
                chat_menu_dialog.visible = true
            }
        }
        MenuItem {
            id: mp_list
            text: "Pilot List"
            onTriggered: {
                // command -> nasal
                // script -> multiplayer.dialog.show()
            }
        }
        MenuItem {
            id: mp_carrier
            text: "MPCarrier Selection"
            onTriggered: {
                ai_carrier_dialog.visible = true
                // command -> nasal
                // script -> if (contains(globals, "MPCarriers")) { MPCarriers.carrier_dialog.show(); } else { gui.popupTip("Found no MPCarriers for activated carrier AI scenarios within range.", 5.0); }
            }
        }
        MenuItem {
            id: lag_adjust
            text: "Lag Settings"
            onTriggered: {
                lag_adjust_dialog.visible = true
            }
        }
        MenuItem {
            id: swift_connection
            text: "SWIFT Connection"
            onTriggered: {
                swift_connection_dialog.visible = true
            }
        }
    }

    Menu {
        title: "Debug"

        Menu {
            id: reload
            title: "Reload"

            MenuItem {
                id: reload_gui
                text: "Reload GUI"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> gui
                }
            }
            MenuItem {
                id: reload_gui_qt
                text: "Reload GUI (Qt)"
                onTriggered: {
                    // command -> reload-quick-gui
                }
            }
            MenuItem {
                id: reload_input
                text: "Reload Input"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> input
                }
            }
            MenuItem {
                id: reload_hud
                text: "Reload HUD"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> hud
                }
            }
            MenuItem {
                id: reload_panel
                text: "Reload Panel"
                onTriggered: {
                    // command -> panel-load
                }
            }
            MenuItem {
                id: reload_autopilot
                text: "Reload Autopilot"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> xml-autopilot
                }
            }
            MenuItem {
                id: reload_network
                text: "Reload Network"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> io
                }
            }
            MenuItem {
                id: reload_model
                text: "Reload Aircraft Model"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> aircraft-model
                }
            }
            MenuItem {
                id: reload_materials
                text: "Reload Materials"
                onTriggered: {
                    // command -> reload-materials
                }
            }
            MenuItem {
                id: reload_scenery
                text: "Reload Scenery"
                onTriggered: {
                    // command -> reinit
                    // subsystem -> scenery
                }
            }
        }

        Menu {
            title: "Nasal"

            MenuItem {
                id: nasal_console
                text: "Nasal Console"
                onTriggered: {
                    nasal_console_dialog.visible = true
                }
            }
            MenuItem {
                id: nasal_repl_interpreter
                text: "Nasal REPL Interpreter"
                onTriggered: {
                    // command -> nasal
                    // script -> console.CanvasPlacement.new()
                }
            }
        }

        Menu {
            title: "Troubleshooting"

            MenuItem {
                id: dump_scene_graph
                text: "Dump Scene Graph"
                onTriggered: {
                    // command -> dump-scenegraph
                }
            }
            MenuItem {
                id: print_rendering_statistics
                text: "Print Rendering Statistics"
                onTriggered: {
                    // command -> property-assign
                    // property -> /sim/rendering/print-statistics
                    // value -> true
                }
            }
            MenuItem {
                id: statistics_display
                text: "Cycle On-Screen Statistics"
                onTriggered: {
                    // command -> property-adjust
                    // property -> /sim/rendering/on-screen-statistics
                    // step -> 1
                }
            }
            MenuItem {
                id: performance_monitor
                text: "Monitor System Performance"
                onTriggered: {
                    // command -> property-assign
                    // property -> /nasal/performance_monitor/enabled
                    // value -> true

                    // command -> nasal
                    // script -> performance_monitor.dialog.show()
                }
            }
        }

        MenuItem {
            id: development_keys
            text: "Development Keys"
            onTriggered: {
                // command -> nasal
                // script -> gui.showHelpDialog("/sim/help/debug")
            }
        }
        MenuItem {
            id: configure_dev_extension
            text: "Configure Development Extensions"
            onTriggered: {
                dev_extensions_dialog.visible = true
            }
        }
        MenuItem {
            id: display_marker
            text: "Display Tutorial Marker"
            onTriggered: {
                marker_adjust_dialog.visible = true
                // command -> nasal
                // script -> setprop("/nasal/tutorial/enabled",1); # load module on demand tutorial.dialog();
            }
        }
        MenuItem {
            id: write_video_config
            text: "Save Video Configuration"
            onTriggered: {
                // command -> nasal
                // script -> video.save()
            }
        }
        MenuItem {
            id: property_browser
            text: "Browse Internal Properties"
            onTriggered: {
                // command -> nasal
                // script -> gui.property_browser()
            }
        }
        MenuItem {
            id: fg1000_pfd
            text: "FG1000 PFD"
            onTriggered: {
                // command -> nasal
                // script -> var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/"; if (! defined("fg1000")) { io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000"); io.load_nasal(nasal_dir ~ 'Interfaces/GenericInterfaceController.nas', "fg1000"); } var fg1000system = fg1000.FG1000.getOrCreateInstance(); var pfdindex = fg1000system.addPFD(); fg1000system.displayGUI(pfdindex); # Start the interface controller after the FG1000, as it will publish # immediately and update the NAV/COM data. var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance(); interfaceController.stop(); interfaceController.start();
            }
        }
        MenuItem {
            id: fg1000_mfd
            text: "FG1000 MFD"
            onTriggered: {
                // command -> nasal
                // script -> var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/"; if (! defined("fg1000")) { io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000"); io.load_nasal(nasal_dir ~ 'Interfaces/GenericInterfaceController.nas', "fg1000"); } var fg1000system = fg1000.FG1000.getOrCreateInstance(); var mfdindex = fg1000system.addMFD(); fg1000system.displayGUI(mfdindex); # Start the interface controller after the FG1000, as it will publish # immediately and update the NAV/COM data. var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance(); interfaceController.stop(); interfaceController.start();
            }
        }
        MenuItem {
            id: logging
            text: "Logging"
            onTriggered: {
                logging_dialog.visible = true
            }
        }
        MenuItem {
            id: local_weather
            text: "Local Weather (Test)"
            enabled: false
            onTriggered: {
                local_weather_dialog.visible = true
            }
        }
        MenuItem {
            id: print_scene_info
            text: "Print Visible Scene Info"
            onTriggered: {
                // command -> print-visible-scene
            }
        }
        MenuItem {
            id: rendering_buffers
            text: "Hide/Show Rendering Buffers"
            onTriggered: {
                // command -> property-toggle
                // property -> /sim/rendering/rembrandt/show-buffers
            }
            enabled: false
        }
        MenuItem {
            id: rembrandt_buffers_choice
            text: "Select Rendering Buffers"
            onTriggered: {
                rembrandt_buffers_dialog.visible = true
            }
            enabled: false
        }
        MenuItem {
            id: cycle_gui
            text: "Cycle GUI Style"
            onTriggered: {
                // command -> nasal
                // script -> gui.nextStyle()
            }
        }
    }

    Menu {
        title: "Help"

        MenuItem {
            id: help_browser
            text: "Help (opens in browser)"
            onTriggered: {
                // command -> open-browser
                // path -> Docs/index.html
            }
        }
        MenuItem {
            id: doc_browser
            text: "Documentation Browser"
            onTriggered: {
                doc_browser_dialog.visible = true
            }
        }
        MenuItem {
            // shortcut: "?"
            id: aircraft_keys
            text: "Aircraft Help..."
            onTriggered: {
                // command -> nasal
                // script -> gui.showHelpDialog("/sim/help")
            }
        }
        MenuItem {
            id: aircraft_checklists
            text: "Aircraft Checklists..."
            onTriggered: {
                checklist_dialog.visible = true
            }
        }
        MenuItem {
            id: common_keys
            text: "Common Aircraft Keys..."
            onTriggered: {
                // command -> nasal
                // script -> gui.showHelpDialog("/sim/help/common")
            }
        }
        MenuItem {
            id: basic_keys
            text: "Basic Simulator Keys..."
            onTriggered: {
                help_basic_keys_dialog.visible = true
            }
        }

        MenuSeparator { }

        MenuItem {
            id: tutorial_start
            text: "Tutorials..."
            onTriggered: {
                tutorial_dialog.visible = true
            }
        }
        MenuItem {
            id: menu_about
            text: "About..."
            onTriggered: {
                about_dialog.visible = true
            }
        }
    }
}
