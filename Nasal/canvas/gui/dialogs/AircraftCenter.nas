var AircraftCenter = {
  show: func
  {
    var dlg = canvas.Window.new([550,500], "dialog")
                           .set("title", "Aircraft Center")
                           .set("resize", 1);
    dlg.getCanvas(1)
       .set("background", canvas.style.getColor("bg_color"));
    var root = dlg.getCanvas().createGroup();

    var vbox = VBoxLayout.new();
    dlg.setLayout(vbox);

    vbox.addItem(
      gui.widgets.Label.new(root, style, {})
                       .setText("Install/remove aircrafts (Showing first 100)")
    );

    var scroll = gui.widgets.ScrollArea.new(root, style, {size: [96, 128]})
                                       .move(20, 100);
    vbox.addItem(scroll, 1);

    var content = scroll.getContent()
                        .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
                        .set("character-size", 16)
                        .set("alignment", "left-center");

    var list = VBoxLayout.new();
    scroll.setLayout(list);

    var num = 0;
    foreach(var catalog; pkg.root.catalogs())
    {
      foreach(var package; catalog.packages())
      {
        var row = HBoxLayout.new();
        list.addItem(row);

        var img = "path-for-missing-thumb...";
        var thumbs = package.thumbnails;
        if( size(thumbs) > 0 )
          img = thumbs[0];
        var image_label = gui.widgets.Label.new(content, style, {})
                                           .setImage(img);
        image_label.setFixedSize(171, 128);
        row.addItem(image_label);

        var detail_box = VBoxLayout.new();
        detail_box.setSpacing(0);
        row.addItem(detail_box);
        
        var title_box = HBoxLayout.new();
        detail_box.addItem(title_box);
        
        title_box.addItem(
          gui.widgets.Label.new(content, style, {})
                           .setText(package.name)
        );
        title_box.addStretch(1);
        (func {
          var p = package;
          var b = gui.widgets.Button.new(content, style, {});
          if( p.installed )
            b.setText("Remove")
             .listen("clicked", func
             {
               p.install().uninstall();
               b.setText("Removing...");
             });
           else
            b.setText("Install")
             .listen("clicked", func
             {
               p.install();
               b.setText("Installing...");
             });
          title_box.addItem(b);
        })();

        foreach(var cat; ["FDM", "systems", "cockpit", "model"])
        {
          detail_box.addItem(
            gui.widgets.Label.new(content, style, {})
                             .setText(cat ~ ": " ~ package.lprop("rating/" ~ cat))
          );
        }

        row.addSpacing(5);

        num += 1;
        if( num >= 100 )
          break;
      }
    }
  }
};

AircraftCenter.show();
