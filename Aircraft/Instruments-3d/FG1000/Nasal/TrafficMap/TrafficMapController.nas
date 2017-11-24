# Traffic Map Controller
var TrafficMapController =
{
  # Altitude levels levels.
  ALTS : { ABOVE  : { label: "ABOVE",  ceiling_ft: 9000, floor_ft: 2700 },
           NORMAL : { label: "NORMAL", ceiling_ft: 2700, floor_ft: 2700 },
           BELOW  : { label: "BELOW",  ceiling_ft: 2700, floor_ft: 9000 },
           UNREST : { label: "UNRESTRICTED", ceiling_ft: 9000, floor_ft: 9000 }},


   # Three ranges available
   # 2nm
   # 2nm / 6nm
   # 6nm / 12nm
   #
   # TODO:  Currently we simply use the outer range, and display the inner
   # range as 1/3 of the outer.  Doing this properly, we should display
   # different inner rings.
   RANGES : [ {range: 2, inner_label: nil, outer_label: "2nm"},
              {range: 6, inner_label: "2nm", outer_label: "6nm"},
              {range: 12, inner_label: "4nm", outer_label: "12nm"} ],


  new : func (trafficmap, svg)
  {
    var obj = { parents : [ TrafficMapController ] };
    obj.range = 1;
    obj.alt = "NORMAL";
    obj.operating = 0;
    obj.flight_id = 0;
    obj.trafficmap = trafficmap;
    obj.trafficmap.setScreenRange(689/2.0);

    obj.setZoom(obj.range);
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
    me.trafficmap.setRange(
      me.RANGES[zoom].range,
      me.RANGES[zoom].inner_label,
      me.RANGES[zoom].outer_label);
  },
  setAlt : func(alt) {
    if (me.ALTS[alt] == nil) return;
    me.trafficmap.alt_label.setText(me.ALTS[alt].label);
    me.alt = alt;
    # Update the TFC controller to filter out the correct targets
    me.trafficmap.mapgroup.getLayer("TFC").options.ceiling_ft =  me.ALTS[alt].ceiling_ft;
    me.trafficmap.mapgroup.getLayer("TFC").options.floor_ft =  me.ALTS[alt].floor_ft;
  },
  setOperate : func(enabled) {
    if (enabled) {
      me.trafficmap.op_label.setText("OPERATING");
      me.trafficmap.setLayerVisible("TFC", 1);
      me.operating = 1;
    } else {
      me.trafficmap.op_label.setText("STANDBY");
      me.trafficmap.setLayerVisible("TFC", 0);
      me.operating = 0;
    }
  },
  setFlightID : func(enabled) {
    me.flight_id = enabled;
    me.trafficmap.Options.setOption("TFC", "display_id", enabled);
  },
  toggleFlightID : func() {
    me.setFlightID(! me.flight_id);
  },
  isEnabled : func(label) {
    # Cheeky little function that returns whether the alt or operation mode
    # matches the label.  Used to highlight current settings in softkeys
    if (label == me.alt) return 1;
    if (me.operating and label == "OPERATE") return 1;
    if (me.operating == 0 and label == "STANDBY") return 1;
    if (me.flight_id == 1 and label == "FLT ID") return 1;
    return 0;
  },
};
