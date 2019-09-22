import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: sandbox
    width: 1024
    height: 800

    // Menu
    SandboxMenu {}

    // Toolbar
    SandboxToolbar { visible: true; y: 400 }

    // Dialogs
    AboutDialog { id: about_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AiCarrierDialog { id: ai_carrier_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AiObjectsDialog { id: ai_objects_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AirDialog { id: air_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AircraftDialog { id: aircraft_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    Airports { id: airports_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AtcFreqDisplay { id: atc_freq_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ExitDialog { id: exit_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    FramesPerSecond { id: fps_dialog; visible: false; x: 200; y: 40 }
    FrameLatency { id: frame_latency_dialog; visible: false; x: 200; y: 40 }
    HelpBasicKeys { id: help_basic_keys_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    OverlaySelect { id: overlay_select_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    SceneryLoading { id: scenery_loading_dialog; visible: false; x: 200; y: 40 }
}
