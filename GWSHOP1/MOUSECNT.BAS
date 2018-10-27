'Program to show if the mouse is displayed

'Written by Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

FUNCTION GetCountLocation% STATIC

  Bytes% = MBuffSize%                 'Get the size of the mouse environment
  Store1$ = SPACE$(Bytes%)            'Prepare some storage space
  CALL MGetState(Store1$)             'Get the mouse environment
  ShowCursor
  Bytes% = MBuffSize%                 'Get the size of the mouse environment
  Store2$ = SPACE$(Bytes%)            'Prepare some storage space
  CALL MGetState(Store2$)             'Get the changed mouse environment

  T = 1
  WHILE T <= LEN(Store1$) AND MID$(Store1$, T, 1) = MID$(Store2$, T, 1)
      T = T + 1                       'Compare the two environments until
  WEND                                'we see a change

  Store1$ = ""                        'Clear up the string space we used
  Store2$ = ""

  GetCountLocation% = T               'Return the position where they were
                                      'different

END FUNCTION

FUNCTION GetMouseCount% (Position%) STATIC

  Bytes% = MBuffSize%                 'Get the size of the mouse's environment
  Store1$ = SPACE$(Bytes%)            'Prepare some storage space
  CALL MGetState(Store1$)             'Get the environment

  'Now compare the byte at the position we found
  IF ASC(MID$(Store1$, Position, 1)) = 0 THEN
     GetMouseCount% = 0               'Say that the mouse is on.
  ELSE                                'Otherwise tell me what the count is
     GetMouseCount% = 256 - ASC(MID$(Store1$, Position, 1))
  END IF

  Store1$ = ""                        'Clear up the string space we used

END FUNCTION

