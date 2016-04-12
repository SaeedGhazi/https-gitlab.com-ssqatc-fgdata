 #---------------------------------------------------------------------------
 #
 #	Title                : EMESARY multiplayer bridge
 #
 #	File Type            : Implementation File
 #
 #	Description          : Bridges selected emesary notifications over MP
 #	                     : To send a message use a Transmitter with an object. That's all there is to it.
 #  
 #  References           : http://chateau-logic.com/content/emesary-nasal-implementation-flightgear
 #
 #	Author               : Richard Harrison (richard@zaretto.com)
 #
 #	Creation Date        : 04 April 2016
 #
 #	Version              : 4.8
 #
 #  Copyright © 2016 Richard Harrison           Released under GPL V2
 #
 #---------------------------------------------------------------------------*/

# Example of connecting an incoming and outgoing bridge (should reside inside an aircraft nasal file)
# 
# var routedNotifications = [notifications.TacticalNotification.new(nil)];
# var incomingBridge = emesary_mp_bridge.IncomingMPBridge.startMPBridge(routedNotifications);
# var outgoingBridge = emesary_mp_bridge.OutgoingMPBridge.new("F-15mp",routedNotifications);
#------------------------------------------------------------------
#
# NOTES: Aircraft do not need to have both an incoming and outgoing bridge, but it is usual.
#        Only the notifications specified will be routed via the bridge.
#        Once routed a message will by default not be re-rerouted again by the outgoing bridge.
#        Transmit frequency and message lifetime may need to be tuned.
#        IsDistinct messages must be absolute and self contained as a later message will 
#        supercede any earlier ones in the outgoing queue (possibly prior to receipt)
#        Use the message type and ident to identify distinct messages
#        The outgoing 'port' is a multiplay/generic/string index.
#  - ! is used as a seperator between the elements that are used to send the 
#       notification (typeid, sequence, notification)
#  -   There is an extra ! at the start of the message that is used to indicate protocol version.
#  - ; is used to seperate serialzied elemnts of the notification

# General Notes
#----------------------------------------------------------------------
# Outgoing messages are sent in a scheduled manner, usually once per
# second, and each message has a lifetime (to allow for propogation to
# all clients over UDP). Clients will ignore messages that they have
# already received (based on the sequence id).

# The incoming bridge will usually be created part of the aircraft
# model file; it is important to understand that each AI/MP model will
# have an incoming bridge as each element in /ai/models needs its own
# bridge to keep up with the incoming sequence id. This scheme may not
# work properly as it relies on the model being loaded which may only
# happen when visible so it may be necessary to track AI models in a
# seperate instantiatable incoming bridge manager.
#
# The outgoing bridge would usually be created within the aircraft loading Nasal.

var OutgoingMPBridge = 
{
    new: func(_ident, _notifications_to_bridge=nil, _mpidx=18, _root="", _transmitter=nil)
    {
        if (_transmitter == nil)
            _transmitter = emesary.GlobalTransmitter;

        print("OutgoingMPBridge created for "~_ident);
        var new_class = emesary.Recipient.new("OutgoingMPBridge "~_ident);

        new_class.MessageIndex = 100;
#        foreach (var notification; _notifications_to_bridge)
#        new_class.NotificationsToBridge = notification.new(;
        if(_notifications_to_bridge == nil)
            new_class.NotificationsToBridge = [];
        else
            new_class.NotificationsToBridge = _notifications_to_bridge;

        foreach(var n ; new_class.NotificationsToBridge)
          print("  bridge --> ",n.NotificationType);

        new_class.MPout = "";
        new_class.MPidx = _mpidx;
        new_class.MessageLifeTime = 10; # seconds
        new_class.OutgoingList = [];
        new_class.Transmitter = _transmitter;
        new_class.TransmitRequired=0;
        new_class.Transmitter.Register(new_class);
        new_class.MpVariable = _root~"sim/multiplay/generic/string["~new_class.MPidx~"]";
        new_class.TransmitterActive = 0;
        new_class.TransmitFrequencySeconds = 1;

        new_class.TransmitTimer = 
          maketimer(6, func
                    {
                        if(new_class.TransmitterActive)
                            new_class.Transmit();

                        new_class.TransmitTimer.restart(new_class.TransmitFrequencySeconds);
                    });

        new_class.Delete = func
          {
              if (me.Transmitter != nil) {
                  me.Transmitter.DeRegister(me);
                  me.Transmitter = nil;
              }
          };
        new_class.AddMessage = func(m)
        {
            append(me.NotificationsToBridge, m);
        };

        #-------------------------------------------
        # Receive override:
        new_class.Receive = func(notification)
        {
            if (notification.FromIncomingBridge)
                return emesary.Transmitter.ReceiptStatus_NotProcessed;

print("Receive ",notification.NotificationType," ",notification.Ident);
            for (var idx = 0; idx < size(me.NotificationsToBridge); idx += 1)
            {
                if(me.NotificationsToBridge[idx].NotificationType == notification.NotificationType)
                {
                    me.MessageIndex += 1;
                    notification.MessageExpiryTime = systime()+me.MessageLifeTime;
                    notification.BridgeMessageId = me.MessageIndex;
                    notification.BridgeMessageNotificationTypeId = idx;
                    #
                    # The message key is a composite of the type and ident to allow for multiple senders
                    # of the same message type.
                    notification.BridgeMessageNotificationTypeKey = notification.NotificationType~"."~notification.Ident;
#print("Received ",notification.BridgeMessageNotificationTypeKey," expire=",notification.MessageExpiryTime);
                    me.AddToOutgoing(notification);
                    return emesary.Transmitter.ReceiptStatus_Pending;
                }
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        new_class.AddToOutgoing = func(notification)
        {
            if (notification.IsDistinct)
            {
                for (var idx = 0; idx < size(me.OutgoingList); idx += 1)
                {
                    if(me.OutgoingList[idx].BridgeMessageNotificationTypeKey == notification.BridgeMessageNotificationTypeKey)
                    {
#print("Update ",me.OutgoingList[idx].BridgeMessageNotificationTypeKey);
                        me.OutgoingList[idx]= notification;
                        me.TransmitterActive = size(me.OutgoingList);
                        return;
                    }
                }
            }
#print("Added ",notification.BridgeMessageNotificationTypeKey);
            append(me.OutgoingList, notification);
            me.TransmitterActive = size(me.OutgoingList);
        };
        new_class.Transmit = func
        {
            var outgoing = "";
            var cur_time=systime();
            var out_idx = 0;
            for (var idx = 0; idx < size(me.OutgoingList); idx += 1)
            {
                var sect = "";
                var notification = me.OutgoingList[idx];
                if (notification.MessageExpiryTime > cur_time)
                {
                    var encval="";
                    var first_time = 1;
                    var eidx = 0;
                    foreach(var p ; notification.bridgeProperties())
                    {
                        if (encval != "")
                            encval = encval ~ ";";
                        encval = encval ~ p.getValue();
#print("Encode ",eidx,"=",encval);
                        eidx += 1;
                    }
                    sect = sprintf("!%d!%d!%s",notification.BridgeMessageId, notification.BridgeMessageNotificationTypeId, encval);
                    outgoing = outgoing~sect;
                    me.OutgoingList[out_idx] = me.OutgoingList[idx];
#                    print("xmit ",idx," out=",out_idx);
                    out_idx += 1;
                }
#                else
#                    printf("expired ",idx,out_idx);
            }
            me.TransmitterActive = size(me.OutgoingList);
            var del_count = size(me.OutgoingList)-out_idx;
            setprop(me.MpVariable,outgoing);
#            print("Set ",me.MpVariable," to ",outgoing);
#            print("outgoingList : ",out_idx, " ", size(me.OutgoingList), " del count=",del_count);
            for(var del_i=0; del_i < del_count; del_i += 1)
                pop(me.OutgoingList);
        };
        new_class.TransmitTimer.restart(new_class.TransmitFrequencySeconds);
        return new_class;
    },
};

#
#
# one of these for each model instantiated in the model XML - it will
# route messages to 
var IncomingMPBridge = 
{
    new: func(_ident, _notifications_to_bridge=nil, _mpidx=18, _transmitter=nil)
    {
        if (_transmitter == nil)
            _transmitter = emesary.GlobalTransmitter;

        print("IncominggMPBridge created for "~_ident);

        var new_class = emesary.Transmitter.new("IncominggMPBridge "~_ident);

        new_class.IncomingMessageIndex = 100;
        if(_notifications_to_bridge == nil)
            new_class.NotificationsToBridge = [];
        else
            new_class.NotificationsToBridge = _notifications_to_bridge;

        new_class.MPout = "";
        new_class.MPidx = _mpidx;
        new_class.MessageLifeTime = 10; # seconds
        new_class.OutgoingList = [];
        new_class.Transmitter = _transmitter;
        new_class.MpVariable = "";

        new_class.Connect = func(_root)
        {
            me.MpVariable = _root~"sim/multiplay/generic/string["~new_class.MPidx~"]";
            me.Callsign = getprop(_root~"callsign");
            print("bridge ",me.MpVariable, " callsign ",me.Callsign);
            setlistener(me.MpVariable, func(v)
                        {
                            me.ProcessIncoming(v.getValue());
                        });
        };

        new_class.AddMessage = func(m)
        {
            append(me.NotificationsToBridge, m);
        };

        new_class.Remove = func
        {
            print("Emesary IncomingMPBridge Remove() ",me.Ident);
            me.Transmitter.DeRegister(me);
        };

        #-------------------------------------------
# Receive override:
        new_class.ProcessIncoming = func(encoded_val)
        {
            if (encoded_val == "")
              return;
#            print("ProcessIncoming ", encoded_val);
            var encoded_notifications = split(";", encoded_val);
            for (var idx = 0; idx < size(encoded_notifications); idx += 1)
            {
# get the message parts
                var encoded_notification = split("!", encoded_val);
                if (size(encoded_notification) < 4)
                    print("Error: emesary.IncomingBridge.ProcessIncoming bad msg ",encoded_val);
                else
                {
                    var msg_idx = encoded_notification[1];
                    var msg_type_id = encoded_notification[2];
                    if (msg_type_id >= size(me.NotificationsToBridge))
                    {
                        print("Error: emesary.IncomingBridge.ProcessIncoming invalid type_id ",msg_type_id);
                    }
                    else
                    {
                        var msg = me.NotificationsToBridge[msg_type_id];
                        var msg_notify = encoded_notification[3];
                        print("received idx=",msg_idx," ",msg_type_id,":",msg.NotificationType);
                        if(msg_idx <= me.IncomingMessageIndex)
                            print("         **Already processed");
                        else
                          {
                              # raise notification
                              var bridged_notification = msg; #emesary.Notification.new(msg.NotificationType,"BridgedMessage");
                              # populate fields
                              var bridgedProperties = msg.bridgeProperties();
                              var encvals=split(";", msg_notify);

                              for (var bpi = 0; bpi < size(encvals); bpi += 1) {
                                  if (bpi < size(bridgedProperties)) {
                                      var bp = bridgedProperties[bpi];
                                      print("encval ",bpi,"=",encvals[bpi]);
                                      if (encvals[bpi] != ";" and encvals[bpi] != "") {
                                          var bp = bridgedProperties[bpi];
                                          bp.setValue(encvals[bpi]);
                                      }
                                      #else
                                      #print("EMPTY encoded ",bpi," empty");
                                  } else
                                    print("Error: emesary.IncomingBridge.ProcessIncoming: supplementary encoded value at",bpi);
                              }
                              if (bridged_notification.Ident == "none")
                                  bridged_notification.Ident = "mp-bridge";
                              bridged_notification.FromIncomingBridge = 1;
                              bridged_notification.Callsign = me.Callsign;
                              me.Transmitter.NotifyAll(bridged_notification);
                              me.IncomingMessageIndex = msg_idx;
                          }
                    }
                }
            }
        }
        foreach(var n; new_class.NotificationsToBridge)
        {
            print("IncomingBridge: ",n.NotificationType);
        }
        return new_class;
    },
    #
    # Each multiplayer object will have its own incoming bridge. This is necessary to allow message ID
    # tracking (as the bridge knows which messages have been already processed)
    # Whenever a client connects over MP a new bridge is instantiated
    startMPBridge : func(notification_list)
    {
        var incomingBridgeList = {};

        #
        # Create bridge whenever a client connects
        #
        setlistener("/ai/models/model-added", func(v)
        {
            # Model added will be eg: /ai[0]/models[0]/multiplayer[0]
            var path = v.getValue();

            print("Model added ",path);
            # Ensure we only handle multiplayer elements
            if (find("/multiplayer",path) > 0)
            {
                var callsign = getprop(path~"/callsign");
                print("Creating Emesary MPBridge for ",callsign);
                if (callsign == "" or callsign == nil)
                    callsign = path;

                var incomingBridge = emesary_mp_bridge.IncomingMPBridge.new(callsign~"mp", notification_list, 18);

                incomingBridge.Connect(path~"/");
                incomingBridgeList[path] = incomingBridge;
            }
        });

        #
        # when a client disconnects remove the associated bridge.
        #
        setlistener("/ai/models/model-removed", func(v){
                        print("Model removed ",v.getValue());
            var path = v.getValue();
                        var bridge = incomingBridgeList[path];
                        if (bridge != nil)
                        {
                            bridge.Remove();
                            incomingBridgeList[path]=nil;
                        }
                    });
    },
};
