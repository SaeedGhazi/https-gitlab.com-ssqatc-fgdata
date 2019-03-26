import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0


Item
{
    id: root

    property StackController controller : StackController { }

    property var __activeLoader: pageLoaderA
    readonly property var __inactiveLoader: (__activeLoader == pageLoaderA) ? pageLoaderB
        : pageLoaderA

    Loader {
        id: pageLoaderA
        width: root.width
        anchors { top: parent.top; bottom: parent.bottom; }

        // make the controller available to pages
        property StackController stack: root.controller
    }

    Loader {
        id: pageLoaderB
        width: root.width
        anchors { top: parent.top; bottom: parent.bottom; }

        // make the controller available to pages
        property StackController stack: root.controller
    }

    Connections {
        target: controller
        onCurrentPageSourceChanged: {
            __inactiveLoader.visible = true;
            __inactiveLoader.source = controller.currentPageSource;

            __inactiveLoader.z = 1;
            __activeLoader.z = 0;
            __activeLoader = __inactiveLoader;

            // can modify this to change animation direction
            __activeLoader.x = root.width
            pageTransitionAnimation.start();
        }
    }

    ParallelAnimation {
        id: pageTransitionAnimation

        NumberAnimation {
            target: root.__activeLoader
            property: "x"
            to: 0
            duration: 800
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: root.__activeLoader
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 800
        }

        onStopped: {
            __inactiveLoader.visible = false;
            __inactiveLoader.source = "";
        }
    }

    Component.onCompleted: {
        pageLoaderA.source = controller.currentPageSource
    }
}

