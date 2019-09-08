import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: about

    Rectangle {
        anchors.fill: parent
        color: "#6d6d6d"
    }

    // modal*: false
    ColumnLayout {
        width: parent.width

        // resizable*: false
        // padding*: 3
        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                // padding*: 1
                Label {
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("About FlightGear")
                }

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("")
                    // key*: qsTr("Esc")
                    width: 16
                    height: 16
                    // border*: 2
                    // binding*: " dialog-close "
                }
            } // RowLayout
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        GroupBox {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width

                // padding*: 5
                GroupBox {
                    Layout.fillWidth: true

                    RowLayout {
                        width: parent.width

                        Label {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: qsTr("FlightGear Flight Simulator VX.X.X")
                        }

                        Label {
                            Layout.fillWidth: true
                        }
                    } // RowLayout
                }

                Label {
                    text: qsTr("(c) 1996-2019, the FlightGear Contributors")
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        // border*: 10

                        // padding*: 2
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("FlightGear is free and open source software, licensed")
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("under the GNU General Public License Version 2.")
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Get new versions, add-ons, forum, wiki and more")
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("from the web-site at http://www.flightgear.org/ for free.")
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Have a nice flight!")
                        }
                    } // ColumnLayout
                }

                Label {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: "#DFAC01"
                }

                Label {

                    text: qsTr("Version Information")
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        // border*: 10

                        // padding*: 2
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMM")
                            // format*: FlightGear Version: %s
                            // property*: /sim/version/flightgear
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMM")
                            // format*: SimGear Version: %s
                            // property*: /sim/version/simgear
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMM")
                            // format*: OpenSceneGraph Version: %s
                            // property*: /sim/version/openscenegraph
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMM")
                            // format*: Build Id: %s
                            // property*: /sim/version/build-id
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMM")
                            // format*: Build Number: %d
                            // property*: /sim/version/build-number
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: Revision: %s
                            // property*: /sim/version/revision
                        }
                    } // ColumnLayout
                }

                Label {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: "#DFAC01"
                }

                Label {

                    text: qsTr("Graphics/OpenGL Information")
                }

                GroupBox {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        // border*: 10

                        // padding*: 2
                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: OpenGL Vendor: %s
                            // property*: /sim/rendering/gl-vendor
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: OpenGL Renderer: %s
                            // property*: /sim/rendering/gl-renderer
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: OpenGL Version: %s
                            // property*: /sim/rendering/gl-version
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: GLSL Version: %s
                            // property*: /sim/rendering/gl-shading-language-version
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: Max Texture Size: %s
                            // property*: /sim/rendering/max-texture-size
                        }

                        Label {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
                            // format*: Depth Buffer Bits: %s
                            // property*: /sim/rendering/depth-buffer-bits
                        }
                    } // ColumnLayout
                }
            } // ColumnLayout
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Close")
                    // equal*: true
                    // default*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "
                }

                Button {
                    text: qsTr("Take Screenshot")
                    // equal*: true
                    // default*: false
                    // binding*: " nasal fgcommand("screen-capture"); "
                }

                Button {
                    text: qsTr("Copy to Clipboard")
                    // equal*: true
                    // default*: false
                    // binding*: " nasal var properties = ["gl-vendor","gl-version","gl-renderer", "gl-shading-language-version"]; var data = ""; var path = "/sim/rendering/"; foreach(var p; properties) data ~= p ~":"~getprop(path~p) ~"\n"; clipboard.setText(data); gui.popupTip("Copied version information to clipboard!"); "
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }
    } // ColumnLayout
}
