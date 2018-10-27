'**** DemoZoom.Bas

'Copyright 1990, Brian C. Giedt

'This demonstrates the routines:
'   PositionBox - A complete window specification routine which handles the
'                 keyboard, drawing the box using XOR to the screen and
'                 returns the region for the box.
'   FullZoom    - A basic routine which takes the window specified and zooms
'                 it onto the entire screen.

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

DECLARE SUB PositionBox (GWWindow AS Window1, Style%, Ch%)
DECLARE SUB FullZoom (GWWindow AS Window1)

'$INCLUDE: 'GetVideo.Bas'

'$INCLUDE: 'GPFont.GW'
FontFile$ = "Helv12"
CALL SetGPFont(1)
CALL LoadFont(FontFile$)

GPDat%(31) = 5     'Force EGA for this demonstration.  FullZoom uses a PCOPY
CALL SetVideo      'statement which doesn't work on VGA hi-res screen modes

DIM GWWindow AS Window1

FOR T = 1 TO 30
    X1 = RND * 240 + 200
    Y1 = RND * 200 + 70
    R1 = RND * 100
    C1 = RND * 15
    CIRCLE (X1, Y1), R1, 15
    PAINT (X1, Y1), C1, 15
    CIRCLE (X1, Y1), R1, C1
NEXT

GWWindow.X1 = 225
GWWindow.Y1 = 75
GWWindow.X2 = 300
GWWindow.Y2 = 125

Text$ = "Exclusive-OR boxing routine"
CALL DrawText(320 - GetWidth(Text$), 300, Text$, 0, 15, 2#)

CALL PositionBox(GWWindow, 0, Ch)

IF NOT Ch THEN CALL FullZoom(GWWindow)

