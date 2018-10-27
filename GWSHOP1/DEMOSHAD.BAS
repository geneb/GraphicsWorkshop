'**** DemoShad.Bas - demo of the background shading routines

'Copyright 1990, Brian C. Giedt

'This demonstrates the routines:
'   ShadeHorizontal - A basic routine which creates a flowing transistion
'                     from one color to another.  You can specify the colors
'                     the number of colors to use, and the window region.
'                     This routine shades from left to right.
'   ShadeH          - Functions like the ShadeHorizontal routine but uses
'                     the mixed coordinate system for faster screen display
'   ShadeVertical   - A basic routine like ShadeHorizontal, except it shades
'                     from the top of the specified region to the bottom.
'   ShadeV          - Functions like the ShadeVertical routine but uses
'                     the mixed coordinate system for faster screen displays
'
'Using a different value for StepChoice will give you a different effect.
'
'Both routines add a special effect to any screen you can create.  Use one
'of these routines, and save the screen to a PCX file and then load it into
'your favorite Paint program to add any other items you want to it.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB ShadeH (Col1%, Line1%, Col2%, Line2%, NumColors%, StepChoice%, Colors%())
DECLARE SUB ShadeV (Col1%, Line1%, Col2%, Line2%, NumColors%, StepChoice%, Colors%())

DECLARE SUB ShadeHorizontal (GWWindow AS ANY, NumColors%, StepChoice%, Colors%())
DECLARE SUB ShadeVertical (GWWindow AS ANY, NumColors%, StepChoice%, Colors%())

  '$INCLUDE: 'GetVideo.BAS'
  '$INCLUDE: 'GPFont.GW'

  FontFile$ = "Helv12"
  CALL SetGPFont(1)               'specify loading font number 1
  CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array
  
  CALL SetVideo

  DIM GWWindow AS Window1
  REDIM Colors(11)

  'Setup the array of colors which will be passed to the Shading routines
  Colors(0) = 0
  Colors(1) = 4
  Colors(2) = 12
  Colors(3) = 9
  Colors(4) = 2

  CALL LineBVE(31, 29, 504, 101, 15)
  CALL LineBVE(49, 129, 151, 333, 15)
  CALL LineBVE(199, 149, 608, 261, 15)
  
  Text$ = "Shading Routines"
  CALL DrawText(400 - GetWidth%(Text$), 300, Text$, 0, 15, 2#)

  GWWindow.X1 = 32
  GWWindow.Y1 = 30
  GWWindow.X2 = 503
  GWWindow.Y2 = 100
  StepChoice = 2
  NumColors = 1
  'One of the two routines below has been commented out.  Both routines will
  'perform the same function.  The ShadeV routine is faster.
  CALL ShadeV(5, 30, 63, 100, NumColors, StepChoice, Colors())
  'CALL ShadeVertical(GWWindow, NumColors, StepChoice, Colors())

  GWWindow.X1 = 50
  GWWindow.Y1 = 130
  GWWindow.X2 = 150
  GWWindow.Y2 = 332
  StepChoice = 6
  NumColors = 2
  CALL ShadeHorizontal(GWWindow, NumColors, StepChoice, Colors())

  GWWindow.X1 = 200
  GWWindow.Y1 = 150
  GWWindow.X2 = 607
  GWWindow.Y2 = 260
  StepChoice = 7
  NumColors = 5
  'One of the two routines below has been commented out.  Both routines will
  'perform the same function.  The ShadeH routine is faster.
  CALL ShadeH(26, 150, 76, 260, NumColors, StepChoice, Colors())
  'CALL ShadeHorizontal(GWWindow, NumColors, StepChoice, Colors())

WHILE INKEY$ = "": WEND

