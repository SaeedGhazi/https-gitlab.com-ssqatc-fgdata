import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: fileSelectDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: fileSelectDialog.id
    title: "Select File"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var self = cmdarg();
        //         var list = self.getNode("list");

        //         # cloning
        //         var dlgname = self.getNode("name").getValue();
        //         self.getNode("input/property").setValue("/sim/gui/dialogs/" ~ dlgname ~ "/directory");
        //         self.getNode("list/property").setValue("/sim/gui/dialogs/" ~ dlgname ~ "/selection");
        //         self.getNode("group[1]/input/property").setValue("/sim/gui/dialogs/" ~ dlgname ~ "/selection");

        //         var dlg = props.globals.getNode("/sim/gui/dialogs/" ~ dlgname, 1);
        //         var selection = dlg.getNode("selection", 1);
        //         var title = dlg.getNode("title", 1);
        //         var button = dlg.getNode("button", 1);
        //         var dir = dlg.getNode("directory", 1);
        //         var file = dlg.getNode("file", 1);
        //         var path = dlg.getNode("path", 1);
        //         var dotfiles = dlg.getNode("dotfiles", 1);
        //         dotfiles.setBoolValue(dotfiles.getValue());
        //         # disable files to show a directory dialog only
        //         self.show_files = dlg.getNode("show-files",1).getValue();
        //         self.getNode("group[1]/input/visible/equals/value").setValue(self.show_files);

        //         var kbdctrl = props.globals.getNode("/devices/status/keyboard/ctrl", 1);
        //         var kbdshift = props.globals.getNode("/devices/status/keyboard/shift", 1);
        //         var kbdalt = props.globals.getNode("/devices/status/keyboard/alt", 1);
        //         var current = { dir : "", file : "" };
        //         var pattern = [];
        //         foreach (var p; dlg.getChildren("pattern"))
        //             append(pattern, p.getValue());

        //         var matches = func(s) {
        //             foreach (var p; pattern)
        //                 if (string.match(s, p))
        //                     return 1;
        //             return 0;
        //         }

        //         var update = func(d) {
        //             var entries = directory(d);
        //             var retval = 1;
        //             if (entries == nil) { # dir doesn't exist or no permissions
        //                 entries = ["..", "Not found or access denied", "Ctrl-click .. for FG_ROOT", "Shift-click .. for FG_HOME","To allow more directories, pass them to --allow-nasal-read"];
        //                 retval = 0;
        //             } else {
        //                 var files = [];
        //                 var dirs = [];
        //                 var hide = !dotfiles.getValue();
        //                 foreach (var e; entries) {
        //                     if (e == ".") {
        //                         append(dirs, e);
        //                         continue;
        //                     }
        //                     if (e == "..") {
        //                         if (d != "/")
        //                             append(dirs, e);
        //                         continue;
        //                     }
        //                     if (hide and e[0] == `.`)
        //                         continue;

        //                     var stat = io.stat(d ~ "/" ~ e);
        //                     if (stat == nil)  # dead link
        //                         continue;

        //                     if (stat[11] == "dir")
        //                         append(dirs, e ~ "/");
        //                     elsif (self.show_files and (!size(pattern) or matches(e)))
        //                         append(files, e);
        //                 }
        //                 var entries = sort(dirs, cmp) ~ sort(files, cmp);
        //             }

        //             list.removeChildren("value");
        //             forindex (var i; entries)
        //                 list.getChild("value", i, 1).setValue(entries[i]);

        //             dir.setValue(d);
        //             gui.dialog_update(dlgname, "dir-input", "list");
        //             return retval;
        //         }

        //         var select = func {
        //             var e = selection.getValue();
        //             current.file = "";
        //             var new = nil;
        //             if (e == ".") {
        //                 new = current.dir;
        //                 if (kbdctrl.getValue())
        //                     dotfiles.setBoolValue(!dotfiles.getValue());
        //             } elsif (e == "..") {
        //                 if (kbdctrl.getValue())
        //                     new = getprop("/sim/fg-root");
        //                 elsif (kbdshift.getValue())
        //                     new = getprop("/sim/fg-home");
        //                 elsif (kbdalt.getValue())
        //                     new = getprop("/sim/fg-current");
        //                 else
        //                     new = current.dir ~ "/..";
        //             } elsif (e[size(e) - 1] == `/`) {
        //                 new = current.dir ~ "/" ~ e;
        //             } else {
        //                 current.file = e;
        //                 gui.dialog_update(dlgname, "file-input");
        //             }
        //             if (new != nil) {
        //                 var p = string.normpath(new);
        //                 if (update(p))
        //                     current.dir = p;
        //                 selection.setValue("");
        //             }
        //         }

        //         var file_input = func {
        //             current.file = selection.getValue();
        //         }

        //         var dir_input = func {
        //             var p = string.normpath(dir.getValue());
        //             if (update(p))
        //                 current.dir = p;
        //             gui.dialog_update(dlgname, "list");
        //         }

        //         var close = func {
        //             call(func { gui.Dialog.instance[dlgname].close() }, nil, var err = []);
        //         }

        //         var ok = func {
        //             dir_input();
        //             if (self.show_files)
        //                 file_input();
        //             else
        //                 current.file = "";
        //             var p = string.normpath(current.dir ~ "/" ~ current.file);
        //             var stat = io.stat(p);
        //             path.setValue(stat != nil and stat[11] == "dir" ? p ~ "/" : p);
        //             file.setValue(current.file);
        //             close();
        //         }

        //         var op = button.getValue();
        //         if (op == nil or op == "")
        //             op = "OK";
        //         self.getNode("group[1]/button/legend").setValue(op);

        //         var t = title.getValue();
        //         if (t == nil or t == "")
        //         {
        //             if (self.show_files)
        //                 t = "Select Directory";
        //             else
        //                 t = "Select File";
        //         }
        //         self.getNode("group[0]/text/label").setValue(t);

        //         current.dir = (var d = dir.getValue()) != nil and d != "" ? d : getprop("/sim/fg-current");
        //         current.file = (var d = file.getValue()) != nil and d != "" ? d : "";
        //         gui.dialog_update(dlgname, "file-input"); ## dir-input ?
        //         update(string.normpath(current.dir));
        //         dir.setValue(current.dir);
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        TextInput {
            id: dir_input
            width: 442
            // property*: /sim/gui/dialogs/file-select/directory
            // live*: 1
            // binding*: " dialog-apply dir-input "
            // binding*: " nasal dir_input() "
        }

        ListView {
            id: list
            Layout.fillWidth: true
            height: 300
            // property*: /sim/gui/dialogs/file-select/selection
            // binding*: " dialog-apply list "
            // binding*: " nasal select() "
        }

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                TextInput {
                    id: file_input
                    width: 230

                    Layout.fillWidth: true
                    // property*: /sim/gui/dialogs/file-select/selection
                    // live*: 1
                    // binding*: " dialog-apply file-input "
                    // binding*: " nasal file_input() "
                    // visible*: 1 1
                }

                Button {
                    text: qsTr("OK")
                    // live*: 1
                    width: 200
                    // default*: true
                    // binding*: " dialog-apply "
                    // binding*: " nasal ok() "
                    onClicked: {
                        fileSelectDialog.closed(fileSelectDialog.id);
                    }
                }
            } // RowLayout
        }
    } // ColumnLayout

    // ======= content end
}
