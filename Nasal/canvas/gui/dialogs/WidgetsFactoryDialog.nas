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
		
		m.menubar = canvas.gui.widgets.MenuBar.new(m.root, canvas.style, {});
		m.menubar.setCanvasItem(m.root);
		m.menubar.createMenu("File")
						.createItem(text: "Quit", cb: func m.del(), shortcut: "<Ctrl>+Q");
		m.menubar.createMenu("Tabs")
						.createItem(text: "Select first tab", cb: func m.tabs.setCurrentTab("tab-1"))
						.createItem(text: "Select second tab", cb: func m.tabs.setCurrentTab("tab-2"));
		m.menubar.createMenu("Widgets")
						.createItem(text: "Benchmark label", cb: func {
							m.benchmark_widget(canvas.gui.widgets.Label, func(w, i) {
								w.setText("Label " ~ i);
							});
						});
		m.vbox.addItem(m.menubar);
		
		m.tabs = gui.widgets.TabWidget.new(m.root, style, {});
		m.tabsContent = m.tabs.getContent();
		m.vbox.addItem(m.tabs);
		
		m.tab_1 = VBoxLayout.new();
		m.tabs.addTab("tab-1", "Tab 1", m.tab_1);
		m.label = gui.widgets.Label.new(m.tabsContent, style, {})
						.setText("A label")
						.setBackground("#ffaaaa");
		m.tab_1.addItem(m.label);

		var r = gui.widgets.HorizontalRule.new(m.tabsContent, style, {});
		r.setText("Checkboxes!");
		m.tab_1.addItem(r);

		m.checkbox_left = gui.widgets.CheckBox.new(m.tabsContent, style, {"label-position": "right"})
						.setText("Wanna check something ?");
		m.tab_1.addItem(m.checkbox_left);
		m.checkbox_right = gui.widgets.CheckBox.new(m.tabsContent, style, {"label-position": "right"})
						.setText("Checkbox with text on the right side");
		m.tab_1.addItem(m.checkbox_right);
		m.property_checkbox = gui.widgets.PropertyCheckBox.new(props.globals.getNode("/controls/lighting/nav-lights"), m.tabsContent, style, {})
						.setText("Nav lights");
		m.tab_1.addItem(m.property_checkbox);
		
		var r2 = gui.widgets.HorizontalRule.new(m.tabsContent, style, {});
		m.tab_1.addItem(r2);

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

		m.upsize_button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setText("Upsize window")
						.setFixedSize(130, 30)
						.listen("clicked", func {
							var s = m.window.getSize();
							m.window.setSize(s[0] + 100, s[1] + 100);
						});
		m.tab_2.addItem(m.upsize_button, 5);
		
		m.downsize_button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setText("Downsize window")
						.setFixedSize(130, 30)
						.listen("clicked", func {
							var s = m.window.getSize();
							m.window.setSize(s[0] - 100, s[1] - 100);
						});
		m.tab_2.addItem(m.downsize_button, 5);
		
		m.benchmark_tab = VBoxLayout.new();
		m.tabs.addTab("benchmark", "Benchmark", m.benchmark_tab);
		m.benchmark_tab_scroll = canvas.gui.widgets.ScrollArea.new(m.tabsContent, canvas.style, {});
		m.benchmark_tab_scroll_layout = VBoxLayout.new();
		m.benchmark_tab_scroll.setLayout(m.benchmark_tab_scroll_layout);
		m.benchmark_tab.addItem(m.benchmark_tab_scroll);
		m.benchmark_statistics = canvas.gui.widgets.Label.new(m.tabsContent, canvas.style, {});
		m.benchmark_statistics.setAlignment(canvas.AlignBottom);
		m.benchmark_tab.addItem(m.benchmark_statistics);

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
	
	benchmark_widget: func(widget, proc_func=nil, amount=50) {
		var start = systime();
		me.benchmark_tab_scroll_layout.clear();
		for (var i = 0; i < amount; i += 1) {
			var w = widget.new(me.benchmark_tab_scroll.getContent(), canvas.style, {});
			if (proc_func != nil) {
				proc_func(w, i);
			}
			me.benchmark_tab_scroll_layout.addItem(w);
		}
		var time = systime() - start;
		me.benchmark_statistics.setText("Took " ~ time ~ " seconds to add " ~ amount ~ " widgets.");
	},
	
	del: func {
		me.property_checkbox.del();
		me.window.del();
	}
};

