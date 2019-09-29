import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: instrumentsDialog

    width: 640
    height: 250
    position: Qt.point(80, 80)

    windowId: instrumentsDialog.id
    title: "Instrument Settings"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var update = func(){
        //             setprop("/instrumentation/altimeter/setting-hpa-formatted", int(getprop("/instrumentation/altimeter/setting-hpa")));
        //             setprop("/instrumentation/altimeter/setting-inhg-formatted", int(getprop("/instrumentation/altimeter/setting-inhg")*100.0)/100.0);
        //         }
        //         var hpaListener = setlistener("/instrumentation/altimeter/setting-hpa", update);
        //         var inhgListener = setlistener("/instrumentation/altimeter/setting-inhg", update);
        //         update();
        //     ]]></open>

        //     <close><![CDATA[
        //         removelistener(hpaListener);
        //         removelistener(inhgListener);
        //     ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 5
            // padding*: 5

            Label {
                text: qsTr(" QNH Setting:")
                horizontalAlignment: Text.AlignRight
            }

            RowLayout {
                width: parent.width
                // padding*: 0

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr("<")
                    // binding*: " property-adjust /instrumentation/altimeter/setting-hpa -1 "
                    // binding*: " dialog-update "
                }
            } // RowLayout

            TextInput {
                width: 75
                height: 25
                // live*: true
                // property*: /instrumentation/altimeter/setting-hpa-formatted
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("hPa")
                horizontalAlignment: Text.AlignLeft
                padding: 0
            }

            RowLayout {
                width: parent.width
                // padding*: 0

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr(">")
                    // binding*: " property-adjust /instrumentation/altimeter/setting-hpa 1 "
                    // binding*: " dialog-update "
                }
            } // RowLayout

            Label {
                text: qsTr("ALT Setting:")
                horizontalAlignment: Text.AlignRight
            }

            RowLayout {
                width: parent.width
                // padding*: 0

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr("<")
                    // binding*: " property-adjust /instrumentation/altimeter/setting-inhg -0.01 "
                    // binding*: " dialog-update "
                }

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr("<<")
                    // binding*: " property-adjust /instrumentation/altimeter/setting-inhg -0.10 "
                    // binding*: " dialog-update "
                }
            } // RowLayout

            TextInput {
                width: 75
                height: 25
                // live*: true
                // property*: /instrumentation/altimeter/setting-inhg-formatted
                // binding*: " dialog-apply "
            }

            Label {
                padding: 0
                horizontalAlignment: Text.AlignLeft
                text: qsTr("inHg")
            }

            RowLayout {
                width: parent.width
                // padding*: 0

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr(">>")
                    // binding*: " property-adjust /instrumentation/altimeter/setting-inhg 0.10 "
                    // binding*: " dialog-update "
                }

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr(">")
                    // binding*: " property-adjust /instrumentation/altimeter/setting-inhg 0.01 "
                    // binding*: " dialog-update "
                }

                Label {
                    text: qsTr(" ")
                }
            } // RowLayout

            Label {
                text: qsTr("HI Offset:")
                horizontalAlignment: Text.AlignRight
            }

            RowLayout {
                width: parent.width
                // padding*: 0

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr("<")
                    // binding*: " property-adjust /instrumentation/heading-indicator/offset-deg -1.0 "
                    // binding*: " dialog-update "
                }

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr("<<")
                    // binding*: " property-adjust /instrumentation/heading-indicator/offset-deg -10.0 "
                    // binding*: " dialog-update "
                }
            } // RowLayout

            TextInput {
                width: 75
                height: 25
                // live*: true
                // property*: /instrumentation/heading-indicator/offset-deg
                // binding*: " dialog-apply "
            }

            Label {
                padding: 0
                horizontalAlignment: Text.AlignLeft
                text: qsTr("deg")
            }

            RowLayout {
                width: parent.width
                // padding*: 0

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr(">>")
                    // binding*: " property-adjust /instrumentation/heading-indicator/offset-deg 10.0 "
                    // binding*: " dialog-update "
                }

                Button {
                    width: 35
                    height: 26
                    // border*: 1
                    text: qsTr(">")
                    // binding*: " property-adjust /instrumentation/heading-indicator/offset-deg 1.0 "
                    // binding*: " dialog-update "
                }

                Label {
                    text: qsTr(" ")
                }
            } // RowLayout
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
                instrumentsDialog.closed(instrumentsDialog.id);
            }
        }
    } // buttons
}
