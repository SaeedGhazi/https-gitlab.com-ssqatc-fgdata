Document updated March 18 1999
==============================

Change log:
-----------

Mar 18 1999 version 1.22:
-New codes for runway markings
-Runway surface codes changed

Mar 17 1999:
-Runway Stopways added
-Displaced runway thresholds added
-Approach light codes changed

General
-------
This document describes the new prototype data files for X-Plane.  The files are:
default.apt (airports and runways)
default.nav (VORs, NDBs and DME)
default.ils (ILS)
default.fix (IFR intersections)

The data in the example files is _not_ limited to 15 per lat lon square - the files are still similar in size to the existing ones, despite much new data.

Contact me with any questions at robin@cpwd.com.



Contents of each file are:

========
Airports
========
AptType
AptCode
AptLat
AptLon
AptElev
AptUse (Civil/military)
AptTwr
AptBdg (Y=Use X-Plane default buildings)
AptName

Runways
=======
RwyType
RwyNo
RwyLat
RwyLon
RwyHdg (note new precision)
RwyLen
RwyWidth
RwySfc
RwyMrk
RwyEdgeLx
RwyCLLx
RwyGuard (aka wig wags)
RwyTDZLxA (First runway end - A ...)
RwyREILA
RwyGSIndA
RwyAppLxA
RwyDispThrA
RwyStopwayA
RwyTDZLxB (First runway end - B ...)
RwyREILB
RwyGSIndB
RwyAppLxB
RwyDispThrB
RwyStopwayB

Fields are in two different types of rows.  The airport data is categorised by AptType as:
A = Airport
S = Seaplane base (note - these should have different airport beacon colours - see AIM).

Apt Use is C (Civil), M (Military).

Runways are identified by a leading R as RwyType (and H may be used later for Helipads).  There are no runways for Seaplane Bases (though if you want to display bobbing bouys in the waves I can create such data).

Note that the total runway length includes displaced thresholds but excludes stopways.

RwySfc codes:
-------------
X-Plane	Master database detail
-------	----------------------
A	Asphalt
A	Treated
C	Concrete
D	Dirt
D	Sand
G	Coral
G	Gravel
M	Mat
T	Turf/Grass
W	Water (for those future seaplane base runways...)
X	[Unknown]
X	Aluminium
X	Brick
X	Metal
X	Neoprene
X	Wood

RwyMrk codes (runway markings)
------------
N	None
V	Visual
R	Non-precision
P	Precision	
B	Buoys (water runways?)

RwyEdgeLx codes:
----------------
H	High
L	Low
M	Medium
N	[None]
M	Non-std

RwyGSInd codes:
---------------
V	VASI
P	PAPI
N	None

RwyAppLx codes:
---------------
X-Plane	Abbrev	AppLxName
-------	------	---------
N	[None]	No system
N	[NSTD]	Non-standard
A	ALS	Approach light system (assumed white lights)
B	ALSF-I	Approach light system with sequenced flashing lights (Rabbit)
C	ALSF-II	Approach light system with sequenced flashing lights (Rabbit) and red side bar lights the last 1000'
L	LDIN	Sequenced flashing lead-in lights (Rabbit) only
M	MALS	Medium intensity approach light system
N	MALSF	Medium intensity approach light system with sequenced flashing lights (Rabbit)
O	MALSR	Medium intensity approach light system with runway alignment indicator lights (RAIL)
P	MILOVRN	Something military, I suppose
N	NSTD	Non standard
Q	ODALS	Omni-directional approach light system
R	RAIL	Runway alignment indicator lights (icw other systems) (RAIL)
S	SALS	Short approach light system
T	SALSF	Short approach light system with sequenced flashing lights (Rabbit)
U	SSALF	Simplified short approach light system with sequenced flashing lights (Rabbit)
V	SSALR	Simplified short approach light system with runway alignment indicator lights (RAIL)
W	SSALS	Simplified short approach light system
D	CAL	Calvert (British) - a jolly good system
E	CAL-II	Calvert (British) - Cat II and II



========
Nav Aids
========

ExptDataCode
------------
NavType
NavLat
NavLon
NavElev
NavFreq
NavRange (in NM)
NavDME (indicates if co-located DME)
NavIdent
NavName

NavType codes:
--------------
X-Plane	Master database detail
-------	----------------------
N	Marine NDB
N	NDB
D	TACAN (only DME part needed)
V	VOR
V	VORTAC
D	DME
N	LOM



===
ILS
===

ExptDataCode
------------
ILSType
ILSTypeName
ILSAptCode
ILSRwyNo
LocFreq
LocIdent
LocHdg (note new precision)
LocLat
LocLon
GSElev
GSAngle
GSLat
GSLon
DMELat
DMELon
OMLat
OMLon
MMLat
MMLon
IMLat
IMLon

Codes for ILS type:
-------------------
I	ILS	Instrument Landing System
M	MLS	Microwave Landing System
D	LDA	Localiser Directional Aid
I	LOCGS	Localiser - Glideslope
L	LOC	Localiser
S	SDF	Simplified Directional Facility
I	IGS	Instrument Guidance System


=====
Fixes
=====

FixName
FixLat
FixLon

Easy - few changes here.
