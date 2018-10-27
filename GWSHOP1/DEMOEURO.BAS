'***** DemoEuro.BAS - Demonstrates using the extended character set in a font

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

MaxGPFonts% = 2                 'Change the number of available fonts to 2
EuroGPFonts% = -1               'Tell the font system we are going to use
				' the extended ascii character set for
                                ' GraphPak fonts
'$INCLUDE: 'GPFont.GW'          'Setup font arrays for GraphPak fonts
FontFile$ = "Euro"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "Helv12"
CALL SetGPFont(2)               'specify loading font number 2
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

EuroGWFonts% = -1               'Tell the font system we are going to use
				' the extended ascii character set for
                                ' Graphics Workshop Vector fonts
'$INCLUDE: 'GWFont.GW'  'Setup font arrays for Graphics Workshop vector fonts
FontFile$ = "EURO"
CALL SetGWFont(1)               'specify loading GW font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array

CALL SetVideo                   'Using this routine to set the screen mode
				'gives you variables for the edge of the
				'screen, aspect ratio of the screen, and
				'more...

Text$ = "European Fonts (‚Œ)"
CALL OutlineText(10, 10, Text$, 0, 12, 1, 1)

CALL SetGPFont(1)
ABC$ = "ABCDEFGHIJKLMNOPQRSTUVWXYZ   abcdefghijklmnopqrstuvwxyz"
CALL DrawText(30, 100, ABC$, 0, 11, 1#)

ABC$ = "`1234567890-= ~!@#$%^&*()_+ []\{}|,./<>?;':" + CHR$(34) + " €‚ƒ„†‡ˆ‰Š"
CALL DrawText(30, 160, ABC$, 0, 11, 1#)
ABC$ = "‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇ"
CALL DrawText(30, 215, ABC$, 0, 11, 1#)
ABC$ = "ÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüış"
CALL DrawText(30, 272, ABC$, 0, 11, 1#)

Text$ = "and you can create more..."
CALL SetGPFont(2)
CALL DrawText(10, 310, Text$, 0, 12, 1#)


Text$ = "Press Any Key to Continue"
CALL SetGPFont(2)
CALL DrawText(320 - GetWidth(Text$) \ 2, 330, Text$, 0, 15, 1#)
WHILE INKEY$ = "": WEND

