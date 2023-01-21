# RadioButton.nas : radio button, and group helper
# to manage updating checked state conherently
# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>, Frederic Croix <thefgfseagle@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.RadioButton = {
  new: func(parent, style = nil, cfg = nil) {
    var m = gui.Widget.new(gui.widgets.RadioButton);
    style = style or canvas.style;
    m._cfg = Config.new(cfg or {});
    m._focus_policy = m.StrongFocus;
    m._checked = 0;
    m.radioGroup = nil;

    m._setView( style.createWidget(parent, m._cfg.get("type", "radio-button"), m._cfg) );

    var parentRadio = m._cfg.get("parentRadio", nil);
    if (parentRadio != nil) {
      m.radioGroup = parentRadio.radioGroup;
    } else {
      m.radioGroup = gui.widgets.RadioButtonsGroup.new();
    }
    m.radioGroup.addRadio(m);

    return m;
  },

  setText: func(text) {
    me._view.setText(me, text);
    return me;
  },

  setChecked: func(checked = 1) {
    if (me._checked == checked) {
      return me;
    }

    me._setRadioGroupSiblingsUnchecked();
    me._trigger("toggled", {checked: checked});
    me._checked = checked;
    me._onStateChange();
    return me;
  },

  _setRadioGroupSiblingsUnchecked: func {
    me.radioGroup._updateChecked(me);
  },

  toggle: func {
    me.setChecked(!me._checked);
    return me;
  },

  _setView: func(view) {
    call(gui.Widget._setView, [view], me);

    var el = view._root;
    el.addEventListener("click", func {
      if (me._enabled) {
        me.setChecked()
      }
    });

    el.addEventListener("drag", func(e) e.stopPropagation());
  },
};

# auto manage radio-button checked state
gui.widgets.RadioButtonsGroup = {
  new: func(name = "unnamed")
  {
    var m = {
      parents: [gui.widgets.RadioButtonsGroup],
      name: name,
      radios: [],
    };
    return m;
  },

  addRadio: func(r)
  {
    r.listen("toggled", func(e) {
      me._updateChecked(r);
    });
    append(me.radios, r);
  },

  removeRadio: func(r)
  {
    # XXX should we update some other item to be checked ?
    if (contains(me.radios, r)) {
      var index = find(r, me.radios);
      me.radios = subvec(me.radios, 0, index) ~ subvec(me.radios, index + 1);
    }
  },

  setEnabled: func(enabled = 1)
  {
    foreach (var r; me.radios) {
      r.setEnabled(enabled);
    }
  },

  # update check state of all radios in the group
  _updateChecked: func(active)
  {
    foreach (var r; me.radios) {
      if (r != active) {
        r.setChecked(0);
      }
    }
  },
};
