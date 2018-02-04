# FG Commands to support simple bindings

removecommand("FG1000HardKeyPushed");
addcommand("FG1000HardKeyPushed",
  func(node) {
    var device = int(node.getNode("device").getValue());
    var name = node.getNode("notification").getValue();
    var value = node.getNode("value").getValue();

    if (device == nil) {
      print("FG1000HardKeyPushed: Unknown device" ~ node.getNode("device").getValue());
      return;
    }

    # Notification may be provided as a number, or a string.
    if (int(name) == nil) {
      # Name is a string, to map it to the correct INT id.
      if (defined(fg1000.FASCIA[name])) {
        name = fg1000.FASCIA[name];
      } else {
        print("Unable to find FASCIA entry for Hard Key " ~ name);
        return;
      }
    }

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      device,
      notifications.PFDEventNotification.HardKeyPushed,
      { Id: name, Value: value }
    );
    emesary.GlobalTransmitter.NotifyAll(notification);
  }
);

removecommand("FG1000SoftKeyPushed");
addcommand("FG1000SoftKeyPushed",
  func(node) {
    var device = int(node.getNode("device").getValue());
    var value = int(node.getNode("value").getValue());

    if (device == nil) {
      print("FG1000SoftKeyPushed: Unknown device" ~ node.getNode("device").getValue());
      return;
    }

    if (value == nil) {
      print("Unable to convert softkey number to integer " ~ node.getNode("value").getValue());
      return;
    }

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      device,
      notifications.PFDEventNotification.SoftKeyPushed,
      value
    );
    emesary.GlobalTransmitter.NotifyAll(notification);
  }
);
