'**** Segue4.Bas -

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB Crossing (P%, R%, Delay%)
DECLARE SUB PreCrossing (P%, R%, Delay%)

SUB Crossing (P, R, Delay) STATIC

    X1 = 0
    Y1 = 0
    U2 = 350 \ (80 \ R)
    U3 = U2 + 1
    U1 = 350 \ U3 \ 20
    T = 0
    WHILE (T < 350)
        WHILE PDQTimer& < NumTicks&: WEND
        NumTicks& = PDQTimer& + Delay \ 20
        S = 0
        WHILE (T < 350) AND (S <= U1)
          X2 = X1
          Y2 = Y1
          WHILE (Y2 >= 0)
            CALL TransferEGA(X2, Y2, R, U3)
            Y2 = Y2 - U3
            X2 = X2 + R
          WEND
          T = T + U3
          Y1 = Y1 + U3
          S = S + 1
        WEND
    WEND

    Y1 = Y1 - U3
    X1 = X1 + R
    WHILE (X2 + R < 80)
        WHILE PDQTimer& < NumTicks&: WEND
        NumTicks& = PDQTimer& + Delay \ 20
        S = 0
        WHILE (X2 + R < 80) AND (S <= U1)
          X2 = X1
          Y2 = Y1
          WHILE (Y2 >= 0)
            CALL TransferEGA(X2, Y2, R, U3)
            Y2 = Y2 - U3
            X2 = X2 + R
          WEND
          X1 = X1 + R
          S = S + 1
        WEND
    WEND

    T = 0
    X1 = X2
    Y1 = 0
    WHILE (T < 350)
        WHILE PDQTimer& < NumTicks&: WEND
        NumTicks& = PDQTimer& + Delay \ 20
        S = 0
        WHILE (T < 350) AND (S <= U1)
          X2 = X1
          Y2 = Y1
          WHILE (Y2 < 350)
            CALL TransferEGA(X2, Y2, R, U3)
            Y2 = Y2 + U3
            X2 = X2 - R
          WEND
          T = T + U3
          Y1 = Y1 + U3
          S = S + 1
        WEND
    WEND

END SUB

SUB DoSegue4 (SubType, SegueColor, Delay) STATIC

  IF SubType MOD 2 = 0 THEN
    CALL Crossing(SegueColor, 2 ^ (SubType \ 2 - 1), Delay)
  ELSE
    CALL PreCrossing(SegueColor, 2 ^ (SubType \ 2), Delay)
  END IF

END SUB

SUB PreCrossing (P, R, Delay) STATIC

    X1 = 0
    Y1 = 0
    U2 = 350 \ (80 \ R)
    U3 = U2 + 1
    U1 = 350 \ U3 \ 20
    T = 0
    WHILE (T < 350)
        WHILE PDQTimer& < NumTicks&: WEND
        NumTicks& = PDQTimer& + Delay \ 20
        S = 0
        WHILE (T < 350) AND (S <= U1)
          X2 = X1
          Y2 = Y1
          WHILE (Y2 >= 0)
            CALL LineBFVE(X2, Y2, X2 + 8 * R - 1, Y2 + U2, P)
            Y2 = Y2 - U3
            X2 = X2 + 8 * R
          WEND
          T = T + U3
          Y1 = Y1 + U3
          S = S + 1
        WEND
    WEND
 
    Y1 = Y1 - U3
    X1 = X1 + 8 * R
    WHILE (X2 + R * 8 < 640)
        WHILE PDQTimer& < NumTicks&: WEND
        NumTicks& = PDQTimer& + Delay \ 20
        S = 0
        WHILE (X2 + R * 8 < 640) AND (S <= U1)
          X2 = X1
          Y2 = Y1
          WHILE (Y2 >= 0)
            CALL LineBFVE(X2, Y2, X2 + 8 * R - 1, Y2 + U2, P)
            Y2 = Y2 - U3
            X2 = X2 + 8 * R
          WEND
          X1 = X1 + 8 * R
          S = S + 1
        WEND
    WEND

    T = 0
    X1 = X2
    Y1 = 0
    WHILE (T < 350)
        WHILE PDQTimer& < NumTicks&: WEND
        NumTicks& = PDQTimer& + Delay \ 20
        S = 0
        WHILE (T < 350) AND (S <= U1)
          X2 = X1
          Y2 = Y1
          WHILE (Y2 < 350)
            CALL LineBFVE(X2, Y2, X2 + 8 * R - 1, Y2 + U2, P)
            Y2 = Y2 + U3
            X2 = X2 - 8 * R
          WEND
          T = T + U3
          Y1 = Y1 + U3
          S = S + 1
        WEND
    WEND

END SUB

