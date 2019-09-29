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
    SandboxToolbar { visible: true; y: 250 }

    // Dialogs
    AboutDialog { id: about_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AiCarrierDialog { id: ai_carrier_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AiObjectsDialog { id: ai_objects_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AirDialog { id: air_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AircraftDialog { id: aircraft_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AirportsDialog { id: airports_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AlsFiltersDialog { id: als_filters_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AtcDialog { id: atc_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AtcAiDialog { id: atc_ai_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AtcFrequenciesDialog { id: atc_freq_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    AtcFrequenciesSearchDialog { id: atc_freq_search_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ButtonAxisConfigDialog { id: button_axis_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // ButtonsConfigDialog { id: button_config_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // CarrierEisenhowerDialog { id: carrier_eisenhower_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    CarrierNimitzDialog { id: carrier_nimitz_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    CarrierSanAntonioDialog { id: carrier_sanantonio_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    CarrierTrumanDialog { id: carrier_truman_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    CarrierVinsonDialog { id: carrier_vinson_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ChatDialog { id: chat_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ChatFullDialog { id: chat_full_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // ChatMenuDialog { id: chat_menu_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ChecklistDialog { id: checklist_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    CockpitViewDialog { id: cockpit_view_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    DevelopmentExtensionsDialog { id: dev_extensions_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    DocBrowserDialog { id: doc_browser_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // EarthviewDialog { id: earthview_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    EnvironmentSettingsDialog { id: env_settings_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ExitDialog { id: exit_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    FGComDialog { id: fgcom_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    FileSelectDialog { id: file_select_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    FlightRecorderDialog_Load { id: recorder_load_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    FlightRecorderDialog_Save { id: recorder_save_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    FormationDialog { id: formation_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    GpsDialog { id: gps_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    HelpDialog_BasicKeys { id: help_basic_keys_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    HudDialog { id: hud_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    InstrumentFailuresDialog { id: instrument_failures_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // InstrumentDialog { id: instruments_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    JetwaysAdjustDialog { id: jetways_adjust_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    JetwaysDialog { id: jetways_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // JoystickConfigDialog { id: joystick_config_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    JoystickInfoDialog { id: joystick_info_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LagAdjustDialog { id: lag_adjust_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LocalWeatherConfigDialog { id: local_weather_config_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LocalWeatherTilesDialog { id: local_weather_tiles_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LocalWeatherWindsDialog { id: local_weather_winds_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LocalWeatherDialog { id: local_weather_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LocationInAirDialog { id: location_inair_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LocationOfTowerDialog { id: location_oftower_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LoggingDialog { id: logging_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    LsoViewDialog { id: lso_view_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    MapCanvasDialog { id: map_canvas_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    MapDialog { id: map_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    MarkerAdjustDialog { id: marker_adjust_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    MessageDialog { id: message_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ModelCockpitViewDialog { id: model_cockpit_view_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ModelViewDialog { id: model_view_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // ModelViewSelectDialog { id: model_view_select_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    MouseConfigDialog { id: mouse_config_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    MultiplayerDialog { id: multiplayer_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    NasalConsoleDialog { id: nasal_console_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    NtpsTargetTaskDialog { id: ntps_target_task_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    OverlaySelectDialog { id: overlay_select_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    PilotOffsetDialog { id: pilot_offset_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    PopupDialog { id: popup_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    PropertyBrowserDialog { id: property_browser_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    PushbackDialog { id: pushback_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // RenderingDialog { id: rendering_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    RadiosDialog { id: radios_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    RandomFailuresDialog { id: random_failures_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // RembrandtBuffersDialog { id: rembrandt_buffers_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    RembrandtDialog { id: rembrandt_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ReplayDialog { id: replay_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // RouteManagerDialog { id: route_manager_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ScenarioDialog { id: scenario_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    SeaportDialog { id: seaport_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ShadersDialog { id: shaders_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    ShadersLightfieldDialog { id: shaders_lightfield_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    SoundDialog { id: sound_config_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    StaticLodDialog { id: static_lod_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    StereoscopicViewOptionsDialog { id: stereoscopic_view_options_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    StopwatchDialog { id: stopwatch_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    SwiftConnectionDialog { id: swift_connection_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    SystemFailuresDialog { id: system_failures_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    TankerDialog { id: tanker_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    TerrasyncDialog { id: terrasync_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    TimeOfDayDialog { id: time_ofday_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    TutorialDialog { id: tutorial_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // ViewOptionsDialog { id: view_options_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoDialog_Beerenberg { id: volcano_beerenberg_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoDialog_Etna { id: volcano_etna_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoDialog_Eyjafjallajokull { id: volcano_eyjafjallajokull_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoDialog_Katla { id: volcano_katla_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoDialog_Kilauea { id: volcano_kilauea_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoDialog_Stromboli { id: volcano_stromboli_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    VolcanoesDialog { id: volcanoes_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // WeatherConfigurationDialog { id: weather_configuration_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    // WeatherDialog { id: weather_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }
    WindsDialog { id: winds_dialog; visible: false; x: 200; y: 40; onClosed: visible = false }


    // Overlays
    FramesPerSecond { id: fps_dialog; visible: false; x: 200; y: 40 }
    FrameLatency { id: frame_latency_dialog; visible: false; x: 200; y: 40 }
    SceneryLoading { id: scenery_loading_dialog; visible: false; x: 200; y: 40 }
}
