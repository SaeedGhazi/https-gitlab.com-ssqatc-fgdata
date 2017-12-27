# Constants to define the display area, for placement of elements.  We
# could try to do something with a layout, but the position and size of
# elements is fixed.  Can't be member variables of MFD as they are
# self-referential.

var DISPLAY = { WIDTH : 1024, HEIGHT  : 768 };
var HEADER_HEIGHT = 56;
var FOOTER_HEIGHT = 25;
var EIS_WIDTH     = 150;

# Size of data display on the right hand side of the MFD
var DATA_DISPLAY = {
  WIDTH  : 300,
  HEIGHT : DISPLAY.HEIGHT - HEADER_HEIGHT - FOOTER_HEIGHT,
  X      : DISPLAY.WIDTH  - 300,
  Y      : HEADER_HEIGHT,
};

# Map dimensions when the data display is not present
var MAP_FULL =  {
  CENTER : { X : ((DISPLAY.WIDTH - EIS_WIDTH) / 2 + EIS_WIDTH),
             Y : ((DISPLAY.HEIGHT - HEADER_HEIGHT - FOOTER_HEIGHT) / 2 + HEADER_HEIGHT), },
  X      : EIS_WIDTH,
  Y      : HEADER_HEIGHT,
  WIDTH  : DISPLAY.WIDTH - EIS_WIDTH,
  HEIGHT : DISPLAY.HEIGHT - HEADER_HEIGHT - FOOTER_HEIGHT,
};

# Map dimensions when the data display is present
var MAP_PARTIAL = {
  X      : EIS_WIDTH,
  Y      : HEADER_HEIGHT,
  WIDTH  : DISPLAY.WIDTH - EIS_WIDTH - DATA_DISPLAY.WIDTH,
  HEIGHT : DISPLAY.HEIGHT - HEADER_HEIGHT - FOOTER_HEIGHT,
  CENTER : { X : ((DISPLAY.WIDTH - EIS_WIDTH - DATA_DISPLAY.WIDTH) / 2 + EIS_WIDTH),
             Y : ((DISPLAY.HEIGHT - HEADER_HEIGHT - FOOTER_HEIGHT) / 2 + HEADER_HEIGHT), },
};

# When the CRSR is selecting fields, this is the period for changing the
# cursor color between normal and highlight (defined below)
# Constants for the hard-buttons on the fascia
FASCIA = {
  NAV_VOL : 0,
  NAV_VOL_TOGGLE : 1,
  NAV_FREQ_TRANSFER :2,
  NAV_OUTER : 3,
  NAV_INNER : 4,
  NAV_TOGGLE : 5,
  HEADING : 6,
  HEADING_PRESS : 7,

  # Joystick
  RANGE : 8,
  JOYSTICK_HORIZONTAL : 9,
  JOYSTICK_VERTICAL : 10,

  #CRS/BARO
  BARO : 11,
  CRS : 12,
  CRS_CENTER : 13,

  COM_OUTER : 14,
  COM_INNER : 15,
  COM_TOGGLE : 16,

  COM_FREQ_TRANSFER : 17,
  COM_FREQ_TRANSFER_HOLD :18,  # Auto-tunes to 121.2 when pressed for 2 seconds

  COM_VOL: 19,
  COM_VOL_TOGGLE: 20,

  DTO : 21,
  FPL : 22,
  CLR : 23,
  CLR_HOLD: 24, # Holding the CLR button for 2 seconds on the MFD displays the Nav Map

  FMS_OUTER : 25,
  FMS_INNER : 26,
  FMS_CRSR  : 27,

  MENU : 28,
  PROC : 29,
  ENT : 30,

  ALT_OUTER : 31,
  ALT_INNER : 32,

  # Autopilot controls
  AP  : 33,
  HDG : 34,
  NAV : 35,
  APR : 36,
  VS  : 37,
  FLC : 38,
  FD  : 39,
  ALT : 40,
  VNV : 41,
  BC  : 42,
  NOSE_UP : 43,
  NOSE_DOWN : 44,

};

var SURFACE_TYPES = {
  1 : "HARD SURFACE",  # Asphalt
  2 : "HARD SURFACE", # Concrete
  3 : "TURF",
  4 : "DIRT",
  5 : "GRAVEL",
  #  Helipads
  6 : "HARD SURFACE",  # Asphalt
  7 : "HARD SURFACE", # Concrete
  8 : "TURF",
  9 : "DIRT",
  0 : "GRAVEL",
};
