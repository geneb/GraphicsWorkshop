'***** DemoBnch.BAS - Benchmarks of the major Graphics Workshop routines

'Copyright 1990, Brian C. Giedt

'This Demonstrates the routines:
'   DrawText     - A basic subroutine which displays one of the GraphPak
'                  fonts.
'   OutlineText  - A basic subroutine which displays the GW vector font.
'                  These fonts are very large scale and should be used for
'                  drawing large fonts (small fonts should be drawn using
'                  DrawText above).

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB ShadeVertical (GWWindow AS ANY, NumColors%, StepChoice%, Colors%())

'$INCLUDE: 'GetVideo.Bas'

'$INCLUDE: 'GPFont.GW'  'Setup font arrays for GraphPak fonts
'$INCLUDE: 'GWFont.GW'  'Setup font arrays for Graphics Workshop vector fonts

FontFile$ = "Helv12"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

FontFile$ = "HELV"
CALL SetGWFont(1)              'specify loading GW font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array


GPDat%(31) = 5  'Force EGA for this demo

CALL SetVideo                   'Using this routine to set the screen mode
				'gives you variables for the edge of the
				'screen, aspect ratio of the screen, and
				'more...

Text$ = "This is a demonstration of the Speed differences"
CALL DrawText(10, 10, Text$, 0, 15, 1.2)
Text$ = "between Graphics Workshop routines and those from BASIC."
CALL DrawText(10, 35, Text$, 0, 15, 1.2)
Text$ = "This demo also demonstrates the added power which Graphics"
CALL DrawText(10, 150, Text$, 0, 15, 1.2)
Text$ = "Workshop routines can provide."
CALL DrawText(10, 175, Text$, 0, 15, 1.2)

Text$ = "Press Any Key"
CALL DrawText(320 - GetWidth%(Text$) \ 2, 290, Text$, 0, 15, 1)
WHILE INKEY$ = "": WEND

CLS
PRINT "Take the BASIC PRINT statement:"
PRINT "Repeat a PRINT 20 times in each of the possible colors.  NOTE: There is no"
PRINT "ability to specify a unique background color when using the BASIC PRINT"
PRINT "statement in graphics mode."
NumTicks0& = PDQTimer&
FOR T = 1 TO 10
   FOR S = 0 TO 15
     '
   NEXT
   FOR S = 0 TO 15
     '
   NEXT
NEXT
NumTicks0& = PDQTimer& - NumTicks0&

NumTicks1& = PDQTimer&
FOR T = 1 TO 10
   FOR S = 0 TO 15
      COLOR S
      LOCATE 5 + S, 30
      PRINT "This is a string of Text"
   NEXT
   FOR S = 0 TO 15
      COLOR S
      LOCATE 5 + S, 30
      PRINT "And Here is another One "
   NEXT
NEXT
NumTicks1& = PDQTimer& - NumTicks1&

CLS
PRINT "BASIC took"; NumTicks1& \ 18; " seconds to print the string 320 times."
PRINT "Now watch the Graphics Workshop' GPrint0VE routine"
NumTicks2& = PDQTimer&
FOR T = 1 TO 10
   FOR S = 0 TO 15
      GPrint0VE 5 + S, 30, "This is a string of Text", S * 256 + 15
   NEXT
   FOR S = 0 TO 15
      GPrint0VE 5 + S, 30, "And Here is another One ", S * 256 + 15
   NEXT
NEXT
NumTicks2& = PDQTimer& - NumTicks2&

CLS
PRINT "FOR LOOP took"; NumTicks0& \ 18; "seconds."
PRINT "BASIC took"; NumTicks1& \ 18; "seconds to print the string 320 times."
PRINT "GPrint0VE took"; NumTicks2& \ 18; "seconds."
PRINT USING "That's a speed improvement of ##.## to 1"; (NumTicks1& - NumTicks0&) / (NumTicks2& - NumTicks0&)
PRINT
PRINT "NOTE: With BASIC, it is using the Video BIOS of your machine.  You can't"
PRINT "      guarantee the speed of all BIOS's.  Even if your BIOS is fast, ask"
PRINT "      yourself, 'Will your customer's BIOS be fast?'"
PRINT
PRINT "Graphics Workshop gives you the ability to specify a unique background color."

WHILE INKEY$ <> "": WEND
WHILE INKEY$ = "": WEND

CLS
FOR T = 1 TO 15
   CALL LineBFVE(50 + RND * 150, 40 + RND * 200, 400 + RND * 150, 250 + RND * 100, RND * 5)
NEXT
GPrint0VE 1, 4, "  The GPrint1VE routine does not need to overwrite the background    ", 7 * 256 + 4
GPrint0VE 2, 4, "  The GPrint1VE routine works just as fast as the GPrint0VE routine  ", 7 * 256 + 4

FOR M = 1 TO 10
   X = RND * 40 + 15
   Y = RND * 15 + 5
   GPrint1VE Y, X, "Sample Text", 15
NEXT

WHILE INKEY$ <> "": WEND
WHILE INKEY$ = "": WEND
CLS
CALL LineBFVE(63, 8, 568, 340, 1)
CALL LineBVE(63, 8, 568, 340, 15)
T = 10
WHILE T < 350
    'Notice that GPrint2VE wipes out part of the earlier printed strings with
    ' its background color, while GPrint3VE merely adds to the image already
    ' on the screen
    GPrint2VE T, 11, "GPrint2VE and", 15 + 256 * 1
    GPrint3VE T, 25, "GPrint3VE can print text at any line position", 15 + 256 * 1
    T = T * 1.2
WEND

WHILE INKEY$ <> "": WEND
WHILE INKEY$ = "": WEND

CLS
GPrint0VE 1, 1, " The PSET and POINT statements changing a block of pixel colors                ", 7 * 256 + 4
CALL LineBVE(31, 30, 232, 131, 15)
CALL LineBVE(351, 30, 552, 131, 15)
CALL OutlineText(90, 36, "G", 0, 14, 2, 1)
CALL OutlineText(410, 36, "G", 0, 14, 2, 1)

NumTicks1& = PDQTimer&
FOR M = 1 TO 3
  FOR T = 32 TO 231
    FOR S = 31 TO 130
	V = POINT(T, S)
	PSET (T, S), (V + 1) MOD 16
    NEXT
  NEXT
NEXT
NumTicks1& = PDQTimer& - NumTicks1&

NumTicks2& = PDQTimer&
FOR M = 1 TO 3
  FOR S = 31 TO 130
    FOR T = 352 TO 551
	V = POINT(T, S)
	PSET (T, S), (V + 1) MOD 16
    NEXT
  NEXT
NEXT
NumTicks2& = PDQTimer& - NumTicks2&

GPrint0VE 1, 2, "The DrawPointVE and GetPointVE routines changing a block of pixel colors ", 7 * 256 + 4
NumTicks3& = PDQTimer&
FOR M = 1 TO 3
  FOR T = 32 TO 231
    FOR S = 31 TO 130
      V = GetPointVE(T, S)
      CALL DrawPointVE(T, S, (V + 1) MOD 16)
    NEXT
  NEXT
NEXT
NumTicks3& = PDQTimer& - NumTicks3&

GPrint0VE 1, 2, "The GetCacheVE% and its sister routine ReDrawVE using a simple Cache         ", 7 * 256 + 4
NumTicks4& = PDQTimer&
FOR M = 1 TO 3
  FOR S = 31 TO 130
    FOR T = 352 TO 551
      V = GetCacheVE%(T, S)
      CALL ReDrawVE((V + 1) MOD 16)
    NEXT
  NEXT
NEXT
NumTicks4& = PDQTimer& - NumTicks4&

GPrint0VE 1, 2, "The PaintByte routine changes colors more at a time                           ", 7 * 256 + 4
NumTicks5& = PDQTimer&
FOR M = 1 TO 3
  V1 = GetPointVE(32, 31) 'Here we are determining the current value
  V2 = GetPointVE(105, 40)' because PaintByte wants the value you want changed
  FOR S = 31 TO 130
    FOR T = 5 TO 29
      CALL PaintByte(T, S, V1, (V1 + 1) MOD 16)
      CALL PaintByte(T, S, V2, (V2 + 1) MOD 16)
    NEXT
  NEXT
NEXT
NumTicks5& = PDQTimer& - NumTicks5&

'Calculate How much of the time is spent in the FOR NEXT loop
NumTicks0& = PDQTimer&
FOR M = 1 TO 3
  FOR T = 32 TO 231
    FOR S = 31 TO 130
      V = (V + 1) MOD 16
    NEXT
  NEXT
NEXT
NumTicks0& = PDQTimer& - NumTicks0&

'Below comments are for a timing of 50 iterations of each method
LOCATE 13, 1
PRINT "FOR LOOP:"; NumTicks0& \ 18; "seconds."    ' 255\18 = 14 seconds
PRINT "BASIC:"; NumTicks1& \ 18; "seconds."       ' 2418\18 = 134 seconds
PRINT "BASIC:"; NumTicks2& \ 18; "seconds."       ' 2418\18 = 134 seconds
PRINT "Graphics Workshop:"; NumTicks3& \ 18; "seconds."         ' 1861\18 = 103 seconds
PRINT "Graphics Workshop using GetCacheVE% and ReDrawVE:"; NumTicks4& \ 18; "seconds." ' 1475\18 = 81 seconds
PRINT "Graphics Workshop using PaintByte:"; NumTicks5& \ 18; "seconds. (Uses a different FOR LOOP)" ' 296\18 = 16 seconds
PRINT
PRINT USING "GetPointVE% improvement over POINT of #.## to 1"; (NumTicks1& - NumTicks0&) / (NumTicks3& - NumTicks0&)
PRINT USING "Improvement using GetCacheVE% of #.## to 1"; (NumTicks1& - NumTicks0&) / (NumTicks4& - NumTicks0&)
PRINT USING "Improvement using PaintByte of ##.## to 1"; (2418 - 255) / (296 - 255) 'Note values done using long test
WHILE INKEY$ = "": WEND

CLS
GPrint0VE 1, 17, "The BASIC LINE statement drawing a rotating spiral", 7 * 256 + 4
GPrint0VE 2, 1, "(takes 4 seconds)", 7
R! = 0
NumTicks1& = PDQTimer&
FOR T = 1 TO 1000
    R! = R! + .1
    X = COS(R!) * 160
    Y = SIN(R!) * 160
    C = (C + 1) MOD 16
    LINE (320, 185)-(320 + X, 185 + Y), C
NEXT
NumTicks1& = PDQTimer& - NumTicks1&

CLS
GPrint0VE 1, 7, "The LineVE routine from Graphics Workshop drawing the same spiral", 7 * 256 + 4
GPrint0VE 2, 1, "(takes 4 seconds)", 7
R! = 0
NumTicks2& = PDQTimer&
FOR T = 1 TO 1000
    R! = R! + .1
    X = COS(R!) * 160
    Y = SIN(R!) * 160
    C = (C + 1) MOD 16
    CALL LineVE(320, 185, 320 + X, 185 + Y, C)
NEXT
NumTicks2& = PDQTimer& - NumTicks2&

CLS
GPrint0VE 1, 16, "Now Timing FOR NEXT Loop and Arithmetic calculations", 7
GPrint0VE 2, 1, "(takes 3 seconds)", 7
R! = 0
NumTicks3& = PDQTimer&
FOR T = 1 TO 1000
    R! = R! + .1
    X = COS(R!) * 160
    Y = SIN(R!) * 160
    C = (C + 1) MOD 16
    'Line statement was here
NEXT
NumTicks3& = PDQTimer& - NumTicks3&

'Commented timings are for 32000 iterations
PRINT
PRINT "FOR LOOP:"; NumTicks3& \ 18; "seconds."  '2694\18 = 149 seconds
PRINT "BASIC:"; NumTicks1& \ 18; "seconds."     '3121\18 = 173 seconds
PRINT "Graphics Workshop:"; NumTicks2& \ 18; "seconds."       '3064\18 = 170 seconds
PRINT
PRINT USING "An overall improvement of #.## to 1"; (NumTicks1& - NumTicks3&) / (NumTicks2& - NumTicks3&)
PRINT USING "A longer test shows an improvement of #.## to 1"; (3121 - 2694) / (3064 - 2694)
PRINT
PRINT "So it's only a slight improvement..."
PRINT "But, can BASIC do this? (The Answer in case you are wondering is NO)"
PRINT "Only Graphics Workshop can do rubberbanding lines and its the same"
PRINT "routine that is doing it."

CALL LineVE(0, 0, 0, 349, 14 + 24 * 256)
FOR M = 1 TO 4
   FOR T = 2 TO 639 STEP 2
      CALL LineVE(0, 0, T, 175, 14 + 24 * 256)
      CALL LineVE(T, 176, 0, 349, 14 + 24 * 256)
      CALL LineVE(0, 0, T - 2, 175, 14 + 24 * 256)
      CALL LineVE(T - 2, 176, 0, 349, 14 + 24 * 256)
   NEXT
   FOR T = 636 TO 0 STEP -2
      CALL LineVE(0, 0, T, 175, 14 + 24 * 256)
      CALL LineVE(T, 176, 0, 349, 14 + 24 * 256)
      CALL LineVE(0, 0, T + 2, 175, 14 + 24 * 256)
      CALL LineVE(T + 2, 176, 0, 349, 14 + 24 * 256)
   NEXT
NEXT
CALL LineVE(0, 0, 0, 349, 14 + 24 * 256)

CLS
Text$ = "All Done"
CALL OutlineText(320 - GetOutlineWidth%(Text$), 100, Text$, 0, 9, 2, 1)

