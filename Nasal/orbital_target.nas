###########################################################################
# simulation of a faraway orbital target (needs handover to spacecraft-specific 
# code for close range)
# Thorsten Renk 2016
###########################################################################

var orbitalTarget = {
	new: func(altitude, inclination, node_longitude, anomaly) {
	        var t = { parents: [orbitalTarget] };
		t.altitude = altitude;
		t.radius = 20908323.0 * 0.3048 + t.altitude;
		t.GM =  398759391386476.0; 
		t.period = 2.0 * math.pi * math.sqrt(math.pow(t.radius, 3.0)/ t.GM);
		t.inclination = inclination;
		t.inc_rad = t.inclination * math.pi/180.0;
		t.l_vec = [math.sin(t.inc_rad), 0.0, math.cos(t.inc_rad)];
		t.node_longitude = node_longitude;
		t.nl_rad = t.node_longitude * math.pi/180.0;
		var l_tmp = t.l_vec[0];
		t.l_vec[0] = math.cos(t.nl_rad) * l_tmp;
		t.l_vec[1] = -math.sin(t.nl_rad) * l_tmp;
		t.anomaly = anomaly;
		t.anomaly_rad = t.anomaly * math.pi/180.0;
		t.delta_lon = 0.0;
		t.update_time = 1.0;
		t.running_flag = 0;
		return t;
	},

	set_anomaly: func (anomaly) {

		t.anomaly = anomaly;
		t.anomaly_rad = t.anomaly * math.pi/180.0;

	},

	set_delta_lon: func (dl) {
		t.delta_lon = dl;
	},

	list: func {

		print("Radius: ", me.radius, " period: ", me.period);
		print("L_vector: ", me.l_vec[0], " ", me.l_vec[1], " ", me.l_vec[2]);
		print("L_norm: ", math.sqrt(me.l_vec[0] * me.l_vec[0] + me.l_vec[1] * me.l_vec[1] + me.l_vec[2] * me.l_vec[2]));
		var pos = me.get_inertial_pos();
		print("Inertial: ", pos[0], " ", pos[1], " ", pos[2]);
		print("Rad: ", math.sqrt(pos[0] * pos[0] + pos[1] * pos[1] + pos[2] * pos[2]));
		var lla = me.get_latlonalt();
		print("Lat: ", lla[0], " lon: ", lla[1], " alt: ", lla[2]);
	},
	
	evolve: func (dt) {
		me.anomaly_rad = me.anomaly_rad + dt/me.period * 2.0 * math.pi;
		if (me.anomaly_rad > 2.0 * math.pi)
			{
			me.anomaly_rad = me.anomaly_rad - 2.0 * math.pi;
			}
		me.anomaly = me.anomaly_rad * 180/math.pi;
		me.delta_lon = me.delta_lon + dt * 0.00418333333333327;
	},
	get_inertial_pos: func {

		# movement around equatorial orbit
		var x = me.radius * -math.sin(me.anomaly_rad);
		var y = me.radius * math.cos(me.anomaly_rad);
		var z = 0;
	
		# tilt with inclination
		z = x * -math.sin(me.inc_rad);
		x = x * math.cos(me.inc_rad);


		# rotate with node longitude
		var xp = x * math.cos(me.nl_rad) - y * math.sin(me.nl_rad);
		var yp = x * math.sin(me.nl_rad) + y * math.cos(me.nl_rad);

		return [xp, yp, z];
	},
	get_latlonalt: func {

		var coordinates = geo.Coord.new();
		var inertial_pos = me.get_inertial_pos();
		coordinates.set_xyz(inertial_pos[0], inertial_pos[1], inertial_pos[2]);
		coordinates.set_lon(coordinates.lon() - me.delta_lon);
	
		return [coordinates.lat(), coordinates.lon(), coordinates.alt()];
	},
	start: func {
		if (me.running_flag == 1) {return;}
		me.running_flag = 1;
		me.run();
	},
	stop: func {
		me.running_flag = 0;
	},

	run: func {
		me.evolve (me.update_time);
		if (me.running_flag == 1)
			{settimer(func me.run(), me.update_time);}
	},
	
};
