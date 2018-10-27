'***** QuickSegue - A complete presentation program for displaying PCX files
'                   Takes an input file (default is QSegue.In) and reads a
'                   script in the file to tell it what to do.

'Copyright 1990, Brian C. Giedt

'This demonstrates the routines:
'   TransferEGA - An assembler subroutine which transfers a portion of the
'                 screen from the background video page to the foreground
'                 video page.  TransferEGA is used by all the Segues in
'                 QuickSegue to bring the screen forward.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DisplayBoxFill (GWWindow AS Window1)
DECLARE SUB DoSegue1 (SubType%, SegueColor%, Delay%)
DECLARE SUB DoSegue2 (SubType%, SegueColor%, Delay%)
DECLARE SUB DoSegue3 (SubType%, SegueColor%, Delay%)
DECLARE SUB DoSegue4 (SubType%, SegueColor%, Delay%)
DECLARE SUB DoSegue5 (SubType%, SegueColor%, Delay%)
DECLARE SUB DoSegue6 (SubType%, SegueColor%, Delay%)
DECLARE SUB HadAnError ()
DECLARE SUB SendArray (Array%())
DECLARE SUB Interlude1 (Segue$)

'$INCLUDE: 'GetVideo.Bas'

'$INCLUDE: 'GPFont.GW'
FontFile$ = "HELV12"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

'$INCLUDE: 'GWFont.GW'
FontFile$ = "HELV"
CALL SetGWFont(1)               'specify loading font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array

    REDIM Array1%(0), Array2%(0), Array3%(0), Array4%(0), Array5%(0)
    REDIM Array6%(0), Array7%(0), Array8%(0), Array9%(0), Array0%(0)
    DIM GWWindow AS Window1

    CALL SetGPSpacing(2, 2)

    GPDat%(31) = 5   'Force EGA monitor
   
    CALL SetVideo

    Filename$ = "QSegue.IN"
    
    IF COMMAND$ <> "" THEN
      Filename$ = COMMAND$
    END IF

    OPEN "I", 1, Filename$

    WHILE NOT EOF(1)
      LINE INPUT #1, B$
      Quoted = 0
      FOR T = 1 TO LEN(B$)
	L = ASC(MID$(B$, T, 1))
	IF L = 34 THEN Quoted = NOT Quoted
	IF NOT Quoted THEN
	  IF L >= ASC("a") AND L <= ASC("z") THEN MID$(B$, T, 1) = CHR$(L - 32)
	END IF
      NEXT

      IF LEFT$(B$, 4) = "LOAD" THEN
	B$ = MID$(B$, 6)
	L = INSTR(B$, " ")
	IF L > 0 THEN
	  Filename$ = LEFT$(B$, L - 1)
	  ArrayNum = VAL(MID$(B$, L + 1))
	  GOSUB LoadCMPTFile
	ELSE
	  CALL HadAnError
	END IF
      ELSEIF LEFT$(B$, 2) = "DO" THEN
	L = VAL(MID$(B$, 4))
	SELECT CASE L
	  CASE 1
	    GWWindow.X1 = 290
	    GWWindow.X2 = 315
	    GWWindow.Y1 = 150
	    GWWindow.Y2 = 250
	    CALL DisplayBoxFill(GWWindow)
	    FOR G = 1 TO 75
	      CALL DisplayBoxFill(GWWindow)
	      GWWindow.X1 = GWWindow.X1 - 2
	      GWWindow.Y2 = GWWindow.Y2 + 1
	      CALL DisplayBoxFill(GWWindow)
	    NEXT
	  CASE 2
	  CASE ELSE
	END SELECT
      ELSEIF LEFT$(B$, 9) = "INTERLUDE" THEN
	L = VAL(MID$(B$, 11))
	B$ = MID$(B$, 14, LEN(B$) - 14)
	IF L = 1 THEN
	  CALL LineBFVE(0, 0, GPDat%(43), GPDat%(44), 1)
	  CALL Interlude1(B$)
	ELSEIF L = 2 THEN
	  CALL Interlude1(B$)
	END IF
      ELSEIF LEFT$(B$, 6) = "LOCATE" THEN
	L = INSTR(B$, ",")
	X$ = MID$(B$, 8, L - 8)
	Y$ = MID$(B$, L + 1)
	IF MID$(Y$, 1, 1) = " " THEN Y$ = MID$(Y$, 2)
      ELSEIF LEFT$(B$, 5) = "PRINT" THEN
	B$ = MID$(B$, 8, LEN(B$) - 8)
	IF X$ = "LEFT" THEN
	  X1 = 8
	ELSEIF X$ = "RIGHT" THEN
	  X1 = GPDat%(43) - 8 - GetWidth(B$)
	ELSEIF X$ = "MIDDLE" THEN
	  X1 = (GPDat%(43) - GetWidth(B$)) / 2
	END IF
	IF Y$ = "TOP" THEN
	  Y1 = 8
	ELSEIF Y$ = "BOTTOM" THEN
	  Y1 = GPDat%(44) - 20
	ELSEIF Y$ = "MIDDLE" THEN
	  Y1 = (GPDat%(44) - 20) / 2
	END IF
	CALL DrawText(X1, Y1, B$, 0, 15, 1#)
      ELSEIF LEFT$(B$, 5) = "PAUSE" THEN
	WHILE INKEY$ <> "": WEND
	I$ = ""
	WHILE I$ = "": I$ = INKEY$: WEND
	IF I$ = CHR$(27) THEN END
      ELSEIF LEFT$(B$, 4) = "SEND" THEN
	ArrayNum = VAL(MID$(B$, 6))
	SELECT CASE ArrayNum
	  CASE 1
	    CALL SendArray(Array1%())
	  CASE 2
	    CALL SendArray(Array2%())
	  CASE 3
	    CALL SendArray(Array3%())
	  CASE 4
	    CALL SendArray(Array4%())
	  CASE 5
	    CALL SendArray(Array5%())
	  CASE 6
	    CALL SendArray(Array6%())
	  CASE 7
	    CALL SendArray(Array7%())
	  CASE 8
	    CALL SendArray(Array8%())
	  CASE 9
	    CALL SendArray(Array9%())
	  CASE 0
	    CALL SendArray(Array0%())
	  CASE ELSE
	END SELECT
      ELSEIF LEFT$(B$, 5) = "CLEAR" THEN
	ArrayNum = VAL(MID$(B$, 7))
	SELECT CASE ArrayNum
	  CASE 1
	    ERASE Array1%
	  CASE 2
	    ERASE Array2%
	  CASE 3
	    ERASE Array3%
	  CASE 4
	    ERASE Array4%
	  CASE 5
	    ERASE Array5%
	  CASE 6
	    ERASE Array6%
	  CASE 7
	    ERASE Array7%
	  CASE 8
	    ERASE Array8%
	  CASE 9
	    ERASE Array9%
	  CASE 0
	    ERASE Array0%
	  CASE ELSE
	END SELECT
      ELSEIF LEFT$(B$, 5) = "SEGUE" THEN
	GOSUB DoSegue
      END IF
    WEND

    END



'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ Subrotines \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
'\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


LoadCMPTFile:
   'Find the size of the file to determine the size of the array
   Size& = GWFileSize&(Filename$)
   ArraySize = CINT(Size& \ 2) + 1
   SELECT CASE ArrayNum
     CASE 1
       REDIM Array1%(0)
     CASE 2
       REDIM Array2%(0)
     CASE 3
       REDIM Array3%(0)
     CASE 4
       REDIM Array4%(0)
     CASE 5
       REDIM Array5%(0)
     CASE 6
       REDIM Array6%(0)
     CASE 7
       REDIM Array7%(0)
     CASE 8
       REDIM Array8%(0)
     CASE 9
       REDIM Array9%(0)
     CASE 10
       REDIM Array0%(0)
     CASE ELSE
   END SELECT
   F& = FRE(-1)
   IF ArraySize > F& THEN
       PRINT "Ran Out of memory for PCX arrays"
       END
   END IF
   SELECT CASE ArrayNum
     CASE 1
       REDIM Array1%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array1%(0))
     CASE 2
       REDIM Array2%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array2%(0))
     CASE 3
       REDIM Array3%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array3%(0))
     CASE 4
       REDIM Array4%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array4%(0))
     CASE 5
       REDIM Array5%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array5%(0))
     CASE 6
       REDIM Array6%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array6%(0))
     CASE 7
       REDIM Array7%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array7%(0))
     CASE 8
       REDIM Array8%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array8%(0))
     CASE 9
       REDIM Array9%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array9%(0))
     CASE 10
       REDIM Array0%(ArraySize)
       Success = QBinaryLoad(Filename$, SEG Array0%(0))
     CASE ELSE
   END SELECT
   IF NOT Success% THEN
       PRINT "An Error has occured loading file "; Filename$
       END
   END IF
   RETURN

DoSegue:
   SegueNum = VAL(MID$(B$, 7, 2))
   L = INSTR(7, B$, " ") + 1
   SubType = VAL(MID$(B$, L, 2))
   L = INSTR(L, B$, " ") + 1
   SegueColor = VAL(MID$(B$, L, 2))
   L = INSTR(L, B$, " ") + 1
   Delay = VAL(MID$(B$, L))
   SELECT CASE SegueNum
     CASE 1
       CALL DoSegue1(SubType, SegueColor, Delay)
     CASE 2
       CALL DoSegue2(SubType, SegueColor, Delay)
     CASE 3
       CALL DoSegue3(SubType, SegueColor, Delay)
     CASE 4
       CALL DoSegue4(SubType, SegueColor, Delay)
     CASE 5
       CALL DoSegue5(SubType, SegueColor, Delay)
     CASE 6
       CALL DoSegue6(SubType, SegueColor, Delay)
     CASE 7
       'CALL DoSegue7(SubType, SegueColor, Delay)
     CASE 8
       'CALL DoSegue8(SubType, SegueColor, Delay)
     CASE 9
       'CALL DoSegue9(SubType, SegueColor, Delay)
     CASE ELSE
   END SELECT
   RETURN


'+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
'+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
'+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

SUB FireWorks STATIC

    Pie! = 3.141529

FOR S = 1 TO 25
    S1! = 19 * Pie! / 32
    S2! = 13 * Pie! / 32
    X = RND * 600 + 20
    s3 = RND * 100 + 70
    Y = RND * 200 + s3
    s4 = RND * 7 + 9
    S5! = .015
    FOR T = 1 TO 29
	S1! = S1! + S5!
	S2! = S2! - S5!
	S5! = S5! + .002
    NEXT
    FOR T = 1 TO 1
	CIRCLE (X, Y), s3, s4, Pie! / 2, S1!, 3.5
	CIRCLE (X, Y), s3, s4, Pie! / 2, S1! * 1.02, 4.5
	CIRCLE (X, Y), s3, s4, Pie! / 2, S1!, 2.5
	CIRCLE (X, Y), s3, s4, Pie! / 2, S1! * 1.015, 7.5
	CIRCLE (X, Y), s3, s4, Pie! / 2, S1! * 1.024, 14.5
	CIRCLE (X, Y), s3, s4, S2! * 1.024, Pie! / 2, 3.5
	CIRCLE (X, Y), s3, s4, S2!, Pie! / 2, 4.5
	CIRCLE (X, Y), s3, s4, S2! * 1.06, Pie! / 2, 2.5
	CIRCLE (X, Y), s3, s4, S2! * 1.037, Pie! / 2, 7.5
	CIRCLE (X, Y), s3, s4, S2! * 1.014, Pie! / 2, 14.5
    NEXT
NEXT

END SUB

SUB HadAnError STATIC

   PRINT "ERROR"
   END

END SUB

SUB SendArray (Array%()) STATIC

   VA% = VARSEG(Array%(0))          'Obtain the Segment of the array
   CALL PCXArrayVE(VA%, 1)

END SUB

