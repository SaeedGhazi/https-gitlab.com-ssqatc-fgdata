var MessageBox = {
  Ok:     0x0001,
  Cancel: 0x0002,
  Yes:    0x0004,
  No:     0x0008,
  new: func
  {
    return {
      parents: [MessageBox],
      _title: "Message",
      _standard_buttons: MessageBox.Ok
    };
  },
  setTitle: func(title)
  {
    me._title = title;
  },
  setImage: func(img)
  {
    if( img != nil and img.find('/') < 0 )
      me._img = style._dir_icons ~ "/" ~ img ~ ".png";
    else
      me._img = img;
    return me;
  },
  setText: func(text)
  {
    me._text = text;
    return me;
  },
  setStandardButtons: func(mask)
  {
    me._standard_buttons = mask;
    return me;
  },
  exec: func(cb = nil)
  {
    var MARGIN = 8; # TODO implement margin in C++ layouting code
    var dlg = canvas.Window.new([250,100], "dialog")
                           .setTitle(me._title);
    var root = dlg.getCanvas(1)
                  .set("background", style.getColor("bg_color"))
                  .createGroup();
    var vbox = VBoxLayout.new();
    dlg.setLayout(vbox);
    vbox.addSpacing(MARGIN);

    var text_box = HBoxLayout.new();
    vbox.addItem(text_box);

    text_box.addSpacing(MARGIN);

    if( me._img != nil )
    {
      text_box.addItem(
        gui.widgets.Label.new(root, style, {})
                         .setFixedSize(48, 48)
                         .setImage(me._img)
      );
    }

    var label_text = gui.widgets.Label.new(root, style, {wordWrap: 1})
                                      .setText(me._text);
    text_box.addItem(label_text, 1);
    text_box.addSpacing(MARGIN);

    vbox.addStretch(1);

    var button_box = HBoxLayout.new();
    vbox.addItem(button_box);

    button_box.addStretch(1);
    foreach(var button; [me.Ok, me.Cancel, me.Yes, me.No])
    {
      if( !(me._standard_buttons & button) )
        continue;

      (func{
        var b_id = button;
        button_box.addItem(
          gui.widgets.Button.new(root, style, {})
                            .setText(me._button_names[button])
                            .listen("clicked", func {
                              dlg.del();
                              if( cb != nil )
                                cb(b_id);
                            })
        );
      })();
    }
    button_box.addSpacing(MARGIN);

    vbox.addSpacing(MARGIN);

    return me;
  },
  show: func(title, text, icon = nil, cb = nil, buttons = nil)
  {
    var msg_box = MessageBox.new();
    msg_box.setTitle(title);
    msg_box.setText(text);

    if( buttons == nil )
      buttons = MessageBox.Ok;
    msg_box.setStandardButtons(buttons);

    if( icon != nil )
      msg_box.setImage(icon);

    return msg_box.exec(cb);
  },
  # Show an error/critical message in a message box
  #
  # @param title
  # @param text
  # @param cb       Dialog close callback
  # @param buttons  Mask indicating the buttons to show
  #                 (default: MessageBox.Ok)
  critical: func(title, text, cb = nil, buttons = nil)
  {
    MessageBox.show(title, text, "dialog-error", cb, buttons);
  },
  # Show a warning message in a message box
  #
  # @param title
  # @param text
  # @param cb       Dialog close callback
  # @param buttons  Mask indicating the buttons to show
  #                 (default: MessageBox.Ok)
  warning:  func(title, text, cb = nil, buttons = nil)
  {
    MessageBox.show(title, text, "dialog-warning", cb, buttons);
  },
  # Show an informative message in a message box
  #
  # @param title
  # @param text
  # @param cb       Dialog close callback
  # @param buttons  Mask indicating the buttons to show
  #                 (default: MessageBox.Ok)
  information: func(title, text, cb = nil, buttons = nil)
  {
    MessageBox.show(title, text, "dialog-info", cb, buttons);
  },
  # Show a question in a message box
  #
  # @param title
  # @param text
  # @param cb       Dialog close callback
  # @param buttons  Mask indicating the buttons to show
  #                 (default: MessageBox.Yes | MessageBox.No)
  question: func(title, text, cb = nil, buttons = nil)
  {
    MessageBox.show(
      title,
      text,
      "dialog-question",
      cb,
      buttons or MessageBox.Yes | MessageBox.No
    );
  },
# private:
  _button_names: {}
};

# Standard button names
MessageBox._button_names[ MessageBox.Ok     ] = "Ok";
MessageBox._button_names[ MessageBox.Cancel ] = "Cancel";
MessageBox._button_names[ MessageBox.Yes    ] = "Yes";
MessageBox._button_names[ MessageBox.No     ] = "No";
