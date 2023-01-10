var WidgetsFactoryDialog = {
	new: func {
		var m = {
			parents: [WidgetsFactoryDialog],
			window: canvas.Window.new([500, 500], "dialog")
		};
		
		m.window.setBool("resize", 1);
		
		m.root = m.window.getCanvas(1)
						.set("background", style.getColor("bg_color"))
						.createGroup();
		m.vbox = VBoxLayout.new();
		#m.vbox.setContentsMargin(10);
		m.window.setLayout(m.vbox);
		
		m.tabs = gui.widgets.TabWidget.new(m.root, style, {});
		m.tabsContent = m.tabs.getContent();
		m.vbox.addItem(m.tabs);
		
		m.tab_1 = VBoxLayout.new();
		m.tabs.addTab("tab-1", "Tab 1", m.tab_1);
		m.label = gui.widgets.Label.new(m.tabsContent, style, {})
						.setText("A label")
						.setBackground("#ffaaaa");
		m.tab_1.addItem(m.label);
		m.checkbox_left = gui.widgets.CheckBox.new(m.tabsContent, style, {"label-position": "right"})
						.setText("Wanna check something ?");
		m.tab_1.addItem(m.checkbox_left);
		m.checkbox_right = gui.widgets.CheckBox.new(m.tabsContent, style, {"label-position": "right"})
						.setText("Checkbox with text on the right side");
		m.tab_1.addItem(m.checkbox_right);
		m.property_checkbox = gui.widgets.PropertyCheckBox.new(props.globals.getNode("/controls/lighting/nav-lights"), m.tabsContent, style, {})
						.setText("Nav lights");
		m.tab_1.addItem(m.property_checkbox);
		
		m.tab_2 = VBoxLayout.new();
		m.tabs.addTab("tab-2", "Tab 2", m.tab_2);
		m.button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setText("A button")
						.setFixedSize(60, 30)
						.listen("clicked", func {
							InputDialog.getText("You clicked the button …", "Enter some text:", func (button, text) {
								MessageBox.information("You clicked the button …", "… and entered '" ~ (text != nil ? text : "nothing") ~ "' !");
							});
						});
		m.tab_2.addItem(m.button);
		m.image = gui.widgets.Label.new(m.tabsContent, style, {})
						.setImage("Textures/Splash1.png")
						.setVisible(0)
						.setFixedSize(128, 128);

		m.tab_2.addItem(m.image);
		m.image._view._root.addEventListener("mousedown", func (e) {
			logprint(LOG_INFO, "Image was clicked at:" ~ e.localX ~ "," ~ e.localY);
			logprint(LOG_INFO, "Client pos:" ~ e.clientX ~ "," ~ e.clientY);
			logprint(LOG_INFO, "Screen pos:" ~ e.screenX ~ "," ~ e.screenY);

			var img = m.image._view._root;
			var localPos = [e.localX, e.localY];
			var canvasPos = img.localToCanvas(localPos);

			logprint(LOG_INFO, "computed canvasPos pos:" ~ canvasPos[0] ~ "," ~ canvasPos[1]);

			var screenPos = m.window.toScreenPosition(canvasPos);
			logprint(LOG_INFO, "computed screen pos:" ~ screenPos[0] ~ "," ~ screenPos[1]);
		});

		m.checkable_button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setCheckable(1)
						.setChecked(0)
						.setText("Checkable button")
						.setFixedSize(120, 30)
						.listen("toggled", func (e) {
							m.image.setVisible(int(e.detail.checked));
						});
		m.tab_2.addItem(m.checkable_button);
		m.resize_button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setText("Resize this window")
						.setFixedSize(130, 30)
						.listen("clicked", func {
							var s = m.window.getSize();
							m.window.setSize(s[0] + 100, s[1] + 100);
						});
		m.tab_2.addItem(m.resize_button, 5);
		
		m.numericControlsTab = VBoxLayout.new();
		m.tabs.addTab("ncTab", "Numeric Controls", m.numericControlsTab);
		m.slider = gui.widgets.Slider.new(m.tabsContent, style, 
			{"max-value" : 100,
			 "page-step" : 20,
			 "tick-count" : 10})
			.setValue(42);
		m.numericControlsTab.addItem(m.slider);

		return m;
	},
	
	del: func {
		me.property_checkbox.del();
		me.window.del();
	}
};

