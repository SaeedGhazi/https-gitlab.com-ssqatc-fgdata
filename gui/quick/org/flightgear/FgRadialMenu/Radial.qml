import QtQuick 2.12

Item {
    id: layout
    property real radius: 250.0

    anchors.fill: parent

    onChildrenChanged: performLayout()
    onWidthChanged: performLayout()
    onHeightChanged: performLayout()

    function performLayout() {
        if (layout.children.length == 0)
            return;

        var radianAngles = [
            1.0,
            0.0,
            1.5,
            0.5,
            1.2,
            1.8,
            0.8,
            0.2
        ];

        var skipCount = 0;
        for (var i = 0; i < layout.children.length; ++i) {
            var obj = layout.children[i];
            if (!obj.toString().startsWith("RadialItem")) {
                ++skipCount;
                continue;
            }

            var newIndex = i - skipCount;
            var idx = newIndex < 8 ? newIndex : 7;
            var displacement = (newIndex - idx) * 35 + (newIndex - idx != 0 ? 12 : 0);

            var angle = radianAngles[idx] * Math.PI;
            obj.x = (radius * Math.cos(angle) + layout.width / 2) - obj.width / 2;
            obj.y = (radius * Math.sin(angle) + layout.height / 2) + displacement;
        }
    }
}
