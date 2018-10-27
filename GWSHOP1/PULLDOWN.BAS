'********** PullDown.Bas - Pull Down menu subprogram with mouse support for
'                          graphics mode

'Copyright (c) 1988,1990 Don Malin & Brian C. Giedt
'Copyright (c) 1988 Crescent Software

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB GPaintBox (Col1%, Line1%, Col2%, Line2%, OldColor%, NewColor%)
DECLARE SUB BarPrintG (Choice$(), BarClr%)

'$INCLUDE: 'Common.GW'

CONST BarLine = 1               'Line number for the menu bar

'Alt Key translation table
CONST AltChars$ = "1234567890     QWERTYUIOP    ASDFGHJKL     ZXCVBNM"

'******************** Display the Menu Bar *****************************
'Note: This is separate so the Main Program can display the Menu Bar
'      before it makes any calls to the PullMen Sub Program.
'***********************************************************************
SUB BarPrintG (Choice$(), BarClr) STATIC

    Row = CSRLIN                        'Save the Current Cursor Position
    Col = POS(0)
    MenuBar$ = SPACE$(80)               'Allocate Menu Bar String
    Length = 2
    FOR C = 0 TO UBOUND(Choice$, 2)     'Compose the Menu Bar
        MID$(MenuBar$, Length) = Choice$(0, C)
        Length = Length + LEN(Choice$(0, C)) + 2
    NEXT
  
    HideCursor
    GPrint0VE BarLine, 1, MenuBar$, BarClr  'Print Menu Bar
    ShowCursor
  
    MenuBar$ = ""
END SUB

'****************************************************************************
'   File Name: PullDown.bas
' Description: Pull Down Menu Sub Program
'          by: Don Malin,  (C) Crescent Software 1988
'         and: Brian C. Giedt (c) 1990
'
' Parameters:
'
'   Choice$() -
'     The "Choice$" Array holds the Menu Choices.
'     Choice$(0, Menus) hold the Bar Titles.
'     Choice$(Choices, Menu) hold the Window Choices.
'     A "-" value for a choice indicates a dividing line across the menu.
'
'   Stat() -
'     This is an integer array parallel to the Choice$ array.
'     Any value in an element indicates that the choice is inactive
'     (Non-Selectable).
'
'   Menu -
'     Current Menu Number.  A non-zero value on entry will cause that menu
'     to be displayed.
'
'   Choice -
'     Current Menu Choice.  A non-zero value on entry will cause that
'     choice to be displayed.
'
'   Ky$ -
'     This string will contain the character or key code that was used to
'     exit the routine.
'
'   Action -
'     Action is a flag which can be used to control the routine in a
'     multi tasking (polled) mode.  The Action commands are as follows:
'
'       0 - PullDown will take control until an active choice is selected
'           or the [Esc] key is pressed.  (Single Tasking Mode)
'       1 - Used on initial entry for multi-tasking mode.  Only saves the
'           background screen, displays the Menu bar and the current menu.
'           Sets the Action variable to 3 for successive calls.
'       2 - Redisplay the current menu.  Reset Action to 3
'       3 - On entry means just check the keyboard and handle keys used by
'           the routine and exit back to the caller.  On exit means nothing
'           was selected.
'       4 - User made a selection from an active choice or pressed the
'           Escape key so you should check the Menu and Choice variables.
'       5 - Restore the screen, erase the screen buffer used by the routine.
'
' External Routines: GMove2VE, BarPrint, GPaintBox, GPrint0VE, GetCursor
'
'****************************************************************************
'
SUB PullDownG (Choice$(), Stat(), Menu, Choice, Ky$, Action) STATIC

    IF Action = 4 THEN Action = 1       'See if they forgot to reinit Action
    IF Action < 3 THEN                  'Redisplaying?
       IF Action < 2 THEN               'Redisplaying whole menu?
          LastMenu = UBOUND(Choice$, 2) 'Find Last Bar Menu Choice
                                        'Find screen rows to save
          BotRow = UBOUND(Choice$, 1) + BarLine + 2
          LastChoice = 0

          SaveToAddress = &HA800
          IF GPDat%(31) = 8 THEN
             SaveToAddress = &HAA00     'Address above Address of line 480
          END IF
          HideCursor
                                        'Save the Bar Line
          GMove2VE 1, (BarLine - 1) * GPDat%(71), 80, GPDat%(71), SaveToAddress, 0
                                        'Display the Menu Bar on top line
          ShowCursor
          BarPrintG Choice$(), GPDat%(74) 'Print the Bar Choices
          StartCol = 1

          Wdth = 0
       END IF

       StartCol = 1                      'Find the column positions to start
       FOR C = 0 TO Menu - 1             '  and end the hilight on Bar Menu
          StartCol = StartCol + LEN(Choice$(0, C)) + 2
       NEXT
       GOSUB PullDisplay                'Display the Menu box

       IF Action THEN Action = 3        'Reset the Action flag to idle state

       PrevChoice = Choice
       PrevMenu = Menu
       GOSUB PullHilite
    END IF

    IF Choice <> PrevChoice THEN GOSUB PullHilite
    IF Menu <> PrevMenu THEN GOSUB PullDisplay
                                        'If Action flag=5, Restore the screen
    IF Action = 5 THEN
       HideCursor
       GMove2VE 1, (BarLine - 1) * GPDat%(71), 80, GPDat%(71), SaveToAddress, -1
       IF Wdth THEN
          GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, -1
          Wdth = 0
       END IF
       ShowCursor
       EXIT SUB                         'Bail out
    END IF

    DO
                                        'If we have a Window, Hilight Choice
                                        'Get typed characters
       AltDown = AltKey%
       IF AltDown THEN WasDown = -1

       Ky$ = INKEY$
       IF AltDown = 0 AND WasDown AND AltPressed THEN
          Ky$ = CHR$(13)
          WasDown = 0
          AltPressed = 0
       END IF

       'Mouse code begins here
       IF GPDat%(73) THEN
          ButtonPress 1, Down, Presses, X, Y
          IF Presses = 0 THEN GetCursor X, Y, Button
          MRow = (Y \ GPDat%(71)) + 1
          MCol = (X \ 8) + 1

          IF (MRow <> LMRow OR MCol <> LMCol OR Presses) AND Down = 1 THEN
             
             IF MRow - BarLine - 1 <= LastChoice AND MRow - BarLine - 1 > 0 AND MCol > StartCol AND MCol < EnBar THEN
                Choice = MRow - BarLine - 1
                IF Choice$(Choice, Menu) = "-" OR Stat(Choice, Menu) <> 0 THEN
                   Choice = 0
                END IF
             ELSEIF MRow = BarLine THEN
                TstCol = 1
                LstMen = UBOUND(Choice$, 2)
                FOR N = 0 TO LstMen
                    IF MCol >= TstCol AND MCol <= TstCol + LEN(Choice$(0, N)) + 1 THEN EXIT FOR
                    TstCol = TstCol + LEN(Choice$(0, N)) + 2
                NEXT
                IF N <= LstMen THEN Menu = N
                Choice = 0
                IF Menu <> PrevMenu THEN
                   GOSUB PullDisplay
                   Choice = 0
                   PrevChoice = 0
                END IF
             ELSE
                Choice = 0
             END IF
             GOSUB PullHilite
             WasPressed = -1
          ELSEIF Button AND 2 THEN
             Ky$ = CHR$(27)
             DO
                GetCursor X, Y, Button
             LOOP WHILE Button AND 2
          END IF

          IF Down = 0 AND WasPressed THEN
             WasPressed = 0
             IF MRow - BarLine - 1 <= LastChoice AND MRow - BarLine - 1 > 0 AND MCol > StartCol AND MCol < EnBar THEN
                IF Choice THEN Ky$ = CHR$(13)
             ELSEIF MRow = BarLine THEN
                IF Wdth = 0 OR Active = 0 THEN
                   Ky$ = CHR$(13)
                ELSE
                   Choice = 1
                   DO WHILE Choice$(Choice, Menu) = "-" OR Stat(Choice, Menu)
                      Choice = Choice + 1
                   LOOP
                   GOSUB PullHilite
                END IF
             ELSE
                Ky$ = CHR$(27)
             END IF
          END IF
          
          IF Down = 0 THEN
            LMRow = -1
            LMCol = -1
          ELSE
            LMRow = MRow
            LMCol = MCol
          END IF
       END IF
       'End of mouse handling code

       IF AltDown AND LEN(Ky$) = 2 THEN

          ASCVal = ASC(RIGHT$(Ky$, 1))
          IF ASCVal >= 120 THEN ASCVal = ASCVal - 119
          Ky$ = MID$(AltChars$, ASCVal, 1)

       END IF


       IF LEN(Ky$) = 1 THEN             'Non extended Keys

          IF Ky$ = CHR$(13) OR Ky$ = CHR$(27) THEN
             IF Action = 0 OR Action = 3 THEN
                HideCursor
                IF Action = 0 THEN
                   GMove2VE 1, (BarLine - 1) * GPDat%(71), 80, GPDat%(71), SaveToAddress, -1
                END IF
                IF Wdth THEN
                   GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, -1
                   Wdth = 0
                END IF
                ShowCursor
             END IF
             IF Action THEN Action = 4
             EXIT SUB

          ELSEIF Wdth AND Active AND Ky$ <> "-" THEN
             Ky$ = UCASE$(Ky$)          'Make Key Uppercase
             Pass = 0                   'See if User pressed a Choice Letter
             OldChoice = Choice         'Save Current Choice setting

             DO                         'Check remaining choices
                IF Choice < LastChoice THEN
                   Choice = Choice + 1
                ELSE Choice = 1
                END IF

                WHILE (Stat(Choice, Menu) OR Ky$ <> LEFT$(Choice$(Choice, Menu), 1)) AND Choice < LastChoice
                    Choice = Choice + 1
                WEND
                                        'If we reached the end without finding
                IF Choice >= LastChoice AND Ky$ <> LEFT$(Choice$(Choice, Menu), 1) THEN
                   IF Pass = 0 THEN
                      Pass = 1
                   ELSE
                      Choice = OldChoice
                      EXIT DO
                   END IF
                ELSE
                   IF AltDown THEN AltPressed = -1
                   EXIT DO
                END IF
             LOOP
             GOSUB PullHilite
          END IF

       ELSEIF LEN(Ky$) THEN           'Handle Extended Key Codes
                                        
          SELECT CASE ASC(RIGHT$(Ky$, 1))
             CASE 72                    'Check for Up Arrow Key
                IF Wdth AND Active THEN
                   DO
                      Choice = Choice - 1
                      IF Choice < 1 THEN Choice = LastChoice
                   LOOP WHILE Choice$(Choice, Menu) = "-" OR Stat(Choice, Menu)
                END IF

             CASE 80                    'Check for Down Arrow Key
                IF Wdth AND Active THEN
                   DO
                      Choice = Choice + 1
                      IF Choice > LastChoice THEN Choice = 1
                   LOOP WHILE Choice$(Choice, Menu) = "-" OR Stat(Choice, Menu)
                END IF

             CASE 71                    'Check for Home Key
                IF Wdth AND Active THEN
                   Choice = 1
                   DO WHILE Choice$(Choice, Menu) = "-" OR Stat(Choice, Menu)
                      Choice = Choice + 1
                   LOOP
                END IF

             CASE 79                    'Check for End Key
                IF Wdth AND Active THEN
                   Choice = LastChoice
                   DO WHILE Choice$(Choice, Menu) = "-" OR Stat(Choice, Menu)
                      Choice = Choice - 1
                   LOOP
                END IF

             CASE 75                    'Check for Left Arrow Key
                IF Menu = 0 THEN        'If on Far Left Bar Choice, go to
                   Menu = LastMenu      '  Far Right Choice
                ELSE
                   Menu = Menu - 1      'Otherwise Decrement Bar Choice
                END IF
                Choice = 0
                PrevChoice = 0
                GOSUB PullDisplay       'Display the New Choice Window

             CASE 77                    'Check for Right Arrow Key
                IF Menu = LastMenu THEN 'If on Far Right Bar Choice, go to
                   Menu = 0             '  Far Left Choice
                ELSE
                   Menu = Menu + 1    'Otherwise Increment Bar Choice
                END IF
                Choice = 0
                PrevChoice = 0
                GOSUB PullDisplay       'Display the New Choice Window

             CASE ELSE
          END SELECT

          GOSUB PullHilite
       END IF

       PrevChoice = Choice
       PrevMenu = Menu
    LOOP WHILE Action = 0

    EXIT SUB

PullHilite:
    IF Wdth AND Active THEN
       HideCursor
       IF PrevChoice > 0 THEN GPrint0VE PrevChoice + BarLine + 1, StartCol + 1, " " + Choice$(PrevChoice, Menu) + " ", GPDat%(76)
       IF Choice > 0 THEN GPrint0VE Choice + BarLine + 1, StartCol + 1, " " + Choice$(Choice, Menu) + " ", GPDat%(78)
       ShowCursor
    END IF
RETURN


PullDisplay:
    HideCursor                          'Restore the screen
    
    IF Menu <> PrevMenu OR Action < 2 THEN
       IF Wdth THEN
          GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, -1
          Wdth = 0
       END IF
                                        'Re-paint the Menu bar
       GPrint0VE BarLine, StartCol, " " + Choice$(0, PrevMenu) + " ", GPDat%(74)
    END IF
    PrevMenu = Menu                     'Save the menu nunber

    StartCol = 1                        'Find the column positions to start
    FOR C = 0 TO Menu - 1               '  and end the hilight on Bar Menu
        StartCol = StartCol + LEN(Choice$(0, C)) + 2
    NEXT
    EnCol = StartCol + LEN(Choice$(0, Menu)) + 1
                                        'Hilight the Bar Menu Choice
    GPrint0VE BarLine, StartCol, " " + Choice$(0, Menu) + " ", GPDat%(78)
   
    ShowCursor
   
    Wdth = 0                            'Find the Width and # of Choices of
    ArrayEnd = UBOUND(Choice$, 1)       '  the new menu
    Active = 0

    IF Choice AND (Stat(Choice, Menu) OR Choice$(Choice, Menu) = "-") THEN Choice = 0
    FOR C = 1 TO ArrayEnd
       ChLen = LEN(Choice$(C, Menu))
       IF ChLen = 0 THEN EXIT FOR
       IF ChLen > Wdth THEN Wdth = ChLen
       IF Stat(C, Menu) = 0 AND Choice$(C, Menu) <> "-" THEN
          Active = -1
          IF Choice = 0 THEN
             Choice = C
             PrevChoice = C
          END IF
       END IF
    NEXT
    LastChoice = C - 1

    IF StartCol + Wdth + 3 >= 80 THEN   'If the Right Side of the window is
       StartCol = 80 - Wdth + 3         '  off the screen, adjust the Left
    END IF                              '  Side of the window

    EnBar = StartCol + Wdth + 2         'Set the Right Side of the Window

    IF Wdth THEN                        'If there are window choices, print
                                        '  them
       HideCursor
   
       Save1Pos = BarLine * GPDat%(71)
       Save2Pos = StartCol
       Save3Pos = (LastChoice + 2 + 1) * GPDat%(71)'The last 1 is for the shadow region
       Save4Pos = Wdth + 4 + 2                     'The last 2 are for the shadow region
       GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, 0
       GPDat%(72) = SaveToAddress + &H100 + (Save3Pos * Save4Pos + 16) \ 16
      
       CALL LineBFVE(StartCol * 8 - 8, BarLine * GPDat%(71), (StartCol + Wdth + 3) * 8 - 1, (BarLine + LastChoice + 2) * GPDat%(71) - 1, GPDat%(76) \ 256)
       CALL LineBVE(StartCol * 8 - 7, BarLine * GPDat%(71) + 1, (StartCol + Wdth + 3) * 8 - 2, (BarLine + LastChoice + 2) * GPDat%(71) - 5, GPDat%(75) MOD 256)
       CALL LineBVE(StartCol * 8 - 6, BarLine * GPDat%(71) + 6, (StartCol + Wdth + 3) * 8 - 3, (BarLine + LastChoice + 2) * GPDat%(71) - 6, GPDat%(75) MOD 256)

       FOR C = 1 TO LastChoice
           IF Choice$(C, Menu) = "-" THEN
               CALL LineVE(StartCol * 8 - 6, (BarLine + C + 1) * GPDat%(71) - GPDat%(71) \ 2, (StartCol + Wdth + 3) * 8 - 3, (BarLine + C + 1) * GPDat%(71) - GPDat%(71) \ 2, GPDat%(76) MOD 256)
           ELSE
               IF Stat(C, Menu) THEN
                 GPrint0VE C + BarLine + 1, StartCol + 2, Choice$(C, Menu), GPDat%(77)
               ELSE
                 GPrint0VE C + BarLine + 1, StartCol + 2, Choice$(C, Menu), GPDat%(76)
               END IF
           END IF
       NEXT

       ShowCursor

       'You can REM out the shadow effect here if it does not produce
       ' satisfactory effects with your background screen.
       GPaintBox EnBar + 2, GPDat%(71) * (BarLine + 1) - 7, EnBar + 2, GPDat%(71) * (C + BarLine + 1) + 7, -1, 0
       GPaintBox StartCol + 1, GPDat%(71) * (C + BarLine + 1), EnBar + 2, GPDat%(71) * (C + BarLine + 1) + 7, -1, 0
       'The -1 on the third parameters above adjust for graphics mode, where
       ' we only want to do the process for GPDat%(71) and without the -1, it
       ' would do it for GPDat%(71)+1
       'Do not mistaken it with the -1 on the fifth parameter.  The fifth
       'parameter is the color we want to replace.  Since it is nearly
       'impossible in graphics mode to know the overall background color (if
       'the overall background is a tile pattern or a solid color drawn with
       'a PAINT or LINE statement) the routine takes the value of the
       'upper-leftmost pixel of the region and assumes that to be the overall
       'background color.  Alternatively you could place the overall
       'background color in GPDat%() element 86 and the routine will look for
       'a value other than 0 (If the background is 0, then shadowing doesn't
       'have any effect anyways).
    END IF
RETURN

END SUB

SUB PullMenKeyG (Ky$, Choice$(), Menu, Init) STATIC

    IF Init THEN
       LstMen = UBOUND(Choice$, 2)
       HotKeys$ = STRING$(LstMen + 1, 0)
       FOR N = 0 TO LstMen
           FstChr$ = UCASE$(LEFT$(LTRIM$(Choice$(0, N)), 1))
           IF LEN(FstChr$) THEN
              HotKey = INSTR(AltChars$, FstChr$)
              IF HotKey <= 15 THEN
                 HotKey = 119 + HotKey
                 IF HotKey = 119 THEN HotKey = 0
              END IF
              MID$(HotKeys$, N + 1) = CHR$(HotKey)
           END IF
       NEXT
       Init = 0
    END IF

    IF LEN(Ky$) = 2 THEN
       Menu = INSTR(HotKeys$, RIGHT$(Ky$, 1)) - 1
    ELSE
       Menu = -1
    END IF

    GetCursor X, Y, Button
    IF Button THEN
       MRow = (Y \ GPDat(71)) + 1
       IF MRow = BarLine THEN
          MCol = (X \ 8) + 1
          LCol = 1
          FOR N = 0 TO LstMen
              IF MCol >= LCol AND MCol <= LCol + LEN(Choice$(0, N)) + 1 THEN EXIT FOR
              LCol = LCol + LEN(Choice$(0, N)) + 2
          NEXT
          IF N <= LstMen THEN Menu = N
       END IF
    END IF

END SUB

