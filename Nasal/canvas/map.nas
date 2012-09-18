# Runway
#
var Runway = {
  # Create Runway from hash
  #
  # @param rwy  Hash containing runway data as returned from
  #             airportinfo().runways[ <runway designator> ]
  new: func(rwy)
  {
    return {
      parents: [Runway],
      rwy: rwy
    };
  },
  # Get a point on the runway with the given offset
  #
  # @param pos  Position along the center line
  # @param off  Offset perpendicular to the center line
  pointOffCenterline: func(pos, off = 0)
  {
    var coord = geo.Coord.new();
    coord.set_latlon(me.rwy.lat, me.rwy.lon);
    coord.apply_course_distance(me.rwy.heading, pos - 0.5 * me.rwy.length);

    if( off )
      coord.apply_course_distance(me.rwy.heading + 90, off);

    return ["N" ~ coord.lat(), "E" ~ coord.lon()];
  }
};

# AirportMap
#
var AirportMap = {
  # Create AirportMap from hash
  #
  # @param apt  Hash containing airport data as returned from airportinfo()
  new: func(apt)
  {
    return {
      parents: [AirportMap],
      _apt: apt
    };
  },
  # Build the graphical representation of the represented airport
  #
  # @param layer_runways  canvas.Group to attach airport map to
  # @param selected       [optional] The name of a property containing the
  #                       currently selected runway
  build: func(layer_runways, selected = nil)
  {
    var rws_done = {};

    me.grp_apt = layer_runways.createChild("group", "apt-" ~ me._apt.id);
    var selected_rwy = (selected) ? getprop(selected) : nil;

    foreach(var rw; keys(me._apt.runways))
    {
      var is_heli = substr(rw, 0, 1) == "H";
      var rw_dir = is_heli ? nil : int(substr(rw, 0, 2));

      var rw_rec = "";
      var thresh_rec = 0;
      if( rw_dir != nil )
      {
        rw_rec = sprintf("%02d", math.mod(rw_dir - 18, 36));
        if( size(rw) == 3 )
        {
          var map_rec = {
            "R": "L",
            "L": "R",
            "C": "C"
          };
          rw_rec ~= map_rec[substr(rw, 2)];
        }

        if( rws_done[rw_rec] != nil )
          continue;

        var rw_rec = me._apt.runways[rw_rec];
        if( rw_rec != nil )
          thresh_rec = rw_rec.threshold;
      }

      rws_done[rw] = 1;

      rw = me._apt.runways[rw];
      var icon_rw =
        me.grp_apt.createChild("path", "runway")
                  .setStrokeLineWidth(0.5)
                  .setColor(1.0,1.0,1.0)
                  .setColorFill(0.2, 0.2, 0.2);

      var rwy = Runway.new(rw);
      var beg_thr  = rwy.pointOffCenterline(rw.threshold);
      var beg_thr1 = rwy.pointOffCenterline(rw.threshold,  0.5 * rw.width);
      var beg_thr2 = rwy.pointOffCenterline(rw.threshold, -0.5 * rw.width);
      var beg1 = rwy.pointOffCenterline(0,  0.5 * rw.width);
      var beg2 = rwy.pointOffCenterline(0, -0.5 * rw.width);

      var end_thr  = rwy.pointOffCenterline(rw.length - thresh_rec);
      var end_thr1 = rwy.pointOffCenterline(rw.length - thresh_rec,  0.5 * rw.width);
      var end_thr2 = rwy.pointOffCenterline(rw.length - thresh_rec, -0.5 * rw.width);
      var end1 = rwy.pointOffCenterline(rw.length,  0.5 * rw.width);
      var end2 = rwy.pointOffCenterline(rw.length, -0.5 * rw.width);

      icon_rw.setDataGeo
      (
        [ canvas.Path.VG_MOVE_TO,
          canvas.Path.VG_LINE_TO,
          canvas.Path.VG_LINE_TO,
          canvas.Path.VG_LINE_TO,
          canvas.Path.VG_CLOSE_PATH ],
        [ beg1[0], beg1[1],
          beg2[0], beg2[1],
          end2[0], end2[1],
          end1[0], end1[1] ]
      );

      if( rw.length / rw.width > 3 and !is_heli )
      {
        # only runways which are much longer than wide are
        # real runways, otherwise it's probably a heliport.
        var icon_cl =
          me.grp_apt.createChild("path", "centerline")
                    .setStrokeLineWidth(0.5)
                    .setColor(1,1,1)
                    .setStrokeDashArray([15, 10]);

        icon_cl.setDataGeo
        (
          [ canvas.Path.VG_MOVE_TO,
            canvas.Path.VG_LINE_TO ],
          [ beg_thr[0], beg_thr[1],
            end_thr[0], end_thr[1] ]
        );

        var icon_thr =
          me.grp_apt.createChild("path", "threshold")
                    .setStrokeLineWidth(1.5)
                    .setColor(1,1,1);

        icon_thr.setDataGeo
        (
          [ canvas.Path.VG_MOVE_TO,
            canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO,
            canvas.Path.VG_LINE_TO ],
          [ beg_thr1[0], beg_thr1[1],
            beg_thr2[0], beg_thr2[1],
            end_thr1[0], end_thr1[1],
            end_thr2[0], end_thr2[1] ]
        );
      }
    }

    foreach(var park; me._apt.parking())
    {
      var icon_park =
        me.grp_apt.createChild("text")
                  .setDrawMode( canvas.Text.ALIGNMENT
                              + canvas.Text.TEXT )
                  .setText(park.name)
                  .setFont("LiberationFonts/LiberationMono-Bold.ttf")
                  .setGeoPosition(park.lat, park.lon)
                  .setFontSize(15, 1.3);
    }
  }
};
