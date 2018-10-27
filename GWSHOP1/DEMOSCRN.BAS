'**** DEMOSCRN.BAS - Demonstrates changing screen modes without loosing the
'                    contents of the screen.

'Copyright 1990 Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo.BAS'

'In order to use the GET and PUT graphics statements, we need to load BASIC's
'graphics libraries.
SCREEN 9

Filename$ = "DEMOSHAD.PCX"
CALL DisplayPCXFile(Filename$, 0)

'Save the data for the text screen before we change to it
REDIM ScrnArray%(32000)
GET (0, 0)-(639, 100), ScrnArray%
PUT (0, 0), ScrnArray%, PSET
WHILE INKEY$ = "": WEND          'Pause until someone hits a key

CALL Screen0(-1)

CLS
LOCATE 12, 26
COLOR 2
PRINT "Now we're in Text mode"

WHILE INKEY$ = "": WEND

CALL Screen9(-1)

GPrint0VE 9, 19, "Now were back in graphics mode.  And if you'll notice the ", 7 * 256 + 1
GPrint0VE 10, 19, "top of the screen is garbled.  But we previously saved the", 7 * 256 + 1
GPrint0VE 11, 19, "image from up there and now we can replace it.            ", 7 * 256 + 1

WHILE INKEY$ = "": WEND

PUT (0, 0), ScrnArray%, PSET

GPrint0VE 9, 19, "Now the screen has been completely restored.              ", 7 * 256 + 1
GPrint0VE 10, 19, "                                                          ", 7 * 256 + 1
GPrint0VE 11, 19, "                                                          ", 7 * 256 + 1

WHILE INKEY$ = "": WEND

CALL Screen0(0)

