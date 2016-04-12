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

var GeoEventNotification = 
{
    new: func(_ident="none", _name="", _kind=0, _secondary_kind=0)
    {
        var new_class = emesary.Notification.new("GeoEventNotification", _ident);

        new_class.Kind = _kind;
        new_class.Name = _name;
        new_class.SecondaryKind = _secondary_kind;
        new_class.Position = geo.aircraft_position();

        new_class.Heading = getprop("/orientation/heading");
        new_class.u_fps = getprop("/velocities/uBody-fps");
        new_class.v_fps = getprop("/velocities/vBody-fps");
        new_class.w_fps = getprop("/velocities/wBody-fps");
        new_class.IsDistinct = 0;
        new_class.Callsign = nil; # populated automatically by the incoming bridge when routed

        new_class.bridgeProperties = func
        {
            return 
            [ 
#             {
#            getValue:func{return emesary.TransferCoord.encode(new_class.Position);},
#            setValue:func(v){new_class.Position=emesary.TransferCoord.decode(v);}, 
#             },
#             {
#            getValue:func{return emesary.TransferString.encode(new_class.Name);},
#            setValue:func(v){new_class.Name=emesary.TransferString.decode(v);}, 
#             },
             {
            getValue:func{return emesary.TransferByte.encode(new_class.Kind);},
            setValue:func(v){new_class.Kind=emesary.TransferByte.decode(v);}, 
             },
             {
            getValue:func{return emesary.TransferByte.encode(new_class.SecondaryKind);},
            setValue:func(v){new_class.SecondaryKind=emesary.TransferByte.decode(v);}, 
             },
#             {
#            getValue:func{return emesary.TransferDouble.encode(new_class.u_fps);},
#            setValue:func(v){new_class.u_fps=emesary.TransferDouble.decode(v);}, 
#             },
#             {
#            getValue:func{return emesary.TransferDouble.encode(new_class.v_fps);},
#            setValue:func(v){new_class.v_fps=emesary.TransferDouble.decode(v);}, 
#             },
#             {
#            getValue:func{return emesary.TransferDouble.encode(new_class.w_fps);},
#            setValue:func(v){new_class.w_fps=emesary.TransferDouble.decode(v);}, 
#             },
            ];
          };
        return new_class;
    },
};
#
# Defined kinds: 
#    1 - Created
#    2 - Moved
#    3 - Deleted
#    4 - 
# ----
# Secondary kind (8 bits)
# using the first 4 bits as the classification and the second 4 bits as the sub-classification
#-----------
# Type 0000 : Cargo
#   0 0000 0000 - Vehicle 
#   1 0000 0001 - Person 
#   2 0000 0010 - 10 kg Item
#   3 0000 0011 - 20 kg Item
#   4 0000 0100 - 30 kg Item
#   5 0000 0101 - 40 kg Item
#   6 0000 0110 - 50 kg Item
#   7 0000 0111 - 100 kg Item
#   8 0000 1000 - 200 kg Item
#   9 0000 1001 - 500 kg Item
#  10 0000 1010 - 1000 kg Item
#  11 0000 1011 - Chaff
#  12 0000 1100 - Flares
#  13 0000 1101 - Water (fire fighting)
#  14 0000 1110 - 
#  15 0000 1111 - Morris Marina
#--------
# Type 0001 : Self propelled
#  16 0001 0000 - X-2
#  17 0001 0001 - X-15
#  18 0001 0010 - X-24
#  19 0001 0011 - 
#  20 0001 0100 - 
#  21 0001 0101 - 
#  22 0001 0110 - 
#  23 0001 0111 - 
#  24 0001 1000 - 
#  25 0001 1001 - 
#  26 0001 1010 - 
#  27 0001 1011 - 
#  28 0001 1100 - 
#  29 0001 1101 - 
#  30 0001 1110 - 
#  31 0001 1111 - 
#--------
# Type 0010 : Aircraft Damage (e.g space shuttle re-entry or during launch)
#  32 0010 0000 - Engine 1
#  33 0010 0001 - Engine 2
#  34 0010 0010 - Engine 3
#  35 0010 0011 - Engine 4
#  36 0010 0100 - Engine 5
#  37 0010 0101 - Engine 6
#  38 0010 0110 - Engine 7
#  39 0010 0111 - Engine 8
#  40 0010 1000 - Vertical Tail Right
#  41 0010 1001 - Left Wing
#  42 0010 1010 - Right Wing
#  43 0010 1011 - Horizontal Tail Left
#  44 0010 1100 - Horizontal Tail Right
#  45 0010 1101 - Fuselage Front
#  46 0010 1110 - Fuselage Center
#  47 0010 1111 - Fuselage Back
#--------
# Type 0011 : 
#  48 0011 0000 - 
#  49 0011 0001 - 
#  50 0011 0010 - 
#  51 0011 0011 - 
#  52 0011 0100 - 
#  53 0011 0101 - 
#  54 0011 0110 - 
#  55 0011 0111 - 
#  56 0011 1000 - 
#  57 0011 1001 - 
#  58 0011 1010 - 
#  59 0011 1011 - 
#  60 0011 1100 - 
#  61 0011 1101 - 
#  62 0011 1110 - 
#  63 0011 1111 - 
#--------
# Type 0100 : 
#  64 0100 0000 - 
#  65 0100 0001 - 
#  66 0100 0010 - 
#  67 0100 0011 - 
#  68 0100 0100 - 
#  69 0100 0101 - 
#  70 0100 0110 - 
#  71 0100 0111 - 
#  72 0100 1000 - 
#  73 0100 1001 - 
#  74 0100 1010 - 
#  75 0100 1011 - 
#  76 0100 1100 - 
#  77 0100 1101 - 
#  78 0100 1110 - 
#  79 0100 1111 - 
#--------
# Type 0101 : Reserved for cooperating aircraft usage.
#  80 0101 0000 - Implementation defined
#  81 0101 0001 - Implementation defined
#  82 0101 0010 - Implementation defined
#  83 0101 0011 - Implementation defined
#  84 0101 0100 - Implementation defined
#  85 0101 0101 - Implementation defined
#  86 0101 0110 - Implementation defined
#  87 0101 0111 - Implementation defined
#  88 0101 1000 - Implementation defined
#  89 0101 1001 - Implementation defined
#  90 0101 1010 - Implementation defined
#  91 0101 1011 - Implementation defined
#  92 0101 1100 - Implementation defined
#  93 0101 1101 - Implementation defined
#  94 0101 1110 - Implementation defined
#  95 0101 1111 - Implementation defined
#--------
# Type 0110 : 
#  96 0110 0000 - 
#  97 0110 0001 - 
#  98 0110 0010 - 
#  99 0110 0011 - 
# 100 0110 0100 - 
# 101 0110 0101 - 
# 102 0110 0110 - 
# 103 0110 0111 - 
# 104 0110 1000 - 
# 105 0110 1001 - 
# 106 0110 1010 - 
# 107 0110 1011 - 
# 108 0110 1100 - 
# 109 0110 1101 - 
# 110 0110 1110 - 
# 111 0110 1111 - 
#--------
# Type 0111 : 
# 112 0111 0000 - 
# 113 0111 0001 - 
# 114 0111 0010 - 
# 115 0111 0011 - 
# 116 0111 0100 - 
# 117 0111 0101 - 
# 118 0111 0110 - 
# 119 0111 0111 - 
# 120 0111 1000 - 
# 121 0111 1001 - 
# 122 0111 1010 - 
# 123 0111 1011 - 
# 124 0111 1100 - 
# 125 0111 1101 - 
# 126 0111 1110 - 
# 127 0111 1111 - 
#--------
# Type 1000 : 
# 128 1000 0000 - 
# 129 1000 0001 - 
# 130 1000 0010 - 
# 131 1000 0011 - 
# 132 1000 0100 - 
# 133 1000 0101 - 
# 134 1000 0110 - 
# 135 1000 0111 - 
# 136 1000 1000 - 
# 137 1000 1001 - 
# 138 1000 1010 - 
# 139 1000 1011 - 
# 140 1000 1100 - 
# 141 1000 1101 - 
# 142 1000 1110 - 
# 143 1000 1111 - 
#--------
# Type 1001 : 
# 144 1001 0000 - 
# 145 1001 0001 - 
# 146 1001 0010 - 
# 147 1001 0011 - 
# 148 1001 0100 - 
# 149 1001 0101 - 
# 150 1001 0110 - 
# 151 1001 0111 - 
# 152 1001 1000 - 
# 153 1001 1001 - 
# 154 1001 1010 - 
# 155 1001 1011 - 
# 156 1001 1100 - 
# 157 1001 1101 - 
# 158 1001 1110 - 
# 159 1001 1111 - 
#--------
# Type 1010 : 
# 160 1010 0000 - 
# 161 1010 0001 - 
# 162 1010 0010 - 
# 163 1010 0011 - 
# 164 1010 0100 - 
# 165 1010 0101 - 
# 166 1010 0110 - 
# 167 1010 0111 - 
# 168 1010 1000 - 
# 169 1010 1001 - 
# 170 1010 1010 - 
# 171 1010 1011 - 
# 172 1010 1100 - 
# 173 1010 1101 - 
# 174 1010 1110 - 
# 175 1010 1111 - 
#--------
# Type 1011 : 
# 176 1011 0000 - 
# 177 1011 0001 - 
# 178 1011 0010 - 
# 179 1011 0011 - 
# 180 1011 0100 - 
# 181 1011 0101 - 
# 182 1011 0110 - 
# 183 1011 0111 - 
# 184 1011 1000 - 
# 185 1011 1001 - 
# 186 1011 1010 - 
# 187 1011 1011 - 
# 188 1011 1100 - 
# 189 1011 1101 - 
# 190 1011 1110 - 
# 191 1011 1111 - 
#--------
# Type 1100 : 
# 192 1100 0000 - 
# 193 1100 0001 - 
# 194 1100 0010 - 
# 195 1100 0011 - 
# 196 1100 0100 - 
# 197 1100 0101 - 
# 198 1100 0110 - 
# 199 1100 0111 - 
# 200 1100 1000 - 
# 201 1100 1001 - 
# 202 1100 1010 - 
# 203 1100 1011 - 
# 204 1100 1100 - 
# 205 1100 1101 - 
# 206 1100 1110 - 
# 207 1100 1111 - 
#--------
# Type 1101 : 
# 208 1101 0000 - 
# 209 1101 0001 - 
# 210 1101 0010 - 
# 211 1101 0011 - 
# 212 1101 0100 - 
# 213 1101 0101 - 
# 214 1101 0110 - 
# 215 1101 0111 - 
# 216 1101 1000 - 
# 217 1101 1001 - 
# 218 1101 1010 - 
# 219 1101 1011 - 
# 220 1101 1100 - 
# 221 1101 1101 - 
# 222 1101 1110 - 
# 223 1101 1111 - 
#--------
# Type 1110 : 
# 224 1110 0000 - 
# 225 1110 0001 - 
# 226 1110 0010 - 
# 227 1110 0011 - 
# 228 1110 0100 - 
# 229 1110 0101 - 
# 230 1110 0110 - 
# 231 1110 0111 - 
# 232 1110 1000 - 
# 233 1110 1001 - 
# 234 1110 1010 - 
# 235 1110 1011 - 
# 236 1110 1100 - 
# 237 1110 1101 - 
# 238 1110 1110 - 
# 239 1110 1111 - 
#--------
# Type 1111 : 
# 240 1111 0000 - 
# 241 1111 0001 - 
# 242 1111 0010 - 
# 243 1111 0011 - 
# 244 1111 0100 - 
# 245 1111 0101 - 
# 246 1111 0110 - 
# 247 1111 0111 - 
# 248 1111 1000 - 
# 249 1111 1001 - 
# 250 1111 1010 - 
# 251 1111 1011 - 
# 252 1111 1100 - 
# 253 1111 1101 - 
# 254 1111 1110 - 
# 255 1111 1111 - 
