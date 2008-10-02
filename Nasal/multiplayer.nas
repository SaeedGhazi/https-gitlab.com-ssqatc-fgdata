# Multiplayer
# ===========
#
# 1) Display chat messages from other aircraft to
#    the screen using screen.nas
#
# 2) Display a complete history of chat via dialog.
#
# 3) Allow chat messages to be written by the user.

var messages = {};

var check_messages = func
{

  var mp = props.globals.getNode("/ai/models").getChildren("multiplayer");
  var lseen = {};

  foreach (i; mp)
  {
    var lmsg           = getprop(i.getPath() ~ "/sim/multiplay/chat");
    var lcallsign      = getprop(i.getPath() ~ "/callsign");
    var lvalid         = getprop(i.getPath() ~ "/valid");

    if ((lvalid)           and
        (lmsg != nil)      and
        (lmsg != "")       and
        (lcallsign != nil) and
        (lcallsign != "")     )
    {
      if (! contains(lseen, lcallsign))
      {
        # Indicate that we've seen this callsign. This handles the case
        # where we have two aircraft with the same callsign in the MP
        # session.
        lseen[lcallsign] = 1;

        if ((! contains(messages, lcallsign)) or
          (! streq(lmsg, messages[lcallsign])))
        {
          # Save the message so we don't repeat it.
          messages[lcallsign] = lmsg;

          # Display the message.
          echo_message(lmsg, lcallsign);
        }
      }
    }
  }

# Check for new messages every couple of seconds.
  settimer(check_messages, 3);
}

var echo_message = func(msg, callsign)
{
  if ((callsign != nil) and
      (! string.match(msg, "*" ~ callsign ~ "*")))
  {
    # Only prefix with the callsign if the message doesn't already include it.
    msg = callsign ~ ": " ~ msg;
  }

  var ldisplay = getprop("/sim/multiplay/chat-display");

  if ((ldisplay != nil) and (ldisplay == "1"))
  {
    # Only display the message to screen if configured.
    setprop("/sim/messages/ai-plane", msg);
  }

  # Add the chat to the chat history.
  var lchat = getprop("/sim/multiplay/chat-history");

  if (lchat == nil)
  {
    setprop("/sim/multiplay/chat-history", msg);
  }
  else
  {
    if (substr(lchat, size(lchat) -1, 1) != "\n")
    {
      lchat = lchat ~ "\n";
    }

    setprop("/sim/multiplay/chat-history", lchat ~ msg);
  }
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

var PILOTSDLG_RUNNING=0;
var METER_TO_NM = 0.0005399568034557235;

var dialog = {
    init : func(x = nil, y = nil) {
        me.x = x;
        me.y = y;
        me.bg = [0, 0, 0, 0.3];    # background color
        me.fg = [[0.9, 0.9, 0.2, 1], [1.0, 1.0, 1.0, 1.0]];   # alternating foreground colors
        me.unit=1;
        me.toggle_unit();          # set to imperial
        #
        # "private"
        me.header = [" callsign", "model", "hdg", func { dialog.dist_hdr }, func { dialog.alt_hdr ~ " " }];
        me.columns = [
            {property:"callsign",    format:" %s",   label: "-----------",   halign:"fill" },
            {property:"model-short", format:"%s",    label: "--------------",halign:"fill" },
            {property:"bearing-to",  format:" %3.0f",label: "----",     halign: "right",font:{name:"FIXED_8x13"}},
            {property:func {dialog.dist_node}, format:" %8.2f",label: "---------",halign: "right",font:{name:"FIXED_8x13"}},
            {property:func {dialog.alt_node},  format:" %7.0f",label: "---------",halign: "right",font:{name:"FIXED_8x13"}}
        ];
        me.name = "who-is-online";
        me.namenode = props.Node.new({"dialog-name" : me.name });
        me.dialog = nil;
        me.mp = props.globals.getNode("/ai/models");

        me.listeners=[];
        append(me.listeners, setlistener("/sim/startup/xsize", func { me._redraw_() }));
        append(me.listeners, setlistener("/sim/startup/ysize", func { me._redraw_() }));
        append(me.listeners, setlistener("/ai/models/model-added", func(n) { me._multiplayer_update_(n) }));
        append(me.listeners, setlistener("/ai/models/model-removed", func(n) { me._multiplayer_update_(n) }));
    },
    getloc : func (p) {
        var ploc = geo.Coord.new();
        ploc.set_xyz(p.getNode("global-x").getValue(), p.getNode("global-y").getValue(), p.getNode("global-z").getValue());
        return ploc;
    },
    create : func {
        if (me.dialog != nil)
            me.close();

        me.dialog = gui.Widget.new();
        me.dialog.set("name", me.name);
        if (me.x != nil)
            me.dialog.set("x", me.x);
        if (me.y != nil)
            me.dialog.set("y", me.y);

        me.dialog.set("layout", "vbox");
        me.dialog.set("default-padding", 0);

        me.dialog.setColor(me.bg[0], me.bg[1], me.bg[2], me.bg[3]);

        var titlebar=me.dialog.addChild("group");
        titlebar.set("layout", "hbox");

        var w = titlebar.addChild("button");
        w.node.setValues({"pref-width": 16, "pref-height": 16, legend: me.unit_button, default: 0});
        w.setBinding("nasal", "multiplayer.dialog.toggle_unit(); multiplayer.dialog._redraw_()");

        titlebar.addChild("empty").set("stretch", 1);
        titlebar.addChild("text").set("label", "Pilots: ");

        var p=titlebar.addChild("text");
        p.node.setValues({label: "---", live: 1, format: "%d", property: me.mp.getPath() ~ "/players"});
        titlebar.addChild("empty").set("stretch", 1);

        var w = titlebar.addChild("button");
        w.node.setValues({"pref-width": 16, "pref-height": 16, legend: "", default: 0, key: "Esc"});
        w.setBinding("nasal", "multiplayer.dialog.del()");

        me.dialog.addChild("hrule");

        var content=me.dialog.addChild("group");
        content.set("layout", "table");
        content.set("default-padding", 0);

        var row=0;
        var col=0;
        foreach (var h; me.header) {
            var w = content.addChild("text");
            var l = typeof(h) == "func" ? h() : h;
            w.node.setValues({"label":l, "row":row, "col":col, halign:me.columns[col].halign});
            w=content.addChild("hrule");
            w.node.setValues({"row":row+1,"col":col});
            col+=1;
        }
        row+=2;
        var children = me.mp.getChildren("multiplayer");
        var mp_vec=[];
        foreach(var c; children) {
            if(c.getNode("callsign") != nil and c.getNode("valid").getValue()) {
                append(mp_vec, { callsign:string.lc(c.getNode("callsign").getValue()), index:c.getIndex()});
            }
        }
        var sorted=sort(mp_vec, func(a,b) { return cmp(a.callsign,b.callsign) });
        foreach(var s; sorted) {
            var c = children[s.index];
            var col=0;
            foreach (var column; me.columns) {
                var w = content.addChild("text");
                w.node.setValues(column);
                var p=typeof(column.property) == "func" ? column.property() : column.property;
                w.node.setValues({row: row, col: col, live: 1, property: c.getPath() ~ "/" ~ p});
                var odd = math.mod(row, 2);
                w.setColor(me.fg[odd][0], me.fg[odd][1], me.fg[odd][2], me.fg[odd][3]);
                col +=1;
            }
            row +=1;
        }

        fgcommand("dialog-new", me.dialog.prop());
        fgcommand("dialog-show", me.namenode);
    },
    update : func {
        var children = me.mp.getChildren("multiplayer");
        var loc = geo.aircraft_position();
        var players = 0;
        foreach(var c; children) {
            if ( c.getNode("valid") == nil or !c.getNode("valid").getValue())
                continue;
            players+=1;
            var ploc = me.getloc(c.getNode("position"));
            var ploc_course = loc.course_to(ploc);
            var ploc_dist = loc.distance_to(ploc);
            var altitude_m = c.getNode("position/altitude-ft").getValue()*geo.FT2M;

            var pathN = c.getNode("sim/model/path");
            if (pathN != nil)
                var path = pathN.getValue();
            else
                var path="";

            var name = split("/", path)[-1];
            var pos = find("-model", name);
            if (pos >= 0)
                name = substr(name, 0, pos);
            if (substr(name, -4) == ".xml")
                name = substr(name, 0, size(name) - 4);
            if (substr(name, -3) == ".ac")
                name = substr(name, 0, size(name) - 3);

            c.setValues({"model-short":name, "bearing-to": ploc_course,
                "distance-to-km":ploc_dist/1000.0, "distance-to-nm":ploc_dist*METER_TO_NM,
                "position/altitude-m":altitude_m });
        }
        me.mp.getNode("players", 1).setIntValue(players);
        if(PILOTSDLG_RUNNING)
            settimer( func { me.update() }, 0.4, 1);
    },
    _redraw_ : func {
        if (me.dialog != nil) {
            me.close();
            me.create();
        }
    },
    _multiplayer_update_ : func(node) {
        var name = split("/", node.getValue())[-1];
        if(substr(name, 0, 11) == "multiplayer")
            me._redraw_()
    },
    toggle_unit : func {
        me.unit = !me.unit;
        if(me.unit)
        {
            me.alt_node = "position/altitude-m";
            me.alt_hdr = "alt-m";
            me.dist_hdr = "dist-km";
            me.dist_node = "distance-to-km";
            me.unit_button = "IM";
        }
        else
        {
            me.alt_node = "position/altitude-ft";
            me.dist_node = "distance-to-nm";
            me.alt_hdr = "alt-ft";
            me.dist_hdr = "dist-nm";
            me.unit_button = "SI";
        }
    },
    close : func {
        fgcommand("dialog-close", me.namenode);
    },
    del : func {
        PILOTSDLG_RUNNING=0;
        me.close();
        foreach(var l; me.listeners)
            removelistener(l);
        delete(gui.dialog, "\"" ~ me.name ~ "\"");
    },
    show : func {
        if(!PILOTSDLG_RUNNING)
        {
            PILOTSDLG_RUNNING=1;
            me.init(-2, -2);
            me.create();
            me.update();
        }
    },
    toggle : func {
        if(!PILOTSDLG_RUNNING)
            me.show();
        else
            me.del();
    }
};

