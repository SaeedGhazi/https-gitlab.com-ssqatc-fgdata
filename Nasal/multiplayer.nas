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

check_messages = func
{

  var mp = props.globals.getNode("/ai/models").getChildren("multiplayer");

  foreach (i; mp)
  {
    var lmsg           = getprop(i.getPath() ~ "/sim/multiplay/chat");
    var lcallsign      = getprop(i.getPath() ~ "/callsign");

    if ((lmsg != nil) and (lmsg != "") and (lcallsign != nil) and (lcallsign != ""))
    {
      #print("Call Sign: " ~ lcallsign);
      #print("lmsg: " ~ lmsg);
      #print("Freq: " ~ ltransmitfreq);

      if ((! contains(messages, lcallsign)) or (lmsg != messages[lcallsign]))
      {
        # Indicate we've seen this message.
        messages[lcallsign] = lmsg;
        echo_message(lmsg, lcallsign);
      }
    }
  }

  # Check for new messages every couple of seconds.
  settimer(check_messages, 3);
}

echo_message = func(msg, callsign)
{
   if (callsign != nil)
   {
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
  setlistener("/sim/multiplay/chat", func{ echo_message(cmdarg().getValue(), getprop("/sim/multiplay/callsign")); });

  # check for new messages
  check_messages();

}, 1);


