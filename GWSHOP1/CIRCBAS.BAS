'CIRCBAS.BAS - This circle routine shows how circles are generated and
'              serves as a template for creating a Hercules circle routine.

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

'$INCLUDE: 'COMMON.GW'

SUB CircleBAS (XCenter%, YCenter%, Radius%, Colr%, XAspect%, YAspect%) STATIC

  X = 0
  Y = Radius * 2
  sum = 0

  WHILE (X <= Y)
    IF (X AND 1) = 0 THEN GOSUB Plot8
    sum = sum + X * 2 + 1
    X = X + 1
    IF sum > 0 THEN
      sum = sum - Y * 2 - 1
      Y = Y - 1
    END IF
  WEND
  GOSUB Plot8

  EXIT SUB

Plot8:
  a = X \ 2
  b = (Y + 1) \ 2
  GOSUB Plot
  b = b * -1
  GOSUB Plot
  a = a * -1
  GOSUB Plot
  b = b * -1
  GOSUB Plot
  c = a
  a = b
  b = c
  GOSUB Plot
  a = a * -1
  GOSUB Plot
  b = b * -1
  GOSUB Plot
  a = a * -1
  GOSUB Plot
  RETURN

Plot:
  IF XAspect& = 0 THEN
    IF YAspect& = 0 THEN
      CALL DrawPointH(XCenter + a, YCenter + b, Colr)
    ELSE
      CALL DrawPointH(XCenter + a, YCenter + (b * YAspect%) \ 65536, Colr)
    END IF
  ELSE
    CALL DrawPointH(XCenter + (a * XAspect%) \ 65536, YCenter + b, Colr)
  END IF
  RETURN

END SUB

