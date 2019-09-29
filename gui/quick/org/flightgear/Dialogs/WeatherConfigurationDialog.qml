import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: weatherConfigurationDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: weatherConfigurationDialog.id
    title: "Basic Troposphere Weather Conditions"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var normalize_string = func(src) {
        //             if( src == nil ) src = "";
        //             var dst = "";
        //             for( var i = 0; i < size(src); i+=1 ) {
        //                 if( src[i] == `\n` or src[i] == `\r` )
        //                     src[i] = ` `;

        //                 if( i != 0 and src[i] == ` ` and src[i-1] == ` ` )
        //                     continue;

        //                 dst = dst ~ " ";
        //                 dst[size(dst)-1] = src[i];
        //             }
        //             return dst;
        //         }

        //         var GlobalWeatherDialogController = {

        //         new : func( dlgRoot ) {
        //             var obj = { parents: [GlobalWeatherDialogController] };
        //             obj.dlgRoot = dlgRoot;
        //             obj.base = "sim/gui/dialogs/weather-scenario";
        //             obj.baseN = props.globals.getNode( obj.base, 1 );

        //             return obj;
        //         },

        //         open : func {
        //             for( var i = 0; i < 5; i+=1 )
        //             me.initTurbulence("aloft", i );

        //             for( var i = 0; i < 2; i+=1 )
        //             me.initTurbulence("boundary", i );
        //         },

        //         close : func {
        //         },

        //         setTurbulence : func( where, idx ) {
        //             var propPath = "/environment/config/" ~ where ~ "/entry[" ~ idx ~ "]/";
        //             setprop( propPath ~ "turbulence/magnitude-norm", 
        //             me.turbulenceNames[getprop(propPath ~ "turbulence-name")]/(size(me.turbulenceNames)-1) );
        //         },

        //         initTurbulence : func( where, idx ) {
        //             var propPath = "/environment/config/" ~ where ~ "/entry[" ~ idx ~ "]/";
        //             var turb = getprop( propPath ~ "turbulence/magnitude-norm" ) * (size(me.turbulenceNames)-1);
        //             turb = int(int(10*turb+5)/10); # round to nearest integer
        //             foreach( var t; keys(me.turbulenceNames) ) {
        //                 if( me.turbulenceNames[t] == turb ) {
        //                     setprop( propPath ~ "turbulence-name", t );
        //                     break;
        //                 }
        //             }
        //         },

        //         turbulenceNames : { "none" : 0, "light" : 1, "moderate" : 2, "severe" : 3 },

        //         };

        //     var controller = GlobalWeatherDialogController.new( cmdarg() );
        //     controller.open();
        // ]]></open>

        // <close><![CDATA[
        //     controller.close();
        // ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0

            Label {
                text: qsTr(" ")
            }

            ColumnLayout {
                width: parent.width

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Cloud Layers (All Altitudes ft-AMSL)")
                        }

                        HorizontalLine {}
                    } // RowLayout

                    RowLayout {
                        width: parent.width

                        GridLayout {
                            width: parent.width
                            columns: 5

                            Label {
                                text: qsTr("Altitude (ft)")
                            }

                            Label {
                                text: qsTr("Coverage")
                                width: 80
                            }

                            Label {
                                text: qsTr("Thickness (ft)")
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[4]/elevation-ft
                                // binding*: " dialog-apply "
                            }

                            ComboBox {
                                width: 100
                                // live*: true
                                // property*: /environment/clouds/layer[4]/coverage
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[4]/thickness-ft
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[3]/elevation-ft
                                // binding*: " dialog-apply "
                            }

                            ComboBox {
                                width: 100
                                // live*: true
                                // property*: /environment/clouds/layer[3]/coverage
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[3]/thickness-ft
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[2]/elevation-ft
                                // binding*: " dialog-apply "
                            }

                            ComboBox {
                                width: 100
                                // live*: true
                                // property*: /environment/clouds/layer[2]/coverage
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[2]/thickness-ft
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[1]/elevation-ft
                                // binding*: " dialog-apply "
                            }

                            ComboBox {
                                width: 100
                                // live*: true
                                // property*: /environment/clouds/layer[1]/coverage
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[1]/thickness-ft
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[0]/elevation-ft
                                // binding*: " dialog-apply "
                            }

                            ComboBox {
                                width: 100
                                // live*: true
                                // property*: /environment/clouds/layer[0]/coverage
                                // binding*: " dialog-apply "
                            }

                            TextInput {
                                // live*: true
                                // property*: /environment/clouds/layer[0]/thickness-ft
                                // binding*: " dialog-apply "
                            }
                        } // GridLayout

                        Label {
                            Layout.fillWidth: true
                        }
                    } // RowLayout
                } // ColumnLayout

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Precipitation")
                        }

                        HorizontalLine {}
                    } // RowLayout

                    ColumnLayout {
                        width: parent.width

                        GridLayout {
                            width: parent.width
                            columns: 5

                            Label {
                                text: qsTr("Rain")
                                horizontalAlignment: Text.AlignLeft
                            }

                            Slider {
                                // live*: true
                                // property*: /environment/rain-norm
                                // binding*: " dialog-apply "
                                Layout.fillWidth: true
                            }

                            Label {
                                text: qsTr("Snow")
                                horizontalAlignment: Text.AlignLeft
                            }

                            Slider {
                                // property*: /environment/snow-norm
                                // live*: true
                                height: 30
                                // binding*: " dialog-apply "
                            }

                            Label {
                                text: qsTr("QNH (inHg)")
                            }

                            TextInput {
                                id: pressure_sea_level_inhg
                                width: 75
                                // property*: /environment/config/boundary/entry[0]/pressure-sea-level-inhg
                                // live*: true
                                // binding*: " dialog-apply pressure-sea-level-inhg "
                            }
                        } // GridLayout

                        Label {
                            Layout.fillWidth: true
                        }
                    } // ColumnLayout
                } // ColumnLayout

                Label {
                    Layout.fillWidth: true
                }
            } // ColumnLayout

            HorizontalLine {}

            ColumnLayout {
                width: parent.width

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr(" Aloft (All Altitudes ft-AMSL)")
                        }

                        Rectangle {
                            width: parent.width
                            height: 2
                            color: "#DFAC01"
                        }
                    } // RowLayout

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr(" ")
                        }

                        GridLayout {
                            width: parent.width
                            columns: 5

                            Label {
                                text: qsTr("Altitude ")
                            }

                            Label {
                                text: qsTr("Wind (dir/kt)")
                            }

                            Label {
                                text: qsTr("Vis (m)")
                            }

                            Label {
                                text: qsTr("Temp (C)")
                            }

                            Label {
                                text: qsTr("Dewpt (C)")
                            }

                            Label {
                                text: qsTr("Turbulence")
                            }

                            TextInput {
                                id: aloft_4_elevation_ft
                                width: 70
                                // property*: /environment/config/aloft/entry[4]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply aloft-4-elevation-ft "
                            }

                            TextInput {
                                id: aloft_4_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/aloft/entry[4]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply aloft-4-wind-from-heading-deg "
                            }

                            TextInput {
                                id: aloft_4_wind_speed_kt
                                width: 45
                                // property*: /environment/config/aloft/entry[4]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply aloft-4-wind-speed-kt "
                            }

                            TextInput {
                                id: aloft_4_visibility_m
                                width: 75
                                // property*: /environment/config/aloft/entry[4]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply aloft-4-visibility-m "
                            }

                            TextInput {
                                id: aloft_4_temperature_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[4]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-4-temperature-degc "
                            }

                            TextInput {
                                id: aloft_4_dewpoint_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[4]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-4-dewpoint-degc "
                            }

                            ComboBox {
                                id: aloft_4_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/aloft/entry[4]/turbulence-name
                                // binding*: " dialog-apply aloft-4-turbulence "
                                // binding*: " nasal controller.setTurbulence("aloft",4); "
                            }

                            TextInput {
                                id: aloft_3_elevation_ft
                                width: 70
                                // property*: /environment/config/aloft/entry[3]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply aloft-3-elevation-ft "
                            }

                            TextInput {
                                id: aloft_3_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/aloft/entry[3]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply aloft-3-wind-from-heading-deg "
                            }

                            TextInput {
                                id: aloft_3_wind_speed_kt
                                width: 45
                                // property*: /environment/config/aloft/entry[3]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply aloft-3-wind-speed-kt "
                            }

                            TextInput {
                                id: aloft_3_visibility_m
                                width: 75
                                // property*: /environment/config/aloft/entry[3]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply aloft-3-visibility-m "
                            }

                            TextInput {
                                id: aloft_3_temperature_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[3]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-3-temperature-degc "
                            }

                            TextInput {
                                id: aloft_3_dewpoint_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[3]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-3-dewpoint-degc "
                            }

                            ComboBox {
                                id: aloft_3_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/aloft/entry[3]/turbulence-name
                                // binding*: " dialog-apply aloft-3-turbulence "
                                // binding*: " nasal controller.setTurbulence("aloft",3); "
                            }

                            TextInput {
                                id: aloft_2_elevation_ft
                                width: 70
                                // property*: /environment/config/aloft/entry[2]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply aloft-2-elevation-ft "
                            }

                            TextInput {
                                id: aloft_2_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/aloft/entry[2]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply aloft-2-wind-from-heading-deg "
                            }

                            TextInput {
                                id: aloft_2_wind_speed_kt
                                width: 45
                                // property*: /environment/config/aloft/entry[2]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply aloft-2-wind-speed-kt "
                            }

                            TextInput {
                                id: aloft_2_visibility_m
                                width: 75
                                // property*: /environment/config/aloft/entry[2]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply aloft-2-visibility-m "
                            }

                            TextInput {
                                id: aloft_2_temperature_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[2]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-2-temperature-degc "
                            }

                            TextInput {
                                id: aloft_2_dewpoint_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[2]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-2-dewpoint-degc "
                            }

                            ComboBox {
                                id: aloft_2_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/aloft/entry[2]/turbulence-name
                                // binding*: " dialog-apply aloft-2-turbulence "
                                // binding*: " nasal controller.setTurbulence("aloft",2); "
                            }

                            TextInput {
                                id: aloft_1_elevation_ft
                                width: 70
                                // property*: /environment/config/aloft/entry[1]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply aloft-1-elevation-ft "
                            }

                            TextInput {
                                id: aloft_1_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/aloft/entry[1]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply aloft-1-wind-from-heading-deg "
                            }

                            TextInput {
                                id: aloft_1_wind_speed_kt
                                width: 45
                                // property*: /environment/config/aloft/entry[1]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply aloft-1-wind-speed-kt "
                            }

                            TextInput {
                                id: aloft_1_visibility_m
                                width: 75
                                // property*: /environment/config/aloft/entry[1]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply aloft-1-visibility-m "
                            }

                            TextInput {
                                id: aloft_1_temperature_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[1]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-1-temperature-degc "
                            }

                            TextInput {
                                id: aloft_1_dewpoint_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[1]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-1-dewpoint-degc "
                            }

                            ComboBox {
                                id: aloft_1_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/aloft/entry[1]/turbulence-name
                                // binding*: " dialog-apply aloft-1-turbulence "
                                // binding*: " nasal controller.setTurbulence("aloft",1); "
                            }

                            TextInput {
                                id: aloft_0_elevation_ft
                                width: 70
                                // property*: /environment/config/aloft/entry[0]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply aloft-0-elevation-ft "
                            }

                            TextInput {
                                id: aloft_0_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/aloft/entry[0]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply aloft-0-wind-from-heading-deg "
                            }

                            TextInput {
                                id: aloft_0_wind_speed_kt
                                width: 45
                                // property*: /environment/config/aloft/entry[0]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply aloft-0-wind-speed-kt "
                            }

                            TextInput {
                                id: aloft_0_visibility_m
                                width: 75
                                // property*: /environment/config/aloft/entry[0]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply aloft-0-visibility-m "
                            }

                            TextInput {
                                id: aloft_0_temperature_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[0]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-0-temperature-degc "
                            }

                            TextInput {
                                id: aloft_0_dewpoint_degc
                                width: 60
                                // property*: /environment/config/aloft/entry[0]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply aloft-0-dewpoint-degc "
                            }

                            ComboBox {
                                id: aloft_0_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/aloft/entry[0]/turbulence-name
                                // binding*: " dialog-apply aloft-0-turbulence "
                                // binding*: " nasal controller.setTurbulence("aloft",0); "
                            }
                        } // GridLayout

                        Label {
                            Layout.fillWidth: true
                        }
                    } // RowLayout
                } // ColumnLayout

                ColumnLayout {
                    width: parent.width
                    // padding*: 1

                    Item {
                        Layout.fillWidth: true

                        RowLayout {
                            width: parent.width
                        } // RowLayout

                        Label {
                            text: qsTr(" Boundary (All Elevations ft-AGL)")
                        }

                        Rectangle {
                            width: parent.width
                            height: 2
                            color: "#DFAC01"
                        }
                    }

                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr(" ")
                        }

                        GridLayout {
                            width: parent.width
                            columns: 5

                            Label {
                                text: qsTr("Elevation")
                            }

                            Label {
                                text: qsTr("Wind (dir/kt)")
                            }

                            Label {
                                text: qsTr("Vis (m)")
                            }

                            Label {
                                text: qsTr("Temp (C)")
                            }

                            Label {
                                text: qsTr("Dewpt (C)")
                            }

                            Label {
                                text: qsTr("Turbulence")
                            }

                            TextInput {
                                id: boundary_1_elevation_ft
                                width: 70
                                // property*: /environment/config/boundary/entry[1]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply boundary-1-elevation-ft "
                            }

                            TextInput {
                                id: boundary_1_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/boundary/entry[1]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply boundary-1-wind-from-heading-deg "
                            }

                            TextInput {
                                id: boundary_1_wind_speed_kt
                                width: 45
                                // property*: /environment/config/boundary/entry[1]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply boundary-1-wind-speed-kt "
                            }

                            TextInput {
                                id: boundary_1_visibility_m
                                width: 75
                                // property*: /environment/config/boundary/entry[1]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply boundary-1-visibility-m "
                            }

                            TextInput {
                                id: boundary_1_temperature_degc
                                width: 60
                                // property*: /environment/config/boundary/entry[1]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply boundary-1-temperature-degc "
                            }

                            TextInput {
                                id: boundary_1_dewpoint_degc
                                width: 60
                                // property*: /environment/config/boundary/entry[1]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply boundary-1-dewpoint-degc "
                            }

                            ComboBox {
                                id: boundary_1_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/boundary/entry[1]/turbulence-name
                                // binding*: " dialog-apply boundary-1-turbulence "
                                // binding*: " nasal controller.setTurbulence("boundary",1); "
                            }

                            TextInput {
                                id: boundary_0_elevation_ft
                                width: 70
                                // property*: /environment/config/boundary/entry[0]/elevation-ft
                                // live*: true
                                // binding*: " dialog-apply boundary-0-elevation-ft "
                            }

                            TextInput {
                                id: boundary_0_wind_from_heading_deg
                                width: 50
                                // property*: /environment/config/boundary/entry[0]/wind-from-heading-deg
                                // live*: true
                                // binding*: " dialog-apply boundary-0-wind-from-heading-deg "
                            }

                            TextInput {
                                id: boundary_0_wind_speed_kt
                                width: 45
                                // property*: /environment/config/boundary/entry[0]/wind-speed-kt
                                // live*: true
                                // binding*: " dialog-apply boundary-0-wind-speed-kt "
                            }

                            TextInput {
                                id: boundary_0_visibility_m
                                width: 75
                                // property*: /environment/config/boundary/entry[0]/visibility-m
                                // live*: true
                                // binding*: " dialog-apply boundary-0-visibility-m "
                            }

                            TextInput {
                                id: boundary_0_temperature_degc
                                width: 60
                                // property*: /environment/config/boundary/entry[0]/temperature-degc
                                // live*: true
                                // binding*: " dialog-apply boundary-0-temperature-degc "
                            }

                            TextInput {
                                id: boundary_0_dewpoint_degc
                                width: 60
                                // property*: /environment/config/boundary/entry[0]/dewpoint-degc
                                // live*: true
                                // binding*: " dialog-apply boundary-0-dewpoint-degc "
                            }

                            ComboBox {
                                id: boundary_0_turbulence
                                width: 90
                                // live*: true
                                // property*: /environment/config/boundary/entry[0]/turbulence-name
                                // binding*: " dialog-apply boundary-0-turbulence "
                                // binding*: " nasal controller.setTurbulence("boundary",0); "
                            }
                        } // GridLayout

                        Label {
                            Layout.fillWidth: true
                        }
                    } // RowLayout

                    Label {
                        Layout.fillWidth: true
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
            text: qsTr("Close")

            onClicked: {
                weatherConfigurationDialog.closed(weatherConfigurationDialog.id);
            }
        }
    } // buttons
}
