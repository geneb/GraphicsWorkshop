'***** DemoFont.BAS

'Copyright 1990, Brian C. Giedt

'This Demonstrates the routines:
'   DrawText     - A basic subroutine which displays one of the GraphPak
'                  fonts.
'   OutlineText  - A basic subroutine which displays the GW vector font.
'                  These fonts are very large scale and should be used for
'                  drawing large fonts (small fonts should be drawn using
'                  DrawText above).
'   GetWidth%    - Find the length in pixels of a text string using the
'                  GraphPak proportional fonts.
'   GetOutlineWidth% - Find the length in pixels of a text string using the
'                      proportional GW vector fonts.
'
'and all the support routines which go with them, like LoadFont,
'LoadOutlineFont, and the include files necessary to set up the font systems.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo.Bas'

MaxGPFonts% = 4         'You can override the setup for 1 font by setting
			'this variable to some number other than 0.
'$INCLUDE: 'GPFont.GW'  'Setup font arrays for GraphPak fonts
FontFile$ = "OldEng"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "Helv12"
CALL SetGPFont(2)               'specify loading font number 2
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "TmRm12"
CALL SetGPFont(3)               'specify loading font number 3
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "Future"
CALL SetGPFont(4)               'specify loading font number 4
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

'$INCLUDE: 'GWFont.GW'  'Setup font arrays for Graphics Workshop vector fonts
FontFile$ = "HELV"
CALL SetGWFont(1)              'specify loading GW font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array

CALL SetVideo                   'Using this routine to set the screen mode
				'gives you variables for the edge of the
				'screen, aspect ratio of the screen, and
				'more...

CALL SetGWFont(1)
CALL SetGWSpacing(4, 4)
CALL OutlineText(50, 0, "FONTS...", -10, 15, 5, 2)
CALL OutlineText(30, 180, "FONTS...", 30, 9, 3, 1)
CALL OutlineText(150, 160, "AND MORE", 30, 2, 1, 1)
CALL OutlineText(300, 230, "FONTS...", 50, 14, 2, 1)

Text$ = "Press Any Key to Continue"
CALL SetGPFont(2)
CALL DrawText(320 - GetWidth(Text$) \ 2, 320, Text$, 0, 15, 1)
WHILE INKEY$ = "": WEND

CLS
CALL SetGPFont(2)
Text$ = "GraphPak Fonts"
CALL OutlineText(320 - GetOutlineWidth(Text$) * 4 \ 6, 2, Text$, 0, 2, 4, 3)

ABC$ = "ABCDEFGHIJKLMNOPQRSTUVWXYZ   abcdefghijklmnopqrstuvwxyz"
Text$ = "Helvetica"
CALL SetGPFont(2)
CALL DrawText(10, 70, Text$, 0, 12, 2#)
CALL DrawText(30, 100, ABC$, 0, 11, 1#)

Text$ = "Times Roman"
CALL SetGPFont(3)
CALL DrawText(10, 130, Text$, 0, 12, 2#)
CALL DrawText(30, 160, ABC$, 0, 11, 1#)

Text$ = "Old English"
CALL SetGPFont(1)
CALL SetGPSpacing(2, 2)
CALL DrawText(10, 180, Text$, 0, 12, 2#)
CALL DrawText(30, 215, ABC$, 0, 11, 1#)

Text$ = "Future"
CALL SetGPFont(4)
CALL DrawText(10, 245, Text$, 0, 12, 2#)
CALL DrawText(30, 272, ABC$, 0, 11, 1#)

Text$ = "and you can create more..."
CALL SetGPFont(2)
CALL DrawText(10, 300, Text$, 0, 12, 1#)


Text$ = "Press Any Key to Continue"
CALL SetGPFont(2)
CALL DrawText(320 - GetWidth(Text$) \ 2, 320, Text$, 0, 15, 1#)
WHILE INKEY$ = "": WEND

CLS
CALL SetGWFont(1)
Text$ = "Graphics Workshop Fonts"
CALL OutlineText(320 - GetOutlineWidth%(Text$) \ 2, 2, Text$, 0, 15, 1, 1)

CALL SetGWFont(1)
Text$ = "Helvetica"
CALL OutlineText(20, 160, Text$, 20, 12, 3, 2)

CALL SetGPFont(2)
Text$ = "Press Any Key to Continue"
CALL DrawText(320 - GetWidth(Text$) \ 2, 320, Text$, 0, 15, 1#)
WHILE INKEY$ = "": WEND

