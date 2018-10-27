'***** DemoPal.BAS - Demonstration of Palette routines

'Copyright 1990, Brian C. Giedt

'This demonstrates the routines:
'  SetPalettePal - An assembler routine which sets an EGA or VGA palette
'                  register uses the ega style of specifying one color value
'                  between 0 and 63.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB ShadeVertical (GWWindow AS ANY, NumColors%, StepChoice%, Colors%())
DECLARE SUB DisplayPCXFile (Filename$, ScrnNum%)
DECLARE SUB ResetPalette ()

'$INCLUDE: 'GetVideo.Bas'
MaxFonts% = 3
'$INCLUDE: 'GPFont.GW'
'$INCLUDE: 'GWFont.GW'

PRINT "Prepping...";

FontFile$ = "OldEng"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "Helv12"
CALL SetGPFont(2)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "TmRm12"
CALL SetGPFont(3)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "HELV"
CALL SetGWFont(1)              'specify loading font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array

GPDat%(31) = 5   'Force EGA for this demostration

CALL SetVideo

CALL SetGPFont(3)

'Here Set All Palette Registers to be BLUE (color value 1)
FOR T = 0 TO 14: CALL SetPaletteEGA(T, 1): NEXT

CALL SetGPFont(2)
Text$ = "Using Multiple Palettes"
CALL DrawText(170, 30, Text$, 0, 1, 2#)
Text$ = "you can draw images to the screen"
CALL DrawText(1, 170, Text$, 0, 2, 2#)
Text$ = "without immediately displaying them"
CALL DrawText(GPDat%(43) - GetWidth(Text$) * 2, GPDat%(44) - 60, Text$, 0, 3, 2#)

CALL SetGPFont(3)
Text$ = "Note: These were all on the screen all the time"
CALL DrawText((GPDat%(43) - GetWidth(Text$)) / 2, 250, Text$, 0, 14, 1#)

Text$ = "Press Any Key to Begin"
CALL DrawText((GPDat%(43) - GetWidth(Text$)) / 2, GPDat%(44) / 2 - 20, Text$, 0, 15, 1#)

CALL SetGPFont(1)
Text$ = "Press Any Key to Continue"
CALL DrawText((GPDat%(43) - GetWidth(Text$)) / 2, GPDat%(44) - 20, Text$, 0, 13, 1#)

CALL LineBFVE(10, 10, 150, 150, 4)
CALL LineBVE(10, 10, 150, 150, 5)
CALL LineBFVE(60, 60, 100, 100, 0)

CIRCLE (540, 140), 70, 4
CIRCLE (540, 140), 30, 4
PAINT (580, 140), 5, 4
CIRCLE (540, 140), 30, 5

WHILE INKEY$ = "": WEND

'Here Change All the Palettes in order
SetPaletteEGA 15, 1
SetPaletteEGA 1, 15
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 1, 1
SetPaletteEGA 2, 14
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 2, 1
SetPaletteEGA 3, 13
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 3, 1
SetPaletteEGA 4, 12
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 4, 1
SetPaletteEGA 5, 11
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 5, 1
SetPaletteEGA 14, 10
NumTicks& = PDQTimer& + 32: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 14, 1
SetPaletteEGA 1, 10
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 2, 11
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 3, 12
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 4, 13
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 5, 14
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 14, 15
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 13, 15

WHILE INKEY$ = "": WEND

'Fix Palettes again
CALL ResetPalette

SetPaletteEGA 14, 0
SetPaletteEGA 13, 0
SetPaletteEGA 12, 0
SetPaletteEGA 11, 0
SetPaletteEGA 10, 0

CLS
CALL SetGPFont(2)
Text$ = "Notice the Four colors below which repeat"
CALL DrawText((GPDat%(43) - GetWidth%(Text$)) / 2, 1, Text$, 0, 14, 1#)
Text$ = "Re-color them using the palette"
CALL DrawText((GPDat%(43) - GetWidth%(Text$)) / 2, 26, Text$, 0, 13, 1#)
Text$ = "We can create a image of ground with gradients"
CALL DrawText((GPDat%(43) - GetWidth%(Text$)) / 2, 51, Text$, 0, 12, 1#)
Text$ = "Which we can then manipulate to simulate motion"
CALL DrawText((GPDat%(43) - GetWidth%(Text$)) / 2, 76, Text$, 0, 11, 1#)
Text$ = "By switching the palettes around"
CALL DrawText((GPDat%(43) - GetWidth%(Text$)) / 2, 101, Text$, 0, 10, 1#)

SetPaletteEGA 14, 11
S = 150
A = 3
WHILE S <= 350
   T = 1
   WHILE (T <= 4) AND (S <= 350)
      CALL LineBFVE(0, S, GPDat%(43), S + A, T)
      S = S + A
      T = T + 1
   WEND
   A = A + 3
WEND

CALL LineVE(0, 349, 300, 150, 7)
CALL LineVE(639, 349, 340, 150, 7)
CALL LineVE(300, 150, 340, 150, 7)

CALL LineVE(323, 151, 380, 349, 7)
CALL LineVE(321, 151, 340, 349, 7)
CALL LineVE(319, 151, 300, 349, 7)
CALL LineVE(317, 151, 260, 349, 7)

NumTicks& = PDQTimer& + 36: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 13, 11
SetPaletteEGA 14, 10
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND

SetPaletteEGA 1, 2
SetPaletteEGA 2, 58
SetPaletteEGA 3, 58
SetPaletteEGA 4, 58
SetPaletteEGA 9, 62
PAINT (365, 349), 9, 7
PAINT (275, 349), 9, 7
PAINT (600, 349), 7, 7
PAINT (40, 349), 7, 7
PAINT (320, 349), 7, 7

NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 12, 11
SetPaletteEGA 13, 10
NumTicks& = PDQTimer& + 36: WHILE NumTicks& > PDQTimer&: WEND

SetPaletteEGA 11, 11
SetPaletteEGA 12, 10
NumTicks& = PDQTimer& + 18: WHILE NumTicks& > PDQTimer&: WEND
SetPaletteEGA 10, 11
M! = 12
N! = .973
O = INT(M!)
T = 4
S = 1
WHILE O <= 12
   NumTicks& = PDQTimer& + O
   WHILE PDQTimer& < NumTicks&: WEND
   T = T MOD 4 + 1
   S = S MOD 4 + 1
   SetPaletteEGA T, 58
   SetPaletteEGA S, 2
   M! = M! * N!
   IF N! > 1! THEN
     N! = N! + .001
   ELSE
     N! = N! + .00021
   END IF
   O = INT(M!)
WEND

WHILE INKEY$ <> "": WEND
CALL ResetPalette

CLS
PRINT "Prepping..."
REDIM TxtColors%(15)
DIM GWWindow AS Window1
FOR T = 1 TO 14
'   SetPaletteEGA T, 0
   TxtColors%(T - 1) = T
NEXT

GWWindow.X1 = 0
GWWindow.Y1 = 175
GWWindow.X2 = 639
GWWindow.Y2 = 349
CALL ShadeVertical(GWWindow, 8, 2, TxtColors%())


Text$ = "Graphics"
CALL OutlineText(GPDat%(43) / 2 - (GetOutlineWidth%(Text$) * 3) / 4, 0, Text$, 0, 15, 3, 2)
Text$ = "WorkShop"
CALL OutlineText(GPDat%(43) / 2 - (GetOutlineWidth%(Text$) * 3) / 4, 80, Text$, 0, 15, 3, 2)

FOR T = 0 TO 174
   FOR S = 0 TO 639
      V = GetCacheVE%(S, T)
      IF V = 15 THEN V = GetPointVE%(S, T + 175)
      CALL ReDrawVE(V)
   NEXT
NEXT
CALL LineBFVE(0, 175, 639, 349, 0)
LOCATE 1, 1
PRINT "           "

'These next data statements contain the colors ordered in a fluent color
'sequence
LogoData:
DATA 63, 19, 51, 23, 51, 55, 54, 62, 30, 26, 58, 22, 50, 18, 6 , 34
DATA 2 , 16, 48, 20, 10, 42, 14, 46, 47, 39, 7 , 35, 3 , 61, 45, 21
DATA 5 , 24, 56, 28, 60, 44, 12, 37, 53, 38, 52, 36, 4 , 32, 0 , 8
DATA 40, 1 , 33, 17, 49, 9 , 41, 25, 29, 13, 11, 43, 15, 27, 31, 59
REDIM X%(14), M%(64)
RESTORE LogoData
FOR T = 1 TO 14
    X%(T) = 62 + T
NEXT

FOR T = 63 TO 1 STEP -1
    READ M%(T)
NEXT

FOR T = 1 TO 170
   NumTicks& = PDQTimer&
   FOR S = 14 TO 1 STEP -1
      IF X%(S) < 64 THEN SetPaletteEGA S, M%(X%(S))
      X%(S) = X%(S) - 1
      IF X%(S) = 0 THEN X%(S) = 63
   NEXT
   WHILE NumTicks& > PDQTimer&: WEND
NEXT

WHILE INKEY$ <> "": WEND
CLS
'Load a PCX here of the mountain scene.
CALL DisplayPCXFile("Mountain.PCX", 0)

SetPaletteEGA 11, 59
Text$ = "This screen would not be much using the standard palette"
CALL DrawText((GPDat%(43) - GetWidth%(Text$)) / 2, 2, Text$, 0, 11, 1#)


WHILE INKEY$ = "": WEND

CALL ResetPalette       'Set the standard palette

WHILE INKEY$ = "": WEND

SetPaletteEGA 0, 54     'These are the palette values from the PCX file
SetPaletteEGA 1, 19     'It is very rare that you will need to set the
SetPaletteEGA 2, 63     'palette values from a .PCX file without loading
SetPaletteEGA 3, 0      'it at that time, so there has been no routine
SetPaletteEGA 4, 1      'added to GW to go to the file and only get the
SetPaletteEGA 5, 2      'palette information.  If you find you need a
SetPaletteEGA 6, 27     'routine that does that, copy DisplayPCXFile and
SetPaletteEGA 7, 7      'take out the section that sends the PCX file to
SetPaletteEGA 8, 56     'the screen.
SetPaletteEGA 9, 14
SetPaletteEGA 10, 58
SetPaletteEGA 11, 59
SetPaletteEGA 12, 41
SetPaletteEGA 13, 28
SetPaletteEGA 14, 11
SetPaletteEGA 15, 55

WHILE INKEY$ = "": WEND
SetPaletteEGA 0, 0       'This will make the screen black when the CLS
CLS                      ' statement is executed.
CALL ResetPalette

SUB ResetPalette STATIC
  
   SetPaletteEGA 0, 0
   SetPaletteEGA 1, 1
   SetPaletteEGA 2, 2
   SetPaletteEGA 3, 3
   SetPaletteEGA 4, 4
   SetPaletteEGA 5, 5
   SetPaletteEGA 6, 18
   SetPaletteEGA 7, 7
   SetPaletteEGA 8, 56
   SetPaletteEGA 9, 57
   SetPaletteEGA 10, 58
   SetPaletteEGA 11, 59
   SetPaletteEGA 12, 60
   SetPaletteEGA 13, 61
   SetPaletteEGA 14, 62
   SetPaletteEGA 15, 63

END SUB

