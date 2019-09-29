import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: checklistDialog

    width: 640
    height: 400
    position: Qt.point(80, 80)

    windowId: checklistDialog.id
    title: "Aircraft Checklists"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var dlgRoot = cmdarg();
        //         var dlgname = dlgRoot.getNode("name").getValue();

        //         # Update the checklist-combo with appropriate set of checklists for
        //         # the user to select from
        //         var setChecklistGroup = func(group_name) {
        //             var combo = gui.findElementByName(dlgRoot, "checklist-combo");
        //             combo.removeChildren("value");
        //             var idx = 0;

        //             foreach (var name; checklist_group[group_name]) {
        //                 combo.getChild("value", idx, 1).setValue(name);
        //                 idx = idx + 1;
        //             }

        //             var checklist_name = checklist_group[group_name][0];

        //             var pgs = checklist_size[checklist_name];
        //             if (pgs == nil) pgs = 1;

        //             setprop("/sim/gui/dialogs/checklist/selected-checklist-group", group_name);
        //             setprop("/sim/gui/dialogs/checklist/selected-checklist-max-pages", pgs);
        //             setprop("/sim/gui/dialogs/checklist/selected-page-text", "1 / " ~ pgs);
        //             setprop("sim/gui/dialogs/checklist/selected-checklist", checklist_name);
        //             gui.dialog_update("checklist", "checklist-combo", "checklist-table-group");
        //         };

        //         var groups = props.globals.getNode("/sim/checklists", 1).getChildren("group");
        //         var checklists = props.globals.getNode("/sim/checklists", 1).getChildren("checklist");
        //         var checklist_size = {};
        //         var checklist_group = {};
        //         var current_group = nil;

        //         # Set up the list of groups so the user can select a group and then
        //         # a checklist.
        //         var groups = props.globals.getNode("/sim/checklists").getChildren("group");

        //         if (size(groups) > 0) {
        //             foreach (var grp; groups) {
        //                 var name = grp.getNode("name", 1).getValue();
        //                 var checks = grp.getChildren("checklist");
        //                 foreach (var chk; checks) {
        //                     var title = chk.getNode("title", 1).getValue();
        //                     if (current_group == nil) current_group = name;
        //                     append(checklists, chk);
        //                     if (checklist_group[name] == nil) checklist_group[name] = [];
        //                     append(checklist_group[name], title);
        //                 }
        //             }
        //         } else {
        //             checklists = props.globals.getNode("/sim/checklists").getChildren("checklist");
        //             foreach (var chk; checklists) {
        //                 var title = chk.getNode("title", 1).getValue();
        //                 var grp = "Standard";
        //                 var items = [];
        //                 if (find("emergency", string.lc(title)) != -1) {
        //                     grp = "EMERGENCY";
        //                 }

        //                 if (current_group == nil) current_group = grp;

        //                 if (checklist_group[grp] == nil) checklist_group[grp] = [];
        //                 append(checklist_group[grp], title);
        //             }
        //         }

        //         if (size(checklists) > 0) {
        //             var current_checklist = getprop("sim/gui/dialogs/checklist/selected-checklist");
        //             if (current_checklist == nil) {
        //                 current_checklist = checklists[0].getNode("title", 1).getValue();
        //                 setprop("sim/gui/dialogs/checklist/selected-checklist", current_checklist);
        //                 setprop("sim/gui/dialogs/checklist/selected-page", 0);
        //             }

        //             foreach (var grp; keys(checklist_group)) {
        //                 foreach (chklist; checklist_group[grp]) {
        //                     if (chklist == current_checklist) {
        //                         setChecklistGroup(grp);
        //                     }
        //                 }
        //             }

        //             var combo = gui.findElementByName(dlgRoot, "checklist-group-combo");
        //             var idx = 0;

        //             foreach (var grp_name; keys(checklist_group)) {
        //                 combo.getChild("value", idx, 1).setValue(grp_name);
        //                 idx = idx + 1;
        //             }

        //             dlgRoot.setValues({"dialog-name": dlgname, "object-name": "checklist-group-combo"});
        //             fgcommand("dialog-update", dlgRoot);

        //             var group = gui.findElementByName(dlgRoot, "checklist-table-group");

        //             var table_count = 0;

        //             forindex (var idx; checklists) {
        //                 var checklist_name = checklists[idx].getNode("title", 1).getValue();

        //                 # Checklist may consist of one or more pages.
        //                 var pages = checklists[idx].getChildren("page");

        //                 if (size(pages) == 0) {
        //                     # Or no pages at all, in which case we need to create a checklist of one page
        //                     append(pages, checklists[idx]);
        //                 }

        //                 checklist_size[checklist_name] = size(pages);

        //                 if (idx == 0) {
        //                     setprop("/sim/gui/dialogs/checklist/next-available", 1);
        //                     setprop("/sim/gui/dialogs/checklist/selected-checklist-max-pages", checklist_size[checklist_name]);
        //                     setprop("/sim/gui/dialogs/checklist/selected-page-text", "1 / " ~ checklist_size[checklist_name]);
        //                 }

        //                 forindex (var p; pages) {
        //                     var c = pages[p];
        //                     var row = 0;

        //                     # Set up a new table, only visible when this checklist is selected.
        //                     var table = group.getChild("group", table_count, 1);
        //                     table.getNode("row", 1).setValue(0);
        //                     table.getNode("col", 1).setValue(0);
        //                     table.getNode("default-padding", 1).setValue(4);
        //                     table.getNode("layout", 1).setValue("table");
        //                     table.getNode("valign", 1).setValue("top");

        //                     # Set up conditional to only display when the checklist is selected
        //                     # and the page is correct.
        //                     var vis = table.getNode("visible", 1).getNode("and", 1);
        //                     var e = vis.getChild("equals", 0, 1);
        //                     e.getNode("property", 1).setValue("sim/gui/dialogs/checklist/selected-checklist");
        //                     e.getNode("value", 1).setValue(checklists[idx].getNode("title").getValue());
        //                     e = vis.getChild("equals", 1, 1);
        //                     e.getNode("property", 1).setValue("sim/gui/dialogs/checklist/selected-page");
        //                     e.getNode("value", 1).setValue(p);

        //                     var items = c.getChildren("item");
        //                     var txtcount = 0;
        //                     var btncount = 0;

        //                     forindex (var i; items) {
        //                         var item = items[i];

        //                         var t = table.getChild("text", txtcount, 1);
        //                         txtcount += 1;

        //                         var values = item.getChildren("value");

        //                         if (size(values) == 0) {
        //                             # Single name element with no values. Used as title
        //                             t.getNode("halign", 1).setValue("center");
        //                             t.getNode("row", 1).setValue(row);
        //                             t.getNode("col", 1).setValue(0);
        //                             t.getNode("colspan", 1).setValue(2);
        //                             t.getNode("label", 1).setValue(item.getNode("name", 1).getValue());
        //                             row = row + 1;
        //                         } else {
        //                             t.getNode("halign", 1).setValue("left");
        //                             t.getNode("row", 1).setValue(row);
        //                             t.getNode("col", 1).setValue(0);
        //                             t.getNode("label", 1).setValue(item.getNode("name", 1).getValue());

        //                             forindex (var v; values) {
        //                                 var t = table.getChild("text", txtcount, 1);
        //                                 txtcount += 1;
        //                                 t.getNode("halign", 1).setValue("right");
        //                                 t.getNode("row", 1).setValue(row);
        //                                 if (v > 0) {
        //                                     # The second row of values can overlap with the
        //                                     # first column if required - helps keep the
        //                                     # checklist dialog as compact as possible
        //                                     t.getNode("col", 1).setValue(0);
        //                                     t.getNode("colspan", 1).setValue(2);
        //                                 } else {
        //                                     t.getNode("col", 1).setValue(1);
        //                                 }

        //                                 t.getNode("label", 1).setValue(values[v].getValue());

        //                                 # If there's a complete node, it contains a condition
        //                                 # that can be checked to ensure the checklist item is
        //                                 # complete. We display this item in yellow while the
        //                                 # condition is not met, and green once it is complete.

        //                                 var condition = item.getNode("condition");

        //                                 if (condition != nil) {
        //                                     var vis = t.getNode("visible", 1);
        //                                     props.copy(condition, vis);
        //                                     var c = t.getNode("color", 1);
        //                                     c.getNode("red", 1).setValue(0.2);
        //                                     c.getNode("green", 1).setValue(1.0);
        //                                     c.getNode("blue", 1).setValue(0.2);

        //                                     # Now create an amber version for when the condition
        //                                     # is not met.
        //                                     t = table.getChild("text", txtcount, 1);
        //                                     txtcount += 1;

        //                                     t.getNode("halign", 1).setValue("right");
        //                                     t.getNode("row", 1).setValue(row);
        //                                     if (v > 0) {
        //                                         # The second row of values can overlap with the
        //                                         # first column if required - helps keep the
        //                                         # checklist dialog as compact as possible
        //                                         t.getNode("col", 1).setValue(0);
        //                                         t.getNode("colspan", 1).setValue(2);
        //                                     } else {
        //                                         t.getNode("col", 1).setValue(1);
        //                                     }

        //                                     t.getNode("label", 1).setValue(values[v].getValue());

        //                                     c = t.getNode("color", 1);
        //                                     c.getNode("red", 1).setValue(1.0);
        //                                     c.getNode("green", 1).setValue(0.7);
        //                                     c.getNode("blue", 1).setValue(0.2);

        //                                     vis = t.getNode("visible", 1).getNode("not", 1);
        //                                     props.copy(condition, vis);
        //                                 }

        //                                 # If there is a marker node we display a small
        //                                 # button that enables the marker.
        //                                 var marker = item.getNode("marker");

        //                                 if ((v == 0) and (marker != nil)) {
        //                                     var s = marker.getNode("scale");
        //                                     var scale = s != nil ? s.getValue() : 1;

        //                                     var btn = table.getChild("button", btncount, 1);
        //                                     btncount += 1;
        //                                     btn.getNode("row", 1).setValue(row);
        //                                     btn.getNode("col", 1).setValue(2);
        //                                     btn.getNode("pref-width", 1).setValue(20);
        //                                     btn.getNode("pref-height", 1).setValue(20);
        //                                     btn.getNode("padding", 1).setValue(0);
        //                                     btn.getNode("legend", 1).setValue("?");
        //                                     var binding = btn.getNode("binding", 1);
        //                                     binding.getNode("command", 1).setValue("nasal");
        //                                     binding.getNode("script", 1).setValue(
        //                                         "placeMarker(" ~
        //                                         marker.getNode("x-m", 1).getValue() ~ ", " ~
        //                                         marker.getNode("y-m", 1).getValue() ~ ", " ~
        //                                         marker.getNode("z-m", 1).getValue() ~ ", " ~
        //                                         scale  ~ ");"
        //                                     );
        //                                 }

        //                                 # If there's one or more binding nodes we display a
        //                                 # small button that executes the binding.  Used to
        //                                 # demonstrate the checklist item
        //                                 var bindings = item.getChildren("binding");

        //                                 if ((v == 0) and (size(bindings) > 0)) {
        //                                     var btn = table.getChild("button", btncount, 1);
        //                                     btncount += 1;
        //                                     btn.getNode("row", 1).setValue(row);
        //                                     btn.getNode("col", 1).setValue(3);
        //                                     btn.getNode("pref-width", 1).setValue(20);
        //                                     btn.getNode("pref-height", 1).setValue(20);
        //                                     btn.getNode("padding", 1).setValue(1);
        //                                     btn.getNode("legend", 1).setValue(">");

        //                                     forindex (var bdg; bindings) {
        //                                         var binding = btn.getChild("binding", bdg, 1);
        //                                         props.copy(bindings[bdg], binding);
        //                                     }
        //                                 }

        //                                 row = row + 1;
        //                             }

        //                             table_count = table_count + 1;
        //                         }
        //                     }
        //                 }
        //             }

        //             var s = getprop("/sim/gui/dialogs/checklist/selected-checklist");
        //             setprop("/sim/gui/dialogs/checklist/selected-checklist-max-pages", checklist_size[s]);
        //             setprop("/sim/gui/dialogs/checklist/selected-page", 0);
        //             setprop("/sim/gui/dialogs/checklist/next-available", 1);
        //             setprop("/sim/gui/dialogs/checklist/selected-page-text", "1 / " ~ checklist_size[s]);

        //         } else {
        //                     var group = gui.findElementByName(dlgRoot, "checklist-table-group");
        //                     var table = group.getNode("text", 1);
        //                     table.getNode("row", 1).setValue(0);
        //                     table.getNode("col", 1).setValue(0);
        //                     table.getNode("default-padding", 1).setValue(4);
        //                     table.getNode("layout", 1).setValue("table");
        //                     table.getNode("valign", 1).setValue("top");
        //                     table.getNode("halign", 1).setValue("center");
        //                     table.getNode("label", 1).setValue("No checklists exist for this aircraft");
        //         }

        //         var placeMarker = func(x,y,z,scale) {
        //             var markerN = props.globals.getNode("/sim/model/marker", 1);

        //             markerN.setValues({
        //                 "x/value": x,
        //                 "y/value": y,
        //                 "z/value": z,
        //                 "scale/value": scale,
        //                 "arrow-enabled": 1,
        //             });
        //         };

        //         var nextPage = func() {
        //             var currentPage = getprop("/sim/gui/dialogs/checklist/selected-page");
        //             var s = getprop("/sim/gui/dialogs/checklist/selected-checklist");

        //             if (currentPage < (checklist_size[s] - 1)) {
        //                 setprop("/sim/gui/dialogs/checklist/selected-page", currentPage + 1);
        //             }

        //             if (currentPage == (checklist_size[s] - 2)) {
        //                 setprop("/sim/gui/dialogs/checklist/next-available", 0);
        //             }

        //             setprop("/sim/gui/dialogs/checklist/selected-page-text", (currentPage + 2) ~ " / " ~ checklist_size[s]);
        //         };

        //         var previousPage = func() {
        //             var currentPage = getprop("/sim/gui/dialogs/checklist/selected-page");

        //             if (currentPage > 0) {
        //                 setprop("/sim/gui/dialogs/checklist/selected-page", currentPage - 1);
        //             }

        //             setprop("/sim/gui/dialogs/checklist/next-available", 1);
        //             setprop("/sim/gui/dialogs/checklist/selected-page-text", currentPage ~ " / " ~ checklist_size[s]);
        //         };

        //         var setTransparency = func(updateDialog){
        //             var alpha = (getprop("/sim/gui/dialogs/checklist/transparent") or 0);
        //             dlgRoot.getNode("color/alpha").setValue(1-alpha*0.3);
        //             var n = props.Node.new({ "dialog-name": "checklist" });
        //             if (updateDialog)
        //             {
        //                 fgcommand("dialog-close", n);
        //                 fgcommand("dialog-show", n);
        //             }
        //         };
        //         setTransparency(0);
        //     ]]></open>

        //     <close><![CDATA[
        //     # Hide the marker.
        //     setprop("/sim/model/marker/arrow-enabled", 0);
        //     ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr("Group:")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                id: checklist_group_combo
                // property*: /sim/gui/dialogs/checklist/selected-checklist-group
                width: 230
                // binding*: " dialog-apply checklist-group-combo "
                // binding*: " nasal var s = getprop("/sim/gui/dialogs/checklist/selected-checklist-group"); setChecklistGroup(s); "
            }

            Label {
                text: qsTr("Checklist:")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                id: checklist_combo
                // property*: /sim/gui/dialogs/checklist/selected-checklist
                width: 230
                // binding*: " dialog-apply checklist-combo "
                // binding*: " nasal var s = getprop("/sim/gui/dialogs/checklist/selected-checklist"); setprop("/sim/gui/dialogs/checklist/selected-checklist-max-pages", checklist_size[s]); setprop("/sim/gui/dialogs/checklist/selected-page", 0); setprop("/sim/gui/dialogs/checklist/next-available", 1); setprop("/sim/gui/dialogs/checklist/selected-page-text", "1 / " ~ checklist_size[s]); "
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                text: qsTr(" Transparent")
                // property*: /sim/gui/dialogs/checklist/transparent
                // live*: true
                //horizontalAlignment: Text.AlignRight
                // binding*: " dialog-apply "
                // binding*: " property-toggle "
                // binding*: " nasal setTransparency(1); "
                //horizontalAlignment: Text.AlignRight
            }
        } // RowLayout

        HorizontalLine {}

        GridLayout {
            width: parent.width
            id: checklist_table_group
        } // GridLayout

        RowLayout {
            width: parent.width
            // visible*: /sim/gui/dialogs/checklist/selected-checklist-max-pages 1

            Label {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Previous page")
                height: 24
                // equal*: true
                // binding*: " nasal previousPage(); "
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("XX/XX")
                // property*: /sim/gui/dialogs/checklist/selected-page-text
                // live*: true
            }

            Label {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Next page")
                // equal*: true
                height: 24
                // binding*: " nasal nextPage(); "
            }

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end
}
