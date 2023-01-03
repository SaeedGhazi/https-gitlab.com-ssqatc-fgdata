var WidgetsFactoryDialog = {
	new: func {
		var m = {
			parents: [WidgetsFactoryDialog],
			window: canvas.Window.new([500, 500], "dialog")
		};
		
		m.window.setBool("resize", 1);
		
		m.root = m.getCanvas(1)
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
						.setFixedSize(128, 128);
		m.tab_2.addItem(m.image);
		# XXX: setVisible(0) must be called AFTER adding the widget to the layout
		# doing that before layout.addItem causes FG to crash with a SIGSEGV
		# see https://sourceforge.net/p/flightgear/mailman/flightgear-devel/thread/CABg8F9Rb87Fy%252B2ppXjJouYcZH9xyiQxts-jkdrPq0GK_Ymq-6w%2540mail.gmail.com/
		m.image.setVisible(0);
		m.checkable_button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setCheckable(1)
						.setChecked(0)
						.setText("Checkable button")
						.setFixedSize(100, 30)
						.listen("toggled", func (e) {
							m.image.setVisible(int(e.detail.checked));
						});
		m.tab_2.addItem(m.checkable_button);
		m.resize_button = gui.widgets.Button.new(m.tabsContent, style, {})
						.setText("Resize this window")
						.setFixedSize(100, 30)
						.listen("clicked", func {
							var s = m.getSize();
							m.setSize(s[0] + 100, s[1] + 100);
						});
		m.tab_2.addItem(m.resize_button);
		
		return m;
	},
	
	del: func {
		me.property_checkbox.del();
		me.window.del();
	}
};

