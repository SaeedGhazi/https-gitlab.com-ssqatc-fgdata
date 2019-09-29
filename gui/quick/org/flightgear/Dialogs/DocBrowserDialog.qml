import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: docBrowserDialog

    width: 700
    height: 200
    position: Qt.point(80, 80)

    windowId: docBrowserDialog.id
    title: "Documentation Browser"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var self = cmdarg();
        //         var dlg = props.globals.getNode("/sim/gui/dialogs/doc-browser", 1);
        //         var edit = dlg.getNode("edit", 1);
        //         if( !contains(globals, "__doc_browser") )
        //         globals["__doc_browser"] = {};

        //         var path = getprop("/sim/fg-root") ~ "/Docs/";
        //         # hard coded list of file names, because not all files are plain text - not even the README* files
        //         # TODO: it would probably make sense to sort these files (README, introduction, properties etc)
        //         var doc_files = [
        //             "README",
        //             "README.introduction",
        //             "README.fgjs",
        //             "README.xmlsyntax",
        //             "README.multiscreen",
        //             "README.properties",
        //             "README.IO",
        //             "README.logging",
        //             "README.protocol",
        //             "README.scenery",
        //             "README.materials",
        //             "README.yasim",
        //             "README.JSBsim",
        //             "README.submodels",
        //             "README.3DClouds",
        //             "README.flightrecorder",
        //             "README.jsclient",
        //             "README.multiplayer",
        //             "README.tutorials",
        //             "README.conditions",
        //             "README.commands",
        //             "README.digitalfilters",
        //             "README.airspeed-indicator",
        //             "README.hud",
        //             "README.gui",
        //             "README.layout",
        //             "README.osgtext",
        //             "README.wildfire",
        //             "README.electrical",
        //             "README.effects",
        //             "README.xmlparticles",
        //             "README.sound",
        //             "README.xmlsound",
        //             "README.xmlpanel",
        //             "README.minipanel"
        //         ];
        //         var filename_list = self.getNode("group[1]/list");
        //         var n=0;
        //         # add the filenames to the list box
        //         foreach(var file; doc_files)
        //         {
        //             filename_list.getChild("value",n,1).setValue( file );
        //             n+=1;
        //         }
        //         var filename_property = "/sim/gui/dialogs/doc-browser/filename";
        //         var update = func {
        //             var file = getprop(filename_property);
        //             var doc_file = path ~ file;
        //             setprop("/sim/gui/dialogs/doc-browser/edit", io.readfile(doc_file));
        //         }

        //         var listener = setlistener(filename_property, update);
        //         setprop("/sim/gui/dialogs/doc-browser/filename", "README.introduction");
        //     </open>
        //     <close>removelistener(listener);</close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            ListView {
                width: 170
                // height: 500
                id: filename

                // property*: /sim/gui/dialogs/doc-browser/filename
                currentIndex: clear
                // binding*: " dialog-apply filename "
                // binding*: " dialog-update editfield "
            }

            Label {
                id: editfield

                Layout.fillWidth: true
                width: 600
                // height: 250
                padding: 6

                Slider {
                    //20
                }
                // font*: sim/gui/selected-style/fonts/fixed
                // property*: /sim/gui/dialogs/doc-browser/edit
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
                docBrowserDialog.closed(docBrowserDialog.id);
            }
        }
    } // buttons
}
