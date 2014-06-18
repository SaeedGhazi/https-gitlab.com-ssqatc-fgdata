var AircraftCenter = {
  new: func
  {
    var m = {
      parents: [AircraftCenter],
      _dlg: canvas.Window.new([600,500], "dialog")
                         .set("title", "Aircraft Center")
                         .set("resize", 1),
      _active_button: nil
    };

    m._dlg.getCanvas(1)
          .set("background", canvas.style.getColor("bg_color"));
    m._root = m._dlg.getCanvas().createGroup();

    var vbox = VBoxLayout.new();
    m._dlg.setLayout(vbox);

    m._tab_bar = HBoxLayout.new();
    vbox.addItem(m._tab_bar);

    m._tab_bar.addStretch(1);
    m._tab_bar.addStretch(1);

    var scroll = gui.widgets.ScrollArea.new(m._root, style, {size: [96, 128]})
                                       .move(20, 100);
    vbox.addItem(scroll, 1);

    m._scroll_content =
      scroll.getContent()
            .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
            .set("character-size", 16)
            .set("alignment", "left-center");

    m._list = VBoxLayout.new();
    scroll.setLayout(m._list);

    m._info_label = gui.widgets.Label.new(m._root, style, {wordWrap: 1});
    vbox.addItem(m._info_label);
    return m;
  },
  addPage: func(name, filter)
  {
    var b = gui.widgets.Button.new(me._root, style, {})
                              .setText(name)
                              .setCheckable(1);
    me._tab_bar.insertItem(me._tab_bar.count() - 1, b);

    b.listen("toggled", func(e)
    {
      if( !e.detail.checked )
        return;

      if( me._active_button != nil )
        me._active_button.setChecked(0);
      me._active_button = b;

      me._list.clear();
      settimer(func me.fillList(pkg.root.search(filter)), 0);
    });

    if( me._active_button == nil )
      b.setChecked(1);

    return me;
  },
  fillList: func(packages)
  {
    foreach(var package; packages)
    {
      var row = HBoxLayout.new();
      me._list.addItem(row);

      var image_label = gui.widgets.Label.new(me._scroll_content, style, {});
      image_label.setFixedSize(171, 128);
      row.addItem(image_label);

      var thumbs = package.thumbnails;
      if( size(thumbs) > 0 )
        image_label.setImage(thumbs[0]);
      else
        image_label.setText("No thumbnail available");

      var detail_box = VBoxLayout.new();
      row.addItem(detail_box);
      row.addSpacing(5);

      var title_box = HBoxLayout.new();
      detail_box.addItem(title_box);

      title_box.addItem(
        gui.widgets.Label.new(me._scroll_content, style, {})
                         .setText(package.name)
      );
      title_box.addStretch(1);
      (func {
        var p = package;
        var b = gui.widgets.Button.new(me._scroll_content, style, {});
        var installed = p.installed;
        var install_text = sprintf("Install (%.1fMB)", p.fileSize/1024/1024);

        if( installed )
          b.setText("Remove");
        else
          b.setText(install_text);

        b.listen("clicked", func
        {
          if( installed )
          {
            p.uninstall();
            installed = 0;
            b.setText(install_text);
          }
          else
          {
            b.setEnabled(0)
             .setText("Wait...");
            p.install()
             .progress(func(i, cur, total)
               b.setText(sprintf("%.1f%%", (cur / total) * 100))
             )
             .fail(func b.setText('Failed'))
             .done(func {
               installed = 1;
               b.setText("Remove")
                .setEnabled(1);
             });
          }
        });

        title_box.addItem(b);
      })();

      var description = parse_markdown(package.description);
      if( size(description) <= 0 )
      {
        foreach(var cat; ["FDM", "systems", "cockpit", "model"])
          description ~= cat ~ ": " ~ package.lprop("rating/" ~ cat) ~ "\n";
      }

      detail_box.addItem(
        gui.widgets.Label.new(me._scroll_content, style, {wordWrap: 1})
                         .setText(description)
      );

      if( package.installed )
      {
        var launch_bar = HBoxLayout.new();
        detail_box.addItem(launch_bar);

        var variants = keys(package.variants);
        foreach(var variant; variants)
        {(func{
          var b = gui.widgets.Button.new(me._scroll_content, style, {})
                                    .setText(package.variants[variant]);
          var acft_id = variant;
          b.listen("clicked", func
          {
            print("launch " ~ acft_id ~ '(' ~ package.variants[variant] ~ ')');
            fgcommand("switch-aircraft", props.Node.new({"aircraft": acft_id}));
          });
          launch_bar.addItem(b);
        })();}
        launch_bar.addStretch(1);
      }

      detail_box.addStretch(1);
    }

    # get rid of references to widgets of last package
    row = nil;
    image_label = nil;
    detail_box = nil;
    title_box = nil;
    launch_bar = nil;

    me._info_label.setText(
      "Install/remove aircraft (Showing " ~ size(packages) ~ " aircraft)"
    );

    me._dlg.getCanvas().update();
  }
};

MessageBox.warning(
  "Experimental Feature...",
  "The Aircraft Center is only a preview and not yet in a stable state!",
  func(sel)
  {
    if( sel != MessageBox.Ok )
      return;

    var ac = AircraftCenter.new();
    ac.addPage("Rated", {
      'rating-FDM': 2,
      'rating-cockpit': 2,
      'rating-model': 2,
      'rating-systems': 1
    });
    ac.addPage("Installed", {
      'installed': 1
    });
    ac.addPage("All", {});
  },
  MessageBox.Ok | MessageBox.Cancel | MessageBox.DontShowAgain
);
