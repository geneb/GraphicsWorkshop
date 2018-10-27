'Inter2.Bas

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB Inter2Line (X1%, Y1%, X2%, Y2%, DrawColor%, OldColor%)

'$INCLUDE: 'Common.GW'

SUB Inter2Line (X1%, Y1%, X2%, Y2%, DrawColor%, OldColor%) STATIC

   IF X1 = X2 THEN
     FOR T = Y1 TO Y2
       V = GetCacheVE%(X1, T)
       IF V = OldColor THEN CALL ReDrawVE(DrawColor)
     NEXT
   ELSE
     FOR T = X1 TO X2
       V = GetCacheVE%(T, Y1)
       IF V = OldColor THEN CALL ReDrawVE(DrawColor)
     NEXT
   END IF

END SUB

SUB Interlude2 (TextColors%(), MaxBoxes%, Seconds%) STATIC

   'Note: TextColors%(0) = The Background Screen Color

   MaxBoxes = MaxBoxes - 1    'Adjust for an OPTION BASE of 0

   REDIM X1(MaxBoxes), Y1(MaxBoxes), X2(MaxBoxes), Y2(MaxBoxes)
   REDIM C1(MaxBoxes), D1(MaxBoxes), xd(MaxBoxes), Done(MaxBoxes)

   FOR T = 0 TO MaxBoxes
     NumTicks& = PDQTimer& + 30  'Set this here in order for RandomSetup to do its job
     GOSUB RandomSetup
   NEXT

   NumTicks& = PDQTimer& + Seconds% * 18
   AllDone = 0
   WHILE NumTicks& > PDQTimer& OR NOT AllDone
     AllDone = -1
     FOR T = 0 TO MaxBoxes
       IF D1(T) = 1 THEN
         X1(T) = X1(T) - xd(T)
         IF X1(T) + X2(T) < 0 THEN GOSUB RandomSetup
       ELSEIF D1(T) = 2 THEN
         Y1(T) = Y1(T) - xd(T)
         IF Y1(T) + Y2(T) < 0 THEN GOSUB RandomSetup
       ELSEIF D1(T) = 3 THEN
         X1(T) = X1(T) + xd(T)
         IF X1(T) + X2(T) >= GPDat%(43) THEN GOSUB RandomSetup
       ELSEIF D1(T) = 4 THEN
         Y1(T) = Y1(T) + xd(T)
         IF Y1(T) + Y2(T) >= GPDat%(44) THEN GOSUB RandomSetup
       END IF
       a1 = X1(T)
       a2 = X1(T) + X2(T)
       b1 = Y1(T)
       b2 = Y1(T) + Y2(T)
       IF D1(T) / 2 <> D1(T) \ 2 THEN
         IF a1 >= 0 AND a1 < GPDat%(43) THEN
           CALL Inter2Line(a1, b1, a1, b2, C1(T), TextColors(0))
         END IF
         IF a2 >= 0 AND a2 < GPDat%(43) THEN
           CALL Inter2Line(a2, b1, a2, b2, TextColors(0), C1(T))
         END IF
       ELSE
         IF b1 >= 0 AND b1 < GPDat%(44) THEN
           CALL Inter2Line(a1, b1, a2, b1, C1(T), TextColors(0))
         END IF
         IF b2 >= 0 AND b2 < GPDat%(44) THEN
           CALL Inter2Line(a1, b2, a2, b2, TextColors(0), C1(T))
         END IF
       END IF
       IF NOT Done(T) THEN AllDone = 0
     NEXT
   WEND
 
   EXIT SUB

RandomSetup:
   IF NumTicks& < PDQTimer& THEN
     Done(T) = -1
     RETURN
   ELSE
     Done(T) = 0
   END IF
   NotGoodColor = -1
   WHILE NotGoodColor
     NotGoodColor = 0
     C1(T) = (RND * 15 + 1) MOD 16
     FOR M = 0 TO UBOUND(TextColors%)
       IF C1(T) = TextColors(M) THEN NotGoodColor = -1
     NEXT
   WEND
   D1(T) = (RND * 4) MOD 4 + 1       '1=Left, 2=Up, 3=Right, 4=Down
   IF D1(T) / 2 <> D1(T) \ 2 THEN
     X2(T) = RND * 200 + 90
     Y2(T) = RND * 30 + 8
     'X is direction of change
     xd(T) = (RND * 3) MOD 3 + 1
     X2(T) = (X2(T) \ xd(T)) * xd(T)
     IF D1(T) = 1 THEN
       X1(T) = RND * 400 + GPDat%(43)
     ELSEIF D1(T) = 3 THEN
       X1(T) = -RND * 400
       X2(T) = -X2(T)
     END IF
     Y1(T) = RND * (GPDat%(44) - Y2(T) * 2) + Y2(T)
   ELSE
     X2(T) = RND * 20 + 5
     Y2(T) = RND * 150 + 100
     xd(T) = (RND * 2) MOD 2 + 1
     Y2(T) = (Y2(T) \ xd(T)) * xd(T)
     IF D1(T) = 2 THEN
       Y1(T) = RND * 200 + GPDat%(44)
     ELSEIF D1(T) = 4 THEN
       Y1(T) = -RND * 200
       Y2(T) = -Y2(T)
     END IF
     X1(T) = RND * (GPDat%(43) - X2(T) * 2) + X2(T)
   END IF
     
   RETURN

END SUB

