import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0


DialogBase {
    id: aboutDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: root.id
    title: "About FlightGear"

    onClosed: {
        dialogTest.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

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
                            text: qsTr("FlightGear Flight Simulator VX.X.X")
                            font.pointSize: Style.subHeadingFontPixelSize
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    } // RowLayout
                }

                Label {
                    text: qsTr("(c) 1996-2019, the FlightGear Contributors")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                GroupBox {
                    id: groupBox1
                    rightPadding: 48
                    leftPadding: 48
                    enabled: true
                    visible: true
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        // border*: 10

                        // padding*: 2
                        Label {
                            text: qsTr("FlightGear is free and open source software, licensed under the GNU General Public License Version 2. Get new versions, add-ons, forum, wiki and more from the web-site at http://www.flightgear.org/ for free. Have a nice flight!")
                            Layout.maximumWidth: 600
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    } // ColumnLayout
                }

                HorizontalLine {}

                Label {
                    text: qsTr("Version Information")
                    font.pointSize: Style.subHeadingFontPixelSize
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                GroupBox {
                    leftPadding: 48
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        // border*: 10

                        // padding*: 2
                        Label {
                            text: qsTr("FlightGear Version: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: FlightGear Version: %s
                            // property*: /sim/version/flightgear
                        }

                        Label {
                            text: qsTr("SimGear Version: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: SimGear Version: %s
                            // property*: /sim/version/simgear
                        }

                        Label {
                            text: qsTr("OpenSceneGraph Version: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: OpenSceneGraph Version: %s
                            // property*: /sim/version/openscenegraph
                        }

                        Label {
                            text: qsTr("Build Id: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: Build Id: %s
                            // property*: /sim/version/build-id
                        }

                        Label {
                            text: qsTr("Build Number: %d")
                            horizontalAlignment: Text.AlignLeft
                            // format*: Build Number: %d
                            // property*: /sim/version/build-number
                        }

                        Label {
                            text: qsTr("Revision: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: Revision: %s
                            // property*: /sim/version/revision
                        }
                    } // ColumnLayout
                }

                HorizontalLine {}

                Label {
                    text: qsTr("Graphics / OpenGL Information")
                    font.pointSize: Style.subHeadingFontPixelSize
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                GroupBox {
                    leftPadding: 48
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width

                        // border*: 10

                        // padding*: 2
                        Label {
                            text: qsTr("OpenGL Vendor: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: OpenGL Vendor: %s
                            // property*: /sim/rendering/gl-vendor
                        }

                        Label {
                            text: qsTr("OpenGL Renderer: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: OpenGL Renderer: %s
                            // property*: /sim/rendering/gl-renderer
                        }

                        Label {
                            text: qsTr("OpenGL Version: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: OpenGL Version: %s
                            // property*: /sim/rendering/gl-version
                        }

                        Label {
                            text: qsTr("GLSL Version: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: GLSL Version: %s
                            // property*: /sim/rendering/gl-shading-language-version
                        }

                        Label {
                            text: qsTr("Max Texture Size: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: Max Texture Size: %s
                            // property*: /sim/rendering/max-texture-size
                        }

                        Label {
                            text: qsTr("Depth Buffer Bits: %s")
                            horizontalAlignment: Text.AlignLeft
                            // format*: Depth Buffer Bits: %s
                            // property*: /sim/rendering/depth-buffer-bits
                        }
                    } // ColumnLayout
                }
            } // ColumnLayout
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                root.closed(root.id);
            }
        }

        Button {
            text: qsTr("Take Screenshot")

            onClicked: {
                // binding*: " nasal fgcommand("screen-capture"); "
            }
        }

        Button {
            text: qsTr("Copy to Clipboard")

            onClicked: {
                // binding*: " nasal var properties = ["gl-vendor","gl-version","gl-renderer", "gl-shading-language-version"]; var data = ""; var path = "/sim/rendering/"; foreach(var p; properties) data ~= p ~":"~getprop(path~p) ~"\n"; clipboard.setText(data); gui.popupTip("Copied version information to clipboard!"); "
            }
            
        }
    } // buttons
}
