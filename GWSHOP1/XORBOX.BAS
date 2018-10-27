'XORBox.BAS - Routine to control and position a box on screen

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DisplayBoxFill (GWWindow AS Window1)
DECLARE SUB DisplayBox (GWWindow AS Window1)

'$INCLUDE: 'Common.GW'

SUB DisplayBox (GWWindow AS Window1) STATIC

   Colr = 15 + 256 * (16 + 8)
   CALL LineVE(GWWindow.X1 + 1, GWWindow.Y1, GWWindow.X2 - 1, GWWindow.Y1, Colr)
   CALL LineVE(GWWindow.X2, GWWindow.Y1 + 1, GWWindow.X2, GWWindow.Y2, Colr)
   CALL LineVE(GWWindow.X2 - 2, GWWindow.Y2, GWWindow.X1, GWWindow.Y2, Colr)
   CALL LineVE(GWWindow.X1, GWWindow.Y2 - 1, GWWindow.X1, GWWindow.Y1, Colr)

END SUB

SUB DisplayBoxFill (GWWindow AS Window1) STATIC

   Colr = 15 + 256 * (16 + 8)
   CALL LineBFVE(GWWindow.X1, GWWindow.Y1, GWWindow.X2, GWWindow.Y2, Colr)

END SUB

SUB PositionBox (GWWindow AS Window1, Style%, Ch%) STATIC

   IF Style% THEN
     CALL DisplayBoxFill(GWWindow)
   ELSE
     CALL DisplayBox(GWWindow)
   END IF
   Corner = 0
   Speed = 1
   I$ = ""
   WHILE I$ <> CHR$(27) AND I$ <> CHR$(13)
     I$ = ""
     WHILE I$ = "": I$ = INKEY$: WEND
     IF I$ = " " THEN Corner = NOT Corner
     IF I$ = "s" OR I$ = "S" THEN
       IF Speed = 1 THEN Speed = 5 ELSE Speed = 1
     END IF
     IF LEN(I$) > 1 THEN
       I$ = MID$(I$, 2)
       IF Style% THEN
         CALL DisplayBoxFill(GWWindow)
       ELSE
         CALL DisplayBox(GWWindow)
       END IF
       IF NOT Corner THEN
         SELECT CASE ASC(I$)
           CASE 72
             GWWindow.Y1 = GWWindow.Y1 - Speed
           CASE 75
             GWWindow.X1 = GWWindow.X1 - Speed
           CASE 77
             GWWindow.X1 = GWWindow.X1 + Speed
           CASE 80
             GWWindow.Y1 = GWWindow.Y1 + Speed
           CASE ELSE
         END SELECT
         IF GWWindow.X1 + 1 >= GWWindow.X2 THEN GWWindow.X1 = GWWindow.X2 - 2
         IF GWWindow.Y1 + 1 >= GWWindow.Y2 THEN GWWindow.Y1 = GWWindow.Y2 - 2
         IF GWWindow.X1 < 0 THEN GWWindow.X1 = 0
         IF GWWindow.Y1 < 0 THEN GWWindow.Y1 = 0
       ELSE
         SELECT CASE ASC(I$)
           CASE 72
             GWWindow.Y2 = GWWindow.Y2 - Speed
           CASE 75
             GWWindow.X2 = GWWindow.X2 - Speed
           CASE 77
             GWWindow.X2 = GWWindow.X2 + Speed
           CASE 80
             GWWindow.Y2 = GWWindow.Y2 + Speed
           CASE ELSE
         END SELECT
         IF GWWindow.X2 - 1 <= GWWindow.X1 THEN GWWindow.X2 = GWWindow.X1 + 2
         IF GWWindow.Y2 - 1 <= GWWindow.Y1 THEN GWWindow.Y2 = GWWindow.Y1 + 2
         IF GWWindow.X2 >= GPDat%(43) THEN GWWindow.X2 = GPDat%(43) - 1
         IF GWWindow.Y2 >= GPDat%(44) THEN GWWindow.Y2 = GPDat%(44) - 1
       END IF
       IF Style% THEN
         CALL DisplayBoxFill(GWWindow)
       ELSE
         CALL DisplayBox(GWWindow)
       END IF
     END IF
   WEND
   IF Style% THEN
     CALL DisplayBoxFill(GWWindow)
   ELSE
     CALL DisplayBox(GWWindow)
   END IF
   IF I$ = CHR$(27) THEN Ch = -1 ELSE Ch = 0

END SUB

