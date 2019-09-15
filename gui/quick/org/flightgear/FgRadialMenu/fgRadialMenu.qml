import QtQuick 2.12

import "jsonManager.js" as JsonManager

Rectangle {
    id: rectangle
    width: 800
    height: 800

    Item {
        id: menuController
        property var menuData: ({})
        property string activeMenuTitle: ""
    }

    function changeMenu(menuId) {
        JsonManager.fetch("menus/menu.json").then(
            function(result) {
                menuController.menuData = result;

                var desiredMenuId = menuId ? menuId : result.default;
                for (var idx in result.menuItems) {
                    if (result.menuItems[idx].id == desiredMenuId) {
                        menuController.activeMenuTitle = result.menuItems[idx].title;
                        break;
                    }
                }

                canvas.requestPaint()
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
        property bool isHit: false
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
            ctx.strokeStyle = (isHit ? "#6d6d6d" : "#9d9d9d");
            ctx.stroke();

            if (!isHit) {
                ctx.beginPath();
                ctx.arc(centerX, centerY, 60, angle - 0.39, angle + 0.39, false);
                ctx.lineWidth = 4;
                ctx.strokeStyle = "#9d9d9d";
                ctx.stroke();
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true

            onPositionChanged: {
                mouseStatus.text = "mouse: (x: " + mouse.x + ", y: " + mouse.y + ")"

                var centerX = width / 2;
                var centerY = height / 2;
                canvas.angle = Math.atan2(mouse.y - centerY, mouse.x - centerX);

                var delta = 50 + 6;  // Home circle radius + half the stroke size
                var isHit = (mouse.x > centerX - delta && mouse.x < centerX + delta && mouse.y > centerY - delta && mouse.y < centerY + delta)
                if (isHit != canvas.isHit) {
                    canvas.isHit = isHit
                }

                canvas.requestPaint()
            }
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
            model: menuController.menuData.menuItems

            RadialItem {
                text: modelData.title
            }
        }
    }

    Text {
        id: mouseStatus
        text: "mouse: "
    }
}
