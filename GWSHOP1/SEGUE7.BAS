'**** Segue7.Bas -

'Copyright, 1990 Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB Fade (P%, R%, Delay%)
DECLARE SUB PreFade (P%, R%, Delay%)

SUB DoSegue7 (SubType, SegueColor, Delay) STATIC

  IF SubType MOD 2 = 0 THEN
    CALL Fade(SegueColor, SubType \ 2, Delay)
  ELSE
    CALL PreFade(SegueColor, SubType \ 2 + 1, Delay)
  END IF

END SUB

SUB Fade (P%, R%, Delay%) STATIC

   x1 = 0
   y1 = 0
   T = 1
   WHILE T <= 28000
      WHILE PDQTimer& < NumTicks&: WEND
      NumTicks& = PDQTimer& + Delay \ 5
      S = 0
      WHILE (T <= 28000) AND (S <= 175)
        t1 = (t1 + 2433) MOD 28000
        x1 = t1 MOD 80
        y1 = t1 \ 80
        CALL TransferEGA(x1, y1, 1, 1)
        T = T + 1
      WEND
   WEND

END SUB

SUB PreFade (P%, R%, Delay%) STATIC

   x1 = 0
   y1 = 0
   T = 1
   WHILE T <= 28000
      WHILE PDQTimer& < NumTicks&: WEND
      NumTicks& = PDQTimer& + Delay \ 5
      S = 0
      WHILE (T <= 28000) AND (S <= 175)
        t1 = (t1 + 2433) MOD 28000
        x1 = t1 MOD 80
        y1 = t1 \ 80
        CALL LineVE (x1 * 8, y1,(x1 + 1) * 8 - 1, y1, P%)
      WEND
   WEND

END SUB

