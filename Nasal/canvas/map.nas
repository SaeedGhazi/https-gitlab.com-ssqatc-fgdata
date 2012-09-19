
# Mapping from surface codes to 
var SURFACECOLORS = {
  1 : { type: "asphalt",  r:0.2,  g:0.2, b:0.2 },
  2 : { type: "concrete", r:0.3,  g:0.3, b:0.3 },
  3 : { type: "turf",     r:0.2,  g:0.5, b:0.2 },
  4 : { type: "dirt",     r:0.4,  g:0.3, b:0.3 },
  5 : { type: "gravel",   r:0.35, g:0.3, b:0.3 },
#  Helipads  
  6 : { type: "asphalt",  r:0.2,  g:0.2, b:0.2 },
  7 : { type: "concrete", r:0.3,  g:0.3, b:0.3 },
  8 : { type: "turf",     r:0.2,  g:0.5, b:0.2 },
  9 : { type: "dirt",     r:0.4,  g:0.3, b:0.3 },
  0 : { type: "gravel",   r:0.35, g:0.3, b:0.3 },
};

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
  # @param apt   Hash containing airport data as returned from airportinfo()
  # @param rwy   Whether to display runways (default=1)
  # @param taxi  Whether to display taxiways (default=1)
  # @param park  Whether to display parking positions (default = 1)
  # @param twr   Whether to display tower positions (default = 1)
  new: func(apt, rwy=1, taxi=1, park=1, twr=1)
  {
    return {
      parents: [AirportMap],
      _apt: apt,
      _display_runways: rwy,
      _display_taxiways: taxi,
      _display_parking: park,
      _display_tower: twr,
    };
  },
  # Build the graphical representation of the represented airport
  #
  # @param layer_runways  canvas.Group to attach airport map to
  build: func(layer_runways)
  {
    var rws_done = {};

    me.grp_apt = layer_runways.createChild("group", "apt-" ~ me._apt.id);
    
    # Taxiways drawn first so the runways and parking positions end up on top.
    if (me._display_taxiways) 
    {
      foreach(var taxi; me._apt.taxiways)
      {
        var clr = SURFACECOLORS[taxi.surface];
        if (clr == nil) { clr = SURFACECOLORS[0]};
        
        var icon_taxi =
          me.grp_apt.createChild("path", "taxi")
                    .setStrokeLineWidth(0)
                    .setColor(clr.r, clr.g, clr.b)
                    .setColorFill(clr.r, clr.g, clr.b);

        var txi = Runway.new(taxi);
        var beg1 = txi.pointOffCenterline(0,  0.5 * taxi.width);
        var beg2 = txi.pointOffCenterline(0, -0.5 * taxi.width);
        var end1 = txi.pointOffCenterline(taxi.length,  0.5 * taxi.width);
        var end2 = txi.pointOffCenterline(taxi.length, -0.5 * taxi.width);

        icon_taxi.setDataGeo
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
      }
    }
    
    if (me._display_runways) 
    {
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
        
        var clr = SURFACECOLORS[rw.surface];
        if (clr == nil) { clr = SURFACECOLORS[0]};
        
        var icon_rw =
          me.grp_apt.createChild("path", "runway-" ~ rw.id)
                    .setStrokeLineWidth(0.5)
                    .setColor(1.0,1.0,1.0)
                    .setColorFill(clr.r, clr.g, clr.b);

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
    }
    
    if (me._display_parking)
    {
      foreach(var park; me._apt.parking())
      {
        var icon_park =
          me.grp_apt.createChild("text", "parking-" ~ park.name)
                    .setDrawMode( canvas.Text.ALIGNMENT
                                + canvas.Text.TEXT )
                    .setText(park.name)
                    .setFont("LiberationFonts/LiberationMono-Bold.ttf")
                    .setGeoPosition(park.lat, park.lon)
                    .setFontSize(15, 1.3);
      }
    }
    
    if (me._display_tower)
    {    
      var icon_tower =
              me.grp_apt.createChild("path", "tower")
                 .setStrokeLineWidth(1)
                 .setScale(1.5)
                 .setColor(0.2,0.2,1.0)
                 .moveTo(-3, 0)
                 .vert(-10)
                 .line(-3, -10)
                 .horiz(12)
                 .line(-3, 10)
                 .vert(10);
                 
      var pos = me._apt.tower();
      icon_tower.setGeoPosition(pos.lat, pos.lon);               
    }    
  }
};
