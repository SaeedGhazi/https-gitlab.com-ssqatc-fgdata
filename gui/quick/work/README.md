## Convert PUI Dialog to QML Dialog

Copyright (C) 2019  Scott Giese (xDraconian) scttgs0@gmail.com\
Released under GPL version 2.0 or higher - Refer to Copying file.

### Purpose:
This is an XSLT transformation to facilitate the conversion of PUI Dialog files to QML.

### Supported Platform:
Any browser supporting XSLT 1.0

### Prerequisites:
	Qt 5
		https://www.qt.io/download/

	Python 3
		https://www.python.org/


### Usage:
<i>We'll use dialog exit.xml -> exit.qml as an example.</i>

	fgdata/gui/quick/work = folder in which to perform the transformation\

Copy a PUI xml dialog file into the **work** folder

    cp  gui/dialogs/exit.xml  gui/quick/work/

Within the **work** folder, edit the xml file to add the XSLT reference on the second line...

    <?xml version="1.0"?>
    <?xml-stylesheet type="application/xslt+xml" href="dialog2qt.xsl"?>
	...

    <?xml version="1.0"?>
    <?xml-stylesheet type="application/xslt+xml" href="menu2qt.xsl"?>
	...

Remain within the **work** folder and start up a HTTP server (either Python or Node should work)

    python3 -m http.server 2000

Open your browser and view the PUI XML file

    http://localhost:2000/exit.xml

Copy the QML output from the browser into a QML file

    touch exit.qml
    <<paste contents within file>>
    save

Open the QML file in Qt Creator

Reformat the file

    Tools > QML/JS > Reformat File

Manually edit the QML as necessary (e.g. Layout close braces are in the wrong position)

	Save the file
	exit Qt Creator

	Move the qml file to folder fgdata/gui/quick/org/flightgear/Dialogs

Clean up the work folder. You may delete the PUI XML file when you have finished the conversion.
