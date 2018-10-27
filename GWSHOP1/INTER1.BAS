'**** Inter1.Bas - Demonstration of an interlude

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB FillPoly (A%, B%, c%, d%, e%, f%, g%, h%, Colr%)
DECLARE SUB Take4 (XCenter%, YCenter%, Size%, Delay%, Segue$)

'$INCLUDE: 'Common.GW'

SUB Interlude1 (Text$) STATIC

    XPos = GPDat%(43) \ 2
    YPos = GPDat%(44) \ 2
    Size = GPDat%(44) \ 6
    Stage = 1
    CALL Take4(XPos, YPos, Size, Stage, Text$)
    FOR T = 1 TO 9
	Size = Size + 20
	CALL Take4(XPos, YPos, Size, Stage, Text$)
    NEXT
    Stage = 2
    FOR T = 1 TO 6
	Size = Size + 20
	CALL Take4(XPos, YPos, Size, Stage, Text$)
    NEXT
    Stage = 3
    Size = Size + 20
    CALL Take4(XPos, YPos, Size, Stage, Text$)

END SUB

SUB Take4 (XCenter, YCenter, Size, Stage, Text$) STATIC

    X = XCenter - Size / 2
    Y = YCenter - Size / 4
    X2 = X + Size
    Y2 = Y + Size / 10

    LineBVE X, Y, X + Size, Y + Size / 2, 15
    LineBFVE X + 1, Y + 1, X2 - 1, Y2 + 1, 0
    LineBVE X + 1, Y2 + 3, X2 - 1, Y + Size / 2 - 1, 15
    LineBVE X + 1, Y2 + 2, X2 - 1, Y + Size / 2 - 1, 15
    LineBFVE X + 2, Y2 + 4, X2 - 2, Y + Size / 2 - 2, 0

    IF Stage = 1 THEN EXIT SUB
    LineBFVE X + 1, Y + Size / 20 - 1, X2 - 1, Y + Size / 20 + 1, 0
    LineBFVE X, Y + Size / 20, X2, Y + Size / 20, 15

    IF Stage = 2 THEN EXIT SUB
    T1 = Size / 10
    FOR T = 1 TO Size - T1 STEP T1 * 2
	CALL FillPoly(X + T, Y2, X + T + T1 - 1, Y + 2, X + T + T1, Y2, X + T + T1 + T1 - 1, Y + 2, 15)
    NEXT
    LineBFVE X + 1, Y + Size / 20 - 1, X2 - 1, Y + Size / 20 + 1, 0
    LineBFVE X, Y + Size / 20, X2, Y + Size / 20, 15

    I = 1
    Y3 = 5
    WHILE I < LEN(Text$)
      L = INSTR(I, Text$, "_")
      IF L > 0 THEN
	T$ = MID$(Text$, I, L - I)
	I = L + 1
      ELSE
	T$ = MID$(Text$, I)
	I = LEN(Text$)
      END IF
      L = GetOutlineWidth(T$)
      TextSize = (4 * Size) \ (L + 10)
      WHILE (Y2 + Y3 + (TextSize * OutLineHeight%(GPDat%(82))) \ 4) > (YCenter + Size \ 4)
	 TextSize = TextSize - 1
      WEND
      L = (L * TextSize) \ 4
      CALL OutlineText(X + (Size - L) / 2, Y2 + Y3, T$, 0, 15, TextSize, 4)
      Y3 = Y3 + (TextSize * OutLineHeight%(GPDat%(82))) \ 4
    WEND

END SUB

