import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: timeOfDayDialog

    width: 500
    height: 400
    position: Qt.point(80, 80)

    windowId: timeOfDayDialog.id
    title: "Time Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         <![CDATA[
        //         # Extract the year month day into properties
        //         var dlgRoot = cmdarg();
        //         var cb_month = gui.findElementByName(dlgRoot, "month-combo");
        //         var dtv = getprop("/sim/time/gmt");
        //         var year = substr(dtv,0,4);
        //         var month = substr(dtv,5,2);
        //         var day = substr(dtv,8,2);
        //         #var daymax = gui.findElementByName(dlgRoot, "sl_day").getChild("max");
        //         var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
        //         var monthmax = [31,28,31,30,31,30,31,31,30,31,30,31];

        //         #
        //         # populate the combo box with the months
        //         forindex(var idx; months)
        //             cb_month.getChild("value", idx, 1).setValue(months[idx]);

        //         setprop("/sim/time/demand-year",year);
        //         setprop("/sim/time/demand-month",months[month-1]);
        //         setprop("/sim/time/demand-month-idx",month-1);
        //         setprop("/sim/time/demand-day",day);

        //         #
        //         # method to set the time of day based on the dialog values
        //         tod_setdate = func{
        //               forindex (var idx; months) {
        //                   if (months[idx] == getprop("/sim/time/demand-month"))
        //                       month=idx+1;
        //               }
        //               var year = getprop("/sim/time/demand-year");
        //               if ( (math.fmod(year,4) == 0 and math.fmod(year,100) != 0) or (math.fmod(year,400) == 0))
        //                   monthmax[1]=29;
        //               else
        //                   monthmax[1]=28;
        //               setprop("/sim/time/demand-month-idx",month-1);
        //               setprop("/sim/time/demand-month",months[month-1]);
        //               var hour = substr(dtv,11,2);
        //               var minute = substr(dtv,14,2);
        //               var second = substr(dtv,18,2);
        //               var new_dt=sprintf("%04d-%02d-%02dT%02d:%02d:%02d",getprop("/sim/time/demand-year"),month,getprop("/sim/time/demand-day"),hour,minute,second*1);
        //               setprop("/sim/time/gmt",new_dt);
        //               #daymax.setValue(monthmax[month-1]);
        //               if (getprop("/sim/time/demand-day") > monthmax[month-1])
        //                   setprop("/sim/time/demand-day",sprintf("%02d",monthmax[month-1]));
        //         }
        //         tod_setminuteofday  = func(minute){
        //               var hour = minute/60;
        //               var minute = math.fmod(minute,60);
        //               var second = 0;
        //               var new_dt=sprintf("%04d-%02d-%02dT%02d:%02d:%02d",getprop("/sim/time/demand-year"),month,getprop("/sim/time/demand-day"),hour,minute,second*1);
        //               setprop("/sim/time/gmt",new_dt);
        //               printf(new_dt);
        //         }
        //         ]]>
        //     </open>
        // </nasal>
    }

    // ======= content

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            GridLayout {
                id: date_group
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                flow: GridLayout.TopToBottom
                rows: 2

                Label {
                    text: qsTr("Year")
                }

                TextInput {
                    id: demand_year
                    width: 100
                    // live*: 1
                    // property*: /sim/time/demand-year
                    // binding*: " dialog-apply demand-year "
                    // binding*: " nasal tod_setdate(); "
                }

                Label {
                    text: qsTr("Month")
                }

                ComboBox {
                    id: month_combo
                    width: 130
                    // live*: 1
                    // property*: /sim/time/demand-month
                    // binding*: " dialog-apply month-combo "
                    // binding*: " nasal tod_setdate(); "
                }

                Label {
                    text: qsTr("Day")
                }

                TextInput {
                    id: demand_day
                    width: 100
                    // property*: /sim/time/demand-day
                    // live*: 1
                    // binding*: " dialog-apply demand-day "
                    // binding*: " nasal tod_setdate(); "
                }
            } // GridLayout

            GridLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                columns: 2

                Label {
                    horizontalAlignment: Text.AlignLeft
                    // padding*: 0
                    text: qsTr("UTC")
                }

                Label {
                    horizontalAlignment: Text.AlignLeft
                    // padding*: 0
                    text: qsTr("00:00:00")
                    // live*: true
                    // property*: /sim/time/gmt-string
                }

                Label {
                    horizontalAlignment: Text.AlignLeft
                    // padding*: 0
                    text: qsTr("Local")
                }

                Label {
                    horizontalAlignment: Text.AlignLeft
                    // padding*: 0
                    text: qsTr("00:00")
                    // live*: true
                    // property*: /instrumentation/clock/local-short-string
                }
            } // GridLayout

            HorizontalLine {}

            Label {
                text: qsTr("Simulation Rate")
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("")
                Layout.alignment: Qt.AlignHCenter
                // live*: true
                // property*: /sim/speed-up
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                // padding*: 0

                Button {
                    text: qsTr("-")
                    // binding*: " nasal controls.speedup(-1); "
                }

                Button {
                    text: qsTr("Reset")
                    // binding*: " property-assign /sim/speed-up /sim/time/warp-delta 1 "
                }

                Button {
                    text: qsTr("+")
                    // binding*: " nasal controls.speedup(1); "
                }
            } // RowLayout

            HorizontalLine {}

            Label {
                text: qsTr("Time Warp")
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("")
                Layout.alignment: Qt.AlignHCenter
                // live*: true
                // property*: /sim/time/warp-delta
            }


            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                // padding*: 0

                Button {
                    text: qsTr("-")
                    // binding*: " property-adjust /sim/time/warp-delta -30 "
                }

                Button {
                    text: qsTr("Reset")
                    // binding*: " property-assign /sim/time/warp-delta 0 "
                }

                Button {
                    text: qsTr("+")
                    // binding*: " property-adjust /sim/time/warp-delta 30 "
                }
            } // RowLayout
        } // ColumnLayout

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            // padding*: 0

            Label {
                text: qsTr("Time Presets")
                // padding*: 0
            }

            HorizontalLine {}

            Button {
                text: qsTr("Clock Time")
                // binding*: " timeofday real "
            }

            Button {
                text: qsTr("Dawn")
                // binding*: " timeofday dawn "
            }

            Button {
                text: qsTr("Morning")
                // binding*: " timeofday morning "
            }

            Button {
                text: qsTr("Noon")
                // binding*: " timeofday noon "
            }

            Button {
                text: qsTr("Afternoon")
                // binding*: " timeofday afternoon "
            }

            Button {
                text: qsTr("Dusk")
                // binding*: " timeofday dusk "
            }

            Button {
                text: qsTr("Evening")
                // binding*: " timeofday evening "
            }

            Button {
                text: qsTr("Night")
                // binding*: " timeofday midnight "
            }
        } // ColumnLayout
    } // RowLayout


    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                timeOfDayDialog.closed(timeOfDayDialog.id);
            }
        }
    } // buttons
}

/*##^##
Designer {
    D{i:1;anchors_width:624}
}
##^##*/
