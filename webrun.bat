@echo off
rem   webrun.bat -- simple browser launcher for FlightGear Help
rem   Norman Vine  -- nhv@laserplot.com

rem   This file should be in same directory that you started
rem   FlightGear from  --  uncomment appropriate line below

rem   you can use this if you are connected to the internet
rem   or your browser is set to connect automatically
rem set FG_HELP_DOC="http://www.flightgear.org/Docs/InstallGuide/getstart.html"

rem this is my local machines FGFS Help File  :-) NHV
rem set FG_HELP_DOC="http://127.0.0.1:9673/FGFS/Help"

rem or you can set HELP_DOC to a local file at a certain place
set FG_HELP_DOC="c:\flightgear\Docs\index.html"

rem choose your browser
rem "c:\Program Files\Netscape\Communicator\Program\netscape " %FG_HELP_DOC%
"C:\Program Files\Internet Explorer\iexplore"  %FG_HELP_DOC%
