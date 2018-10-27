'DEMOBOX.BAS - Demo of the XOR boxing routines in Graphics Workshop

'Copyright 1990, Brian C. Giedt

'This demonstration uses the routines:
'   PositionBox - A complete boxing routine written in Basic, which handles
'                 the keyboard, displaying the box and returns the box
'                 coordinates.
'   DisplayBox  - Displays a box outline using XOR.  Calls LineVE to do it.
'   DisplayBoxFill - Displays a filled box using XOR.  Uses LineVE.
'   LineVE      - The Assembler line routine for EGA and VGA high resolution
'                 screens which has the inherent ability to use any of the
'                 mathematical operations like XOR, AND, OR, or just straight
'                 placement of the line.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB PositionBox (GWWindow AS Window1, Style%, Ch%)

DIM GWWindow AS Window1

'$INCLUDE: 'GetVideo.Bas'
'$INCLUDE: 'GPFont.GW'

FontFile$ = "HELV12"
CALL SetGPFont(1)
CALL LoadFont(FontFile$)

CALL SetVideo

FOR T = 1 TO 30
    X1 = RND * 240 + 200
    Y1 = RND * 200 + 70
    R1 = RND * 100
    C1 = RND * 15
    CIRCLE (X1, Y1), R1, 15
    PAINT (X1, Y1), C1, 15
    CIRCLE (X1, Y1), R1, C1
NEXT

GWWindow.X1 = 175
GWWindow.Y1 = 50
GWWindow.X2 = 350
GWWindow.Y2 = 200

Text$ = "Exclusive-OR boxing routine"
CALL DrawText(320 - GetWidth(Text$), 300, Text$, 0, 15, 2#)
Text$ = "Faster than the normal Basic LINE statement"
CALL DrawText(320 - GetWidth(Text$) / 2, 336, Text$, 0, 15, 1#)

Text$ = "Position the box with the <ArrowKeys>.  <SpaceBar> toggles the active corner"
CALL DrawText(320 - GetWidth%(Text$) \ 2, 275, Text$, 0, 15, 1#)

FillBox = 0         'Specifies whether to use a filled box, or an outline
CALL PositionBox(GWWindow, FillBox, Ch)

IF NOT Ch THEN
    CALL LineBFVE(GWWindow.X1, GWWindow.Y1, GWWindow.X2, GWWindow.Y2, 1)
    CALL LineBVE(GWWindow.X1, GWWindow.Y1, GWWindow.X2, GWWindow.Y2, 15)
END IF

