# RadioButton.nas : radio button, and group helper
# to manage updating checked state conherently
# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.RadioButton = {
  new: func(parent, style, cfg)
  {
    cfg["type"] = "radio";
    var m = gui.widgets.Button.new(parent, style, cfg);
    m._checkable = 1;

    append(m.parents, gui.widgets.RadioButton);

    if (contains(pr, "radioGroup") {
      pr.radioGroup.addRadio(m);
    }

    return m;
  },

  del: func()
  {
    var pr = getParent();
    if (contains(pr, "radioGroup") {
      pr.radioGroup.removeRadio(me);
    }
  },

  setCheckable: nil,
  setChecked: func(checked = 1)
  {
    # call our base version
    me.parents[0].setChecked(checked);
    if (checked) {
      me._setRadioGroupSiblingsUnchecked();
    }
  },
# protected members
  _setRadioGroupSiblingsUnchecked: func
  {
    var pr = getParent();
    if (contains(pr, "radioGroup") {
      pr.radioGroup._updateChecked(me);
    } else {
      # todo, remove me, it's okay to manually manage RadioButtons
      logprint(LOG_DEV, "No radio group defined");
    }
  }
};

# auto manage radio-button checked state
gui.widgets.RadioGroup = {
  new: func(nm = 'unnamed')
  {
    var m = {parents:[gui.widgets.RadioGroup, name:nm, radios:[]]};
    return m;
  },

  addRadio: func(r)
  {
    if (r.parents[0] != RadioButton) {
      logprint(LOG_ALERT, "Adding non-RadioButton to RadioGroup")
      return;
    }
    append(me.radios, r);
  },

  removeRadio: func(r)
  {
    if (r.parents[0] != RadioButton) {
      logprint(LOG_ALERT, "Remove non-RadioButton from RadioGroup")
      return;
    }

    # should we update some other item to be checked?
    me.radios.remove(r);
  },

  setEnabled: func(doEnable = 1)
  {
    foreach (var r : me.radios) {
      r.setEnabled(doEnable);
    }
  },

# protected methods
  # update check state of all radios in the group
  _updateChecked: func(active)
  {
    foreach (var r : me.radios) {
      r.setChecked(r == active);
    }
  }
};