#
# Functions for XML-based tutorials
#

#
# Each tutorial consists of the following XML sections
#
# <name>        - Tutorial Name
# <description> - description
# <audio-dir>   - Optional:  Directory to pick up audio instructions from.
#                   Relative to FG_ROOT
# <timeofday>   - Optional: Time of day setting for tutorial:
#                   dawn/morning/noon/afternoon etc.
# <presets>     - Optional: set of presets to used for start position.
#                   See commit-presets and gui/dialog/location-*.xml for details.
#   <airport-id>
#   <on-ground>
#   <runway>
#   <altitude-ft>
#   <latitude-deg>
#   <longitude-deg>
#   <heading-deg>
#   <airspeed-kt>
# <init>       - Optional: Initialization section consist of one or more
#                  set nodes:
#    <set>
#    <prop> - Property to set
#    <val>  - value
# <step>       - Tutorial step - a segment of the tutorial, consisting of
#                the following:
#   <instruction> - Text instruction displayed when the tutorial reaches
#                   this step, and when neither the exit nor any error
#                   criteria have been fulfilled
#   <instruction-voice> - Optional: wav filename to play when displaying
#                         instruction
#   <error> - Error conditions, causing error messages to be displayed.
#             The tutorial doesn't advance while any error conditions are
#             fulfilled. Consists of one or more check nodes:
#    <check>
#      <prop> - property to check.
#        <lt> - less than value. One of <lt>, <gt>, <eq> must be defined
#        <gt> - greater than value. One of <lt>, <gt>, <eq> must be defined
#        <eq> - equal value. One of <lt>, <gt>, <eq> must be defined
#        <msg> - Error message to display if error criteria fulfilled.
#        <msg-voice> - Optional: wav filename to play when error condition fulfilled.
# <exit> - Exit criteria causing tutorial to progress to next step. Consists of
#          one or more check nodes. All check nodes must be fulfilled at the same
#          time of the tutorial to progress to the next step.
#      <prop> - property to check.
#        <lt> - less than value. One of <lt>, <gt>, <eq> must be defined
#        <gt> - greater than value. One of <lt>, <gt>, <eq> must be defined
#        <eq> - equal value. One of <lt>, <gt>, <eq> must be defined
#
# <endtext> - Optional: Text to display when the tutorial exits the last step.
# <endtext-voice> - Optional: wav filename to play when the tutorial exits the last step

#
# GLOBAL VARIABLES
#

# Time between tutorial steps.
STEP_TIME = 5;

# We also have a gap between the fulfillment of a step and the start
# of the next step. This can be much shorter.
STEP_EXIT = 1;

m_currentStep = 0;
m_errors = 0;
m_tutorial = 0;
m_firstEntry = 1;
m_audioDir = "";
m_lastmsgcount = 0;

#
# startTutorial()
#
# Start a tutorial defined within xiProp
#
startTutorial = func {
  m_currentStep = 0;
  m_errors = 0;

  if (getprop("/sim/tutorial/current-tutorial") == nil)
  {
    # Tutorial not defined - exit
    screen.log.write("No tutorial selected");
    return;
  }

  ltutorial = getprop("/sim/tutorial/current-tutorial");
  lfound = 0;

  foreach(c; props.globals.getNode("/sim/tutorial").getChildren("tutorial"))
  {
    if (c.getChild("name").getValue() == ltutorial)
    {
      m_tutorial = c;
      lfound = 1;
    }
  }

  if (lfound == 0)
  {
    # Unable to find tutorial
    screen.log.write("Unable to find tutorial : " ~ ltutorial);
    return;
  }

  # Indicate that the tutorial is running
  screen.log.write("Loading tutorial: " ~ ltutorial ~ " ...");
  isRunning(1);

  # If defined, get the audio directory
  if (m_tutorial.getChild("audio-dir") != nil)
  {
    fg_root = getprop("/sim/fg-root");
    m_audioDir = sprintf("%s/%s/", fg_root, m_tutorial.getChild("audio-dir").getValue());
  }

  # Set the time of day, if present
  timeofday = m_tutorial.getChild("timeofday");
  if (timeofday != nil)
  {
    fgcommand("timeofday", props.Node.new("timeofday", timeofday.getValue()));
  }

  # First, set any presets that might be present
  presets = m_tutorial.getChild("presets");

  if ((presets != nil) and (presets.getChildren() != nil))
  {
    children = presets.getChildren();
    foreach(c; children)
    {
      setprop("/sim/presets/" ~ c.getName(), c.getValue());
    }

    # Apply the presets
    fgcommand("presets-commit", props.Node.new());

    # Set the various engines to be running
    if (getprop("/sim/presets/on-ground"))
    {
      var eng = props.globals.getNode("/controls/engines");
      if (eng != nil)
      {
        foreach (c; eng.getChildren("engine"))
        {
          c.getNode("magnetos", 1).setIntValue(3);
          c.getNode("throttle", 1).setDoubleValue(0.5);
        }
      }
    }
  }

  # Run through any initialization nodes
  inits = m_tutorial.getChild("init");
  if ((inits != nil) and (inits.getChildren("set") != nil))
  {
    children = inits.getChildren("set");
    foreach(c; children)
    {
      setVal(c);
    }
  }

  # Pick up any weather conditions/scenarios set
  setprop("/environment/rebuild-layers", getprop("/environment/rebuild-layers")+1);

  # Set the timer to start the first tutorial step
  settimer(stepTutorial, STEP_TIME);
}

#
# stopTutorial
#
# Stops the current tutorial .
#
stopTutorial = func
{
  isRunning(0);
  settimer(resetStop, STEP_TIME);
}

#
# resetStop
#
# Reset the stop value, having given any running tutorials the
# chance to stop. Also reset the various state variables incase
# they have been changed.
resetStop = func
{
  m_currentStep = 0;
  m_firstEntry = 1;
  m_errors = 0;
}

#
# stepTutorial
#
# This function does the actual work. It is executed every 5 seconds.
#
# Each iteration it:
# - Gets the current step node from the tutorial
# - If this is the first time the step is entered, it displays the instruction message
# - Otherwise, it
#   - Checks if the exit conditions have been met. If so, it increments the step counter.
#   - Checks for any error conditions, in which case it displays a message to the screen and
#     increments an error counter
#   - Otherwise display the instructions for the step.
# - Sets the timer for 5 seconds again.
#
stepTutorial = func {

  var lerror = 0;
  var ltts = nil;
  var lsnd = nil;
  var lmessage = nil;

  if (!isRunning())
  {
    # If we've been told to stop, just do so.
    return;
  }

  # If we've reached the end of the tutorial, simply indicate and exit
  if (m_currentStep == size(m_tutorial.getChildren("step")))
  {
    # End of tutorial.

    lfinished = "Tutorial finished.";

    if (m_tutorial.getChild("endtext") != nil)
    {
      lfinished = m_tutorial.getChild("endtext").getValue();
    }

    if (m_tutorial.getChild("endtext-voice") != nil)
    {
      lsnd = m_tutorial.getChild("endtext-voice").getValue();
    }

    say(lfinished, lsnd);
    say("Deviations : " ~ m_errors);
    isRunning(0);
    return;
  }

  lstep = m_tutorial.getChildren("step")[m_currentStep];

  lmessage = "Tutorial step " ~ m_currentStep;


  if (lstep.getChild("instruction") != nil)
  {
    # By default, display the current instruction
    lmessage = lstep.getChild("instruction").getValue();
  }

  if (m_firstEntry == 1)
  {
    # If this is the first time we've encountered this step :
    # - Set any values required
    # - Display any messages
    # - Play any instructions.
    #
    # We then do not go through the error or exit processing, giving the user
    # time to react to the instructions.

    if (lstep.getChild("instruction-voice") != nil)
    {
      lsnd = lstep.getChild("instruction-voice").getValue();
    }

    say(lmessage, lsnd);

    # Set any properties
    foreach (c; lstep.getChildren("set"))
    {
      setVal(c);
    }

    m_firstEntry = 0;
    settimer(stepTutorial, STEP_TIME);
    return;
  }

  # Check for error conditions
  if ((lstep.getChild("error") != nil) and
      (lstep.getChild("error").getChildren("check") != nil))
  {
    #print("Checking errors");

    foreach(c; lstep.getChild("error").getChildren("check"))
    {
      if (checkVal(c))
      {
        # and error condition was fulfilled - set the error message
        lerror = 1;
        m_errors += 1;

        if (c.getChild("msg") != nil)
        {
          lmessage = c.getChild("msg").getValue();

          if (c.getChild("msg-voice") != nil)
          {
            lsnd = c.getChild("msg-voice").getValue();
          }
        }
      }
    }
  }


  # Check for exit condition, but only if we didn't hit any errors
  if (lerror == 0)
  {
    if ((lstep.getChild("exit") == nil) or
        (lstep.getChild("exit").getChildren("check") == nil))
    {
      m_currentStep += 1;
      m_firstEntry = 1;
      settimer(stepTutorial, STEP_EXIT);
      return;
    }
    else
    {
      lexit = 1;
      foreach(c; lstep.getChild("exit").getChildren("check"))
      {
        if (checkVal(c) == 0)
        {
          lexit = 0;
        }
      }

      if (lexit == 1)
      {
        # Passed all exit steps
        m_currentStep += 1;
        m_firstEntry = 1;
        settimer(stepTutorial, STEP_EXIT);
        return;
      }
    }
  }


  # Display the resulting message and wait to go around again.
  say(lmessage, lsnd, lerror);

  settimer(stepTutorial, STEP_TIME);
}

# Set a value in the property tree based on an entry of the form
# <set>
#   <prop>/foo/bar</prop>
#   <val>woof</val>
# </set>
#
setVal = func(node) {

  if (node.getName("set"))
  {
    lprop = node.getChild("prop").getValue();
    lval = node.getChild("val").getValue();

    if ((lprop != nil) and (lval != nil))
    {
      setprop(lprop, lval);
    }
  }
}

# Check a value in the property tree based on an entry of the form
#
#  <check>
#   <prop>/foo/bar</prop>
#   <_operator_>woof</_operator_>
#
# where _operator_ may be one of "eq", "lt", "gt"
#
checkVal = func(node) {

  if (node.getName("check"))
  {
    lprop = node.getChild("prop").getValue();

    if (getprop(lprop) == nil)
    {
      # This is probably an error
      print("Undefined property: " ~ lprop);
      return 0;
    }

    if ((node.getChild("eq") != nil) and
        (getprop(lprop) == node.getChild("eq").getValue()))
    {
      return 1;
    }

    if ((node.getChild("lt") != nil) and
        (getprop(lprop) < node.getChild("lt").getValue() ))
    {
      return 1;
    }

    if ((node.getChild("gt") != nil) and
        (getprop(lprop) > node.getChild("gt").getValue() ))
    {
      return 1;
    }
  }

  return 0;
}

#
# Set and return running state. Disable/enable stop menu.
#
isRunning = func(which=nil)
{
  var prop = "/sim/tutorial/running";
  if (which != nil)
  {
    setprop(prop, which);
    gui.menuEnable("tutorial-stop", which);
  }
  return getprop(prop);
}

#
# Output the message and optional sound recording.
#
say = func(msg, snd=nil, lerror=0)
{
  var lastmsg = getprop("/sim/tutorial/last-message");

  if ((msg != lastmsg) or (lerror == 1 and m_lastmsgcount == 1))
  {
    # Error messages are only displayed every 10 seconds (2 iterations)
    # Other messages are only displayed if they change
    if (snd == nil)
    {
      # Simply set to the co-pilot channel. TTS is picked up automatically.
      setprop("/sim/messages/copilot", msg);
    }
    else
    {
      # Play the audio, and write directly to the screen-logger to avoid
      # any tts being sent to festival.
      lprop = { path : m_audioDir, file : snd };
      fgcommand("play-audio-message", props.Node.new(lprop) );
      screen.log.write(msg, 1, 1, 1);
    }

    setprop("/sim/tutorial/last-message", msg);
    m_lastmsgcount = 0;
  }
  else
  {
    m_lastmsgcount += 1;
  }
}
