 #---------------------------------------------------------------------------
 #
 #	Title                : EMESARY inter-object communication
 #
 #	File Type            : Implementation File
 #
 #	Description          : Provides generic inter-object communication. For an object to receive a message it
 #	                     : must first register with an instance of a Transmitter, and provide a Receive method
 #
 #	                     : To send a message use a Transmitter with an object. That's all there is to it.
 #  
 #  References           : http://chateau-logic.com/content/emesary-nasal-implementation-flightgear
#                        : http://www.chateau-logic.com/content/class-based-inter-object-communication
 #                       : http://chateau-logic.com/content/emesary-efficient-inter-object-communication-using-interfaces-and-inheritance
 #                       : http://chateau-logic.com/content/c-wpf-application-plumbing-using-emesary
 #
 #	Author               : Richard Harrison (richard@zaretto.com)
 #
 #	Creation Date        : 29 January 2016
 #
 #	Version              : 4.8
 #
 #  Copyright © 2016 Richard Harrison           Released under GPL V2
 #
 #---------------------------------------------------------------------------*/

# Transmitters send notifications to all recipients that are registered.
var Transmitter =
{
    ReceiptStatus_OK : 0,          # Processing completed successfully
    ReceiptStatus_Fail : 1,        # Processing resulted in at least one failure
    ReceiptStatus_Abort : 2,       # Fatal error, stop processing any further recipieints of this message. Implicitly failed.
    ReceiptStatus_Finished : 3,    # Definitive completion - do not send message to any further recipieints
    ReceiptStatus_NotProcessed : 4,# Return value when method doesn't process a message.
    ReceiptStatus_Pending : 5,     # Message sent with indeterminate return status as processing underway
    ReceiptStatus_PendingFinished : 6,# Message definitively handled, status indeterminate. The message will not be sent any further

    # create a new transmitter. shouldn't need many of these
    new: func(_ident)
    {
        var new_class = { parents: [Transmitter]};
        new_class.Recipients = [];
        new_class.Ident = _ident;
        return new_class;
    },

    # Add a recipient to receive notifications from this transmitter
    Register: func (recipient)
    {
        append(me.Recipients, recipient);
    },

    # Stops a recipient from receiving notifications from this transmitter.
    DeRegister: func(todelete_recipient)
    {
        var out_idx = 0;
        var element_deleted = 0;

        for (var idx = 0; idx < size(me.Recipients); idx += 1)
        {
            if (me.Recipients[idx] != todelete_recipient)
            {
                me.Recipients[out_idx] = me.Recipients[idx];
                out_idx = out_idx + 1;
            }
            else
                element_deleted = 1;
        }

        if (element_deleted)
            pop(me.Recipients);
    },

    RecipientCount: func
    {
        return size(me.Recipients);
    },

    PrintRecipients: func
    {
        print("Recpient list");
        for (var idx = 0; idx < size(me.Recipients); idx += 1)
            print("Recpient ",idx," ",me.Recipients[idx].Ident);
    },

    # Notify all registered recipients. Stop when receipt status of abort or finished are received.
    # The receipt status from this method will be 
    #  - OK > message handled
    #  - Fail > message not handled. A status of Abort from a recipient will result in our status
    #           being fail as Abort means that the message was not and cannot be handled, and
    #           allows for usages such as access controls.
    NotifyAll: func(message)
    {
        var return_status = Transmitter.ReceiptStatus_NotProcessed;
        foreach (var recipient; me.Recipients)
        {
            if (recipient.Active)
            {
                var rstat = recipient.Receive(message);

                if(rstat == Transmitter.ReceiptStatus_Fail)
                {
                    return_status = Transmitter.ReceiptStatus_Fail;
                }
                elsif(rstat == Transmitter.ReceiptStatus_Pending)
                {
                    return_status = Transmitter.ReceiptStatus_Pending;
                }
                elsif(rstat == Transmitter.ReceiptStatus_PendingFinished)
                {
                    return rstat;
                }
#               elsif(rstat == Transmitter.ReceiptStatus_NotProcessed)
#               {
#                   ;
#               }
                elsif(rstat == Transmitter.ReceiptStatus_OK)
                {
                    if (return_status == Transmitter.ReceiptStatus_NotProcessed)
                        return_status = rstat;
                }
                elsif(rstat == Transmitter.ReceiptStatus_Abort)
                {
                    return Transmitter.ReceiptStatus_Abort;
                }
                elsif(rstat == Transmitter.ReceiptStatus_Finished)
                {
                    return Transmitter.ReceiptStatus_OK;
                }
            }
        }
        return return_status;
    },

    # Returns true if a return value from NotifyAll is to be considered a failure.
    IsFailed: func(receiptStatus)
    {
        # Failed is either Fail or Abort.
        # NotProcessed isn't a failure because it hasn't been processed.
        if (receiptStatus == Transmitter.ReceiptStatus_Fail or receiptStatus == Transmitter.ReceiptStatus_Abort)
            return 1;
        return 0;
    }
};

#
#
# Base class for Notifications. By convention a Notification has a type and a value.
#   SubClasses can add extra properties or methods.
var Notification =
{
    new: func(_type, _value)
    {
        var new_class = { parents: [Notification]};
        new_class.Value = _value;
        new_class.Type = _type;
        return new_class;
    },
};

# Inherit or implement class with the same signatures to receive messages.
var Recipient =
{
    new: func(_ident)
    {
        var new_class = { parents: [Recipient]};
        if (_ident == nil or _ident == "")
        {
            _ident = id(new_class);
            print("ERROR: Ident required when creating a recipient, defaulting to ",_ident);
        }
        Recipient.construct(_ident, new_class);
    },
    construct: func(_ident, new_class)
    {
        new_class.Ident = _ident;
        new_class.Active = 1;
        new_class.Receive = func(notification)
        {
            # warning if required function not 
            print("Emesary Error: Receive function not implemented in recipient ",me.Ident);
            return Transmitter.ReceiptStatus_NotProcessed;
        };
        return new_class;
    },
};

#
# Instantiate a Global Transmitter, this is a convenience and a known starting point. Generally most classes will
# use this transmitters, however other transmitters can be created and merely use the global transmitter to discover each other
var GlobalTransmitter =  Transmitter.new("GlobalTransmitter");
