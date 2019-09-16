import QtQuick 2.12

import "jsonManager.js" as JsonManager

Rectangle {
    id: rectangle
    width: 1024
    height: 800

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            if (canvas.visible) {
                canvas.visible = false;
                mouse.accepted = true;
            }
        }
    }

    Item {
        id: menuController
        property var menuData: ({})
        property string activeMenuId: ""
        property string activeMenuTitle: ""
        property string menuType: "Control"
    }

    function changeMenu(menuId, menuType = menuController.menuType) {
        JsonManager.fetch("menus/menu.json").then(
            function(result) {
                if (menuType == "Main") {
                    menuController.menuData = result;
                    rptMenuControl.model = menuController.menuData.menuItems
                }

                var desiredMenuId = menuId ? menuId : result.default;
                var subMenuName = ""

                for (var idx in result.menuItems) {
                    if (result.menuItems[idx].id == desiredMenuId) {
                        menuController.activeMenuId = desiredMenuId
                        menuController.activeMenuTitle = result.menuItems[idx].title;
                        subMenuName = result.menuItems[idx].definition
                        break;
                    }
                }

                if (subMenuName == "") {
                    canvas.requestPaint()
                    return;
                }

                JsonManager.fetch(subMenuName).then(
                    function(result) {
                        if (menuType == "Control") {
                            menuController.menuData = result;
                            rptMenuControl.model = menuController.menuData.controlItems.menuItems
                        }
                        if (menuType == "Configure") {
                            menuController.menuData = result;
                            rptMenuControl.model = menuController.menuData.configureItems.menuItems
                        }

                        canvas.requestPaint()
                    },
                    function(err) {
                        console.log(err);
                    }
                );
            },
            function(err) {
                console.log(err);
            }
        );
    }

    Component.onCompleted: {
        changeMenu(null);
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        visible: false
        focus: true

        property bool isHit: false
        property bool isHover: false
        property real angle: 0.0
        property string menuName: ""

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;

            ctx.beginPath();
            ctx.arc(centerX, centerY, 50, 0, 2 * Math.PI, false);
            ctx.lineWidth = 12;
            ctx.strokeStyle = (isHover ? "#6d6d6d" : "#9d9d9d");
            ctx.stroke();

            if (!isHover) {
                ctx.beginPath();
                ctx.arc(centerX, centerY, 60, angle - 0.39, angle + 0.39, false);
                ctx.lineWidth = 4;
                ctx.strokeStyle = "#9d9d9d";
                ctx.stroke();
            }
        }

        Text {
            id: menuTitle
            text: menuController.activeMenuTitle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 12
        }

        Radial {
            Repeater {
                id: rptMenuControl
                model: null

                RadialItem {
                    menuId: modelData.id
                    text: modelData.title
                    onClicked: {
                        console.log(menuId)
                        if (menuId != null) {
                            changeMenu(menuId)
                        }
                        canvas.visible = false;
                    }
                }
            }
        }
    }

    Row {
        spacing: 12
        Text { id: mouseStatus; text: "" }
        Text { color: "gray"; text: "Menu Usage:" }
        Row { Text { color: "gray"; text: "<esc>: " } Text { text: "Toggle show/hide" } }
        Row { Text { color: "gray"; text: "<ctrl>-click: " } Text { text: "Control menu" } }
        Row { Text { color: "gray"; text: "<ctrl><alt>-click: " } Text { text: "Change active menu" } }
        Row { Text { color: "gray"; text: "<shift>-click: " } Text { text: "Configure menu" } }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Escape) {
            canvas.visible = !canvas.visible
            event.accepted = false;
            return;
        }

        if (!canvas.isHover) {
            event.accepted = false;
            return;
        }

        if (event.modifiers & Qt.ShiftModifier) {
            changeMenu(menuController.activeMenuId, "Configure")
            event.accepted = true;
        }
        else if (event.modifiers & Qt.AltModifier && event.modifiers & Qt.ControlModifier) {
            changeMenu(menuController.activeMenuId, "Main")
            event.accepted = true;
        }
        else if (event.modifiers & Qt.ControlModifier) {
            changeMenu(menuController.activeMenuId, "Control")
            event.accepted = true;
        }
        else
            event.accepted = false;
    }

    Keys.onReleased: {
        changeMenu(menuController.activeMenuId)
        event.accepted = true;
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        onClicked: {
            if (mouse.modifiers & Qt.ShiftModifier) {
                canvas.visible = true;
                menuController.menuType = "Configure";
                changeMenu(menuController.activeMenuId)
                mouse.accepted = true;
            }
            else if (mouse.modifiers & Qt.AltModifier && mouse.modifiers & Qt.ControlModifier) {
                canvas.visible = true;
                menuController.menuType = "Main";
                changeMenu(menuController.activeMenuId)
                mouse.accepted = true;
            }
            else if (mouse.modifiers & Qt.ControlModifier) {
                canvas.visible = true;
                menuController.menuType = "Control";
                changeMenu(menuController.activeMenuId)
                mouse.accepted = true;
            }
            else
                mouse.accepted = false;
        }

        onPositionChanged: {
            // mouseStatus.text = "mouse: (x: " + mouse.x + ", y: " + mouse.y + ")"

            var centerX = width / 2;
            var centerY = height / 2;
            canvas.angle = Math.atan2(mouse.y - centerY, mouse.x - centerX);

            var delta = 50 + 6;  // Home circle radius + half the stroke size
            var isHover = (mouse.x > centerX - delta && mouse.x < centerX + delta && mouse.y > centerY - delta && mouse.y < centerY + delta)
            if (isHover != canvas.isHover) {
                canvas.isHover = isHover
            }

            canvas.requestPaint()
        }
    }
}
