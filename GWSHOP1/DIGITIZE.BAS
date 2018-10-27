'Digitize.Bas - routines for digitizing the screen

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

SUB Digitize (GWWindow AS Window1, Pixels, Quick) STATIC

  CALL SetGWPages(1, 1)  'Make the background screen the active screen
  REDIM C(15)
  FOR Y = GWWindow.Y1 TO GWWindow.Y2 STEP Pixels
    V = 1
    FOR X = GWWindow.X1 TO GWWindow.X2 STEP Pixels
      IF Quick THEN
        V = GetCacheVE%(X + Pixels \ 2, Y + Pixels \ 2)
        CALL LineBF2VE(X, Y, X + Pixels - 1, Y + Pixels - 1, V)
      ELSE
        FOR A = 0 TO 15: C(A) = 0: NEXT
        FOR T = 0 TO Pixels - 1
          FOR S = 0 TO Pixels - 1
            V = GetCacheVE%(X + S, Y + T)
            IF V >= 0 THEN C(V) = C(V) + 1
          NEXT
        NEXT
        V = 0
        FOR A = 1 TO 15
          IF C(A) > C(V) THEN V = A
        NEXT
        CALL LineBF2VE(X, Y, X + Pixels - 1, Y + Pixels - 1, V)
      END IF
    NEXT
  NEXT
  ERASE C     'Practically Eliminate the array

  CALL SetGWPages(1, 0)  'Make the visible screen the active screen

  PCOPY 1, 0      'Copy what we have done back to the visible screen

END SUB

