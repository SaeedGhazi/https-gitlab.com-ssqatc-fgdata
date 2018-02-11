# generic widgets for aircraft-side canvas dialogs
# Thorsten Renk 2018

# box gauge ##############################################################

var cdlg_widget_box = {
	new: func (root, width, height, color, fill_color ) {
 	var wb = { parents: [cdlg_widget_box] };
		
	wb.width = width;
	wb.height = height;
	wb.color = color;
	wb.fill_color = fill_color;

	wb.graph = root.createChild("group", "box_widget");

	#var data = [[0.0, 0.0], [0.0, height], [width, height], [width, 0.0], [0.0, 0.0]];
	
	var data = [[0.0, 0.0], [-0.5 * width, 0.0], [-0.5*width, -height], [0.5*width, -height], [0.5*width, 0.0], [0.0, 0.0]];

	wb.frame = wb.graph.createChild("path", "")
        .setStrokeLineWidth(2)
        .setColor(color)
	.moveTo(data[0][0], data[0][1]);
	for (var i = 0; (i< size(data)-1); i=i+1) 
		{wb.frame.lineTo(data[i+1][0], data[i+1][1]);}

	wb.fill = wb.graph.createChild("path", "")
        .setStrokeLineWidth(2)
        .setColor(color)
	.setColorFill(fill_color)
	.moveTo(data[0][0], data[0][1]);
	for (var i = 0; (i< size(data)-1); i=i+1) 
		{wb.fill.lineTo(data[i+1][0], data[i+1][1]);}

	return wb;
	},


	setTranslation: func (x,y) {
		me.graph.setTranslation(x,y);

	},

	setPercentageHt: func (x) {

		if (x > 1.0)
			{x = 1.0;}
		else if (x < 0.0) {x = 0.0;}

		var red_ht = me.height * x;

		var cmd = [canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
	  		canvas.Path.VG_LINE_TO,canvas.Path.VG_LINE_TO,canvas.Path.VG_LINE_TO];

		var draw = [0.0, 0.0, -0.5 * me.width, 0.0, -0.5*me.width, -red_ht, 0.5*me.width, -red_ht, 0.5*me.width, 0.0, 0.0, 0.0];


		me.fill.setData(cmd, draw);

	},

	setContextHelp: func (f) {

			me.frame.addEventListener("mouseover", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'left-right'}));
			f("mouseover");
		  	});

			me.frame.addEventListener("mouseout", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'inherit'}));
			f("mouseout");
		  	});

			me.fill.addEventListener("mouseover", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'left-right'}));
			f("mouseover");
		  	});

			me.fill.addEventListener("mouseout", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'inherit'}));
			f("mouseout");
		  	});



	},


};



# tank gauge ##############################################################

var cdlg_widget_tank = {
	new: func (root, radius, color, fill_color ) {
	 	var wtk = { parents: [cdlg_widget_tank] };
		
		wtk.radius = radius;
		wtk.color = color;
		wtk.fill_color = fill_color;

		wtk.graph = root.createChild("group", "tank_widget");

		var data = [];


		for (var i = 0; i< 33; i=i+1)
			{
			var phi = i * 2.0 * math.pi/32.0;

			var x = radius * math.cos(phi);
			var y = radius * math.sin(phi);

			append(data, [x,y]);
			}


		wtk.frame = wtk.graph.createChild("path", "")
		.setStrokeLineWidth(2)
		.setColor(color)
		.moveTo(data[0][0], data[0][1]);
		for (var i = 0; (i< size(data)-1); i=i+1) 
			{wtk.frame.lineTo(data[i+1][0], data[i+1][1]);}

		wtk.fill = wtk.graph.createChild("path", "")
		.setStrokeLineWidth(2)
		.setColor(color)
		.setColorFill(fill_color)
		.moveTo(data[0][0], data[0][1]);
		for (var i = 0; (i< size(data)-1); i=i+1) 
			{wtk.fill.lineTo(data[i+1][0], data[i+1][1]);}



		return wtk;
	},

	setTranslation: func (x,y) {
		me.graph.setTranslation(x,y);

	},

	setPercentage: func (x) {

		if (x > 1.0)
			{x = 1.0;}
		else if (x < 0.0) {x = 0.0;}

		var red_ht = me.radius -2.0 * me.radius * x;
		var arg = me.radius * me.radius - red_ht * red_ht;
		if (arg < 0.0) {arg = 0.0;}

		var xlimit = math.sqrt(arg);
		
		var draw = [];
		var cmd = [];

		for (var i = 0; i< 33; i=i+1)
			{
			var phi = i * 2.0 * math.pi/32.0;

			var x = me.radius * math.cos(phi);
			var y = me.radius * math.sin(phi);

			
			if (y < red_ht) { y = red_ht; if (x>0.0) {x = xlimit;} else {x=-xlimit;} }

			append(draw,x);
			append(draw,y);
			append(cmd, canvas.Path.VG_LINE_TO);
			}

		cmd[0] = canvas.Path.VG_MOVE_TO; 

		me.fill.setData(cmd, draw);		

	},


	setContextHelp: func (f) {

			me.frame.addEventListener("mouseover", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'left-right'}));
			f("mouseover");
		  	});

			me.frame.addEventListener("mouseout", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'inherit'}));
			f("mouseout");
		  	});

			me.fill.addEventListener("mouseover", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'left-right'}));
			f("mouseover");
		  	});

			me.fill.addEventListener("mouseout", func(e) {
			fgcommand("set-cursor", props.Node.new({'cursor':'inherit'}));
			f("mouseout");
		  	});



	},


};


# property display labels ##############################################################

var cdlg_widget_property_label = {
	new: func (root, text, text_color = nil, color = nil, fill_color = nil ) {
 	var pl = { parents: [cdlg_widget_property_label] };
		
	pl.text_string = text;
	pl.size = utf8.size(text);
	pl.limits = 0;

	if (text_color == nil) {text_color = [0.0, 0.0, 0.0];}
	pl.text_color = text_color;

	pl.font_scale_factor = 1.0;

	if (color == nil) 
		{pl.box_mode = 0;}
	else
		{
		pl.color = color;
		pl.box_mode = 1;
		}

	if (fill_color == nil)
		{
		pl.box_fill = 0;
		}
	else
		{
		pl.box_fill = 1;
		pl.fill_color = fill_color;
		}



	pl.graph = root.createChild("group", "property_label");



	if (pl.box_mode == 1)
		{
		var height = 25.0;
		var width = 10.0 * pl.size;
		var data = [[0.0, -0.8 * height], [-0.5 * width, -0.8 * height], [-0.5 * width, 0.2 * height], [0.5 * width, 0.2 * height], [0.5 * width, -0.8 * height],[0.0, -0.8 * height]];
		pl.box = pl.graph.createChild("path", "")
		.setStrokeLineWidth(2)
		.setColor(color)
		.moveTo(data[0][0], data[0][1]);
		for (var i = 0; (i< size(data)-1); i=i+1) 
			{pl.box.lineTo(data[i+1][0], data[i+1][1]);}

		if (pl.box_fill == 1)
			{
			pl.box.setColorFill(fill_color);
			}
		}

	
	pl.text = pl.graph.createChild("text")
      		.setText(text)
		.setColor(text_color)
		.setFontSize(15)
		#.setFont("LiberationFonts/LiberationMono-Bold.ttf")
		.setFont("LiberationFonts/LiberationSans-Bold.ttf")
		.setAlignment("center-bottom")
		.setRotation(0.0);

	pl.text.enableUpdate();

	pl.text.setTranslation(0.0, pl.getOffset(text));
	if (pl.box_mode == 1)
		{
		pl.box.setTranslation(0.0, -pl.getOffset(text));
		}
	
	return pl;
	},

	setTranslation: func (x,y) {
		me.graph.setTranslation(x,y);

	},

	updateText: func (text) {

		me.text.updateText(text);
	},

	setText: func (text) {

		me.text.setText(text);
	},

	setFont: func (font) {

		me.text.setFont(font);
	},

	setFontSize: func (size) {

		me.font_scale_factor = size/15.0;
		me.text.setFontSize(size);
	},

	setScale: func (x,y = nil) {

		me.graph.setScale(x,y);
	},

	setBoxScale: func (x,y = nil) {

		if (me.box_mode == 0) {return;}
		me.box.setScale(x,y);
	},

	setLimits: func (lower, upper = 1e6) {
	
		me.limits = 1;
		me.limit_lower = lower;
		me.limit_upper = upper; 

	},	 

	getOffset: func (string) {
		return 0.0;
		var flag = 0;
		for (var i = 0; i < utf8.size(string); i=i+1)
			{
			var char = utf8.strc(string, i);

			if ((char == "y") or (char == "g") or (char == "j") or (char == "p") or (char == "q"))
				{
				flag == 1; break;
				}
			}
		if (flag == 0) {return -2.0;}
		else {return 0.0;}
	},

};



# analog gauge ##############################################################

var cdlg_widget_analog_gauge = {
	new: func (root, gauge_bg, gauge_needle ) {
 	var ag = { parents: [cdlg_widget_analog_gauge] };

	ag.graph = root.createChild("group", "analog gauge");

	ag.gauge_background = ag.graph.createChild("image")
			.setFile(gauge_bg);

	ag.gauge_needle = ag.graph.createChild("image")
			.setFile(gauge_needle);

	ag.gauge_needle.setCenter(127,127);

	return ag;
	},

	setTranslation: func (x,y) {

		me.graph.setTranslation(x,y);

	},


	setAngle: func (angle) {

		me.gauge_needle.setRotation(angle);

	},

};


# clickspots ##############################################################

var cdlg_clickspot = {

	new: func (x,y,rw,rh,tab,type) {
	 	var cs = { parents: [cdlg_clickspot] };
		
		cs.x = x;
		cs.y = y;
		cs.rw = rw;
		cs.rh = rh;
		cs.fraction_up = 0.0;
		cs.fraction_right = 0.0;
		cs.tab = tab;
		cs.type = type;

		return cs;
	},

	check_event : func (click_x, click_y) {

		if (me.type = "rect") 
			{
			if ((math.abs(click_x - me.x) < me.rw) and (math.abs(click_y - me.y) < me.rh)) 					{
				me.update_fractions (click_x, click_y);
				return 1;
				}
			}
		else if (me.type = "circle") 
			{
			var click_r = math.sqrt((click_x - me.x) * (click_x - me.x) + (click_y - me.y) * (click_y - me.y));

			if (click_r < me.rw)
				{
				me.update_fractions (click_x, click_y);
				return 1;
				}
			}
		return 0;
	},

	update_fractions: func (click_x, click_y) {

		var y_rel = (click_y - me.y);
		var x_rel = (click_x - me.x);
		me.fraction_up = (-y_rel + me.rw)/(2.0 * me.rw);
		me.fraction_right = (x_rel + me.rw)/(2.0 * me.rw);

	},

	get_fraction_up: func {

		return me.fraction_up;

	},

	get_fraction_right: func {

		return me.fraction_right;

	},

};
