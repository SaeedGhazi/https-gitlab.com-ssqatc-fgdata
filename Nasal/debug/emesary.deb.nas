#-------------------------------------------------------------------------------
# emesary.deb.nas - emesary debug helpers
#-------------------------------------------------------------------------------
var _emesaryDebugN = props.getNode("/_debug/emesary/",1);
var _emesaryDebugEnableN = _emesaryDebugN.getNode("enabled",1);
_emesaryDebugEnableN.setBoolValue(_emesaryDebugEnableN.getValue());

var __setup = func {
    var debugRecipient = emesary.Recipient.new("Debug");

    debugRecipient.Receive = func(ntf) {
        _emesaryDebugEnableN.getValue() or return;
        
        if (!isa(ntf, emesary.Notification)) {
            logprint(DEV_ALERT, "debugRecipient: argument is not a emesary.Notification!");
            return emesary.Transmitter.ReceiptStatus_Fail; 
        }
        # ignore FrameNotification as it would flood the log/console at frame rate
        if (ntf.NotificationType != "FrameNotification") {
            print("debugRecipient: type=", ntf.NotificationType, " id=", ntf.Ident);
            debug.dump(keys(ntf));
            # count notifications
            if (isstr(ntf.NotificationType)) {
                var cnt = _emesaryDebugN.getChild(ntf.NotificationType, 0, 1);
                if (isstr(ntf.Ident)) {
                    cnt = cnt.getNode(ntf.Ident, 1);
                }
                if (cnt.getValue() == nil) {
                    cnt.setIntValue(0);
                }
                cnt.increment();
            }
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed; 
    }

    emesary.GlobalTransmitter.Register(debugRecipient);

    # send a test message
    var debugNotification = emesary.Notification.new("debug", "test");
    emesary.GlobalTransmitter.NotifyAll(debugNotification);

    #add monitoring
    emesary._transmitters.addCallback(func (k, v) {
        emesary._transmitters.keys2props(_emesaryDebugN);
    });
    emesary._transmitters.keys2props(_emesaryDebugN);
}

settimer(__setup,0);