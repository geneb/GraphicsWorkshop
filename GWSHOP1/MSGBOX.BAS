'********** MsgBox.Bas

'Copyright (c) 1988 Crescent Software

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'Common.GW'

SUB MsgBoxG (Message$, Wdth) STATIC

    HideCursor
    IF LEN(Message$) THEN
       Row = CSRLIN                             'Get the Row & Column Posits
       Col = POS(0)

       REDIM Temp$(23)                          'Make a temporary array to
                                                '  hold the parsed up lines
       MesLen = LEN(Message$)                   'Get the total length of the
                                                '  help message
       IF MesLen = 0 THEN EXIT SUB              'If its nul, bail out

       LN = 0                                   'Line number
       Strt = 1                                 'Starting parse position
       '*** Parse the message into lines
       DO
           WHILE MID$(Message$, Strt, 1) = " "  'Skip over blanks
              Strt = Strt + 1
           WEND
           ND = Strt + Wdth                     'Guess at the end of line
                                                'Loop backwards to find
           WHILE MID$(Message$, ND, 1) <> " " AND ND <= MesLen AND ND > Strt
               ND = ND - 1                      '  blank space
           WEND
       
           LN = LN + 1                          'Increment the Line number
                                                'Pull out the new line
           Temp$(LN) = MID$(Message$, Strt, ND - Strt)
           Strt = ND + 1                        'Reset starting posit. for
                                                '  next line
       LOOP UNTIL ND >= MesLen                  'Get more unless @ end of mes

       BotRow = Row + LN + 1                    'Find the bottom row #
       IF BotRow > 24 THEN BotRow = 24          'No farther than line 24

       BoxWdth = Wdth + 4                       'Find the outer box width
       ColPos = 40 - (BoxWdth \ 2)              'Starting position for
                                                '  centered box
       'This method is not foolproof, as it does not check if there is always
       'enough memory available at this point.  What you might want to do
       'if your demo works like this one does, it to calculate the most
       'memory used at any one time and hardcode that value in.  What I mean
       'by "what this demo does" is that when a message is displayed, the
       'user can move the menu, and then the old message is removed from the
       'screen.  Moving a menu changes the value in GPDat%(72) and could
       'cause something to be overwritten in the video memory where we are
       'saving things.
       SaveAddress = GPDat%(72) + &H80
       GMove2VE ColPos, GPDat%(71) * (Row - 1), BoxWdth + 1, (LN + 3) * GPDat%(71), SaveAddress, 0

       'Print the top of box
       LineBFVE ColPos * 8 - 8, (Row - 1) * GPDat%(71), (ColPos + Wdth + 3) * 8 - 1, (Row + LN + 1) * GPDat%(71), GPDat%(75) \ 256
       LineBVE ColPos * 8 - 7, (Row - 1) * GPDat%(71) + 1, (ColPos + Wdth + 3) * 8 - 2, (Row + LN + 1) * GPDat%(71) - 1, GPDat%(75) MOD 256
       
       FOR N = 1 TO LN                          'Print message lines
           GPrint0VE N + Row, ColPos + 2, Temp$(N), GPDat%(76)
       NEXT

       GPaintBox ColPos + BoxWdth, GPDat%(71) * (Row), ColPos + BoxWdth, GPDat%(71) * (N + Row) + 7, -1, 0
       GPaintBox ColPos + 1, GPDat%(71) * (N + Row), ColPos + BoxWdth, GPDat%(71) * (N + Row) + 7, -1, 0

       Pass = 1                                 'Set flag say we've been here
       ERASE Temp$                              'Don't need this anymore

    ELSEIF Pass = 1 THEN                        'If we've been here before,
                                                '  restore the screen
       GMove2VE ColPos, (Row - 1) * GPDat%(71), BoxWdth + 1, (LN + 3) * GPDat%(71), SaveAddress, -1
       Pass = 0                                 'Reset flag for next call
    END IF
    ShowCursor

END SUB

