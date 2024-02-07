gui.widgets.CheckBox = {
  new: func(parent, style = nil, cfg = nil)
  {
    cfg = cfg or {};
    cfg["type"] = "checkbox";
    var m = gui.widgets.Button.new(parent, style, cfg);
    m._checkable = 1;

    append(m.parents, gui.widgets.CheckBox);
    return m;
  },
  setCheckable: nil
};
