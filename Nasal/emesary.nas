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

var __emesaryUniqueId = 14; # 0-15 are reserved, this way the global transmitter will be 15.

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
        __emesaryUniqueId += 1;
        new_class.UniqueId = __emesaryUniqueId;
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
        print("Emesary: Recipient list for ",me.Ident,"(",me.UniqueId,")");
        for (var idx = 0; idx < size(me.Recipients); idx += 1)
            print("Emesary: Recipient[",idx,"] ",me.Recipients[idx].Ident," (",me.Recipients[idx].UniqueId,")");
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
            if (recipient.RecipientActive)
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
# Properties:
# Ident : Generic message identity. Can be an ident, or for simple messages a value that needs transmitting.
# NotificationType  : Notification Type
# IsDistinct : non zero if this message supercedes previous messages of this type.
#              Distinct messages are usually sent often and self contained
#              (i.e. no relative state changes such as toggle value)
#              Messages that indicate an event (such as after a pilot action)
#              will usually be non-distinct. So an example would be gear/up down
#              or ATC acknowledgements that all need to be transmitted
# The IsDistinct is important for any messages that are bridged over MP as
# only the most recently sent distinct message will be transmitted over MP
var Notification =
{
    new: func(_type, _ident)
    {
        var new_class = { parents: [Notification]};
        new_class.Ident = _ident;
        new_class.NotificationType = _type;
        new_class.IsDistinct = 1;
        new_class.FromIncomingBridge = 0;
        new_class.Callsign = nil;
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
            print("Emesary Error: Ident required when creating a recipient, defaulting to ",_ident);
        }
        Recipient.construct(_ident, new_class);
    },
    construct: func(_ident, new_class)
    {
        new_class.Ident = _ident;
        new_class.RecipientActive = 1;
        __emesaryUniqueId += 1;
        new_class.UniqueId = __emesaryUniqueId;
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

#
#
# This is basically a base64 like encode except we just use alphanumerics which gives us a base62 encode.
var BinaryAsciiTransfer = 
{
    alphabet : "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    encodeInt : func(num)
    {
        if (num == 0)
            return substr(BinaryAsciiTransfer.alphabet,0,1);
        
        var arr="";
        var _base = size(BinaryAsciiTransfer.alphabet);
        while(num > 0)
        {
            var rem = math.mod(num,_base);
            num = int(num / _base);
            arr =substr(BinaryAsciiTransfer.alphabet, rem,1) ~ arr;
        }
        return arr;
    },
    decodeInt : func(v)
    {
        var _base = size(BinaryAsciiTransfer.alphabet);
        var power = size(v) - 1;
        var num = 0;

        var idx = 0;
        for(var idx=0; idx < size(v); idx += 1)
        {
            var c = substr(v,idx,1);
            var cc = find(c,BinaryAsciiTransfer.alphabet);
            if (cc < 0)
                return nil;
            num += int(cc * math.exp(math.ln(_base) * power));
          
            power -= 1;
        }
        return num;
    }
};

var TransferCoord = 
{
# 28 bits = 268435456 (268 435 456)
# to transfer lat lon (360 degree range) 268435456/360=745654
# we could use different factors for lat lon due to the differing range, however
# this will be fine.
 encode : func(v)
 {
     return BinaryAsciiTransfer.encodeInt( (v.lat()+90)*745654) ~ "." ~
       BinaryAsciiTransfer.encodeInt((v.lon()+180)*745654) ~ "." ~
         BinaryAsciiTransfer.encodeInt((v.alt()+1400)*100);
 }
 ,
 decode : func(v)
 {
     var parts = split(".", v);
     var lat = (BinaryAsciiTransfer.decodeInt(parts[0]) / 745654)-90;
     var lon = (BinaryAsciiTransfer.decodeInt(parts[1]) / 745654)-180;
     var alt = (BinaryAsciiTransfer.decodeInt(parts[2]) / 100)-1400;
     return geo.Coord.new().set_latlon(lat, lon).set_alt(alt);
 }
};

var TransferString = 
{
#
# just to pack a valid range and keep the lower and very upper control codes for seperators
# that way we don't need to do anything special to encode the string.
    getalphanumericchar : func(v)
    {
        if (find(v,"-./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_abcdefghijklmnopqrstuvwxyz") > 0)
          return v;
        return nil;
    },
    encode : func(v)
    {
        var l = size(v);
        if (l > 16)
            l = 16;
        var rv = BinaryAsciiTransfer.encodeInt(l);

        for(var ii = 0; ii < l; ii = ii + 1)
        {
            ev = TransferString.getalphanumericchar(substr(v,ii,1));
            if (ev != nil)
                rv = rv ~ ev;
        }
        return rv;
    },
    decode : func(v)
    {
        var l = BinaryAsciiTransfer.decodeInt(v);
        var rv = substr(v,1,l-1);
        return rv;
    }
};

var TransferByte = 
{
    encode : func(v)
    {
        return BinaryAsciiTransfer.encodeInt(v);
    },
    decode : func(v)
    {
        return BinaryAsciiTransfer.decodeInt(v);
    }
};

var TransferInt = 
{
    encode : func(v)
    {
        return BinaryAsciiTransfer.encodeInt(v);
    },
    decode : func(v)
    {
        return BinaryAsciiTransfer.decodeInt(v);
    }
};

var TransferFixedDouble = 
{
    encode : func(v, precision=4)
    {
        return BinaryAsciiTransfer.encodeInt(v*math.exp(math.ln(10) * precision));
    },
    decode : func(v, precision=4)
    {
        return BinaryAsciiTransfer.decodeInt(v)/math.exp(math.ln(10) * precision);
    }
};
