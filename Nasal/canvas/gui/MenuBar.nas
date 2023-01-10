gui.MenuBar = {
        new: func(id = nil) {
                var m = canvas.Window.new([64, 24]);
                m.parents = [gui.MenuBar] ~ m.parents;

                m._canvas = m.createCanvas().setColorBackground(style.getColor("bg_color"));
                m._root = m._canvas.createGroup();
                m._layout = VBoxLayout.new();
                m.setLayout(m._layout);
                m._menubar = gui.widgets.MenuBar.new(m._root, style, {});
                m._menubar.setCanvasItem(getDesktop());
                m._layout.addItem(m._menubar);
                m.setPosition(0, 0);

                return m;
        },

        addMenu: func(text = nil, menu = nil, enabled = 1) {
                var item = me._menubar.addMenu(text, menu, enabled);
                me.setSize(math.max(me._layout.sizeHint()[0], 64), math.max(me._layout.sizeHint()[1], 24));
                return me;
        },

        createMenu: func(text = nil, enabled = 1) {
                var menu = me._menubar.createMenu(text, enabled);
                me.setSize(math.max(me._layout.sizeHint()[0], 64), math.max(me._layout.sizeHint()[1], 24));
                return menu;
        },

        clear: func {
                me._menubar.clear();
                return me;
        },

        removeMenu: func(item) {
                me._menubar.removeMenu(item);
                return me;
        },

        takeAt: func(index) {
                return me._menubar.takeAt(index);
        },

        count: func() {
                return me._menubar.count();
        },

        getItem: func(index) {
                return me._menubar.getItem(index);
        },

        getMenu: func(index) {
                return me._menubar.getMenu(index);
        },

        show: func(x = nil, y = nil) {
                if (x != nil and y != nil) {
                        me.setPosition(x, y);
                }
		me._ghost.show();
		me.raise();
		if (me._canvas != nil) {
			me._canvas.update();
		}
        },

        del: func() {
                me.hide();
                me._menubar.clear();
                me._canvas.del();
        },
};

