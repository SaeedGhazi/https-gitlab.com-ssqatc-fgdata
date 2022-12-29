var WidgetsFactoryDialog = {
	new: func {
		var m = {
			parents: [WidgetsFactoryDialog, canvas.Window.new([500, 500], "dialog")]
		};
		
		m.setBool("resize", 1);
		
		m.root = m.getCanvas(1)
						.set("background", style.getColor("bg_color"))
						.createGroup();
		m.vbox = VBoxLayout.new();
		vbox.setContentsMargin(10);
		m.setLayout(vbox);
		
		m.tabs = gui.widgets.TabWidget.new(m.root, style, {});
		m.vbox.addItem(m.tabs);
		
		m.tab_1 = VBoxLayout.new();
		m.tabs.addTab("tab-1", "Tab 1", m.tab_1);
		m.label = gui.widgets.Label.new(m.root, style, {})
						.setText("A label")
						.setBackground("#ff0000");
		m.tab_1.addItem(m.label);
		m.checkbox_left = gui.widgets.CheckBox.new(m.root, style, {"label-position": "left"})
						.setText("Checkbox with text on the left side");
		m.tab_1.addItem(m.checkbox_left);
		m.checkbox_right = gui.widgets.CheckBox.new(m.root, style, {"label-position": "right"})
						.setText("Checkbox with text on the right side")
		m.tab_1.addItem(m.checkbox_right);
		m.property_checkbox = gui.widgets.PropertyCheckBox.new(props.globals.getNode("/controls/lighting/nav-lights"), m.root, style, {})
						.setText("Nav lights");
		m.tab_1.addItem(m.property_checkbox);
		
		m.tab_2 = VBoxLayout.new();
		m.tabs.addTab("tab-2", "Tab 2", m.tab_2);
		m.button = gui.widgets.Button.new(m.root, style, {})
						.setText("A button")
						.listen("clicked", func {
							var s = InputDialog.getText("You clicked the button …", "Enter some text:");
							MessageBox.information("You clicked the button …", "… and entered '" ~ s ~ "' !");
						});
		m.tab_2.addItem(m.button);
		m.image = gui.widgets.Label.new(m.root, style, {})
						.setImage("Textures/Splash1.png");
		m.tab_2.addItem(m.image);
		m.checkable_button = gui.widgets.Button.new(m.root, style, {})
						.setCheckable(1)
						.setChecked(0)
						.setText("Checkable button")
						.listen("toggled", func (e) {
							m.image.setVisible(int(e.detail.checked));
						});
		m.table.addItem(m.checkable_button);
		
		return m;
	},
	
	del: func {
		me.property_checkbox.del();
	}
};

