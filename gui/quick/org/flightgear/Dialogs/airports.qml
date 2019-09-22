import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

//import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle {
    id: root

    width: 1024
    height: 800
    // resizable*: true
    // padding*: 3
    anchors.centerIn: parent
    border.width: 1
    border.color: Style.frameColor
    color: Style.windowColor
    opacity: Style.panelOpacity

    signal closed(string windowId)

    ColumnLayout {
        width: parent.width

        GroupBox {
            id: groupBox
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Select an Airport")
                    font.pointSize: Style.headingFontPixelSize
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    id: closeBox
                    width: 20
                    height: 20
                    color: mouseClose.containsMouse ? Style.activeColor : Style.themeColor
                    anchors.right: parent.right
                    anchors.rightMargin: Style.margin
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: mouseClose
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.closed(root.id);
                        }
                    }
                }
            } // RowLayout
        }

        HorizontalLine {}

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

//                    GroupBox {
//                        Layout.fillWidth: true

//                        GridLayout {
//                            width: parent.width
//                        } // GridLayout

//                        // padding*: 0
//                        ListView {

//                            // visible*: /sim/gui/dialogs/airports/mode 100nm
//                            id: close_airport_list
//                            width: 260
//                            height: 260

//                            Layout.fillWidth: true
//                            // property*: /sim/gui/dialogs/airports/list

//                            // binding*: " dialog-apply close-airport-list "
//                            // binding*: " nasal listbox() "
//                        }
//                    }

//                    GroupBox {
//                        Layout.fillWidth: true

//                        RowLayout {
//                            width: parent.width
//                        } // RowLayout

//                        Label {
//                            text: qsTr("METAR")
//                        }

//                        Rectangle {
//                            width: parent.width
//                            height: 2
//                            color: "#DFAC01"
//                        }
//                    }

//                    Label {
//                        id: metar

//                        Layout.fillWidth: true
//                        width: 260
//                        height: 70

//                        Slider {}

//                        // live*: true
//                        // property*: /sim/gui/dialogs/airports/selected-airport/metar/data
//                    }

//                    GroupBox {
//                        Layout.fillWidth: true

//                        ColumnLayout {
//                            width: parent.width

//                            GroupBox {
//                                Layout.fillWidth: true

//                                RowLayout {
//                                    width: parent.width

//                                    Label {
//                                        text: qsTr("Aircraft Position")
//                                    }

//                                    Rectangle {
//                                        width: parent.width
//                                        height: 2
//                                        color: "#DFAC01"
//                                    }
//                                } // RowLayout
//                            }

//                            GroupBox {
//                                Layout.fillWidth: true

//                                GridLayout {
//                                    width: parent.width
//                                } // GridLayout

//                                // property*: /sim/gui/dialogs/airports/use_best_runway
//                                // live*: true
//                                // binding*: " nasal set_radio("bestrunway") "
//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Best runway")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("(based on wind)")
//                                }

//                                // property*: /sim/gui/dialogs/airports/use_runway
//                                // live*: true
//                                // binding*: " nasal set_radio("runway") "
//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Runway:")
//                                }

//                                ComboBox {
//                                    id: runway_list

//                                    width: 85
//                                    //horizontalAlignment: Text.AlignLeft

//                                    // property*: /sim/gui/dialogs/airports/selected-airport/rwy

//                                    // binding*: " dialog-apply runway-list "
//                                }

//                                // property*: /sim/gui/dialogs/airports/use_parkpos
//                                // live*: true
//                                // binding*: " nasal set_radio("parkpos") "
//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Parking:")
//                                }

//                                Text {

//                                    id: parking_list
//                                    width: 120

//                                    Layout.fillWidth: true
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/parkpos
//                                    // binding*: " dialog-apply parking-list "
//                                    // binding*: " nasal var pos = getprop("/sim/gui/dialogs/airports/selected-airport/parkpos"); setprop( "/sim/gui/dialogs/airports/selected-airport/parkpos-invalid", contains(avail_parking, pos) == 0); "
//                                    // binding*: " dialog-update parking-list-valid "
//                                }

//                                Label {

//                                    id: parking_list_valid
//                                    horizontalAlignment: Text.AlignLeft
//                                    text: qsTr("Parking position not found")
//                                    // visible*: /sim/gui/dialogs/airports/selected-airport/parkpos-invalid
//                                }
//                            }
//                        } // ColumnLayout
//                    }
                }
            } // RowLayout

            HorizontalLine {}

//            GroupBox {
//                Layout.fillWidth: true

//                ColumnLayout {
//                    width: parent.width

//                    // padding*: 0
//                    GroupBox {
//                        Layout.fillWidth: true

//                        RowLayout {
//                            width: parent.width

//                            //horizontalAlignment: Text.AlignLeft
//                            // padding*: 2
//                            Button {
//                                text: qsTr("Airfield Information")
//                                // binding*: " property-assign /sim/gui/dialogs/airports/display-mode 0 "
//                            }

//                            Button {
//                                text: qsTr("Airfield Chart")
//                                // binding*: " property-assign /sim/gui/dialogs/airports/display-mode 1 "
//                            }
//                        } // RowLayout
//                    }

//                    GroupBox {
//                        Layout.fillWidth: true

//                        GridLayout {
//                            width: parent.width
//                        } // GridLayout

//                        // padding*: 0
//                        GroupBox {
//                            Layout.fillWidth: true

//                            ColumnLayout {
//                                width: parent.width

//                                // visible*: /sim/gui/dialogs/airports/display-mode 1
//                                GroupBox {
//                                    Layout.fillWidth: true

//                                    ColumnLayout {
//                                        width: parent.width

//                                        GroupBox {
//                                            Layout.fillWidth: true

//                                            RowLayout {
//                                                width: parent.width

//                                                Label {
//                                                    text: qsTr("Airfield Chart")
//                                                }

//                                                Rectangle {
//                                                    width: parent.width
//                                                    height: 2
//                                                    color: "#DFAC01"
//                                                }
//                                            } // RowLayout
//                                        }

//                                        GroupBox {
//                                            Layout.fillWidth: true

//                                            RowLayout {
//                                                width: parent.width

//                                                CheckBox {
//                                                    text: qsTr("Nav data")
//                                                    //horizontalAlignment: Text.AlignLeft
//                                                    // property*: /sim/gui/dialogs/map-canvas/draw-DME
//                                                    // live*: true
//                                                    // binding*: " property-toggle "
//                                                    // binding*: " nasal var visible = ! getprop("/sim/gui/dialogs/map-canvas/draw-DME"); setprop("/sim/gui/dialogs/map-canvas/draw-DME", visible); setprop("/sim/gui/dialogs/map-canvas/draw-VOR", visible); setprop("/sim/gui/dialogs/map-canvas/draw-NDB", visible); setprop("/sim/gui/dialogs/map-canvas/draw-FIX", visible); dialog-apply "
//                                                }

//                                                CheckBox {
//                                                    text: qsTr("Parking")
//                                                    //horizontalAlignment: Text.AlignLeft
//                                                    // property*: /sim/gui/dialogs/map-canvas/draw-PARKING
//                                                    // live*: true
//                                                    // binding*: " dialog-apply "
//                                                    // binding*: " property-toggle "
//                                                }

//                                                Label {
//                                                    Layout.fillWidth: true
//                                                }

//                                                Button {
//                                                    id: zoomout
//                                                    text: qsTr("+")
//                                                    width: 52
//                                                    height: 22
//                                                    // binding*: " nasal var range = AirportChart.getScreenRange(); if (range < 10000) AirportChart.setScreenRange(range*range_step); setprop("/sim/gui/dialogs/airports/zoom-range", AirportChart.getScreenRange()); "
//                                                }

//                                                Label {
//                                                    id: zoomdisplay
//                                                    text: qsTr("MMMMMMMMMMMMM")
//                                                    // format*: Zoom %d
//                                                    // property*: /sim/gui/dialogs/airports/zoom-range
//                                                    // live*: true
//                                                }

//                                                Button {
//                                                    id: zoomin
//                                                    text: qsTr("-")
//                                                    width: 52
//                                                    height: 22
//                                                    // binding*: " nasal var range = AirportChart.getScreenRange(); if (range > 100) AirportChart.setScreenRange(range/range_step); setprop("/sim/gui/dialogs/airports/zoom-range", AirportChart.getScreenRange()); "
//                                                }
//                                            } // RowLayout
//                                        }
//                                    } // ColumnLayout
//                                }
//                            } // ColumnLayout
//                        }

//                        GroupBox {
//                            Layout.fillWidth: true

//                            GridLayout {
//                                width: parent.width
//                            } // GridLayout

//                            // visible*: /sim/gui/dialogs/airports/display-mode 0
//                            GroupBox {
//                                Layout.fillWidth: true

//                                GridLayout {
//                                    width: parent.width
//                                } // GridLayout

//                                GroupBox {
//                                    Layout.fillWidth: true

//                                    RowLayout {
//                                        width: parent.width

//                                        Label {
//                                            text: qsTr("Airfield Information")
//                                        }

//                                        Rectangle {
//                                            width: parent.width
//                                            height: 2
//                                            color: "#DFAC01"
//                                        }
//                                    } // RowLayout
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Name:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("Athens Intl Airport Elefterios Venizel")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/name
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("ICAO:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("AAAA")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/id
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Lat / Lon:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("XXXXXXXXXXXX")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/location
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Elevation:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    // format*: %.0f ft
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/elevation-ft
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Longest runway:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    // format*: %.0f ft
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/longest-runway
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Distance:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    // format*: %.1f nm
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/distance-nm
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignRight
//                                    text: qsTr("Course:")
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    // format*: %.0f deg
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/course-deg
//                                }
//                            }

//                            GroupBox {
//                                Layout.fillWidth: true

//                                GridLayout {
//                                    width: parent.width
//                                } // GridLayout

//                                // padding*: 2
//                                GroupBox {
//                                    Layout.fillWidth: true

//                                    RowLayout {
//                                        width: parent.width

//                                        Label {
//                                            text: qsTr("Communications Frequencies")
//                                        }

//                                        Rectangle {
//                                            width: parent.width
//                                            height: 2
//                                            color: "#DFAC01"
//                                        }
//                                    } // RowLayout
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[0]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[0]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[1]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[1]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[2]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[2]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[3]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[3]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[4]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[4]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[5]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[5]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[6]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[6]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[7]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[7]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[8]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[8]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[9]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[9]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[10]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[10]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[11]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[11]/value
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("ACTIVATE LIGHTS")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[12]/label
//                                }

//                                Label {

//                                    horizontalAlignment: Text.AlignLeft
//                                    // live*: true
//                                    text: qsTr("123.456 123.456")
//                                    // property*: /sim/gui/dialogs/airports/selected-airport/comms/freq[12]/value
//                                }
//                            }

//                            GroupBox {
//                                Layout.fillWidth: true

//                                GridLayout {
//                                    width: parent.width
//                                } // GridLayout

//                                // padding*: 2
//                                GroupBox {
//                                    Layout.fillWidth: true

//                                    RowLayout {
//                                        width: parent.width

//                                        Label {
//                                            text: qsTr("Runways")
//                                        }

//                                        Rectangle {
//                                            width: parent.width
//                                            height: 2
//                                            color: "#DFAC01"
//                                        }
//                                    } // RowLayout
//                                }

//                                Label {

//                                    id: runways_info

//                                    Layout.fillWidth: true
//                                    width: 260
//                                    height: 250

//                                    Slider {}

//                                    // property*: /sim/gui/dialogs/airports/selected-airport/runways-info
//                                }
//                            }
//                        }
//                    }
//                } // ColumnLayout
//            }
        }

        HorizontalLine {}

//        GroupBox {
//            Layout.fillWidth: true

//            RowLayout {
//                width: parent.width

//                // padding*: 5
//                Label {
//                    Layout.fillWidth: true
//                }

//                Button {
//                    text: qsTr("Go To Airport")
//                    // equal*: true
//                    // binding*: " dialog-apply airport-list "
//                    // binding*: " nasal apply() "
//                    // binding*: " reposition "
//                    // binding*: " dialog-close "
//                }

//                Label {
//                    Layout.fillWidth: true
//                }

//                Button {
//                    text: qsTr("Close")
//                    // equal*: true
//                    // key*: qsTr("Esc")
//                    // binding*: " dialog-apply input "
//                    // binding*: " dialog-close "
//                }

//                Label {
//                    Layout.fillWidth: true
//                }
//            } // RowLayout
//        }

    } // ColumnLayout
}
