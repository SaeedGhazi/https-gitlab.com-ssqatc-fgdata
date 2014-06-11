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

    var packages = pkg.root.search({
      'rating-FDM': 2,
      'rating-cockpit': 2,
      'rating-model': 2,
      'rating-systems': 1
    });

    var info_text =
      "Install/remove aircrafts (Showing " ~ size(packages) ~ " aircrafts)";

    vbox.addItem(
      gui.widgets.Label.new(root, style, {})
                       .setText(info_text)
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

    foreach(var package; packages)
    {
      var row = HBoxLayout.new();
      list.addItem(row);

      var image_label = gui.widgets.Label.new(content, style, {});
      image_label.setFixedSize(171, 128);
      row.addItem(image_label);

      var thumbs = package.thumbnails;
      if( size(thumbs) > 0 )
        image_label.setImage(thumbs[0]);
      else
        image_label.setText("No thumbnail available");

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
        var installed = p.installed;

        if( installed )
          b.setText("Remove");
        else
          b.setText("Install");

        b.listen("clicked", func
        {
          if( installed )
          {
            p.uninstall();
            installed = 0;
            b.setText("Install");
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

      foreach(var cat; ["FDM", "systems", "cockpit", "model"])
      {
        detail_box.addItem(
          gui.widgets.Label.new(content, style, {})
                           .setText(cat ~ ": " ~ package.lprop("rating/" ~ cat))
        );
      }

      row.addSpacing(5);
    }
  }
};

AircraftCenter.show();
