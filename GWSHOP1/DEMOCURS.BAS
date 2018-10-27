'DemoCurs.BAS - Demo of the graphics cursor routine

'Copyright 1990, Brian C. Giedt

'The demonstrates the DrawCursor routine, which is written in basic and
' provides a blinking cursor.  The DrawCursor routine uses the PDQTimer&
' function to provide a constant blink

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'


'$INCLUDE: 'GetVideo.Bas'

'$INCLUDE: 'GPFont.GW'
FontFile$ = "HELV12"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

CALL SetVideo

CALL LineBVE(10, 10, GPDat%(43) - 10, GPDat%(44) - 10, 15)

Text$ = "This is a line of TEXT."
CALL DrawText(20, 20, Text$, 0, 15, 1#)

LOCATE 24, 23: PRINT "Press <SpaceBar> to advance cursor";

CursorWidth = 1
CursorLength = 20
CursorIs = 0
CursorY = 18
CursorTiming = 9 'A value of 9 will cause the cursor to blink completely every
		 'second.  CursorTiming is measured in 1/18ths of a second.

'Include the following type of code, wherever you intend to use a graphics
'cursor.  Note that the DrawCursor returns to the main program always and
'must be called again to draw it again.  This allows you and your program
'to be executing other instructions while the cursor is apparently blinking.
'Be sure to call DrawCursor often enough to provide a fluent blink.  The
'variable CursorIs is a boolean variable which tells you wether or not the
'cursor is currently visible on screen.  You should turn it off every time
'you move it.
FOR t = 0 TO LEN(Text$)
    A$ = MID$(Text$, 1, t)
    CursorX = GetWidth%(A$) + 20
    WHILE INKEY$ <> " "
      OldTime! = TIMER + .2
      CALL DrawCursor(CursorX, CursorY, CursorWidth, CursorLength, CursorIs, CursorTiming)
      WHILE TIMER < OldTime!: WEND
    WEND
    'This next line turns the cursor off, if necessary.
    IF CursorIs THEN CALL DrawCursor(CursorX, CursorY, CursorWidth, CursorLength, CursorIs, -1)
NEXT


