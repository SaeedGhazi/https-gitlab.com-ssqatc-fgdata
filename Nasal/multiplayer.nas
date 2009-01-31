# Multiplayer
# ===========
#
# 1) Display chat messages from other aircraft to
#    the screen using screen.nas
#
# 2) Display a complete history of chat via dialog.
#
# 3) Allow chat messages to be written by the user.


var check_messages = func
{

  var mp = props.globals.getNode("/ai/models").getChildren("multiplayer");
  var lseen = {};

  foreach (var n; mp)
  {
    var last           = n.initNode("sim/multiplay/last-message", "");
    var lmsg           = n.getNode("sim/multiplay/chat", 1).getValue();
    var lcallsign      = n.getNode("callsign", 1).getValue();
    var lvalid         = n.getNode("valid", 1).getValue();

    if (!lvalid or !lmsg or !lcallsign)
      continue;

    if (contains(lseen, lcallsign))
      continue;

    # Indicate that we've seen this callsign. This handles the case
    # where we have two aircraft with the same callsign in the MP
    # session.
    lseen[lcallsign] = 1;

    if (lmsg != last.getValue())
    {
      # Display the message.
      echo_message(lmsg, lcallsign);
      last.setValue(lmsg);
    }
  }

# Check for new messages every couple of seconds.
  settimer(check_messages, 3);
}

var echo_message = func(msg, callsign)
{
  if ((callsign != nil) and (find(callsign, msg) < 0))
  {
    # Only prefix with the callsign if the message doesn't already include it.
    msg = callsign ~ ": " ~ msg;
  }

  msg = string.trim(string.replace(msg, "\n", " "));

  var ldisplay = getprop("/sim/multiplay/chat-display");

  if ((ldisplay != nil) and (ldisplay == "1"))
  {
    # Only display the message to screen if configured.
    setprop("/sim/messages/ai-plane", msg);
  }

  # Add the chat to the chat history.
  var lchat = getprop("/sim/multiplay/chat-history") or "";

  if (lchat)
  {
    lchat = string.trim(lchat, 0, string.isxspace);
    msg = lchat ~ "\n" ~ msg;
  }

  setprop("/sim/multiplay/chat-history", msg);
}

settimer(func {
  # Call-back to ensure we see our own messages.
  setlistener("/sim/multiplay/chat", func(n) {
    echo_message(n.getValue(), getprop("/sim/multiplay/callsign"));
  });

  # check for new messages
  check_messages();
}, 1);

# Message composition function, activated using the - key.
var prefix = "Chat Message:";
var input = "";
var kbdlistener = nil;

var compose_message = func(msg = "")
{
  input = prefix ~ msg;
  gui.popupTip(input, 1000000);

  kbdlistener = setlistener("/devices/status/keyboard/event", func (event) {
    var key = event.getNode("key");

    # Only check the key when pressed.
    if (!event.getNode("pressed").getValue())
      return;

    if (handle_key(key.getValue()))
      key.setValue(-1);           # drop key event
  });
}

var handle_key = func(key)
{
  if (key == `\n` or key == `\r`)
  {
    # CR/LF -> send the message

    # Trim off the prefix
    input = substr(input, size(prefix));
    # Send the message and switch off the listener.
    setprop("/sim/multiplay/chat", input);
    removelistener(kbdlistener);
    gui.popdown();
    return 1;
  }
  elsif (key == 8)
  {
    # backspace -> remove a character

    if (size(input) > size(prefix))
    {
      input = substr(input, 0, size(input) - 1);
      gui.popupTip(input, 1000000);
      return 1;
    }
  }
  elsif (key == 27)
  {
    # escape -> cancel
    removelistener(kbdlistener);
    gui.popdown();
    return 1;
  }
  elsif ((key > 31) and (key < 128))
  {
    # Normal character - add it to the input
    input ~= chr(key);
    gui.popupTip(input, 1000000);
    return 1;
  }
  else
  {
    # Unknown character - pass through
    return 0;
  }
}




# (l) 2008 by till busch <buti (at) bux (dot) at>
#
# multiplayer.dialog.show() -- displays the dialog and starts the update loop

var PILOTSDLG_RUNNING = 0;

var dialog = {
    init: func(x = nil, y = nil) {
        me.x = x;
        me.y = y;
        me.bg = [0, 0, 0, 0.3];    # background color
        me.fg = [[0.9, 0.9, 0.2, 1], [1.0, 1.0, 1.0, 1.0]];   # alternating foreground colors
        me.unit = 1;
        me.toggle_unit();          # set to imperial
        #
        # "private"
        var font = { name: "FIXED_8x13" };
        me.header = [" callsign", "model", "brg", func { dialog.dist_hdr }, func { dialog.alt_hdr ~ " " }];
        me.columns = [
            {property:"callsign",    format:" %s",   label: "-----------",   halign:"fill" },
            {property:"model-short", format:"%s",    label: "--------------",halign:"fill" },
            {property:"bearing-to",  format:" %3.0f",label: "----",     halign: "right", font: font },
            {property:func {dialog.dist_node}, format:" %8.2f",label: "---------",halign: "right", font: font },
            {property:func {dialog.alt_node},  format:" %7.0f",label: "---------",halign: "right", font: font }
        ];
        me.name = "who-is-online";
        me.dialog = nil;
        me.loopid = 0;

        me.listeners=[];
        append(me.listeners, setlistener("/sim/startup/xsize", func me._redraw_()));
        append(me.listeners, setlistener("/sim/startup/ysize", func me._redraw_()));
        append(me.listeners, setlistener("/sim/signals/reinit-gui", func me._redraw_()));
        append(me.listeners, setlistener("/sim/signals/multiplayer-updated", func me._redraw_()));
    },
    create: func {
        if (me.dialog != nil)
            me.close();

        me.dialog = gui.Widget.new();
        me.dialog.set("name", me.name);
        me.dialog.set("dialog-name", me.name);
        if (me.x != nil)
            me.dialog.set("x", me.x);
        if (me.y != nil)
            me.dialog.set("y", me.y);

        me.dialog.set("layout", "vbox");
        me.dialog.set("default-padding", 0);

        me.dialog.setColor(me.bg[0], me.bg[1], me.bg[2], me.bg[3]);

        var titlebar = me.dialog.addChild("group");
        titlebar.set("layout", "hbox");

        var w = titlebar.addChild("button");
        w.node.setValues({"pref-width": 16, "pref-height": 16, legend: me.unit_button, default: 0});
        w.setBinding("nasal", "multiplayer.dialog.toggle_unit(); multiplayer.dialog._redraw_()");

        titlebar.addChild("empty").set("stretch", 1);
        titlebar.addChild("text").set("label", "Pilots: ");

        var p = titlebar.addChild("text");
        p.node.setValues({label: "---", live: 1, format: "%d", property: "ai/models/num-players"});
        titlebar.addChild("empty").set("stretch", 1);

        var w = titlebar.addChild("button");
        w.node.setValues({"pref-width": 16, "pref-height": 16, legend: "", default: 0});
        w.setBinding("nasal", "multiplayer.dialog.del()");

        me.dialog.addChild("hrule");

        var content = me.dialog.addChild("group");
        content.set("layout", "table");
        content.set("default-padding", 0);

        var row = 0;
        var col = 0;
        foreach (var h; me.header) {
            var w = content.addChild("text");
            var l = typeof(h) == "func" ? h() : h;
            w.node.setValues({ "label": l, "row": row, "col": col, halign: me.columns[col].halign });
            w = content.addChild("hrule");
            w.node.setValues({ "row": row + 1,"col": col });
            col += 1;
        }
        row += 2;
        var odd = 0;
        foreach (var mp; model.list) {
            var col = 0;
            foreach (var column; me.columns) {
                var w = content.addChild("text");
                w.node.setValues(column);
                var p = typeof(column.property) == "func" ? column.property() : column.property;
                w.node.setValues({row: row, col: col, live: 1, property: mp.path ~ "/" ~ p});
                w.setColor(me.fg[odd][0], me.fg[odd][1], me.fg[odd][2], me.fg[odd][3]);
                col += 1;
            }
            odd = !odd;
            row +=1;
        }
        me.update(me.loopid += 1);
        fgcommand("dialog-new", me.dialog.prop());
        fgcommand("dialog-show", me.dialog.prop());
    },
    update: func(id) {
        id == me.loopid or return;
        var self = geo.aircraft_position();
        foreach (var mp; model.list) {
            var n = mp.node;
            var ac = geo.Coord.new().set_xyz(
                    n.getNode("position/global-x").getValue(),
                    n.getNode("position/global-y").getValue(),
                    n.getNode("position/global-z").getValue());
            var distance = self.distance_to(ac);

            n.setValues({
                "model-short": mp.model,
                "bearing-to": self.course_to(ac),
                "distance-to-km": distance / 1000.0,
                "distance-to-nm": distance * M2NM,
                "position/altitude-m": n.getNode("position/altitude-ft").getValue() * FT2M,
            });
        }
        if (PILOTSDLG_RUNNING)
            settimer(func me.update(id), 1, 1);
    },
    _redraw_: func {
        if (me.dialog != nil) {
            me.close();
            me.create();
        }
    },
    toggle_unit: func {
        me.unit = !me.unit;
        if (me.unit) {
            me.alt_node = "position/altitude-m";
            me.alt_hdr = "alt-m";
            me.dist_hdr = "dist-km";
            me.dist_node = "distance-to-km";
            me.unit_button = "IM";
        } else {
            me.alt_node = "position/altitude-ft";
            me.dist_node = "distance-to-nm";
            me.alt_hdr = "alt-ft";
            me.dist_hdr = "dist-nm";
            me.unit_button = "SI";
        }
    },
    close: func {
        fgcommand("dialog-close", me.dialog.prop());
    },
    del: func {
        PILOTSDLG_RUNNING=0;
        me.close();
        foreach (var l; me.listeners)
            removelistener(l);
        delete(gui.dialog, "\"" ~ me.name ~ "\"");
    },
    show: func {
        if (!PILOTSDLG_RUNNING) {
            PILOTSDLG_RUNNING=1;
            me.init(-2, -2);
            me.create();
            me.update();
        }
    },
    toggle: func {
        if (!PILOTSDLG_RUNNING)
            me.show();
        else
            me.del();
    },
};



# Autonomous singleton class that monitors multiplayer aircraft,
# maintains a data hash and a list (sorted by callsign), and raises
# signal "/sim/signals/multiplayer-updated" whenever an aircraft
# joined or left. Both multiplayer.model.data and multiplayer.model.list
# contain hash entries of this form:
#
# {
#    callsign: "bimaus",
#    model: "bo105",     # model name without suffixes (xml, ac, -anim, -model)
#    node: {...},        # node as props.Node hash
#    path: "/ai/models/multiplayer[4]",
# }
#
#
var model = {
    init: func {
        me.L = [];
        me.list = [];
        append(me.L, setlistener("ai/models/model-added", func(n) me.update(n.getValue())));
        append(me.L, setlistener("ai/models/model-removed", func(n) me.update(n.getValue())));
        me.update();
    },
    update: func(n = nil) {
        if (n != nil and props.globals.getNode(n, 1).getName() != "multiplayer")
            return;

        me.data = {};
        foreach (var n; props.globals.getNode("ai/models", 1).getChildren("multiplayer")) {
            if (!n.getNode("valid", 1).getValue())
                continue;

            if ((var callsign = n.getNode("callsign")) == nil or !(callsign = callsign.getValue()))
                continue;

            var model = n.getNode("sim/model/path").getValue();
            model = split(".", split("/", model)[-1])[0];
            model = me.remove_suffix(model, "-model");
            model = me.remove_suffix(model, "-anim");

            var path = n.getPath();
            me.data[path] = { node: n, callsign: callsign, model: model, path: path };
        }

        me.list = sort(keys(me.data), func(a, b) string.icmp(me.data[a].callsign, me.data[b].callsign));
        forindex (var i; me.list)
            me.list[i] = me.data[me.list[i]];

        setprop("ai/models/num-players", size(me.list));
        setprop("sim/signals/multiplayer-updated", 1);
    },
    remove_suffix: func(s, x) {
        var len = size(x);
        if (substr(s, -len) == x)
            return substr(s, 0, size(s) - len);
        return s;
    },
};


_setlistener("sim/signals/nasal-dir-initialized", func model.init());


