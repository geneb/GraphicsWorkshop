'**** DemoIntr.Bas

'Copyright 1990, Brian C. Giedt

'This demonstrates the routines:
'   Interlude1 - A basic routine written for use in the QuickSegue
'                presentation demo.  It displays a Movie Clickboard and
'                displays a title on it for your presentation.
'   Interlude2 - A basic routine which sends multiple rectangular objects
'                across the screen and seemingly behind all the objects on
'                the screen.  Many television and cable companies are using
'                this techinique as an attention getter.
'   FillPoly   - A basic routine which creates a quadrilateral and colors
'                it in the specified color.
'   GetPoint   - An assembler replacement for BASIC's POINT statement.  Used
'                here because it alone is faster, but using its cache and
'                its sister routine ReDraw the speed improvement is two fold.
'   ReDraw     - An assembler routine to change the color at the location of
'                the last GetPoint statement.  These routines are used by
'                Interlude2 to provide fast drawing and moving of the
'                rectangles.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB FillPoly (A%, b%, c%, d%, e%, f%, g%, h%, Colr%)
DECLARE SUB Interlude1 (Text$)
DECLARE SUB Interlude2 (TextColors%(), MaxBoxes%, Delay%)

'$INCLUDE: 'GetVideo.Bas'
'$INCLUDE: 'GPFont.GW'
'$INCLUDE: 'GWFont.GW'

FontFile$ = "HELV12"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "HELV"
CALL SetGWFont(1)              'specify loading font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array

CALL SetVideo

'Demonstrate the first interlude

CALL LineBFVE(0, 0, GPDat%(43), GPDat%(44), 1) 'Paints the screen blue. Fast.

CALL SetGWFont(1)
CALL SetGWSpacing(4, 1)
CALL Interlude1("DemoIntr_Take 18")

WHILE INKEY$ = "": WEND

'Demonstrate the second interlude

CLS
REDIM TextColors(5)
TextColors(0) = 0     'Background screen color

TextColors(1) = 15    'Colors which can not be used by rectangles, because
TextColors(2) = 4     'they are used by objects on the screen that we
TextColors(3) = 5     'don't want to be able to destroy.
TextColors(4) = 10
TextColors(5) = 12

'Create some foreground objects
CALL FillPoly(50, 50, 50, 200, 430, 50, 430, 50, 12)
CALL FillPoly(75, 75, 75, 150, 280, 75, 280, 75, 0)
CALL FillPoly(430, 170, 430, 170, 100, 300, 350, 300, 10)

Text$ = "INTERLUDE"
CALL OutlineText(40, 220, Text$, 30, 15, 2, 1)

Text$ = "Watch as moving bars"
CALL DrawText(410, 230, Text$, 0, 15, 1#)
Text$ = "move behind objects"
CALL DrawText(410, 255, Text$, 0, 15, 1#)
Text$ = "on the screen"
CALL DrawText(410, 280, Text$, 0, 15, 1#)

MaxBoxes% = 5
Seconds% = 40
CALL Interlude2(TextColors(), MaxBoxes%, Seconds%)

