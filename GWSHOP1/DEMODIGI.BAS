'DemoDigi - Demo of screen digitizing

'Copyright 1990, Brian C. Giedt

'Demonstrates the use of the Digitize routine, written in Basic.  This
'routine, takes a image region on the screen an digitizes it to make its
'characteristics unrecognizable.  This type of routine is used on television
'news broadcasts when they do not want to show a persons face, or they want
'to censor some element of the broadcast.  It also has an artistic quality,
'which is its purpose in this package.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DisplayPCXFile (Filename$, ScrnNum%)
DECLARE SUB Digitize (GWWindow AS Window1, Pixels%, Quick%)

DIM GWWindow AS Window1

'$INCLUDE: 'GetVideo.BAS'

GPDat%(31) = 5  'PCOPY does not work with VGA so use EGA screen mode
CALL SetVideo

CALL DisplayPCXFile("MOUNTAIN.PCX", 0)

GWWindow.X1 = 174
GWWindow.X2 = 182
GWWindow.Y1 = 0
GWWindow.Y2 = 349

PCOPY 0, 1      'Make a copy of the rest of the screen
'Note: PCOPY does not work in VGA modes because VGA's have insufficient
'      memory for more than one video page

FOR T = 3 TO 10
   CALL Digitize(GWWindow, T, -1)
   GWWindow.X1 = GWWindow.X1 + 3 * T
   GWWindow.X2 = GWWindow.X2 + 3 * (T + 1)
NEXT

GWWindow.X2 = GWWindow.X2 - 11
FOR T = 11 TO 20
   CALL Digitize(GWWindow, T, -1)
   GWWindow.X1 = GWWindow.X1 + 2 * T
   GWWindow.X2 = GWWindow.X2 + 2 * (T + 1)
NEXT

WHILE INKEY$ = "": WEND
PALETTE 0, 0                  'Restore the black Palette to the screen
CLS

