'Cursor.BAS - Cursor Drawing routines

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

SUB DrawCursor (X, Y, CursorWidth, CursorLength, CursorIs, CursorTime) STATIC

  ThisTime = PDQTimer& MOD CursorTime
  IF ThisTime < LastTime OR CursorTime = -1 THEN
      Colr = 15 + 256 * (16 + 8)
      FOR T = 0 TO CursorWidth - 1
          CALL LineVE(X + T, Y, X + T, Y + CursorLength, Colr)
      NEXT
      CursorIs = NOT CursorIs
      IF CursorTime = -1 THEN
          ThisTime = 32000 'Make sure cursor comes back fast
      END IF
  END IF
  LastTime = ThisTime

END SUB

