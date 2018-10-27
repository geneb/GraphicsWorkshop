'**** Segue2.Bas -

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB Implode (Colr%, R%, Delay%)
DECLARE SUB PreImplode (Colr%, R%, Delay%)

SUB DoSegue2 (SubType, SegueColor, Delay) STATIC

    IF SubType MOD 2 = 0 THEN
        CALL Implode(SegueColor, 2 ^ (SubType \ 2), Delay)
    ELSE
        CALL PreImplode(SegueColor, 2 ^ (SubType \ 2), Delay)
    END IF

END SUB

SUB Implode (Colr, R, Delay) STATIC

    T2 = 4 * R
    T3 = 40 \ R - 1
    T4 = (T3 / 20) + 1
   
    T = 0
    WHILE T <= T3
       WHILE PDQTimer& < NumTicks&: WEND
       NumTicks& = PDQTimer& + Delay \ 20
       S = 1
       WHILE (T <= T3) AND (S <= T4)
         CALL TransferEGA(T * R, T * T2, 80 - 2 * T * R, T2)
         CALL TransferEGA(T * R, 350 - (T + 1) * T2, 80 - 2 * T * R, T2)
         CALL TransferEGA(T * R, (T + 1) * T2, R, 350 - 2 * (T + 1) * T2)
         CALL TransferEGA(80 - (T + 1) * R, (T + 1) * T2, R, 350 - 2 * (T + 1) * T2)
         T = T + 1
         S = S + 1
       WEND
    WEND

END SUB

SUB PreImplode (Colr, R, Delay) STATIC

    T1 = 8 * R
    T2 = 4 * R
    T3 = 40 \ R - 1
    T4 = (T3 / 20) + 1
  
    T = 0
    WHILE T <= T3
       WHILE PDQTimer& < NumTicks&: WEND
       NumTicks& = PDQTimer& + Delay \ 20
       S = 1
       WHILE (T <= T3) AND (S <= T4)
         LineBFVE T * T1, T * T2, 639 - T * T1, (T + 1) * T2, Colr
         LineBFVE T * T1, 349 - T * T2, 639 - T * T1, 349 - (T + 1) * T2, Colr
         LineBFVE T * T1, (T + 1) * T2, (T + 1) * T1, 349 - (T + 1) * T2, Colr
         LineBFVE 639 - T * T1, (T + 1) * T2, 639 - (T + 1) * T1, 349 - (T + 1) * T2, Colr
         T = T + 1
         S = S + 1
       WEND
    WEND
  
END SUB

