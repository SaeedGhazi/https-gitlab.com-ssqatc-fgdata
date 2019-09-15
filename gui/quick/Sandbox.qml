import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: sandbox

    SandboxToolbar {
        visible: true
        y: 400
    }

    AboutDialog {
        id: about_dialog
        visible: false
        x: 200
        y: 40
    }

    AiCarrier {
        id: ai_carrier_dialog
        visible: false
        x: 200
        y: 40
    }

    AiObjects {
        id: ai_objects_dialog
        visible: false
        x: 200
        y: 40
    }

    AirDialog {
        id: air_dialog
        visible: false
        x: 200
        y: 40
    }

    Aircraft {
        id: aircraft_dialog
        visible: false
        x: 200
        y: 40
    }

    Airports {
        id: airports_dialog
        visible: false
        x: 200
        y: 40
    }

    AtcFreqDisplay {
        id: atc_freq_dialog
        visible: false
        x: 200
        y: 40
    }

    ExitDialog {
        id: exit_dialog
        visible: false
        x: 200
        y: 40
    }

    FramesPerSecond {
        id: fps_dialog
        visible: false
        x: 200
        y: 40
    }

    FrameLatency {
        id: frame_latency_dialog
        visible: false
        x: 200
        y: 40
    }

    OverlaySelect {
        id: overlay_select_dialog
        visible: false
        x: 200
        y: 40
    }

    SceneryLoading {
        id: scenery_loading_dialog
        visible: false
        x: 200
        y: 40
    }
}
