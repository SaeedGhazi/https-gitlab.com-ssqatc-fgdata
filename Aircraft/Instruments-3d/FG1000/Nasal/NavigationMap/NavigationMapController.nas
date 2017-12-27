# Navigation Map Controller
var NavigationMapController =
{
  # Vertical ranges, and labels.
  # 28 ranges from 500ft to 2000nm, measuring the vertical map distance.
  # Vertical size of the map (once the nav box and softkey area is removed) is 689px.
  # 2000nm = 12,152,000ft.
  RANGES : [{range: 500/6076.12, label: "500ft"},
            {range: 750/6076.12, label: "750ft"},
            {range: 1000/6076.12, label: "1000ft"},
            {range: 1500/6076.12, label: "1500ft"},
            {range: 2000/6076.12, label: "2000ft"},
            {range: 0.5, label: "0.5nm"},
            {range: 0.75, label: "0.75nm"},
            {range: 1, label: "1nm"},
            {range: 2, label: "2nm"},
            {range: 3, label: "3nm"},
            {range: 4, label: "4nm"},
            {range: 6, label: "6nm"},
            {range: 8, label: "8nm"},
            {range: 10, label: "10nm"},
            {range: 12, label: "12nm"},
            {range: 15, label: "15nm"},
            {range: 20, label: "20nm"},
            {range: 25, label: "25nm"},
            {range: 30, label: "30nm"},
            {range: 40, label: "40nm"},
            {range: 50, label: "50nm"},
            {range: 75, label: "75nm"},
            {range: 100, label: "100nm"},
            {range: 200, label: "200nm"},
            {range: 500, label: "500nm"},
            {range: 1000, label: "1000nm"},
            {range: 1500, label: "1500nm"},
            {range: 2000, label: "2000nm"}, ],

  ORIENTATIONS : [
    { label: "NORTH UP" },
    { label: "TRK UP" },
    { label: "DTK UP" },
    { label: "HDG UP" },
  ],

  # Layer display configuration:
  # enabled   - whether this layer has been enabled by the user
  # declutter - the maximum declutter level (0-3) that this layer is visible in
  # range     - the maximum range this layer is visible (configured by user)
  # max_range - the maximum range value that a user can configure for this layer.
  LAYER_RANGES : {
    GRID : { enabled: 0, declutter: 1, range: 20, max_range: 2000 },
    DME  : { enabled: 1, declutter: 1, range: 150, max_range: 300 },
    VOR  : { enabled: 1, declutter: 1, range: 150, max_range: 300 },
    NDB  : { enabled: 1, declutter: 1, range: 15, max_range: 30 },
    FIX  : { enabled: 1, declutter: 1, range: 15, max_range: 30 },
    RTE  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000 },
    WPT  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000 },

    APS  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000 },
    FLT  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000 },

    WXR  : { enabled: 1, declutter: 2, range: 2000, max_range: 2000 },

    APT  : { enabled: 1, declutter: 2, range: 150, max_range: 300 },

    TFC  : { enabled: 0, declutter: 3, range: 150, max_range: 2000},

    OpenAIP : { enabled: 1, declutter: 1, range: 150, max_range: 300 },
    STAMEN  : { enabled: 1, declutter: 3, range: 500, max_range: 2000 },
    STAMEN_terrain  : { enabled: 1, declutter: 3, range: 500, max_range: 2000 },
  },

  # TODO: Add STAMEN topo layer, which is visible on all levels as opposed to
  # roads, railways, boundaries, cities which are only visible on declutter 0.

  # Declutter levels.
  DCLTR : [ "DCLTR", "DCLTR-1", "DCLTR-2", "DCLTR-3"],

  # Airways levels.
  AIRWAYS : [ "AIRWAYS", "AIRWY ON", "AIRWY LO", "AIRWY HI"],


  new : func (page, svg)
  {
    var obj = { parents : [ NavigationMapController ] };
    obj.current_zoom = 8;
    obj.declutter = 0;
    obj.airways = 0;
    obj.page = page;
    obj.setZoom(obj.current_zoom);
    obj.setOrientation(obj.ORIENTATIONS[0]);

    # Emesary
    obj._recipient = nil;
    obj._zoomRecipient = nil;

    return obj;
  },
  zoomIn : func() {
    me.setZoom(me.current_zoom -1);
  },
  zoomOut : func() {
    me.setZoom(me.current_zoom +1);
  },
  zoom : func(val)
  {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me.setZoom(me.current_zoom + incr_or_decr);
  },
  setZoom : func(zoom) {
    if ((zoom < 0) or (zoom > (size(me.RANGES) - 1))) return;
    me.current_zoom = zoom;
    # Ranges above represent vertical ranges, but the display is a rectangle, so
    # we need to use the diagonal range of the 1024 x 689, which is 617px.
    # 617px is 1.8 x 689/2, so we need to increase the range values by x1.8
    me.page.setRange(me.RANGES[zoom].range, me.RANGES[zoom].label);
    me.updateVisibility();
  },
  setOrientation : func(orientation) {
    me.page.setOrientation(orientation.label);
  },
  updateVisibility : func() {
    # Determine which layers should be visible.
    foreach (var layer_name; keys(me.LAYER_RANGES)) {
      var layer = me.LAYER_RANGES[layer_name];
      if (layer.enabled and
          (me.RANGES[me.current_zoom].range <= layer.range) and
          (me.declutter <= layer.declutter)   )
      {
        me.page.MFDMap.getLayer(layer_name).setVisible(1);
      } else {
        me.page.MFDMap.getLayer(layer_name).setVisible(0);
      }
    }
  },
  configureLayer : func(layer, enabled, range) {
    me.LAYER_RANGES[layer].enabled = enabled;
    me.LAYER_RANGES[layer].range = math.min(range, me.LAYER_RANGES[layer].max_range);
  },
  isEnabled : func(layer) {
    return me.LAYER_RANGES[layer].enabled;
  },
  toggleLayer : func(layer) {
    me.LAYER_RANGES[layer].enabled = ! me.LAYER_RANGES[layer].enabled;
    me.updateVisibility();
  },

  # Increment through the de-clutter levels, which impact what layers are
  # displayed.  We also need to update the declutter menu item.
  incrDCLTR : func(device, menuItem) {
    me.declutter = math.mod(me.declutter +1, 4);
    menuItem.title = me.DCLTR[me.declutter];
    device.updateMenus();
    me.updateVisibility();
  },

  # Increment through the AIRWAYS levels.  At present this doesn't do anything
  # except change the label.  It should enable/disable different airways
  # information.
  incrAIRWAYS : func(device, menuItem) {
    me.airways = math.mod(me.airways +1, 4);
    menuItem.title = me.AIRWAYS[me.airways];
    device.updateMenus();
    me.updateVisibility();
  },
  handleFMSInner : func(value) {
    # This page has no use for the FMS knob, so we pass all such
    # events to the pageGroupController which displays the page menu in the
    # bottom right of the screen
    return me.page.mfd._pageGroupController.handleFMSInner(value);
  },
  handleFMSOuter : func(value) {
    # This page has no use for the FMS knob, so we pass all such
    # events to the pageGroupController which displays the page menu in the
    # bottom right of the screen
    return me.page.mfd._pageGroupController.handleFMSOuter(value);
  },
  RegisterWithEmesary : func(transmitter = nil) {
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._recipient == nil){
      me._recipient = emesary.Recipient.new("NavMapController_" ~ me.page.device.designation);
      var pfd_obj = me.page.device;
      var controller = me;
      me._recipient.Receive = func(notification)
      {
        if (notification.Device_Id == pfd_obj.device_id
            and notification.NotificationType == notifications.PFDEventNotification.DefaultType) {
          if (notification.Event_Id == notifications.PFDEventNotification.HardKeyPushed
              and notification.EventParameter != nil)
          {
            var id = notification.EventParameter.Id;
            var value = notification.EventParameter.Value;
            #printf("Button pressed " ~ id ~ " " ~ value);
            if (id == fg1000.FASCIA.FMS_OUTER)  return controller.handleFMSOuter(value);
            if (id == fg1000.FASCIA.FMS_INNER)  return controller.handleFMSInner(value);
            if (id == fg1000.FASCIA.RANGE)      return controller.zoom(value);
          }
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
      };
    }
    transmitter.Register(me._recipient);
    me.transmitter = transmitter;
  },
  DeRegisterWithEmesary : func(transmitter = nil) {
      # remove registration from transmitter; but keep the recipient once it is created.
      if (me.transmitter != nil)
        me.transmitter.DeRegister(me._recipient);
      me.transmitter = nil;
  },
  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();
  },
  offdisplay : func() {
    me.DeRegisterWithEmesary();
  },

  # Set controller for cases where the NavigationMap is displayed as part of
  # another page, e.g. NearestAirports
  #
  # In this case we are only interested in a subset of the buttons to control
  # the map.

  RegisterZoomWithEmesary : func(transmitter = nil) {
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._zoomRecipient == nil){
      me._zoomRecipient = emesary.Recipient.new("NavMapController_" ~ me.page.device.designation);
      var pfd_obj = me.page.device;
      var controller = me;
      me._zoomRecipient.Receive = func(notification)
      {
        if (notification.Device_Id == pfd_obj.device_id
            and notification.NotificationType == notifications.PFDEventNotification.DefaultType) {
          if (notification.Event_Id == notifications.PFDEventNotification.HardKeyPushed
              and notification.EventParameter != nil)
          {
            var id = notification.EventParameter.Id;
            var value = notification.EventParameter.Value;
            #printf("Button pressed " ~ id ~ " " ~ value);
            if (id == fg1000.FASCIA.RANGE)      return controller.zoom(value);
          }
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
      };
    }
    transmitter.Register(me._zoomRecipient);
    me.zoomTransmitter = transmitter;
  },
  DeRegisterZoomWithEmesary : func(transmitter = nil) {
      # remove registration from transmitter; but keep the recipient once it is created.
      if (me.zoomTransmitter != nil)
        me.zoomTransmitter.DeRegister(me._zoomRecipient);
      me.zoomTransmitter = nil;
  },

  ondisplayPartial : func() {
    me.RegisterZoomWithEmesary();
  },
  offdisplayPartial : func() {
    me.DeRegisterZoomWithEmesary();
  },
};
