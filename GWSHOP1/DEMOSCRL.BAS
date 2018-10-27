'DemoScrl.Bas - demo of the scrolling routines in four directions at once

'Copyright 1990, Brian C. Giedt

'This demostrates the routine GScrollVE, an assembler routine which scrolls
'a region of the screen in any direction.  EVEN DIAGONALLY.  All you have
'to do is specify the region and the amount of change in position using a
'minus sign to specify direction.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo.BAS'

'$INCLUDE: 'GPFont.GW'
FontFile$ = "TmRm12"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

CALL SetVideo

PAINT (1, 1), 4, 15
CALL LineBVE(15, 23, 264, 144, 15)
CALL LineBVE(335, 23, 584, 144, 15)
CALL LineBVE(15, 183, 264, 304, 15)
CALL LineBVE(335, 183, 584, 304, 15)

CIRCLE (140, 84), 50, 6
CIRCLE (140, 244), 50, 6
CIRCLE (460, 84), 50, 6
CIRCLE (460, 244), 50, 6

PAINT (140, 84), 15, 6
PAINT (140, 244), 15, 6
PAINT (460, 84), 15, 6
PAINT (460, 244), 15, 6

FOR T = 1 TO 22
   NumTicks& = PDQTimer + 4
   CALL GScrollVE(2, 24, 31, 120, 1, 0)
   CALL GScrollVE(42, 24, 31, 120, 0, 5)
   CALL GScrollVE(2, 184, 31, 120, -1, 0)
   CALL GScrollVE(42, 184, 31, 120, 0, -5)
   WHILE NumTicks& > PDQTimer: WEND
NEXT

Text$ = "Now without delays"
CALL DrawText(320 - GetWidth%(Text$) \ 2, 0, Text$, 0, 15, 1#)

CIRCLE (140, 84), 50, 6
CIRCLE (140, 244), 50, 6
CIRCLE (460, 84), 50, 6
CIRCLE (460, 244), 50, 6

PAINT (140, 84), 15, 6
PAINT (140, 244), 15, 6
PAINT (460, 84), 15, 6
PAINT (460, 244), 15, 6

FOR T = 1 TO 22
   CALL GScrollVE(2, 24, 31, 120, 1, 0)
   CALL GScrollVE(42, 24, 31, 120, 0, 5)
   CALL GScrollVE(2, 184, 31, 120, -1, 0)
   CALL GScrollVE(42, 184, 31, 120, 0, -5)
NEXT

CLS

Text$ = "You can even do some things like on TV"
CALL DrawText(320 - GetWidth%(Text$), 2, Text$, 0, 15, 2#)

NumTicks& = PDQTimer& + 42: WHILE NumTicks& > PDQTimer&: WEND

CLS

CALL SetGPSpacing(2, 2)
CALL LineBFVE(200, 1, 439, 29, 4)
CALL LineBVE(200, 1, 439, 29, 15)
Text$ = "H       B       O"
CALL DrawText(320 - GetWidth%(Text$) * 2 / 2, 3, Text$, 0, 15, 2#)
CALL LineBFVE(0, 156, 239, 184, 1)
CALL LineBVE(0, 156, 239, 184, 15)
Text$ = "T h e   B e s t   T i m e"
CALL DrawText(120 - GetWidth%(Text$) * 1.5 / 2, 159, Text$, 0, 15, 1.5#)
CALL LineBFVE(200, 320, 319, 349, 4)
CALL LineBVE(200, 320, 319, 349, 15)
Text$ = "O  n"
CALL DrawText(260 - GetWidth%(Text$) * 1.5 / 2, 323, Text$, 0, 15, 1.5#)
CALL LineBFVE(521, 191, 639, 220, 3)
CALL LineBVE(521, 191, 639, 220, 15)
Text$ = "T  V"
CALL DrawText(581 - GetWidth%(Text$) * 1.5 / 2, 195, Text$, 0, 0, 1.5#)

NumTicks& = PDQTimer& + 26: WHILE NumTicks& > PDQTimer&: WEND

   CALL GScrollVE(25, 0, 30, 150, 0, 4)
   CALL LineBFVE(200, 0, 439, 3, 0)
   CALL GScrollVE(0, 156, 55, 29, 1, 0)
   CALL LineBFVE(0, 156, 7, 184, 0)
   CALL GScrollVE(40, 191, 40, 30, -1, 0)
   CALL LineBFVE(632, 191, 639, 220, 0)
   CALL GScrollVE(25, 191, 15, 170, 0, -5)
   CALL LineBFVE(200, 345, 319, 349, 0)
  
   CALL GScrollVE(25, 0, 30, 150, 0, 5)
   CALL GScrollVE(25, 191, 15, 170, 0, -16)

FOR T = 1 TO 12
   NumTicks& = PDQTimer + 1
   CALL GScrollVE(25, 0, 30, 150, 0, 4)
   CALL GScrollVE(0, 156, 55, 29, 1, 0)
   CALL GScrollVE(40, 191, 40, 30, -1, 0)
   CALL GScrollVE(25, 191, 15, 170, 0, -4)
   WHILE NumTicks& > PDQTimer: WEND
NEXT

FOR T = 1 TO 12
   NumTicks& = PDQTimer + 1
   CALL GScrollVE(25, 0, 30, 150, 0, 5)
   CALL GScrollVE(0, 156, 55, 29, 1, 0)
   CALL GScrollVE(40, 191, 40, 30, -1, 0)
   CALL GScrollVE(25, 191, 15, 170, 0, -5)
   WHILE NumTicks& > PDQTimer: WEND
NEXT

WHILE INKEY$ = "": WEND

