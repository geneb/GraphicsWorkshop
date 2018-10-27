'**** Segue5.Bas -

'Copyright, 1990 Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB LineCrush (P%, R%, Delay%)
DECLARE SUB PreLineCrush (P%, R%, Delay%)

SUB DoSegue5 (SubType, SegueColor, Delay) STATIC

  IF SubType MOD 2 = 0 THEN
    CALL LineCrush(SegueColor, SubType \ 2, Delay)
  ELSE
    CALL PreLineCrush(SegueColor, SubType \ 2 + 1, Delay)
  END IF

END SUB

SUB LineCrush (P, R, Delay) STATIC
  
    IF R = 1 THEN
        T = 0
        WHILE T <= 174
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 174) AND (S <= 4)
              CALL TransferEGA(0, T, 80, 2)
              CALL TransferEGA(0, 349 - T, 80, 2)
              T = T + 2
              S = S + 1
            WEND
        WEND
    ELSEIF R = 2 THEN
        T = 0
        WHILE T <= 174
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 174) AND (S <= 4)
              CALL TransferEGA(0, T, 80, 1)
              CALL TransferEGA(0, 175 + T, 80, 1)
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 3 THEN
        T = 0
        WHILE T <= 87
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 87) AND (S <= 4)
              CALL TransferEGA(0, T, 80, 1)
              CALL TransferEGA(0, 349 - T, 80, 1)
              CALL TransferEGA(0, 87 + T, 80, 1)
              CALL TransferEGA(0, 262 - T, 80, 1)
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 4 THEN
        T = 0
        WHILE T <= 87
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 87) AND (S <= 4)
              CALL TransferEGA(0, T, 80, 1)
              CALL TransferEGA(0, 87 + T, 80, 1)
              CALL TransferEGA(0, 175 + T, 80, 1)
              CALL TransferEGA(0, 262 + T, 80, 1)
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 5 THEN
        T = 0
        WHILE T <= 49
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 49) AND (S <= 2)
              FOR M = 0 TO 300 STEP 50
                CALL TransferEGA(0, M + T, 80, 1)
              NEXT
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 6 THEN
        T = 0
        WHILE T <= 24
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 24) AND (S <= 1)
              FOR M = 0 TO 325 STEP 25
                CALL TransferEGA(0, M + T, 80, 1)
              NEXT
              T = T + 1
              S = S + 1
            WEND
        WEND
    END IF

END SUB

SUB PreLineCrush (P, R, Delay) STATIC

    NumTicks& = PDQTimer&
    IF R = 1 THEN
        T = 0
        WHILE T <= 174
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 174) AND (S <= 4)
              CALL LineVE(0, T, 639, T + 1, P)
              CALL LineVE(0, 349 - T, 639, 349 - T + 1, P)
              T = T + 2
              S = S + 1
            WEND
        WEND
    ELSEIF R = 2 THEN
        T = 0
        WHILE T <= 174
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 174) AND (S <= 4)
              CALL LineVE(0, T, 639, T + 1, P)
              CALL LineVE(0, 175 + T, 639, 175 + T + 1, P)
              T = T + 2
              S = S + 1
            WEND
        WEND
    ELSEIF R = 3 THEN
        T = 0
        WHILE T <= 87
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 87) AND (S <= 4)
              CALL LineVE(0, T, 639, T, P)
              CALL LineVE(0, 87 + T, 639, 87 + T, P)
              CALL LineVE(0, 262 - T, 639, 262 - T, P)
              CALL LineVE(0, 349 - T, 639, 349 - T, P)
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 4 THEN
        T = 0
        WHILE T <= 87
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 87) AND (S <= 4)
              CALL LineVE(0, T, 639, T, P)
              CALL LineVE(0, 87 + T, 639, 87 + T, P)
              CALL LineVE(0, 175 + T, 639, 175 + T, P)
              CALL LineVE(0, 262 + T, 639, 262 + T, P)
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 5 THEN
        T = 0
        WHILE T <= 49
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 49) AND (S <= 2)
              FOR M = 0 TO 300 STEP 50
                CALL LineVE(0, M + T, 639, M + T, P)
              NEXT
              T = T + 1
              S = S + 1
            WEND
        WEND
    ELSEIF R = 6 THEN
        T = 0
        WHILE T <= 24
            WHILE PDQTimer& < NumTicks&: WEND
            NumTicks& = PDQTimer& + Delay \ 20
            S = 0
            WHILE (T <= 24) AND (S <= 1)
              FOR M = 0 TO 325 STEP 25
                CALL LineVE(0, M + T, 639, M + T, P)
              NEXT
              T = T + 1
              S = S + 1
            WEND
        WEND
    END IF
  
END SUB

