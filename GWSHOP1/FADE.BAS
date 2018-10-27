'**** Fade.BAS - Some of the routines which use the Random Fade routines

'Copyright 1990, Brian C. Giedt

DEFINT A-Z
'$INCLUDE: 'GWDECL.BAS'

'$INCLUDE: 'Common.GW'

SUB NightFall STATIC

  T1 = 0:  S1 = 1
  T2 = -2: S2 = 2
  T3 = -4: S3 = 3
  T4 = -6: S4 = 4
  S5 = 4
  WHILE S5 < 12 OR T4 < 11
    IF T1 > 0 AND T1 < 11 THEN
      CALL FadeEGA(1, S1, T1)
      CALL FadeEGA(2, S1, T1)
      CALL FadeEGA(3, S1, T1)
      CALL FadeEGA(4, S1, T1)
    END IF
    IF T2 > 0 AND T2 < 11 THEN
      CALL FadeEGA(1, S2, T2)
      CALL FadeEGA(2, S2, T2)
      CALL FadeEGA(3, S2, T2)
      CALL FadeEGA(4, S2, T2)
    END IF
    IF T3 > 0 AND T3 < 11 THEN
      CALL FadeEGA(1, S3, T3)
      CALL FadeEGA(2, S3, T3)
      CALL FadeEGA(3, S3, T3)
      CALL FadeEGA(4, S3, T3)
    END IF
    IF T4 > 0 AND T4 < 11 THEN
      CALL FadeEGA(1, S4, T4)
      CALL FadeEGA(2, S4, T4)
      CALL FadeEGA(3, S4, T4)
      CALL FadeEGA(4, S4, T4)
    END IF
    T1 = T1 + 1: T2 = T2 + 1: T3 = T3 + 1: T4 = T4 + 1
    IF T1 > 10 AND S5 < 12 THEN
      T1 = 1
      S1 = S5
      S5 = S5 + 1
    END IF
    IF T2 > 10 AND S5 < 12 THEN
      T2 = 1
      S2 = S5
      S5 = S5 + 1
    END IF
    IF T3 > 10 AND S5 < 12 THEN
      T3 = 1
      S3 = S5
      S5 = S5 + 1
    END IF
    IF T4 > 10 AND S5 < 12 THEN
      T4 = 1
      S4 = S5
      S5 = S5 + 1
    END IF
  WEND

END SUB

SUB RandomFade STATIC

  REDIM RR(15, 43)
  FOR t = 0 TO 15
    FOR S = 0 TO 43
      RR(t, S) = (RND * 6) MOD 5 + 1
    NEXT
  NEXT

  FOR T2 = 1 TO 5
    FOR S = 1 TO 44 * 16
      t = (t + 37) MOD 44 * 16
      a = RR(t MOD 16, t \ 16)
      CALL Fade2EGA(t MOD 16 + 1, t \ 16 + 1, a)
      RR(t MOD 16, t \ 16) = a MOD 5 + 1
    NEXT
  NEXT

END SUB

