import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: gpsDialog

    width: 700
    height: 470
    position: Qt.point(80, 80)

    windowId: gpsDialog.id
    title: "GPS"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 5

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("MMMM")
                // format*: Mode: %s
                // property*: /instrumentation/gps/mode
                // live*: true
            }

            Label {
                // visible*: /instrumentation/gps/mode leg
                text: qsTr("MMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Current Route Wp: %03d
                // property*: /autopilot/route-manager/current-wp
                // live*: true
            }

            Label {
                // visible*: /instrumentation/gps/mode leg
                text: qsTr("MMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Desired course: %5.1f*
                // property*: /instrumentation/gps/desired-course-deg
                // live*: true
            }

            Label {
                text: qsTr("MMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Xtrack: %5.2fnm
                // property*: /instrumentation/gps/wp/wp[1]/course-error-nm
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Longitude: %6.3f
                // property*: /instrumentation/gps/indicated-longitude-deg
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Latitude: %6.3f
                // property*: /instrumentation/gps/indicated-latitude-deg
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Altitude: %6.0fft
                // property*: /instrumentation/gps/indicated-altitude-ft
                // live*: true
            }

            Label {
                text: qsTr("MMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Groundspeed: %4.0fkts
                // property*: /instrumentation/gps/indicated-ground-speed-kt
                // live*: true
            }

            Label {
                text: qsTr("MMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Track: %3.0f*
                // property*: /instrumentation/gps/indicated-track-magnetic-deg
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: VS: %4.0ffpm
                // property*: /instrumentation/gps/indicated-vertical-speed
                // live*: true
            }

            Label {
                text: qsTr("MMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Odometer: %4.1fnm
                // property*: /instrumentation/gps/odometer
                // live*: true
            }

            Label {
                text: qsTr("MMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: RAIM: %3.2f
                // property*: /instrumentation/gps/raim
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Ident: %s
                // property*: /instrumentation/gps/wp/wp[1]/ID
                // live*: true
            }

            Label {
                text: qsTr("MMMMMMMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Name: %s
                // property*: /instrumentation/gps/wp/wp[1]/name
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Longitude: %6.3f
                // property*: /instrumentation/gps/wp/wp[1]/longitude-deg
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Latitude: %6.3f
                // property*: /instrumentation/gps/wp/wp[1]/latitude-deg
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Altitude: %6.0fft
                // property*: /instrumentation/gps/wp/wp[1]/altitude-ft
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Bearing: %3.0f
                // property*: /instrumentation/gps/wp/wp[1]/bearing-mag-deg
                // live*: true
            }

            Label {
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Distance: %5.2fnm
                // property*: /instrumentation/gps/wp/wp[1]/distance-nm
                // live*: true
            }

            Label {
                text: qsTr("MMMMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: TTW: %s
                // property*: /instrumentation/gps/wp/wp[1]/TTW
                // live*: true
            }

            Label {
                // visible*: /instrumentation/gps/mode leg
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Leg Course: %3.0f
                // property*: /instrumentation/gps/wp/leg-mag-course-deg
                // live*: true
            }

            Label {
                // visible*: /instrumentation/gps/mode leg
                text: qsTr("MMMMMM")
                horizontalAlignment: Text.AlignLeft
                // format*: Leg Distance: %5.1fnm
                // property*: /instrumentation/gps/wp/leg-distance-nm
                // live*: true
            }

            Label {
                // visible*: /instrumentation/gps/mode obs /instrumentation/gps/to-flag
                text: qsTr("TO")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                // visible*: /instrumentation/gps/mode obs /instrumentation/gps/from-flag
                text: qsTr("FROM")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width

                RowLayout {
                    width: parent.width

                    Label {
                        text: qsTr(" Type:")
                        horizontalAlignment: Text.AlignLeft
                    }

                    ComboBox {
                        width: 100
                        id: searchType
                        // property*: /sim/gui/dialogs/gps/search-type
                        // live*: true
                        // binding*: " dialog-apply "
                    }
                } // RowLayout
            } // ColumnLayout

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr(" Search:")
                    horizontalAlignment: Text.AlignLeft
                }

                TextInput {
                    id: search_query

                    Layout.fillWidth: true
                    width: 150
                    // live*: true
                    // property*: /sim/gui/dialogs/gps/search-query
                    // binding*: " dialog-apply "
                }

                Label {
                    text: qsTr(" ")
                    horizontalAlignment: Text.AlignLeft
                }
            } // RowLayout

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr(" ")
                    horizontalAlignment: Text.AlignLeft
                }

                Button {
                    text: qsTr("Search")
                    // binding*: " nasal doSearch() "
                }

                Button {
                    text: qsTr("Search Names")
                    // binding*: " nasal doSearchNames() "
                }

                Button {
                    text: qsTr("Nrst")
                    // binding*: " nasal doSearchNearest() "
                }

                Button {
                    text: qsTr("Actv RTE WPT")
                    // binding*: " nasal doLoadRouteWaypoint() "
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        } // RowLayout

        HorizontalLine {}

        Item {
            Layout.fillWidth: true
            // visible*: /sim/gui/dialogs/gps/scratch/valid

            ColumnLayout {
                width: parent.width

                Item {
                    Layout.fillWidth: true
                    // visible*: /sim/gui/dialogs/gps/scratch/valid

                    GridLayout {
                        width: parent.width
                        columns: 5

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMM")
                            // format*: Ident: %s
                            // property*: /instrumentation/gps/scratch/ident
                            // live*: true
                        }

                        Label {
                            width: 250
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMM")
                            // format*: Name: %s
                            // property*: /instrumentation/gps/scratch/name
                            // live*: true
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMM")
                            // format*: Lon: %6.3f
                            // property*: /instrumentation/gps/scratch/longitude-deg
                            // live*: true
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMM")
                            // format*: Lat: %6.3f
                            // property*: /instrumentation/gps/scratch/latitude-deg
                            // live*: true
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMM")
                            // format*: Alt: %6.0fft
                            // property*: /instrumentation/gps/scratch/altitude-ft
                            // live*: true
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr(" ")
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMM")
                            // format*: Bearing: %3.0f
                            // property*: /sim/gui/dialogs/gps/scratch-mag-bearing-deg
                            // live*: true
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMM")
                            // format*: Distance: %5.1fnm
                            // property*: /sim/gui/dialogs/gps/scratch-distance-nm
                            // live*: true
                        }

                        Label {
                            // visible*: /instrumentation/gps/scratch/type vor
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMM")
                            // format*: Frequency: %5.1fMhz
                            // property*: /instrumentation/gps/scratch/frequency-mhz
                            // live*: true
                        }

                        Label {
                            // visible*: /instrumentation/gps/scratch/type ndb
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMM")
                            // format*: Frequency: %5.1fKhz
                            // property*: /instrumentation/gps/scratch/frequency-khz
                            // live*: true
                        }
                    } // GridLayout
                }
            } // ColumnLayout

            Item {
                Layout.fillWidth: true
                // visible*: /sim/gui/dialogs/gps/scratch/valid

                RowLayout {
                    width: parent.width

                    Button {
                        //horizontalAlignment: Text.AlignLeft
                        text: qsTr("Prev")
                        // key*: qsTr("left")
                        // binding*: " nasal doScratchPrevious() "
                    }

                    Button {
                        //horizontalAlignment: Text.AlignLeft
                        text: qsTr("Next")
                        // key*: qsTr("right")
                        // binding*: " nasal doScratchNext() "
                    }
                } // RowLayout
            }
        }

        HorizontalLine {}

        RowLayout {
            width: parent.width
            // padding*: 6

            Button {
                text: qsTr("LEG")
                // equal*: true
                // binding*: " nasal cmd.setValue("leg") "
            }

            Button {
                text: qsTr("DTO")
                // binding*: " nasal cmd.setValue("direct") "
            }

            Button {
                text: qsTr("OBS")
                // binding*: " nasal cmd.setValue("obs") "
            }

            Label {
                // visible*: /instrumentation/gps/mode obs
                text: qsTr("MMMMMMMMMMM")
                // format*: Selected Course: %03d*
                // property*: /instrumentation/gps/selected-course-deg
                // live*: true
            }

            Dial {
                // visible*: /instrumentation/gps/mode obs
                width: 30
                height: 30
                Layout.fillWidth: true
                // property*: /instrumentation/gps/selected-course-deg
                // binding*: " dialog-apply "
            }

            Label {
                Layout.fillWidth: true
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("NAV1 Slave")
                // property*: /instrumentation/nav[0]/slaved-to-gps
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
                gpsDialog.closed(gpsDialog.id);
            }
        }
    } // buttons
}
