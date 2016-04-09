 #---------------------------------------------------------------------------
 #
 #	Title                : EMESARY flightgear standardised notifications
 #
 #	File Type            : Implementation File
 #
 #	Description          : Messages that are applicable across all models and do not specifically relate to a single sysmte
 #	                     : - mostly needed when using the mutiplayer bridge
 #
 #	Author               : Richard Harrison (richard@zaretto.com)
 #
 #	Creation Date        : 06 April 2016
 #
 #	Version              : 4.8
 #
 #  Copyright © 2016 Richard Harrison           Released under GPL V2
 #
 #---------------------------------------------------------------------------*/

var TacticalNotification = 
{
    new: func(_ident=nil, _kind=0)
    {
        if(_ident==nil)
            _ident="none";

        var new_class = emesary.Notification.new("TacticalNotification", _ident);

        new_class.Kind = _kind;
        new_class.Position=geo.aircraft_position();
        new_class.IsDistinct = 0;

        new_class.bridgeProperties = func
        {
            return 
            [ 
             {
            getValue:func{return emesary.TransferCoord.encode(new_class.Position);},
            setValue:func(v){new_class.Position=emesary.TransferCoord.decode(v);}, 
             },
             {
            getValue:func{return emesary.TransferByte.encode(new_class.Kind);},
            setValue:func(v){new_class.Kind=emesary.TransferByte.decode(v);}, 
             },
            ];
          };
        return new_class;
    },
};
