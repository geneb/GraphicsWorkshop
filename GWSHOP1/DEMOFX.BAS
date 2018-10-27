'**** DEMOFX.BAS - Demo of the Graphics Move routines and there ability to
'                  create spectacular effects

'Copyright 1990, Brian C. Giedt

' The routines demonstrated here are:
'    LoadPCXFile - A basic subroutine which loads a pcx file to a screen.
'    GMove1VE   - An assembler subroutine which moves a region of graphics
'                 memory.
'    GMove3VE   - An assembler subroutine which moves a region of graphics
'                 memory, just as GMove1VE does, but with the ability to
'                 skip lines and provide an interlaced effect.
'    SlideLeft, SlideRight, SlideUp, and SlideDown - Routines which use
'                 GMove1VE to transfer images to the screen.
'    SplitHorizontal - Similar to the slide routines, but utilizes GMove3VE
'    Mirror     - Takes a graphics region an performs a vertical flip of the
'                 pixels.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DisplayPCXFile (Filename$, ScrnNum%)
DECLARE SUB MirrorImage (Col1%, Line1%, Col2%, Line2%, DestCol%, DestLine%)

'$INCLUDE: 'GetVideo'

'$INCLUDE: 'GWFont.GW'

SetGWFont 1
CALL LoadOutlineFont("HELV")
SetGWFont 1
CALL SetGWSpacing(3, 5)

GPDat%(31) = 5
CALL SetVideo

'Load two demo screens, one to the visible page (0) and one to the background
'page (1).
CALL DisplayPCXFile("DEMOSHAD", 0)
CALL DisplayPCXFile("XORBOX", 1)

'Move a background screen in, coming from the right side of the screen
CALL SlideLeft(3, 12, 77, GPDat%(44) - 16, 3, 13)
'NOTE: You don't have to specify full screen regions

'Load a PCX file into the background
CALL DisplayPCXFile("ZOOMED", 1)
CALL SplitHorizontal(1, 0, 80, GPDat%(44) - 1, 1, 0)

'Load and bring in a PCX file, and push it in from the left side of the screen
CALL DisplayPCXFile("FONTEDIT", 1)
CALL SlideRight(1, 0, 80, GPDat%(44) - 1, 1, 0)

'Load and bring in a PCX file from the top of the screen.
CALL DisplayPCXFile("FONTS2", 1)
CALL SlideDown(1, 0, 80, GPDat%(44) - 1, 1, 0)

'Load and bring in a PCX file from the bottom of the screen.
CALL DisplayPCXFile("FONTS1", 1)
CALL SlideUp(1, 0, 80, GPDat%(44) - 1, 1, 0)

WHILE INKEY$ = "": WEND
CLS
CALL LineVE(20, 30, 90, 120, 2)
CALL LineVE(90, 120, 500, 50, 2)
CALL LineVE(500, 50, 20, 30, 2)
PAINT (90, 60), 2, 2
CALL LineVE(200, 150, 600, 70, 4)
CALL LineVE(600, 70, 520, 180, 4)
CALL LineVE(520, 180, 200, 150, 4)
PAINT (400, 140), 4, 4

CALL SetGWPages(0, 0) 'Change the Source for the GMove1VE statement below to
		    ' be the current page
CALL OutlineText(20, 40, "Mirror Images", 0, 15, 2, 1)
'Copy the image drawn on the screen in a mirror image style by flipping it

NewY% = 30 + GPDat%(85) * 2
CALL MirrorImage(1, 30, 80, GPDat%(85) * 2 + 40, 1, NewY%)

WHILE INKEY$ = "": WEND


