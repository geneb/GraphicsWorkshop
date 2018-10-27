' **** VIEWPCX.BAS - Loads a pcx from a DOS Prompt.

' Copyright 1990 Brian C. Giedt
'
' To Compile VIEWPCX.EXE use:
'
' BC VIEWPCX/O;
' BC PCXHEADR/O;
' LINK /E /NOE VIEWPCX+PCXHEADR,,NUL,GW.LIB;


DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB WhichPCXScreen (Array$, WhichScreen%)
DECLARE SUB HandlePCXPalette (Array$, WhichScreen%)

'$INCLUDE: 'GetVideo'

'This program is set up to be used as an EXE.  The variable COMMAND$ tells
'the program what parameters where specified on the command line when the
'EXE is executed.  The COMMAND$ can be set using the Run Menu in QuickBASIC.
   Filename$ = COMMAND$
   IF Filename$ = "" THEN
     PRINT "No .PCX Filename specified on command line."
     INPUT "Filename:", Filename$
   END IF
   L = INSTR(Filename$, ".")
   IF L = 0 THEN Filename$ = Filename$ + ".PCX"

   Array$ = SPACE$(68 + 768)
   IF NOT OpenPCXFile(Filename$, Array$) THEN
     PRINT "File Not Found"
     END
   END IF

   CALL WhichPCXScreen(Array$, WhichScreen)

   IF GPDat(31) = 4 THEN
      IF WhichScreen = 4 OR WhichScreen = 6 THEN
	GPDat(31) = WhichScreen
      ELSEIF WhichScreen = 2 AND (GPMonitor% AND &H1) THEN
	GPDat(31) = WhichScreen
      ELSE
	END
      END IF
   ELSEIF (GPDat(31) = 5) OR (GPDat(31) = 1) THEN
      IF WhichScreen = 6 THEN WhichScreen = 5
      IF WhichScreen = 2 AND (GPMonitor% AND &H1) = 0 THEN END
      IF WhichScreen = 9 THEN END
      GPDat(31) = WhichScreen
   ELSEIF (GPDat(31) = 8) OR (GPDat(31) = 7) THEN
      IF WhichScreen = 6 THEN WhichScreen = 8
      IF WhichScreen = 2 AND (GPMonitor% AND &H1) = 0 THEN END
      GPDat(31) = WhichScreen
   ELSEIF GPDat(31) = 2 THEN
      IF WhichScreen <> 2 THEN END
   END IF

   y = 349
   'Set the proper screen mode
   IF GPDat(31) = 1 THEN
      SCREEN 7
   ELSEIF GPDat(31) = 5 THEN
      SCREEN 9
   ELSEIF GPDat(31) = 8 THEN
      SCREEN 12
      y = 479
   ELSEIF GPDat(31) = 9 THEN
      SCREEN 13
   ELSEIF GPDat(31) = 4 THEN
      SCREEN 1
   ELSEIF GPDat(31) = 6 THEN
      SCREEN 2
   ELSEIF GPDat(31) = 2 THEN
      CALL Screen3(0)
   END IF

   CALL HandlePCXPalette(Array$, WhichScreen)

   IF WhichScreen = 4 OR WhichScreen = 6 THEN
      CALL DispPCXC(0)
      WHILE INKEY$ = "": WEND
   ELSEIF WhichScreen = 2 THEN
      CALL DispPCXH(0)
      WHILE INKEY$ = "": WEND
   ELSEIF WhichScreen = 9 THEN
      CALL DispPCXV256(0)
      WHILE INKEY$ = "": WEND
   ELSE
    IF CVI(MID$(Array$, 67, 2)) <= 80 THEN
      CALL DispPCXVE(0)
      WHILE INKEY$ = "": WEND
    ELSE
      V = 1
      U = 0
      CALL DispScrollPCXVE(0, V, U, V + 79, U + y)
      DO
       I$ = INKEY$
       IF LEN(I$) = 2 THEN
	 I$ = MID$(I$, 2)
	 Respond = -1
	 SELECT CASE ASC(I$)
	   CASE 72
	     IF U > 349 THEN
	       U = U - 350
	     ELSE
	       U = 0
	     END IF
	   CASE 75
	     IF V > 60 THEN
	       V = V - 60
	     ELSE
	       V = 1
	     END IF
	   CASE 77
	     IF V < CVI(MID$(Array$, 67, 2)) - 140 THEN
	       V = V + 60
	     ELSE
	       V = CVI(MID$(Array$, 67, 2)) - 79
	     END IF
	     IF V < 1 THEN V = 1
	   CASE 80
	     IF U + y + 350 < CVI(MID$(Array$, 11, 2)) THEN
	       U = U + 350
	     ELSE
	       U = CVI(MID$(Array$, 11, 2)) - y
	     END IF
	     IF U < 0 THEN U = 0
	   CASE ELSE
	     Respond = 0
	 END SELECT
	 IF Respond THEN
	   IF NOT OpenPCXFile(Filename$, Array$) THEN END
	   CALL DispScrollPCXVE(0, V, U, V + 79, U + y)
	 END IF
       END IF
      LOOP UNTIL I$ = CHR$(27)
    END IF
   END IF

   CALL Screen0(0)

