import QtQuick 2.4
import org.flightgear.UI 1.0

Item {
    id: root
    property alias title: header.text
    property alias contents: contentBox.children
    property alias showAdvanced: header.showAdvanced
    property string settingGroup: ""
    property string summary: ""
    readonly property bool haveAdvancedSettings: anyAdvancedSettings(contents)


    implicitWidth: parent.width
    implicitHeight: header.height + contentBox.height + (Style.margin * 2)

    signal apply();

    function saveState()
    {
        for (var i = 0; i < contents.length; i++) {
            contents[i].saveState();
        }
    }

    function anyAdvancedSettings(items)
    {
        for (var i = 0; i < items.length; i++) {
            if (items[i].advanced === true) return true;
        }

        return false;
    }

    // we determine the initial open/close state of the advanced section
    // based on whether any of the advanced settings are non-default
    function anyNonDefaultAdvancedSettings(items)
    {
        for (var i = 0; i < items.length; i++) {
            var control = items[i];
            if (control.advanced === true) {
                if (!control.__isDefault && !control.hidden) {
                    //console.info("Non-default advanced setting:" + control.label + ","
                    //             + control.defaultValue + " != " + control.value) ;
                    return true;
                }
             }
        }

        return false;
    }

    // Connections {
    //     target: _config
    //     onCollect: root.apply();
    // }

    Component.onCompleted: {
        // use this as a trigger to decide the initial open/close state
        if (anyNonDefaultAdvancedSettings(contents)) {
            showAdvanced = true;
        }
    }

    SettingsHeader {
        id: header
        width: parent.width
        haveAdvancedSettings: root.haveAdvancedSettings
    }

    MouseArea {
        anchors.fill: contentBox
        onClicked: {
            // take focus back from any active control
            root.focus = true
        }
    }

    Column {
        id: contentBox
        anchors.top: header.bottom
        anchors.topMargin: Style.margin
        width: parent.width
        spacing: Style.margin * 2

        // this is here so SettingControl 's parent (which is us)
        // can be used to find the advanced toggle state
        property alias showAdvanced: header.showAdvanced
    }

    // bottom spacing item
    Item {
        height: Style.margin
        width: parent.width
        anchors.top: contentBox.bottom
    }
}
