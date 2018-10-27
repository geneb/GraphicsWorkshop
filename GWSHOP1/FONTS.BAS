'Fonts.Bas - Designs and edits GraphPak fonts

'Copyright (c) 1993 Brian Giedt and Phil Cramer
'Copyright (c) 1993 Crescent Software


DEFINT A-Z

DECLARE SUB ButtonUp ()
DECLARE SUB GEditor (Edit$, LeftCol%, KeyCode%, TxtPos%)
DECLARE SUB InputBox (Choice%, Msg$(), Prompt$, Text$)
DECLARE SUB HighPrint (Row%, HiEl, Menu$())
DECLARE SUB HelpScrn ()
DECLARE SUB Box3D (X1%, Y1%, X2%, y2%, Drop%)
DECLARE SUB ViewFont (Char$(), Cols, CurChar)
DECLARE SUB PrintRefChar (Ky%)

DECLARE FUNCTION FindLastChar% (Char$())
DECLARE FUNCTION NoPath$ (FileSpec$)
DECLARE FUNCTION LongestString% (Array$())

DIM SHARED MenuRow, MenuCol, Menu$(15), MenuHiClr, MenuClr

'$INCLUDE: 'GWDECL.BAS'

'$INCLUDE: 'GetVideo.Bas'

bv = 15
IF GPDat%(31) <> 5 AND GPDat%(31) <> 8 THEN
   PRINT "This program requires an EGA or VGA display"
   END
END IF

SCREEN 9

CALL Mouse(7, 0, 0, 639)
CALL Mouse(8, 0, 0, 349)

False = 0
True = NOT False
Front = 15
Back = 1
Mark1 = 2
Mark2 = 4
HelpLineClr = 14
Cl$ = SPACE$(22)
GPDat(74) = 15 + 256
SaveUpTo = 126                'Default number of characters to save
Enable2To1 = -1               'Set to 0 for faster character display response

REDIM Msg$(0)


REDIM Char$(223), LnIn$(223)
FOR t = 32 TO 254
  Char$(t - 31) = STRING$(32, 0)           'Fill with CHR$(0)
NEXT


FileName$ = COMMAND$

IF LEN(FileName$) THEN

  t = INSTR(FileName$, ".")
  IF t THEN FileName$ = LEFT$(FileName$, t - 1)
  
  FSize& = GWFileSize&(FileName$ + ".GPK")

  IF FSize& = 7136 OR FSize& = 3040 THEN
    OPEN FileName$ + ".GPK" FOR RANDOM AS #1 LEN = 32
    FIELD #1, 32 AS Wr$

    FOR t = 32 TO 254
      GET #1, t - 31
      Char$(t - 31) = Wr$
      IF EOF(1) THEN EXIT FOR
    NEXT
    CLOSE

  ELSE
    CLS                                        '  7136,3040
    BEEP
    PRINT "File not found - press a key";
    WHILE INKEY$ = "": WEND
  END IF

END IF

 Menu$(1) = " Edit Character       "
 Menu$(2) = " F1  - Help           "
 Menu$(3) = " F2  - Make .GFN file "
 Menu$(4) = " F3  - Load .GPK file "
 Menu$(5) = " F4  - Save .GPK file "
 Menu$(6) = " F5  - View Font      "
 Menu$(7) = " F6  - Make Bold H    "
 Menu$(8) = " F7  - Make Bold V    "
 Menu$(9) = " F8  - Copy Letter    "
Menu$(10) = " F9  - Clear          "
Menu$(11) = " F10 - Undo           "
Menu$(12) = " Shift F1 - Move Axis "
Menu$(13) = " Alt-Arrow - Shift"
Menu$(14) = " Ctl-Arrow - Shift all"
Menu$(15) = ""



Buf$ = SPACE$(40)
FileBuf$ = SPACE$(12)

IF LEN(FileName$) THEN
  GPKName$ = FileName$
ELSE
  GPKName$ = "Working"
END IF
FontName$ = GPKName$

FBuf$ = SPACE$(12)
LSET FBuf$ = FileName$
LOCATE 24, 65: PRINT RIGHT$(FBuf$, 12);


FOR t = 0 TO 15             'draw boxes
  FOR S = 0 TO 15
    LINE (60 + t * 24, 20 + S * 20)-(59 + (t + 1) * 24, 19 + (S + 1) * 20), Back, BF
    LINE (60 + t * 24, 20 + S * 20)-(59 + (t + 1) * 24, 19 + (S + 1) * 20), 0, B
  NEXT
NEXT

'LINE (60, 20)-(443, 339), 12, B


LINE (58, 18)-(445, 341), 7, B
BLine = 10
SLine = 11
GOSUB DrawHelpLines

LINE (474, 20)-(491, 37), Back, BF
LINE (474, 20)-(491, 37), 7, B
'LINE (496, 20)-(522, 46), 7, B
IF Enable2To1 THEN LINE (529, 20)-(562, 53), 7, B
'LINE (569, 20)-(634, 85), 7, B

'LINE (450, 135)-STEP(184, 206), 1, BF
'LINE (450, 135)-STEP(184, 206), 7, B
	       
LOCATE 1, 1                         'give boxes a coordinates system
PRINT TAB(10); "0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15";

DIM Crossair(200)
FOR t = 0 TO 15
  GET (64 + t * 24, 0)-(64 + (t + 1) * 24, 13), Crossair
  PUT (39, t * 20 + 23), Crossair, XOR
NEXT

LOCATE 1, 60
IF Enable2To1 THEN
  PRINT "x1     x2"
ELSE
  PRINT "x1 "
END IF

MenuRow = 9
MenuCol = 58
MenuHiClr = 15 + 9 * 256'15 + 1 * 256
MenuClr = 7 + 1 * 256
GOSUB DisplayMenu


Ky = 65
LastKy = Ky
Ky$ = "A"

GOSUB DrawChar  'Draw x1 reference character
GOSUB Fixit     'Draw scaled characters
GOSUB ShowFontName


PrintRefChar Ky

Undo$ = SPACE$(32)
LSET Undo$ = Char$(Ky - 31)
X = 0
Y = 0
GOSUB ShowBox

CALL InitMouse(There)

ShowCursor
DO

  Ky$ = INKEY$
  SELECT CASE LEN(Ky$)
    CASE 0
      Ky = 0
    CASE 1
      Ky = ASC(Ky$)
    CASE 2
      Ky = -ASC(RIGHT$(Ky$, 1))
  END SELECT
  GetCursor Mx, My, Button

  IF Button = 1 OR Button = 2 THEN

    IF Button = 1 AND Mx > 463 AND Mx < 631 AND My > 139 AND My < 335 THEN
      Ky = -(((My - 140) \ 14) + 59)
      IF Ky < -68 THEN Ky = Ky - 15
    ELSE

      Y1 = (My - 20) \ 20
      X1 = (Mx - 60) \ 24

      IF X1 <> LastX1 OR Y1 <> LastY1 OR Released THEN
	Released = 0
	IF Y1 >= 0 AND Y1 <= 15 AND X1 >= 0 AND X1 <= 15 THEN
	  X = X1
	  Y = Y1
	  HideCursor
	  IF Button = 1 THEN
	    PSET (475 + X, 21 + Y), Front'Fv      'toggle pixel
	    GOSUB BitOn
	  ELSE
	    PSET (475 + X, 21 + Y), Back    'turn off pixel
	    GOSUB BitOff
	  END IF
	  ShowCursor
	  GOSUB FixPoint
	  LastX1 = X1
	  LastY1 = Y1
	  ButtonDown = -1
	END IF
      END IF

    END IF
  END IF

  IF Button = 0 AND ButtonDown THEN Released = -1

  SELECT CASE Ky

    CASE 27

      GPrint0VE 24, 58, "  Are you sure? (Y/N) ", 14 + 256
      i$ = " "
      WHILE INSTR("yYnN" + CHR$(27), i$) < 1
	i$ = ""
	WHILE i$ = ""
	  i$ = INKEY$
	WEND
      WEND
      GPrint0VE 24, 58, Cl$, 15 + 256

      IF INSTR("yY", i$) > 0 THEN
	SCREEN 0, 1
	CLS
	CLOSE
	END
      END IF
      GOSUB ShowFontName

    CASE 43 '+
      IF Edited THEN GOSUB SaveChar
      LastKy = LastKy + 1
      IF LastKy > FindLastChar(Char$()) THEN LastKy = 32
      HideCursor
      PrintRefChar LastKy
      ShowCursor
      GOSUB Refresh
      WHILE INKEY$ <> "": WEND

    CASE 45 '-
      IF Edited THEN GOSUB SaveChar
      LastKy = LastKy - 1
      IF LastKy < 32 THEN LastKy = FindLastChar(Char$())
      HideCursor
      PrintRefChar LastKy
      ShowCursor
      GOSUB Refresh
      WHILE INKEY$ <> "": WEND

    CASE 33 TO 255

      IF Edited THEN GOSUB SaveChar

      LastKy = Ky
      HideCursor
      PrintRefChar LastKy

      GOSUB DrawChar  'Draw x1 reference character
      GOSUB Fixit     'Draw scaled characters
      LSET Undo$ = Char$(Ky - 31)
      ShowCursor
      WHILE INKEY$ <> "": WEND

    CASE 32, 13               'Spacebar, Enter
      HideCursor
      Fv = POINT(475 + X, 21 + Y)
      IF Fv = Back THEN Fv = Front ELSE Fv = Back
      PSET (475 + X, 21 + Y), Fv      'toggle pixel
      ShowCursor
      GOSUB ToggleBit
      GOSUB FixPoint
    
    CASE -72     'Up
      Y = Y - 1
      IF Y < 0 THEN Y = 15

    CASE -75     'Left
      X = X - 1
      IF X < 0 THEN X = 15

    CASE -77     'Right
      X = X + 1
      IF X > 15 THEN X = 0

    CASE -80     'Down
      Y = Y + 1
      IF Y > 15 THEN Y = 0


'***************** Function Keys

    CASE -59
      HelpScrn

    CASE -60   'F2 Make .GFN file

      HighPrint 3 + MenuRow, 3, Menu$()

      REDIM Msg$(3)
      Msg$(1) = "This will create a font file with a .GFN extension"
      Msg$(2) = "This file can then used with the DrawText routines "
      Msg$(3) = "to display the font in your program."

      Prompt$ = "FileName:"
      LSET Buf$ = FontName$ + ".GFN"
      Text$ = Buf$

      InputBox Choice, Msg$(), Prompt$, Text$

      IF Choice = 1 AND LEN(RTRIM$(Text$)) THEN
	SaveUpTo = FindLastChar(Char$())
	HideCursor

	FOR S2 = 32 TO SaveUpTo
	  
	  PrintRefChar S2

	  LINE (475, 21)-(490, 36), Back, BF          'clear display

	  FOR t = 0 TO 31
	    B = 0
	    IF t \ 2 <> t / 2 THEN B = 8
	    a = ASC(MID$(Char$(S2 - 31), t + 1, 1))
	    FOR T1 = 0 TO 7
	      IF a AND 2 ^ (7 - T1) THEN
		X = T1 + B
		Y = t \ 2
		PSET (475 + X, 21 + Y), Front
	      END IF
	    NEXT
	  NEXT
	  GOSUB Here          'this goes to special routines below...
	  Quotes = False
	  LnIn$(S2 - 31) = LnCh$
	  IF J1 < LEN(LnCh$) THEN J1 = LEN(LnCh$)
	NEXT

	J1 = J1 + 1


	ON ERROR GOTO ErrHandler
SaveGFN:
	FontName$ = LTRIM$(RTRIM$(Text$))
	Per = INSTR(FontName$, ".")
	IF Per THEN FontName$ = LEFT$(FontName$, Per - 1)

	OPEN FontName$ + ".GFN" FOR RANDOM AS #2 LEN = J1 'file name user entered
	FIELD #2, J1 AS Into$
	LSET Into$ = STR$(J1) + CHR$(13) + CHR$(10)
	PUT #2
	FOR j2 = 1 TO SaveUpTo - 31
	  LnCh$ = CHR$(LEN(LnIn$(j2))) + LnIn$(j2)
	  LSET Into$ = LnCh$
	  PUT #2
	NEXT
	CLOSE #2
	ON ERROR GOTO 0

	LINE (475, 21)-(490, 36), Back          'clear display
	ShowCursor
      ELSE
	FontName$ = GPKName$
      END IF
      HighPrint 1 + MenuRow, 1, Menu$()

      GOSUB Refresh
      PrintRefChar LastKy
      WHILE INKEY$ <> "": WEND


    CASE -61 'F3  Load .GPK file
      HighPrint 4 + MenuRow, 4, Menu$()

      REDIM Msg$(3)
      Msg$(1) = "  This will load a new GPK bit-mapped font file. "
      Msg$(2) = "  These files have a .GPK extension"

      Prompt$ = "FileName:"
      LSET Buf$ = GPKName$ + ".GPK"
      Text$ = Buf$

LoadGPK:
      InputBox Choice, Msg$(), Prompt$, Text$

      TempName$ = LTRIM$(RTRIM$(Text$))

      IF Choice = 1 AND LEN(TempName$) THEN

	Per = INSTR(TempName$, ".")
	IF Per THEN TempName$ = LEFT$(TempName$, Per - 1)


	ON ERROR GOTO ErrHandler
	
	OPEN TempName$ + ".GPK" FOR RANDOM AS #1 LEN = 32
	FSize& = LOF(1)

	IF FSize& MOD 32 OR FSize& = 0 THEN
	  IF FSize& = 0 THEN
	    CLOSE
	    KILL TempName$ + ".GPK"
	  END IF
	  BEEP
	  Msg$(1) = "    Not a valid .GPK file! Enter a new name or"
	  Msg$(2) = "             press escape to cancel."
	  GOTO LoadGPK
	END IF

	FIELD #1, 32 AS Wr$
	FOR t = 32 TO 254
	  GET #1, t - 31
	  Char$(t - 31) = Wr$
	  IF EOF(1) THEN EXIT FOR
	NEXT
	CLOSE
	ON ERROR GOTO 0

	IF t < 255 THEN  'Clear any remaining chars from last font
	  FOR t = t TO 254: Char$(t - 31) = STRING$(32, 0): NEXT
	END IF

	GPKName$ = TempName$
	FontName$ = GPKName$
	LastKy = 65                   'Start with an "A"
	GOSUB Refresh
	LSET Undo$ = Char$(LastKy - 31)

     END IF

      HighPrint 1 + MenuRow, 1, Menu$()
      GOSUB ShowFontName
      WHILE INKEY$ <> "": WEND

    CASE -62 'F4 Save .GPK font file
      HighPrint 5 + MenuRow, 5, Menu$()

      REDIM Msg$(3)
      Msg$(1) = "This will save the current font as a 32 byte per character"
      Msg$(2) = "bit map. The file will be saved with a .GPK extension."
      Msg$(3) = ".GPK files are used only by this program."

      Prompt$ = "FileName:"
      LSET Buf$ = GPKName$ + ".GPK"
      Text$ = Buf$

SaveGPK:
      InputBox Choice, Msg$(), Prompt$, Text$

      IF Choice = 1 AND LEN(RTRIM$(Text$)) THEN
	SaveName$ = LTRIM$(RTRIM$(Text$))

	Per = INSTR(SaveName$, ".")
	IF Per THEN SaveName$ = LEFT$(SaveName$, Per - 1)

	'---- Determine number of characters to save, either 127 or 254
	SaveUpTo = FindLastChar(Char$())
	IF SaveUpTo > 126 THEN
	  SaveUpTo = 254
	ELSE
	  SaveUpTo = 126
	END IF


	ON ERROR GOTO ErrHandler

	OPEN SaveName$ + ".GPK" FOR RANDOM AS #1 LEN = 32

	FileSz& = LOF(1)
	

	'---- If new file will be smaller than before (shrunk from 254 to 127),
	'     close the old file so we can KILL it and then create a new file
	IF SaveUpTo < FileSz& THEN
	  CLOSE #1
	  KILL SaveName$ + ".GPK"
	  OPEN SaveName$ + ".GPK" FOR RANDOM AS #1 LEN = 32
	END IF

	FIELD #1, 32 AS Wr$

	FOR t = 32 TO SaveUpTo
	  LSET Wr$ = Char$(t - 31)
	  PUT #1, (t - 31)
	NEXT
	CLOSE
	ON ERROR GOTO 0
	GPKName$ = SaveName$
	FontName$ = GPKName$

	LSET FBuf$ = SaveName$
	LOCATE 24, 65: PRINT RIGHT$(FBuf$, 12);

      END IF

      HighPrint 1 + MenuRow, 1, Menu$()
      GOSUB ShowFontName
      WHILE INKEY$ <> "": WEND
      ButtonUp

    CASE -63 'F5  View Font
      HighPrint 6 + MenuRow, 6, Menu$()
      CurrentChar = LastKy - 31
      ViewFont Char$(), 16, CurrentChar
      LastKy = CurrentChar + 31
      Undo$ = Char$(CurrentChar)
      PrintRefChar LastKy
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      ButtonUp


    CASE -64 'F6  'Make Bold
      HighPrint 7 + MenuRow, 7, Menu$()

      FOR CC = 1 TO UBOUND(Char$)
	FOR i = 1 TO 32 STEP 2
	  Byte1 = ASC(MID$(Char$(CC), i, 1))
	  Byte2 = ASC(MID$(Char$(CC), i + 1, 1))
	  Byte2 = Byte2 OR Byte2 \ 2
	  IF Byte1 AND 1 THEN Byte2 = Byte2 OR 128
	  Byte1 = Byte1 OR Byte1 \ 2
	  MID$(Char$(CC), i, 1) = CHR$(Byte1)
	  MID$(Char$(CC), i + 1, 1) = CHR$(Byte2)
	NEXT
      NEXT
      GOSUB Refresh

      HighPrint 1 + MenuRow, 1, Menu$()

      WHILE INKEY$ <> "": WEND
      ButtonUp

    CASE -65 'F7 Make Bold V

      HighPrint 8 + MenuRow, 8, Menu$()
   
      FOR CC = 1 TO UBOUND(Char$)
	Temp$ = Char$(CC)
	FOR i = 32 TO 3 STEP -1
	  MID$(Temp$, i, 1) = CHR$(ASC(MID$(Temp$, i, 1)) OR ASC(MID$(Char$(CC), i - 2, 1)))
	  Char$(CC) = Temp$
	NEXT
      NEXT
      GOSUB Refresh

      HighPrint 1 + MenuRow, 1, Menu$()
      ButtonUp

    CASE -66 'F8 Copy Letter

      HighPrint 9 + MenuRow, 9, Menu$()

      REDIM Msg$(0)
      Prompt$ = "Enter the letter to copy:"
      Text$ = " "
      InputBox Choice, Msg$(), Prompt$, Text$
      l$ = LTRIM$(Text$)

      IF Choice = 1 AND LEN(l$) THEN
	Char$(LastKy - 31) = Char$(ASC(l$) - 31)
	GOSUB Refresh
      END IF

      HighPrint 1 + MenuRow, 1, Menu$()

    CASE -67 'Clear Character

      HighPrint 10 + MenuRow, 10, Menu$()

      Char$(LastKy - 31) = STRING$(32, 0)
      GOSUB Refresh

      HighPrint 1 + MenuRow, 1, Menu$()
      ButtonUp


    CASE -68
      HighPrint 11 + MenuRow, 11, Menu$()

      Char$(LastKy - 31) = Undo$
      HideCursor
      GOSUB DrawChar  'Draw x1 reference character
      GOSUB Fixit     'Draw scaled characters
      ShowCursor
      HighPrint 1 + MenuRow, 1, Menu$()
      ButtonUp

    CASE -84 'Shift F1

      HelpLineClr = 9
      GOSUB DrawHelpLines
      LastBLine = BLine
      LastSLine = SLine
      HighPrint 12 + MenuRow, 12, Menu$()

      DO
	K$ = INKEY$
	SELECT CASE LEN(K$)
	  CASE 0
	    K = 0
	  CASE 1
	    K = ASC(K$)
	  CASE 2
	    K = -ASC(RIGHT$(K$, 1))
	END SELECT
	GetCursor Lx, Ly, Button
	IF Button = 2 THEN K = 27

	IF Lx > 57 AND Lx < 444 AND Ly > 17 AND Ly < 340 THEN

	  IF Button = 1 THEN
	    BLine = (Ly - 20) \ 20
	    SLine = (Lx - 60) \ 24
	  END IF

	END IF

	SELECT CASE K
	  CASE 13, 27
	    HelpLineClr = 14
	    GOSUB DrawHelpLines
	    EXIT DO

	  CASE -72 'Up
	    BLine = BLine - 1
	    IF BLine < 0 THEN BLine = 15

	  CASE -75 'Left
	    SLine = SLine - 1
	    IF SLine < 0 THEN SLine = 15

	  CASE -77 'Right
	    SLine = SLine + 1
	    IF SLine > 15 THEN SLine = 0

	  CASE -80 'Down
	    BLine = BLine + 1
	    IF BLine > 15 THEN BLine = 0

	END SELECT

	IF BLine <> LastBLine OR SLine <> LastSLine THEN
	  HideCursor
	  LINE (60, 39 + LastBLine * 20)-(443, 40 + LastBLine * 20), 0, B
	  LINE (83 + LastSLine * 24, 20)-(84 + LastSLine * 24, 339), 0, B
	  ShowCursor
	  GOSUB DrawHelpLines
	  GOSUB ShowBox
	  LastBLine = BLine
	  LastSLine = SLine
	END IF

      LOOP

      HighPrint 1 + MenuRow, 1, Menu$()
      ButtonUp


    CASE -85 'Shift F2   Inverse
     ' FOR i = 1 TO UBOUND(Char$)
     '   FOR Char = 1 TO 32
     '     MID$(Char$(i), Char, 1) = CHR$(ASC(MID$(Char$(i), Char, 1)) XOR 255)
     '   NEXT
     ' NEXT
     ' GOSUB Refresh

    CASE -141  'Ctrl Up
      HighPrint 14 + MenuRow, 14, Menu$()
      FOR i = 1 TO UBOUND(Char$)
	Char$(i) = MID$(Char$(i), 3) + LEFT$(Char$(i), 2)
      NEXT
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()

    CASE -145  'Ctrl Down
      HighPrint 14 + MenuRow, 14, Menu$()
      FOR i = 1 TO UBOUND(Char$)
	Char$(i) = MID$(Char$(i), 31) + LEFT$(Char$(i), 30)
      NEXT
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()

    CASE -115  'Ctrl Left
      HighPrint 14 + MenuRow, 14, Menu$()
      FOR CC = 1 TO UBOUND(Char$)
	FOR i = 1 TO 31 STEP 2
	  Byte1 = ASC(MID$(Char$(CC), i, 1))
	  Byte2 = ASC(MID$(Char$(CC), i + 1, 1))

	  IF Byte1 AND 128 THEN
	    B1OS = 1
	  ELSE
	    B1OS = 0
	  END IF

	  IF Byte2 AND 128 THEN
	    B2OS = 1
	  ELSE
	    B2OS = 0
	  END IF

	  Byte1 = (Byte1 * 2) MOD 256 + B2OS
	  Byte2 = (Byte2 * 2) MOD 256 + B1OS

	  MID$(Char$(CC), i, 1) = CHR$(Byte1)
	  MID$(Char$(CC), i + 1, 1) = CHR$(Byte2)


	NEXT
      NEXT
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      WHILE INKEY$ <> "": WEND

    CASE -116  'Ctrl Right
      HighPrint 14 + MenuRow, 14, Menu$()

      FOR CC = 1 TO UBOUND(Char$)
	FOR i = 1 TO 31 STEP 2
	  Byte1 = ASC(MID$(Char$(CC), i, 1))
	  Byte2 = ASC(MID$(Char$(CC), i + 1, 1))

	  IF Byte1 AND 1 THEN
	    B1OS = 128
	  ELSE
	    B1OS = 0
	  END IF

	  IF Byte2 AND 1 THEN
	    B2OS = 128
	  ELSE
	    B2OS = 0
	  END IF

	  Byte1 = Byte1 \ 2 + B2OS
	  Byte2 = Byte2 \ 2 + B1OS

	  MID$(Char$(CC), i, 1) = CHR$(Byte1)
	  MID$(Char$(CC), i + 1, 1) = CHR$(Byte2)

	NEXT
      NEXT
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      WHILE INKEY$ <> "": WEND

    CASE -152 'Alt up
      HighPrint 13 + MenuRow, 13, Menu$()
      Char$(LastKy - 31) = MID$(Char$(LastKy - 31), 3) + LEFT$(Char$(LastKy - 31), 2)
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      WHILE INKEY$ <> "": WEND

    CASE -160 'Alt down
      HighPrint 13 + MenuRow, 13, Menu$()
      Char$(LastKy - 31) = MID$(Char$(LastKy - 31), 31) + LEFT$(Char$(LastKy - 31), 30)
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      WHILE INKEY$ <> "": WEND

    CASE -157 'Alt right

      HighPrint 13 + MenuRow, 13, Menu$()
      FOR i = 1 TO 31 STEP 2
       Byte1 = ASC(MID$(Char$(LastKy - 31), i, 1))
	Byte2 = ASC(MID$(Char$(LastKy - 31), i + 1, 1))

	IF Byte1 AND 1 THEN
	  B1OS = 128
	ELSE
	  B1OS = 0
	END IF

	IF Byte2 AND 1 THEN
	  B2OS = 128
	ELSE
	  B2OS = 0
	END IF

	Byte1 = Byte1 \ 2 + B2OS
	Byte2 = Byte2 \ 2 + B1OS

	MID$(Char$(LastKy - 31), i, 1) = CHR$(Byte1)
	MID$(Char$(LastKy - 31), i + 1, 1) = CHR$(Byte2)

      NEXT
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      WHILE INKEY$ <> "": WEND

    CASE -155 'Alt left

      HighPrint 13 + MenuRow, 13, Menu$()
      FOR i = 1 TO 31 STEP 2
	Byte1 = ASC(MID$(Char$(LastKy - 31), i, 1))
	Byte2 = ASC(MID$(Char$(LastKy - 31), i + 1, 1))

	IF Byte1 AND 128 THEN
	  B1OS = 1
	ELSE
	  B1OS = 0
	END IF

	IF Byte2 AND 128 THEN
	  B2OS = 1
	ELSE
	  B2OS = 0
	END IF

	Byte1 = (Byte1 * 2) MOD 256 + B2OS
	Byte2 = (Byte2 * 2) MOD 256 + B1OS

	MID$(Char$(LastKy - 31), i, 1) = CHR$(Byte1)
	MID$(Char$(LastKy - 31), i + 1, 1) = CHR$(Byte2)

      NEXT
      GOSUB Refresh
      HighPrint 1 + MenuRow, 1, Menu$()
      WHILE INKEY$ <> "": WEND

  END SELECT

  IF X <> LastX OR Y <> LastY THEN
    GOSUB ClearBox
    LastX = X
    LastY = Y
    GOSUB ShowBox
  END IF


LOOP


Here:
    LINE (474, 40)-(491, 57), 7, B
    LINE (474, 60)-(491, 77), 7, B
    FOR t = 0 TO 15
      FOR S = 0 TO 15
	Fv = POINT(475 + t, 21 + S)
	PSET (475 + t, 41 + S), Fv
	PSET (475 + t, 61 + S), Fv
      NEXT
    NEXT
    LnCh$ = ""
    Ofs = 0

There:
    IF POINT(475 + (Ofs MOD 16), 21 + Ofs \ 16) = Front GOTO Lp1
    Ofs = Ofs + 1
    IF Ofs < 256 GOTO There
    LINE (474, 40)-(491, 77), 0, BF
    RETURN


Lp1:  'check to see if a line across would be valid
    Of2 = Ofs + 1
    bv = POINT(475 + (Of2 MOD 16), 41 + Of2 \ 16)
    WHILE Of2 MOD 16 > 0 AND bv = Front
       Of2 = Of2 + 1
       bv = POINT(475 + (Of2 MOD 16), 41 + Of2 \ 16)
    WEND
    IF Of2 > Ofs + 1 THEN
      bv = POINT(475 + (Ofs MOD 16), 41 + Ofs \ 16)
      LINE (475 + (Ofs MOD 16), 41 + Ofs \ 16)-(475 + ((Of2 - 1) MOD 16), 41 + (Of2 - 1) \ 16), Mark1
      LnCh$ = LnCh$ + CHR$(Ofs) + CHR$(Of2 - 1)
    END IF

    Of2 = Ofs + 16
    bv = POINT(475 + (Of2 MOD 16), 61 + Of2 \ 16)
    WHILE Of2 < 256 AND bv = Front
       Of2 = Of2 + 16
       bv = POINT(475 + (Of2 MOD 16), 61 + Of2 \ 16)
    WEND
    IF Of2 > Ofs + 16 THEN
      LINE (475 + (Ofs MOD 16), 61 + Ofs \ 16)-(475 + (Of2 MOD 16), 60 + Of2 \ 16), Mark2
      LnCh$ = LnCh$ + CHR$(Ofs) + CHR$(Of2 - 16)
    END IF

    IF POINT(475 + (Ofs MOD 16), 41 + Ofs \ 16) = Front AND POINT(475 + (Ofs MOD 16), 61 + Ofs \ 16) = Front THEN
       PSET (475 + (Ofs MOD 16), 41 + Ofs \ 16), Mark1
       LnCh$ = LnCh$ + CHR$(Ofs) + CHR$(Ofs)
    END IF

    Ofs = Ofs + 1
    GOTO There

Refresh:
  HideCursor
  GOSUB DrawChar  'Draw x1 reference character
  GOSUB Fixit     'Draw scaled characters
  ShowCursor
RETURN

ShowBox:
  HideCursor
  LINE (X * 24 + 60, Y * 20 + 20)-STEP(23, 19), 12, B
  LINE (X * 24 + 60 - 1, Y * 20 + 20 - 1)-STEP(25, 21), 12, B
  ShowCursor
RETURN


ClearBox:
  HideCursor

  LINE (LastX * 24 + 60, LastY * 20 + 20)-STEP(23, 19), 0, B
  LINE (LastX * 24 + 60 - 1, LastY * 20 + 20 - 1)-STEP(25, 21), 0, B

  ShowCursor
  GOSUB DrawHelpLines
RETURN

DrawHelpLines:
  HideCursor
  LINE (60, 39 + BLine * 20)-(443, 40 + BLine * 20), HelpLineClr, B
  LINE (83 + SLine * 24, 20)-(84 + SLine * 24, 339), HelpLineClr, B
  ShowCursor
RETURN







Fixit:
  FOR FT = 0 TO 15
    FOR FS = 0 TO 15
      Fv = POINT(475 + FT, 21 + FS)
      LINE (61 + FT * 24, 21 + FS * 20)-(58 + (FT + 1) * 24, 18 + (FS + 1) * 20), Fv, BF
'      LINE (497 + FT * 1.5, 21 + FS * 1.5)-(497 + (FT + 1) * 1.5, 21 + (FS + 1) * 1.5), Fv, BF
      IF Enable2To1 THEN LINE (530 + FT * 2, 21 + FS * 2)-(531 + FT * 2, 22 + FS * 2), Fv, BF
'      LINE (570 + FT * 4, 21 + FS * 4)-(573 + FT * 4, 24 + FS * 4), Fv, BF
    NEXT
  NEXT
RETURN

FixPoint:
  HideCursor
  Fv = POINT(475 + X, 21 + Y)
  LINE (61 + X * 24, 21 + Y * 20)-(58 + (X + 1) * 24, 18 + (Y + 1) * 20), Fv, BF
 ' LINE (497 + X * 1.5, 21 + Y * 1.5)-(497 + (X + 1) * 1.5, 21 + (Y + 1) * 1.5), Fv, BF
   IF Enable2To1 THEN LINE (530 + X * 2, 21 + Y * 2)-(531 + X * 2, 22 + Y * 2), Fv, BF
 ' LINE (570 + X * 4, 21 + Y * 4)-(573 + X * 4, 24 + Y * 4), Fv, BF
  ShowCursor
RETURN


DrawChar:
  LINE (475, 21)-(490, 36), Back, BF

  Cnt = 0
  FOR N = 1 TO 32 STEP 2
    a$ = MID$(Char$(LastKy - 31), N, 1)
    B$ = MID$(Char$(LastKy - 31), N + 1, 1)
    Ll$ = B$ + a$
    Tle = CVI(Ll$)
    LINE (475, 21 + Cnt)-STEP(15, 0), Front, , Tle
    Cnt = Cnt + 1
  NEXT

RETURN


ToggleBit:
  Edited = -1
  Byte = (X \ 8 + 1) + (Y * 2)
  BitCol = X + 1
  IF BitCol > 8 THEN BitCol = X - 7
  ByteVal = ASC(MID$(Char$(LastKy - 31), Byte, 1))

  Bit = 2 ^ (8 - BitCol)
  IF Bit = 0 THEN Bit = 1

  '---- Is bit set?
  IF ByteVal AND Bit THEN       'Its set
    ByteVal = ByteVal XOR Bit   'Turn it off
  ELSE
    ByteVal = ByteVal OR Bit    'Turn it on
  END IF

  MID$(Char$(LastKy - 31), Byte, 1) = CHR$(ByteVal)

RETURN


BitOn:
  Edited = -1
  Byte = (X \ 8 + 1) + (Y * 2)
  BitCol = X + 1

  IF BitCol > 8 THEN BitCol = X - 7
  ByteVal = ASC(MID$(Char$(LastKy - 31), Byte, 1))

  Bit = 2 ^ (8 - BitCol)
  IF Bit = 0 THEN Bit = 1

  ByteVal = ByteVal OR Bit   'Turn it off
  MID$(Char$(LastKy - 31), Byte, 1) = CHR$(ByteVal)

RETURN

BitOff:
  Edited = True
  Byte = (X \ 8 + 1) + (Y * 2)
  BitCol = X + 1
  IF BitCol > 8 THEN BitCol = X - 7
  ByteVal = ASC(MID$(Char$(LastKy - 31), Byte, 1))

  Bit = 2 ^ (8 - BitCol)
  IF Bit = 0 THEN Bit = 1

  IF ByteVal AND Bit THEN       'If the bit is set,
    ByteVal = ByteVal XOR Bit   ' turn it off
  END IF
  MID$(Char$(LastKy - 31), Byte, 1) = CHR$(ByteVal)

RETURN

SaveChar:
  HideCursor
  FOR t = 0 TO 31         'Save bit pattern
    B = 0
    IF t \ 2 <> t / 2 THEN B = 8
    a = 0
    FOR T1 = 0 TO 7
      XPoint = T1 + B
      YPoint = t \ 2
      IF POINT(475 + XPoint, 21 + YPoint) = Front THEN a = a + 2 ^ (7 - T1)
    NEXT
    MID$(Char$(LastKy - 31), t + 1, 1) = CHR$(a)
  NEXT
  ShowCursor
  Edited = 0
RETURN


'---- Handle errors that can occur when saving the file
ErrHandler:

  BEEP

  '---- Determine appropriate error message
  SELECT CASE ERR
    CASE 52, 64
      Msg$ = "Bad file name."
    CASE 61
      Msg$ = "Disk full."
    CASE 70
      Msg$ = "Permission denied."
    CASE 71
      Msg$ = "Disk not ready."
    CASE 75, 76
      Msg$ = "Path/File access error."
    CASE ELSE
      Msg$ = "Error" + STR$(ERR) + " occurred."
  END SELECT


  REDIM Msg$(3)
  Msg$(1) = SPACE$(15 - LEN(Msg$) \ 2) + Msg$
  Msg$(2) = "Correct the error to try again"
  Msg$(3) = "  or press Escape to cancel."


  SELECT CASE Ky
    CASE -61       'Load GPK
      RESUME LoadGPK

    CASE -63
      RESUME SaveGPK

    CASE -60       'Make GFN file
      LSET Buf$ = FontName$
      Text$ = Buf$
      InputBox Choice, Msg$(), Prompt$, Text$

      RESUME SaveGFN         'Let 'em try again

  END SELECT

  CLOSE

ShowFontName:
  LSET FileBuf$ = NoPath$(GPKName$) + ".GPK"
  HideCursor
  GPrint0VE 24, MenuCol, " Font: " + FileBuf$, 15 + 256
  ShowCursor
RETURN


DisplayMenu:
  HideCursor
  LINE (451, 121)-STEP(184, 220), 1, BF
  LINE (451, 121)-STEP(184, 220), 7, B
  HighPrint 1 + MenuRow, 1, Menu$()
  ShowCursor
RETURN

DoNothing:   'Dummy label for handling KILL filename$ errors
RESUME NEXT

SUB Box3D (X1, Y1, X2, y2, Drop)

  Clr1 = 15
  Clr2 = 8
  IF Drop THEN SWAP Clr1, Clr2
  LineVE X1, Y1, X2, Y1, Clr1
  LineVE X1, Y1, X1, y2, Clr1
  LineVE X1, y2, X2, y2, Clr2
  LineVE X2, Y1, X2, y2, Clr2

END SUB

SUB ButtonUp

  '---- Wait til all mouse buttons are released
  DO
    GetCursor X, Y, Button
  LOOP WHILE Button

END SUB

FUNCTION FindLastChar (Char$())

  FOR i = UBOUND(Char$) TO 1 STEP -1
    IF Char$(i) <> STRING$(32, 0) THEN
      FindLastChar = i + 31
      EXIT FUNCTION
    END IF
  NEXT
  
END FUNCTION

SUB HelpScrn

  ON ERROR RESUME NEXT

  HelpFile$ = "FONTS.HLP"

  OPEN HelpFile$ FOR INPUT AS #1
  IF ERR THEN
    BEEP
    EXIT SUB
  END IF

  REDIM Help$(300)

  DO WHILE NOT EOF(1)
    Count = Count + 1
    LINE INPUT #1, Help$(Count)
  LOOP
  CLOSE #1
  
  IF ERR THEN
    BEEP
    EXIT SUB
  END IF

  '---- Delete E's formating character
  Help$(1) = RIGHT$(Help$(1), LEN(Help$(1)) - 1)

  NumPages = Count \ 23
  IF NumPages * 23 < Count THEN NumPages = NumPages + 1

  PrnBuf$ = SPACE$(78)
  PageBuf$ = SPACE$(2 + (NumPages < 10))

  FG = 15
  BG = 1
  TxtFG = 7

  HideCursor
  PCOPY 0, 1

  LineBFVE 0, 0, 640, 350, 1
  LineBVE 3, 3, 637, 344, 15

  GPrint0VE 1, 28, " FONTS.EXE Help Window ", FG + 256
  GPrint0VE 25, 60, " PgUp/PgDn/Up/Down ", 14 + 256
  Temp$ = " Page" + SPACE$(2 + (NumPages < 10)) + "1 of" + STR$(NumPages) + " "
  GPrint0VE 25, 3, Temp$, 14 + 256
  
  ShowCursor

  Start = 1
  Finish = 23
  PageNo = 1
  GOSUB PrintArray

  DO
    Ky$ = INKEY$

    SELECT CASE LEN(Ky$)
      CASE 0
	Ky = 0
      CASE 1
	Ky = ASC(Ky$)
      CASE 2
	Ky = -ASC(RIGHT$(Ky$, 1))
    END SELECT

    GetCursor Mx, My, Button
    IF Button THEN Ky = 13

    SELECT CASE Ky
      CASE 27, 13
	EXIT DO

      CASE -80, -81   'Down arrow, PgDn
	IF Start < Count - 22 THEN
	  Start = Start + 23
	  IF Start + 23 > Count THEN
	    Start = Count - 22
	  END IF
	  PageNo = PageNo + 1
	  GOSUB PrintArray
	END IF

      CASE -72, -73   'Up Arrow, PgUp
	IF Start <> 1 THEN
	  Start = Start - 23
	  IF Start < 1 THEN Start = 1
	  PageNo = PageNo - 1
	  GOSUB PrintArray
	END IF

    END SELECT

  LOOP

  DO
    GetCursor X, Y, Button
  LOOP WHILE Button

  HideCursor
  PCOPY 1, 0
  ShowCursor

EXIT SUB


PrintArray:
  HideCursor
  Finish = Start + 22

  Row = 1
  FOR i = Start TO Finish
    Row = Row + 1
    LSET PrnBuf$ = Help$(i)
    GPrint0VE Row, 2, PrnBuf$, TxtFG + BG * 256
  NEXT

  RSET PageBuf$ = LTRIM$(STR$(PageNo))
  GPrint0VE 25, 9, PageBuf$, 14 + BG * 256
  ShowCursor

RETURN


END SUB

SUB HighPrint (Row, HiEl, Menu$())

  SHARED MenuRow, MenuCol, MenuHiClr, MenuClr

  HideCursor
  FOR i = 1 TO UBOUND(Menu$)
    GPrint0VE i + MenuRow, MenuCol, Menu$(i), MenuClr
  NEXT

  GPrint0VE Row, MenuCol, Menu$(HiEl), MenuHiClr
  ShowCursor

END SUB

SUB InputBox (Choice, Msg$(), Prompt$, Text$)

  Choice = 0
  Ht = (UBOUND(Msg$) + 4) * GPDat(71)
  Wdth = (LongestString(Msg$()) + 4)
  l = LEN(Prompt$) + LEN(Text$) + 4
  IF l > Wdth THEN
    Wdth = l * 8
  ELSE
    Wdth = Wdth * 8
  END IF

  HCtr = 320
  VCtr = 175
  Top = VCtr - Ht \ 2
  LSide = HCtr - Wdth \ 2
  TopRow = Top \ GPDat(71) + 1
  LCol = LSide \ 8 + 2

  HideCursor
  PCOPY 0, 1
  LineBFVE LSide, Top, LSide + Wdth - 1, Top + Ht - 1, 7
  Box3D LSide, Top, LSide + Wdth - 1, Top + Ht - 1, 0
  Box3D LSide + 4, Top + 8, LSide + Wdth - 4, Top + Ht - 4, -1
  LineBVE LSide + 5, Top + 9, LSide + Wdth - 5, Top + Ht - 5, 0
  
  FOR i = 1 TO UBOUND(Msg$)
    GPrint0VE TopRow + i, LCol + 1, Msg$(i), 7 * 256
  NEXT
  
  GPrint0VE TopRow + i + 1, LCol + 1, Prompt$, 7 * 256
  LeftCol = LCol + LEN(Prompt$) + 2
  Box3D LeftCol * 8 - 9, (TopRow + i) * GPDat(71) - 1, (LeftCol + LEN(Text$) - 1) * 8, (TopRow + i + 1) * GPDat(71), -1
  Edit$ = Text$
  
  LOCATE TopRow + i + 1, LeftCol + LEN(RTRIM$(Text$))
  DO
    GEditor Edit$, LeftCol, KeyCode, TxtPos
  LOOP UNTIL KeyCode = 13 OR KeyCode = 27

  IF KeyCode = 13 THEN
    Choice = 1
    Text$ = Edit$
  END IF

  PCOPY 1, 0
  ShowCursor


END SUB

FUNCTION LongestString (Array$())
  'Returns the length of the longest string in Array$()

  FOR i = 1 TO UBOUND(Array$)
    l = LEN(Array$(i))
    IF l > Longest THEN Longest = l
  NEXT

  LongestString = Longest

END FUNCTION

FUNCTION NoPath$ (FileSpec$)

  NoPath$ = FileSpec$

  l = LEN(FileSpec$)
  FOR i = l TO 1 STEP -1
    X = ASC(MID$(FileSpec$, i, 1))
    IF X = 58 OR X = 92 THEN              ': or \
      NoPath$ = MID$(FileSpec$, i + 1)
      EXIT FUNCTION
    END IF
  NEXT

END FUNCTION

SUB PrintRefChar (Ky)

  COLOR 15
  LOCATE 8, 59
  PRINT "Char ("; CHR$(34); CHR$(Ky); CHR$(34); ") ASCII"; Ky

END SUB

SUB ViewFont (Char$(), Cols, CurrentChar)


  SHARED MenuRow, MenuCol
  LineTile = -21846
  BackClr = 15
  LastChar = FindLastChar(Char$())

  REDIM ChartMenu$(14)
  ChartMenu$(1) = "Select Character"
  ChartMenu$(2) = "F1 - Swap  "
  ChartMenu$(3) = "F2 - Copy  "
  ChartMenu$(4) = "F3 - Clear "
  FOR i = 5 TO 14
    ChartMenu$(i) = SPACE$(14)
  NEXT

  MaxChar = FindLastChar%(Char$()) - 31

  IF MaxChar = -31 THEN     'No characters to show!
    BEEP
    EXIT SUB
  END IF

  NumRows = MaxChar \ Cols
  IF NumRows * Cols < MaxChar THEN NumRows = NumRows + 1

  Border = 20
  Ht = NumRows * 20 + Border
  Wdth = Cols * 16 + Border
  TopLine = 175 - Ht \ 2
  Left = 252 - Wdth \ 2

  HideCursor
  PCOPY 0, 1

  LINE (450, 121)-STEP(184, 220), 1, BF
  LINE (450, 121)-STEP(184, 220), 7, B
  HighPrint 1 + MenuRow, 1, ChartMenu$()

  LINE (Left, TopLine)-STEP(Wdth, Ht), BackClr, BF

  LINE (Left, TopLine)-STEP(Wdth, Ht), 0, B
  LINE (Left + 2, TopLine + 2)-STEP(Wdth - 4, Ht - 4), 0, B
  LINE (Left + 3, TopLine + 3)-STEP(Wdth - 6, Ht - 6), 1, B
  LINE (Left + 4, TopLine + 4)-STEP(Wdth - 8, Ht - 8), 0, B

  Fontx = Left + Border \ 2
  Fonty = TopLine + Border \ 2

  FOR Y = Fonty TO Fonty + ((NumRows - 1) * 20) STEP 20
    FOR X = Fontx TO Left + Wdth - 16 - Border \ 2 STEP 16
      El = El + 1
      Cnt = 0
      IF El > MaxChar THEN EXIT FOR
      Clr = 0
      IF El = CurrentChar THEN Clr = 12
      LINE (X, Y)-STEP(15, 15), 7, B', LineTile

      FOR N = 1 TO 32 STEP 2
	a$ = MID$(Char$(El), N, 1)
	B$ = MID$(Char$(El), N + 1, 1)
	Ll$ = B$ + a$
	Tle = CVI(Ll$)

	LINE (X, Y + Cnt)-STEP(15, 0), Clr, , Tle
	Cnt = Cnt + 1
      NEXT
    NEXT
  NEXT

  ShowCursor
  El = CurrentChar
  Selecting = -1
  DO
    Ky$ = INKEY$

    SELECT CASE LEN(Ky$)
      CASE 0
	Ky = 0
      CASE 1
	Ky = ASC(Ky$)
      CASE 2
       Ky = -ASC(RIGHT$(Ky$, 1))
    END SELECT

    GetCursor Mx, My, Button

    IF Button = 1 THEN
      IF Mx > 463 AND Mx < 631 AND My > 139 AND My < 335 THEN
	Ky = -(((My - 140) \ 14) + 59)
      ELSEIF Mx >= Fontx - 1 AND Mx < Fontx + 16 * Cols - 1 THEN
	IF My > Fonty AND My < Fonty + NumRows * 20 THEN
	  FontCol = (Mx - Fontx + 1) \ 16 + 1
	  FontRow = (My - Fonty + 1) \ 20 + 1
	  CharEl = FontCol + (FontRow - 1) * Cols
	  Ky = CharEl + 31
	END IF
      END IF
    ELSE
      IF Button > 1 THEN EXIT DO
    END IF


    SELECT CASE Ky

      CASE 43 '+
	IF Selecting THEN
	  Clr = 0
	  GOSUB PrintChar
	  El = El + 1
	  IF El > LastChar THEN El = 1
	  Ky = El + 31
	  CurrentChar = El
	  Clr = 12
	  GOSUB PrintChar
	  PrintRefChar Ky
	END IF

      CASE 45 '-
	IF Selecting THEN
	  Clr = 0
	  GOSUB PrintChar
	  El = El - 1
	  IF El < 1 THEN El = LastChar
	  Ky = El + 31
	  CurrentChar = El
	  Clr = 12
	  GOSUB PrintChar
	  PrintRefChar Ky
	END IF

      CASE 33 TO 255

	IF Ky <= MaxChar + 32 THEN
	  IF Selecting THEN
	    PrintRefChar Ky
	    Clr = 0
	    GOSUB PrintChar
	    El = Ky - 31
	    CurrentChar = El
	    Clr = 12
	    GOSUB PrintChar
	    DO
	      GetCursor Mx, My, Button
	    LOOP UNTIL Button = 0
	  ELSE
	    PrintRefChar Ky
	    El = Ky - 31
	    CurrentChar = El

	    SELECT CASE Operation
	      CASE 1 'Swap
		SWAP Char$(SwapChar), Char$(El)
		El = SwapChar
		Clr = 0
		GOSUB PrintChar
		El = CurrentChar
		Clr = 12
		GOSUB PrintChar
		LINE ((MenuCol - 1) * 8, 318)-STEP(167, 22), 1, BF
		Selecting = -1
		HighPrint 1 + MenuRow, 1, ChartMenu$()
		ButtonUp

	      CASE 2 'Copy
		Char$(CurrentChar) = Char$(CopyChar)
		El = CopyChar
		Clr = 0
		GOSUB PrintChar
		El = CurrentChar
		Clr = 12
		GOSUB PrintChar
		LINE ((MenuCol - 1) * 8, 318)-STEP(167, 22), 1, BF
		Selecting = -1
		HighPrint 1 + MenuRow, 1, ChartMenu$()
		ButtonUp

	    END SELECT
	  END IF
	END IF

      CASE -59 'F1 Swap
	Selecting = 0
	HighPrint 2 + MenuRow, 2, ChartMenu$()
	t$ = "Swap `  ' with..."
	Clr = 2
	GOSUB PrintChar
	GOSUB PrintPrompt
	Operation = 1
	SwapChar = El
	ButtonUp

      CASE -60 'F2 Copy
	Selecting = 0
	HighPrint 3 + MenuRow, 3, ChartMenu$()
	t$ = "Copy `  ' to..."
	Clr = 9
	GOSUB PrintChar
	GOSUB PrintPrompt
	Operation = 2
	CopyChar = CurrentChar
	ButtonUp

      CASE -61 'F3 Clear
	HighPrint 4 + MenuRow, 4, ChartMenu$()
	Operation = 3
	Char$(CurrentChar) = STRING$(32, 0)
	GOSUB PrintChar
	HighPrint 1 + MenuRow, 1, ChartMenu$()
	ButtonUp

      CASE 27
	IF Selecting THEN
	  EXIT DO
	ELSE
	  Selecting = -1
	  Clr = 12
	  GOSUB PrintChar
	  HighPrint 1 + MenuRow, 1, ChartMenu$()
	  LINE ((MenuCol - 1) * 8, 318)-STEP(167, 22), 1, BF
	END IF
	ButtonUp

    END SELECT

  LOOP

  DO
    GetCursor X, Y, Button
  LOOP WHILE Button

  HideCursor
  PCOPY 1, 0
  ShowCursor

EXIT SUB


PrintChar:
  FCol = El MOD Cols
  IF FCol = 0 THEN FCol = Cols
  X = Fontx + ((FCol - 1) * 16)
  
  Y = Fonty + ((El \ Cols + (FCol = Cols)) * 20)
  Cnt = 0

  HideCursor
  LINE (X, Y)-STEP(15, 15), BackClr, BF
  LINE (X, Y)-STEP(15, 15), 7, B', LineTile
  FOR N = 1 TO 32 STEP 2
    a$ = MID$(Char$(El), N, 1)
    B$ = MID$(Char$(El), N + 1, 1)
    Ll$ = B$ + a$
    Tle = CVI(Ll$)

    LINE (X, Y + Cnt)-STEP(15, 0), Clr, , Tle
    Cnt = Cnt + 1
  NEXT
  ShowCursor
RETURN

PrintPrompt:
  HideCursor
  GPrint0VE 24, MenuCol, t$, 15 + 1 * 256
  Y1 = 321
  X1 = (MenuCol + 5) * 8
  LINE (X1, Y1)-STEP(15, 19), 1, BF
  GOSUB SampleChar
  ShowCursor
RETURN

SampleChar:
  Cnt = 0
  FOR N = 1 TO 32 STEP 2
    a$ = MID$(Char$(El), N, 1)
    B$ = MID$(Char$(El), N + 1, 1)
    Ll$ = B$ + a$
    Tle = CVI(Ll$)
    LINE (X1, Y1 + Cnt)-STEP(15, 0), 15, , Tle
    Cnt = Cnt + 1
  NEXT
RETURN

END SUB

