# Multiplayer Chat
# ================
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
      key.setValue(0);           # drop key event
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
