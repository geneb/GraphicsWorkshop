'**** Segue3.BAS - Utilities for executing a Screen Change using style 3

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB PreSmallBoxes (Colr%, R%, Delay%)
DECLARE SUB SmallBoxes (Colr%, R%, Delay%)

SUB DoSegue3 (SubType, SegueColor, Delay) STATIC

    IF SubType MOD 2 = 0 THEN
      CALL SmallBoxes(SegueColor, SubType \ 2 + 1, Delay)
    ELSE
      CALL PreSmallBoxes(SegueColor, SubType \ 2 + 1, Delay)
    END IF

END SUB

SUB LargeBoxes (Colr) STATIC

    T = 15
    FOR S = 0 TO 39
	WHILE INKEY$ = "": WEND
	CALL LineBVE(((T * 8) MOD 64) * 10, (T \ 8) * 70, ((T * 80 + 79) MOD 640), ((T \ 8) + 1) * 70, 15)
	WHILE INKEY$ = "": WEND
	CALL TransferEGA((T * 10) MOD 80, (T \ 8) * 70, 10, 70)
	T = (T + 17) MOD 40
    NEXT

END SUB

SUB PreLargeBoxes (Colr, R) STATIC

    T = R
    NumTicks& = PDQTimer&
    FOR S = 0 TO 39
	WHILE PDQTimer& < NumTicks&: WEND
	NumTicks& = PDQTimer& + 1 / 100
	CALL LineBFVE(((T * 8) MOD 64) * 10, (T \ 8) * 70, ((T * 80 + 79) MOD 640), ((T \ 8) + 1) * 70, Colr)
	T = (T + 17) MOD 40
    NEXT

END SUB

SUB PreSmallBoxes (Colr, R, Delay) STATIC

    IF R = 1 THEN
	T1 = 13: T2 = 18: T3 = 43: T4 = 34
    ELSEIF R = 2 THEN
	T1 = 13: T2 = 18: T3 = 83: T4 = 42
    ELSEIF R = 3 THEN
	T1 = 2: T2 = 13: T3 = 42: T4 = 75
    ELSEIF R = 4 THEN
	T1 = 46: T2 = 13: T3 = 42: T4 = 23
    END IF

    T = 2 * INT(RND * 30) + 1
    S = 0
    WHILE S <= 39
	WHILE PDQTimer& < NumTicks&: WEND
	NumTicks& = PDQTimer& + Delay \ 20
	M = 0
	WHILE (S <= 39) AND (M <= 2)
	  CALL LineBFVE(((T * 4) MOD 64) * 10, (T \ 16) * 35, ((T * 40 + 39) MOD 640), ((T \ 16) + 1) * 35, Colr)
	  T = (T + T1) MOD 160
	  CALL LineBFVE(((T * 4) MOD 64) * 10, (T \ 16) * 35, ((T * 40 + 39) MOD 640), ((T \ 16) + 1) * 35, Colr)
	  T = (T + T2) MOD 160
	  CALL LineBFVE(((T * 4) MOD 64) * 10, (T \ 16) * 35, ((T * 40 + 39) MOD 640), ((T \ 16) + 1) * 35, Colr)
	  T = (T + T3) MOD 160
	  CALL LineBFVE(((T * 4) MOD 64) * 10, (T \ 16) * 35, ((T * 40 + 39) MOD 640), ((T \ 16) + 1) * 35, Colr)
	  T = (T + T4) MOD 160
	  S = S + 1
	  M = M + 1
	WEND
    WEND

END SUB

SUB SmallBoxes (Colr, R, Delay) STATIC

    IF R = 1 THEN
	T1 = 13: T2 = 18: T3 = 43: T4 = 34
    ELSEIF R = 2 THEN
	T1 = 13: T2 = 18: T3 = 83: T4 = 42
    ELSEIF R = 3 THEN
	T1 = 2: T2 = 13: T3 = 42: T4 = 75
    ELSEIF R = 4 THEN
	T1 = 46: T2 = 13: T3 = 42: T4 = 23
    END IF
    T5 = 5   'Width of boxes in bytes
    T6 = 35  'Height of boxes in pixel lines

    T = 2 * INT(RND * 30) + 1
    S = 0
    WHILE (S <= 39)
	WHILE PDQTimer& < NumTicks&: WEND
	NumTicks& = PDQTimer& + Delay \ 20
	M = 0
	WHILE (S <= 39) AND (M <= 2)
	  CALL TransferEGA((T * 5) MOD 80, (T \ 16) * 35, T5, T6)
	  T = (T + T1) MOD 160
	  CALL TransferEGA((T * 5) MOD 80, (T \ 16) * 35, T5, T6)
	  T = (T + T2) MOD 160
	  CALL TransferEGA((T * 5) MOD 80, (T \ 16) * 35, T5, T6)
	  T = (T + T3) MOD 160
	  CALL TransferEGA((T * 5) MOD 80, (T \ 16) * 35, T5, T6)
	  T = (T + T4) MOD 160
	  S = S + 1
	  M = M + 1
	WEND
    WEND

END SUB

