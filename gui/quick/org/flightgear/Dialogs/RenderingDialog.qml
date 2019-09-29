import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: renderingDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: renderingDialog.id
    title: "Rendering Options"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //     <![CDATA[
        //         var getScenerySuffix = func(layer) {
        //             var suffixes = props.globals.getNode("/sim/rendering", 1).getChildren("scenery-path-suffix");
        //             #printf("Looking for suffix " ~ layer);

        //             foreach (var p; suffixes) {
        //                 #printf("Checking suffix " ~ p.getNode("name",1).getValue());
        //                 #printf("Checking suffix enabled " ~ p.getNode("enabled",1).getValue());
        //                 if (p.getNode("name",1).getValue() == layer) {
        //                     #printf("Found layer " ~ layer ~ " value: " ~ p.getNode("enabled", 1).getValue() ~ " " ~ p.getNode("enabled", 1).getBoolValue());
        //                     return p.getNode("enabled", 1).getBoolValue();
        //                 }
        //             }

        //             return 0;
        //         }

        //         var setScenerySuffix = func(layer, enable) {
        //             var suffixes = props.globals.getNode("/sim/rendering", 1).getChildren("scenery-path-suffix");
        //             #printf("Setting scenery suffix" ~ layer ~ " to " ~ enable);

        //             foreach (var p; suffixes) {
        //                 if (p.getNode("name",1).getValue() == layer) {
        //                     #printf("Matched scenery suffix" ~ layer ~ " to " ~ enable);
        //                     p.getNode("enabled", 1).setBoolValue(enable);
        //                 }
        //             }
        //         }

        //         var materials = {
        //             "Region-specific" : "Materials/regions/materials.xml",
        //             "Global" : "Materials/default/materials.xml",
        //             "Global alternative (DDS format)" : "Materials/dds/materials.xml"
        //         };


        //         gui.enable_widgets(cmdarg(), "shadows-debug", getprop("/sim/gui/devel-widgets"));
        //         props.globals.getNode("/sim/rendering/shaders/quality-level", 1).setAttribute("userarchive", 0);
        //         setprop("/sim/gui/frame-rate-throttled", (getprop("/sim/frame-rate-throttle-hz") > 0));

        //         var matfile = getprop("/sim/rendering/materials-file");
        //         foreach (var name; keys(materials)) {
        //             if (matfile == materials[name]) {
        //                 setprop("/sim/gui/dialogs/rendering/texture-set", name);
        //             }
        //         }

        //         var vendor = getprop("/sim/rendering/gl-vendor");
        //         if (vendor != nil) {
        //             vendor = string.lc(vendor);
        //             if (find("intel", vendor) != -1) {
        //                 setprop("/sim/gui/dialogs/rendering/shader-warning", 1);
        //             } else {
        //                 setprop("/sim/gui/dialogs/rendering/shader-warning", 0);
        //             }
        //         }

        //         # Mapping from underlying properties to those used by the GUI.

        //         if (getScenerySuffix("Pylons")) {
        //             setprop("/sim/gui/dialogs/rendering/pylons", "Enabled");
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/pylons", "Disabled");
        //         }

        //         if (getScenerySuffix("Roads")) {
        //             setprop("/sim/gui/dialogs/rendering/roads", "Enabled");
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/roads", "Disabled");
        //         }

        //         if (getScenerySuffix("Buildings")) {
        //             setprop("/sim/gui/dialogs/rendering/buildings", "OpenStreetMap Data");
        //         } else if (getprop("/sim/rendering/random-buildings")) {
        //             setprop("/sim/gui/dialogs/rendering/buildings", "Random");
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/buildings", "Disabled");
        //         }

        //         if (getprop("/sim/rendering/random-objects")) {
        //             setprop("/sim/gui/dialogs/rendering/random-objects", "Enabled");
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/random-objects", "Disabled");
        //         }

        //         if (getprop("/sim/rendering/random-vegetation")) {
        //             var density = getprop("/sim/rendering/vegetation-density");
        //             if (density < 0.2) {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "Ultra Low Density");
        //                 # 0.1
        //             } else if (density < 0.4) {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "Very Low Density");
        //                 # 0.25
        //             } else if (density < 0.8) {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "Low Density");
        //                 # 0.5
        //             } else if (density < 1.5) {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "Medium Density");
        //                 # 1.0
        //             } else if (density < 3.0) {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "High Density");
        //                 # 2.0
        //             } else if (density < 6.0) {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "Very High Density");
        //                 # 4.0
        //             } else {
        //                 setprop("/sim/gui/dialogs/rendering/random-vegetation", "Ultra High Density");
        //                 # 8.0
        //             }
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/random-vegetation", "Disabled");
        //         }

        //         if (getprop("/sim/rendering/random-vegetation-shadows")) {
        //             setprop("/sim/gui/dialogs/rendering/vegetation-shadows", "Enabled");
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/vegetation-shadows", "Disabled");
        //         }

        //         if (getScenerySuffix("Objects")) {
        //             setprop("/sim/gui/dialogs/rendering/placed-objects", "Enabled");
        //         } else {
        //             setprop("/sim/gui/dialogs/rendering/placed-objects", "Disabled");
        //         }


        //         var reload_props = [
        //             "/sim/rendering/materials-file",
        //             "/sim/rendering/osm-buildings",
        //             "/sim/rendering/random-buildings",
        //             "/sim/rendering/random-objects",
        //             "/sim/rendering/random-vegetation",
        //             "/sim/rendering/random-vegetation-shadows",
        //             "/sim/rendering/vegetation-density",
        //             "/sim/rendering/clouds3d-enable",
        //             "/sim/rendering/clouds3d-density",
        //             "/sim/rendering/scenery-path-suffix[0]/enabled",
        //             "/sim/rendering/scenery-path-suffix[1]/enabled",
        //             "/sim/rendering/scenery-path-suffix[2]/enabled",
        //             "/sim/rendering/scenery-path-suffix[3]/enabled",
        //             "/sim/rendering/scenery-path-suffix[4]/enabled",
        //             "/sim/rendering/scenery-path-suffix[5]/enabled",
        //             "/sim/rendering/scenery-path-suffix[6]/enabled"
        //         ];

        //         var reload_vals = {};
        //         foreach (var p; reload_props) {
        //             reload_vals[p] = getprop(p);
        //         }
        //     ]]>
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr("Warning: Intel integrated graphics detected. Your graphics card may not support shaders or complex graphics.")
            // visible*: /sim/gui/dialogs/rendering/shader-warning 1
            color: "#FF9999"
        }

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

                RowLayout {
                    width: parent.width

                    Label {
                        text: qsTr("General")
                        horizontalAlignment: Text.AlignLeft
                    }

                    Rectangle {
                        width: parent.width
                        height: 2
                        color: "#DFAC01"
                    }
                } // RowLayout

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Wireframe")
                    id: wireframe
                    // property*: /sim/rendering/wireframe
                    // binding*: " dialog-apply wireframe "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Use point sprites for runway lights")
                    // property*: /sim/rendering/point-sprites
                    // binding*: " dialog-apply "
                }

                RowLayout {
                    width: parent.width
                    //horizontalAlignment: Text.AlignLeft

                    CheckBox {
                        text: qsTr("Throttle frame rate")
                        id: frame_rate_throttle
                        // property*: /sim/gui/frame-rate-throttled
                        // binding*: " dialog-apply frame-rate-throttle "
                        // binding*: " nasal var throttled = getprop("/sim/gui/frame-rate-throttled"); if (throttled) setprop("/sim/frame-rate-throttle-hz", 50); else setprop("/sim/frame-rate-throttle-hz", 0); "
                    }

                    Label {
                        width: 46
                    }

                    Slider {
                        id: frame_rate
                        // visible*: /sim/frame-rate-throttle-hz 0
                        // live*: true
                        // property*: /sim/frame-rate-throttle-hz
                        // binding*: " dialog-apply frame-rate "
                    }

                    Label {
                        // visible*: /sim/frame-rate-throttle-hz 0
                        text: qsTr("99 Hz")
                        // format*: %2.0f Hz
                        // live*: true
                        // property*: /sim/frame-rate-throttle-hz
                    }
                } // RowLayout

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Compensate field of view for wider screens")
                    // property*: sim/current-view/field-of-view-compensation
                    // binding*: " nasal view.screenWidthCompens.toggle() "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Animated jetways")
                    id: jetways
                    // property*: /nasal/jetways/enabled
                    // binding*: " dialog-apply jetways "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Use disk space for faster loading (DDS Texture Cache)")
                    id: texture_cache_enabled
                    // property*: /sim/rendering/texture-cache/cache-enabled
                    // binding*: " dialog-apply texture-cache-enabled "
                }

                Label {
                    Layout.fillWidth: true
                }

                RowLayout {
                    width: parent.width

                    Label {
                        text: qsTr("Scenery Layers")
                        horizontalAlignment: Text.AlignLeft
                    }

                    Rectangle {
                        width: parent.width
                        height: 2
                        color: "#DFAC01"
                    }
                } // RowLayout

                GridLayout {
                    width: parent.width
                    columns: 5

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Pylons and power lines")
                    }

                    ComboBox {
                        id: pylons
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/pylons
                        // binding*: " dialog-apply pylons "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/pylons"); if (val == "Enabled") { setScenerySuffix("Pylons", 1); } else { setScenerySuffix("Pylons", 0); } "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Detailed Roads and Railways")
                    }

                    ComboBox {
                        id: roads
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/roads
                        // binding*: " dialog-apply roads "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/roads"); if (val == "Enabled") { setScenerySuffix("Roads", 1); } else { setScenerySuffix("Roads", 0); } "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Buildings")
                    }

                    ComboBox {
                        id: buildings
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/buildings
                        // binding*: " dialog-apply buildings "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/buildings"); if (val == "Disabled") { setprop("/sim/rendering/random-buildings", 0); setprop("/sim/rendering/osm-buildings", 0); setScenerySuffix("Buildings", 0); } if (val == "Randomly Generated") { setprop("/sim/rendering/random-buildings", 1); setprop("/sim/rendering/osm-buildings", 0); setScenerySuffix("Buildings", 0); } if (val == "OpenStreetMap Data") { setprop("/sim/rendering/random-buildings", 0); setprop("/sim/rendering/osm-buildings", 1); setScenerySuffix("Buildings", 1); } "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Random Scenery Objects")
                    }

                    ComboBox {
                        id: random_objects
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/random-objects
                        // binding*: " dialog-apply random-objects "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/random-objects"); if (val == "Enabled") { setprop("/sim/rendering/random-objects", 1); } else { setprop("/sim/rendering/random-objects", 0); } "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Vegetation")
                    }

                    ComboBox {
                        id: random_vegetation
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/random-vegetation
                        // binding*: " dialog-apply random-vegetation "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/random-vegetation"); if (val == "Disabled") { setprop("/sim/rendering/random-vegetation", 0); } if (val == "Ultra Low Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 0.1); } if (val == "Very Low Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 0.25); } if (val == "Low Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 0.5); } if (val == "Medium Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 1.0); } if (val == "High Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 2.0); } if (val == "Very High Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 4.0); } if (val == "Ultra High Density") { setprop("/sim/rendering/random-vegetation", 1); setprop("/sim/rendering/vegetation-density", 8.0); } "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Vegetation Shadows")
                    }

                    ComboBox {
                        id: vegetation_shadows
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/vegetation-shadows
                        // binding*: " dialog-apply vegetation-shadows "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/vegetation-shadows"); if (val == "Enabled") { setprop("/sim/rendering/random-vegetation-shadows", 1); } else { setprop("/sim/rendering/random-vegetation-shadows", 0); } "
                    }

                    Label {
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Scenery Objects")
                    }

                    ComboBox {
                        id: placed_objects
                        width: 200
                        // property*: /sim/gui/dialogs/rendering/placed-objects
                        // binding*: " dialog-apply placed-objects "
                        // binding*: " nasal var val = getprop("/sim/gui/dialogs/rendering/placed-objects"); if (val == "Enabled") { setScenerySuffix("Objects", 1); } else { setScenerySuffix("Objects", 0); } "
                    }

                    Label {
                        text: qsTr("Terrain Textures")
                        horizontalAlignment: Text.AlignLeft
                    }

                    ComboBox {
                        id: texture_set
                        width: 200
                        // property*: sim/gui/dialogs/rendering/texture-set
                        // binding*: " dialog-apply texture-set "
                        // binding*: " nasal var file = materials[getprop("/sim/gui/dialogs/rendering/texture-set")]; setprop("/sim/rendering/materials-file", file); "
                        // binding*: " reload-materials "
                    }

                    Label {
                        text: qsTr("Warning: Pylons, Detailed Roads, Buildings use a lot of memory")
                        horizontalAlignment: Text.AlignLeft
                        color: "#FF9999"
                    }

                    Label {
                        text: qsTr("and disk space, and are only available in limited areas.")
                        horizontalAlignment: Text.AlignLeft
                        color: "#FF9999"
                    }
                } // GridLayout
            } // ColumnLayout

            ColumnLayout {
                width: parent.width
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    Label {
                        text: qsTr(" ")
                    }
                } // ColumnLayout

                HorizontalLine {}

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    Label {
                        text: qsTr(" ")
                    }
                } // ColumnLayout

                ColumnLayout {
                    width: parent.width

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Shader Effects")
                            horizontalAlignment: Text.AlignLeft
                        }

                        Rectangle {
                            width: parent.width
                            height: 2
                            color: "#DFAC01"
                        }
                    } // RowLayout

                    GridLayout {
                        width: parent.width

                        CheckBox {
                            id: custom_settings
                            text: qsTr("Custom settings (fine-tuning)")
                            //horizontalAlignment: Text.AlignLeft
                            // property*: /sim/rendering/shaders/custom-settings
                            // binding*: " dialog-apply custom-settings "
                        }

                        RowLayout {
                            width: parent.width

                            // visible*: /sim/rendering/shaders/custom-settings

                            Label {
                                text: qsTr("Performance")
                            }

                            Slider {
                                id: quality_level

                                // property*: /sim/rendering/shaders/quality-level-internal
                                // binding*: " dialog-apply quality-level "
                            }

                            Label {
                                text: qsTr("Quality")
                            }

                            Label {
                                text: qsTr("12345678")
                                // format*: (%1.0f)
                                // live*: true
                                // property*: /sim/rendering/shaders/quality-level-internal
                            }
                        } // RowLayout

                        RowLayout {
                            width: parent.width

                            // visible*: /sim/rendering/shaders/custom-settings /sim/rendering/shaders/skydome

                            Button {
                                text: qsTr("Shader Options")
                                //horizontalAlignment: Text.AlignLeft
                                // binding*: " dialog-show shaders "
                                // binding*: " dialog-close rendering "
                                width: 200
                            }
                        } // RowLayout

                        RowLayout {
                            width: parent.width

                            // visible*: /sim/rendering/shaders/custom-settings /sim/rendering/shaders/skydome /sim/rendering/rembrandt/enabled

                            Button {
                                text: qsTr("Shader Options")
                                //horizontalAlignment: Text.AlignLeft
                                // binding*: " dialog-show shaders-lightfield "
                                // binding*: " dialog-close rendering "
                                width: 200
                            }
                        } // RowLayout
                    } // GridLayout

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Atmospheric Effects")
                            horizontalAlignment: Text.AlignLeft
                        }

                        Rectangle {
                            width: parent.width
                            height: 2
                            color: "#DFAC01"
                        }
                    } // RowLayout

                    CheckBox {
                        id: particles
                        text: qsTr("Particles (smoke, dust, spray)")
                        //horizontalAlignment: Text.AlignLeft
                        // property*: /sim/rendering/particles
                        // binding*: " dialog-apply particles "
                    }

                    CheckBox {
                        id: precipitation
                        text: qsTr("Precipitation")
                        //horizontalAlignment: Text.AlignLeft
                        // property*: /sim/rendering/precipitation-gui-enable
                        // binding*: " dialog-apply precipitation "
                    }

                    CheckBox {
                        id: clouds_3d
                        text: qsTr("3D clouds")
                        //horizontalAlignment: Text.AlignLeft
                        // property*: /sim/rendering/clouds3d-enable
                        // binding*: " dialog-apply 3d-clouds "
                    }

                    RowLayout {
                        width: parent.width
                        //horizontalAlignment: Text.AlignRight

                        Label {
                            text: qsTr("Cloud density")
                        }

                        Slider {
                            id: cloud_density
                            // property*: /sim/rendering/clouds3d-density
                            // binding*: " dialog-apply cloud-density "
                            // binding*: " property-toggle /sim/rendering/clouds3d-enable "
                            // binding*: " property-toggle /sim/rendering/clouds3d-enable "
                        }

                        Label {
                            text: qsTr("12345678")
                            // format*: %.2f
                            // live*: true
                            // property*: /sim/rendering/clouds3d-density
                        }
                    } // RowLayout

                    RowLayout {
                        width: parent.width
                        //horizontalAlignment: Text.AlignRight

                        Label {
                            text: qsTr("Cloud visibility range")
                        }

                        Slider {
                            id: cloud_vis_range
                            // property*: /sim/rendering/clouds3d-vis-range
                            // binding*: " dialog-apply cloud-vis-range "
                        }

                        Label {
                            text: qsTr("12345678")
                            // format*: %.fm
                            // live*: true
                            // property*: /sim/rendering/clouds3d-vis-range
                        }
                    } // RowLayout

                    GridLayout {
                        width: parent.width
                        columns: 5

                        ColumnLayout {
                            width: parent.width
                            height: 35
                            //horizontalAlignment: Text.AlignLeft

                            CheckBox {
                                //horizontalAlignment: Text.AlignLeft
                                text: qsTr("Atmospheric Light Scattering (ALS)")
                                id: skydome_scattering
                                // property*: /sim/rendering/shaders/skydome
                                // binding*: " dialog-apply skydome-scattering "
                            }
                        } // ColumnLayout

                        Button {
                            text: qsTr("Filter settings (experimental)")

                            // binding*: " dialog-show als-filters "
                            // binding*: " dialog-close rendering "
                            width: 200
                        }

                        RowLayout {
                            width: parent.width

                            Label {
                                text: qsTr("Rembrandt")
                                horizontalAlignment: Text.AlignLeft
                            }

                            Label {
                                text: qsTr("(experimental)")
                                horizontalAlignment: Text.AlignLeft
                                color: "#FF9999"
                            }

                            Rectangle {
                                width: parent.width
                                height: 2
                                color: "#DFAC01"
                            }
                        } // RowLayout

                        Button {
                            text: qsTr("Rembrandt Options")

                            // binding*: " dialog-show rembrandt "
                            // binding*: " dialog-close rendering "
                            width: 200
                        }
                    } // GridLayout

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
            } // ColumnLayout
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr(" OK ")
            // binding*: " nasal var reinit = 0; foreach (var p; reload_props) { if (reload_vals[p] != getprop(p)) { reinit = 1; } } if (reinit) { fgcommand("reinit", props.Node.new({"subsystem": "scenery"})); } "
            onClicked: {
                renderingDialog.closed(renderingDialog.id);
            }
        }

    } // buttons
}
