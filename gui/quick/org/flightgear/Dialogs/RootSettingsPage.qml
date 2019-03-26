import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item
{
    id: settingsRoot

    Flickable
    {
        id: settingsFlick
        contentHeight: sectionColumn.height
        flickableDirection: Flickable.VerticalFlick
        height: parent.height
        width: parent.width - scrollbar.width
        clip: true

       Column
        {
            id: sectionColumn
            width: parent.width

            Item {
                // top margin
                width: parent.width
                height: Style.margin
            }

            Item {
                id: header
                width: parent.width
                height: headerText.height

                // Back button when drilled-down

                // make this breadcrumbs when we have multiple pages
                Text {
                    id: headerText
                    text: qsTr("Settings")
                    font.pixelSize: Style.headingFontPixelSize
                    anchors.left: parent.left
                    anchors.leftMargin: Style.inset
                }

                SearchButton {
                    id: search
                    width: Style.strutSize * 4
                    anchors.right: parent.right
                    anchors.rightMargin: Style.margin
                    anchors.verticalCenter: parent.verticalCenter
                    autoSubmitTimeout: 250
                    onSearch: {
                    //    _launcher.settingsSearchTerm = term
                    }
                }
            }

            Item {
                // below header margin
                width: parent.width
                height: Style.margin
            }

            Section {
                id: generalSettings
                title: qsTr("General")
                settingGroup: "general"

                contents: [
                    SettingCheckbox {
                        id: startPaused
                        label: qsTr("Start paused")
                        description: qsTr("Automatically pause the simulator when launching. This is useful "
                            + "when starting in the air.")
                        keywords: ["pause", "freeze"]
                        option: "freeze"
                        setting: "start-paused"
                    },

                    SettingCheckbox {
                        id: autoCoordination
                        label: qsTr("Enable auto-coordination")
                        description: qsTr("When flying with the mouse, or a joystick lacking a rudder axis, "
                            + "it's difficult to manually coordinate aileron and rudder movements during "
                            + "turn. This option automatically commands the rudder to maintain zero "
                            + "slip angle when banking");
                        advanced: true
                        keywords: ["input", "mouse", "control", "rudder"]
                        option: "auto-coordination"
                        setting: "auto-coordination"
                    },

                    SettingPathChooser {
                        id: screenshotDirectory
                        label: qsTr("Screenshot location")
                        description: qsTr("Select the location to save screenshots")
                        advanced: true
                        keywords: ["screenshot"]
                    },


                    SettingCheckbox {
                        id: terrasync
                        label: qsTr("Download scenery automatically")
                        description: qsTr("Automatically download scenery as you fly");
                    }
                ]
            }

            Section {
                id: inputSettings
                title: qsTr("Controls & joysticks")

                contents: [
                    // press-and-hold vs right-click-to-cycle mode

                    SettingCheckbox {
                        id: mouseFlightControlsEnabled
                        label: qsTr("Allow flight with mouse input")
                        description: qsTr("Allow mouse control of the flight surfaces (pitch and roll) by pressing the tab key")
                        advanced: true
                        keywords: ["input", "mouse", "controls"]
                    },

                    SettingCheckbox {
                        id: invertMouseWheel
                        label: qsTr("Invert mouse-wheel direction")
                        description: qsTr("Swap the direction of increasing / decreasing movement when using the mouse wheel to adjust cockpit knobs and levers")
                        keywords: ["input", "mouse","wheel", "direction", "invert"]
                    },

                    SettingDrillDown {
                        label: qsTr("Configure joysticks, pedals and similar devices")
                        drillDownTarget: Qt.resolvedUrl("SettingsJoysticksPage.qml");
                    }
                ]
            }

            Section {
                id: soundSettings
                title: qsTr("Sound")
                settingGroup: "sound"

                contents: [
                    // todo only show this if we have > 1 device
                    SettingsComboBox {
                        id: soundOutputDevice
                        label: qsTr("Sound output")
                        choices: ["Built-in", "HDMI"]
                        description: qsTr("Select which audio output device is used for sound")
                        keywords: ["device", "audio", "alsa", "output", "speaker", "headphone"]
                    },

                    SoundVolumeSetting {
                        id: masterVolume
                        label: qsTr("Master volume")
                        description: qsTr("Make noises")
                        keywords: ["sound", "audio", "mute"]
                    },

                    SoundVolumeSetting {
                        id: atcVolume
                        label: qsTr("ATC volume")
                        advanced: true
                        description: qsTr("ATC is used for COMM radios")
                        keywords: ["sound", "audio", "mute", "atc"]
                    },

                    SoundVolumeSetting {
                        id: effectsVolume
                        label: qsTr("Effects volume")
                        advanced: true
                        description: qsTr("Effects include engine noise, wind, rain")
                        keywords: ["sound", "audio", "mute", "effects"]
                    },

                    SettingCheckbox {
                        id: voicePrompts
                        label: qsTr("Use voice synthesis for tutorials and comms")
                        description: qsTr("Use the built-in syntheziser to speak tutorial and comms messages. "
                            + "Chaning this setting requires a restart.")
                    }
                ]
            }

            Section {
                id: viewSettings
                title: qsTr("Views")

                contents: [
                    SettingCheckbox {
                        label: qsTr("Some view settings")
                        description: qsTr("Booleanb view setting toggle")
                    },

                    SettingDrillDown {
                        label: qsTr("Select available views")
                        drillDownTarget: Qt.resolvedUrl("SettingsViewsPage.qml");
                    }
                ]


            }

            Section {
                id: renderSettings
                title: qsTr("Graphics & Rendering")
                settingGroup: "rendering"

                contents: [
                    SettingCheckbox {
                        label: qsTr("Enable particles")
                        description: qsTr("Particle effects are used for smoke, dust, contrails and other effects.")
                        keywords: ["performance", "effects", "particles", "rendering"]
                    },

                    SettingCheckbox {
                        id: show3DClouds
                        label: qsTr("Show 3D clouds")
                        description: qsTr("Render clouds in 3D using layered sprites")
                        keywords: ["performance", "clouds", "rendering", "weather"]

                    },

                    SettingSlider {
                        label: qsTr("3D cloud density")
                        advanced: true
                        description: qsTr("Adjust the maximum density of clouds. Larger values can severely impact frame-rates")
                        keywords: show3DClouds.keywords
                        max: 100
                    },

                    SettingDrillDown {
                        label: qsTr("Advanced shader settings")
                        drillDownTarget: Qt.resolvedUrl("EffectsSettingsPage.qml");
                    }

                ]
            }


        } // of layout column
    } // of the flickable

    Scrollbar {
        id: scrollbar
        anchors.right: parent.right
        height: parent.height
        flickable: settingsFlick
        visible: settingsFlick.contentHeight > settingsFlick.height
    }
}

