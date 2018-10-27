'***** PullDnMS.Bas - Pull Down menu subprogram with Hot Key support.
'                     Resembles and behaves like MicroSoft's pull downs.
'                     The routine PullDnMSG is for EGA and VGA graphics modes

'by Don Malin & Phil Cramer & Brian C. Giedt
'Copyright (c) 1989, 1990 Crescent Software

'08-08-1990 Modified Mouse code to handle Logitec mouse (set LMRow/Col to -1)

DEFINT A-Z

'$INCLUDE: 'GWDECL'

DECLARE SUB DotPatternMSG (BarLine%, StartCol%, Wdth%, Clr%)
DECLARE SUB UnderlineEntryMSG (Y%, UnderScorePos%, ScoreColor%)
DECLARE SUB BarPrintMSG (Choice$(), Stat%())
DECLARE FUNCTION PullMenKeyMSG% (Ky$, Choice$(), Stat%())

CONST BarLine = 1               'Line number for the menu bar
CONST BarLCol = 1               'Left column where the bar starts
CONST BarRCol = 80              'Right column where the bar ends

                                'Alt Key translation table
CONST AltChars$ = "1234567890     QWERTYUIOP    ASDFGHJKL     ZXCVBNM"

'$INCLUDE: 'COMMON.GW'

DIM SHARED Temp, N, LastMenu, MRow, MCol, LCol, RCol, Button, AltUsed

'****************************************************************************
'Displays the menu bar on the line specified by the constant "BarLine".
'Also initializes a "Hot Key" table for use with "PullMenKeyMSG"
'
'   Choice$() -
'     The "Choice$" Array holds the Menu Choices.
'     Choice$(0, Menus) hold the Bar Titles.
'
'   Stat() -
'     This is an integer array parallel to the Choice$ array.
'     A value in the low byte of elements (M, 0) indicates the offset + 2
'     from the left menu title to display.  The high byte of the element
'     indicates the offset of the hot key letter.
'
'Note: This is separate so your Program can display the Menu Bar before it
'      makes any calls to the PullMenKeyMSG or PullDnMSG Sub Programs.
'****************************************************************************
'
SUB BarPrintMSG (Choice$(), Stat()) STATIC

    SHARED HotKeys$                             'Share "Menu" Hot key table
   
    LastMenu = UBOUND(Choice$, 2)               'Get the last menu number
    HotKeys$ = STRING$(LastMenu + 1, 0)         'Make string for Hot key table
    Bar$ = SPACE$(BarRCol - BarLCol + 1)        'Make a string for Menu Bar
    Temp = 4 + BarLCol - 1                      'Put first Menu title @ pos. 4
    HideCursor
    GPrint0VE BarLine, BarLCol, Bar$, GPDat%(74) 'Print Menu Bar

    FOR N = 0 TO LastMenu                       'Examine each Menu title
                                                'Get the Hot key character
                                                '  from the given offset
        HotChr$ = UCASE$(MID$(Choice$(0, N), Stat(0, N) \ 256 + 1, 1))
        HotKey = INSTR(AltChars$, HotChr$)      'Get it's position in table
        IF HotKey <= 15 THEN                    'Is it a number?
           HotKey = 119 + HotKey                'Add 119
           IF HotKey = 119 THEN HotKey = 0      'Special case for "M"
        END IF
        MID$(HotKeys$, N + 1) = CHR$(HotKey)    'Put the character in table

        'Print the Menu Entry
        GPrint0VE BarLine, Temp, Choice$(0, N), GPDat%(74)
        UnderlineEntryMSG BarLine * GPDat%(71) - 2, Temp + Stat(0, N) \ 256, GPDat%(74)

        IF N < LastMenu THEN                    'Get position for next title
           Temp = Temp + Stat(0, N + 1) MOD 256 + LEN(Choice$(0, N)) + 2
        END IF
    NEXT

    ShowCursor

END SUB

SUB DotPatternMSG (BarLine, StartCol, Wdth, Clr) STATIC

  HideCursor
  BitPattern = 170
  FOR M = (BarLine - 1) * GPDat%(71) + 1 TO BarLine * GPDat%(71)
    Address = M * 80 + StartCol
    BitPattern = NOT BitPattern
    FOR N = 1 TO Wdth
      DrawByteVE Address, BitPattern, Clr
      Address = Address + 1
    NEXT
  NEXT
  ShowCursor

END SUB

'****************************************************************************
' Description: Pull Down Menu Sub Program
'          by: Don Malin,  (c) Crescent Software 1988
'    modified: Phil Cramer & Brian C. Giedt, (c) 1990
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
'     Any value in the low byte of an element indicates that the choice is
'     inactive (Non Selectable).  The high byte of the element indicates
'     the offset (0 based) of the hot key letter.
'
'   Menu -
'     Current Menu Number.  A nonzero value on entry will cause that menu
'     to be displayed.
'
'   Choice -
'     Current Menu Choice.  A nonzero value on entry will cause that
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
'       0 - PullDnMS will take control until an active choice is selected
'           or the [Esc] key is pressed.  (Single Tasking Mode)
'       1 - Used on initial entry for multitasking mode.  Only saves the
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
'****************************************************************************
'
SUB PullDnMSG (Choice$(), Stat(), Menu, Choice, Ky$, Action) STATIC

    LOCATE , , 0

    AltReleased = NOT AltKey%

    IF Action = 4 THEN Action = 1       'See if they forgot to reinit. Action
    IF Action < 3 THEN                  'Redisplaying?
       IF Action < 2 THEN               'Redisplaying whole menu?
          LastMenu = UBOUND(Choice$, 2) 'Find Last Bar Menu Choice
          LastChoice = 0
          Wdth = 0
                                       
          SaveToAddress = &HA800
          IF GPDat%(31) = 8 THEN
             SaveToAddress = &HAA00     'Address above Address of line 480
          END IF
          HideCursor
                                        'Save the Bar Line
          GMove2VE 1, (BarLine - 1) * GPDat%(71), 80, GPDat%(71), SaveToAddress, 0
                                        'Display the Menu Bar on top line
          ShowCursor
          BarPrintMSG Choice$(), Stat() 'Print the Bar Choices
         
          Wdth = 0
       END IF

       ArrayEnd = UBOUND(Choice$, 1)

       GOSUB PullDisplay                'Display the Menu box
       
       IF Action THEN Action = 3        'Reset the Action flag to idle state

       PrevChoice = Choice
       PrevMenu = Menu
       ButtonPress 1, Down, Presses, MCol, MRow
       IF Down = 0 THEN GOSUB PullHiLite
    END IF

                                        'If Action flag=5, Restore the screen
    IF Action = 5 THEN
       GOSUB CleanUp
       PrevChoice = Choice
       PrevMenu = Menu
       AltUsed = 0
       EXIT SUB                         'Bail out
    END IF

    IF Choice <> PrevChoice THEN GOSUB PullHiLite
    IF Menu <> PrevMenu THEN GOSUB PullDisplay



    DO
       IF AltKey% THEN                  'Here we are going to allow the Alt
         IF AltReleased THEN            ' key to be released and re-depressed
           GOSUB CleanUp                'Remove any menus visible
           Ky$ = CHR$(0)                'Pretend we are doing nothing
           EXIT SUB                     'Exit and let the menu activation
                                        ' routines like PullMenKeyMSG% bring
                                        ' us back into PullDnMSG properly.
         END IF
       ELSE
         AltReleased = -1
       END IF
                                        'If we have a Window, Highlight Choice
                                        'Get typed characters
       Ky$ = INKEY$

       'Mouse code starts here
       ButtonPress 1, Down, Presses, MCol, MRow
       IF Presses = 0 THEN GetCursor MCol, MRow, Button
       IF MRow = 0 THEN
         MRow = 1
       ELSE
         MRow = ((MRow - 1) \ GPDat%(71)) + 1
       END IF
       MCol = (MCol \ 8) + 1
       IF Button = 1 THEN
         t = t
       END IF
       IF (MRow <> LMRow OR MCol <> LMCol OR Presses) AND Down = 1 THEN
          WasPressed = -1
          IF MRow - BarLine <= LastChoice AND MRow - BarLine > 0 AND MCol >= StartCol AND MCol <= EnBar + 2 THEN
             Choice = MRow - BarLine
             IF Choice$(Choice, Menu) = "-" THEN
                Choice = PrevChoice
                WasPressed = 0
             END IF
             GOSUB PullHiLite
          ELSEIF MRow = BarLine THEN
             Temp = BarLCol + 2
             FOR N = 0 TO LastMenu
                 IF MCol >= Temp AND MCol <= Temp + LEN(Choice$(0, N)) + 1 THEN EXIT FOR
                 IF N < LastMenu THEN
                    Temp = Temp + Stat(0, N + 1) MOD 256 + LEN(Choice$(0, N)) + 2
                 END IF
             NEXT
             IF N <= LastMenu THEN Menu = N
             IF Menu <> PrevMenu THEN GOSUB PullDisplay
          END IF
          
       ELSEIF Button AND 2 THEN
          Ky$ = CHR$(27)
          DO
             GetCursor MCol, MRow, Button
          LOOP WHILE Button AND 2
       END IF

       IF Down = 0 AND WasPressed THEN
          WasPressed = 0
          IF MRow - BarLine <= LastChoice AND MRow - BarLine > 0 AND MCol >= StartCol AND MCol <= EnBar + 2 THEN
             Ky$ = CHR$(13)
          ELSEIF MRow = BarLine THEN
             IF Wdth = 0 THEN
                Ky$ = CHR$(13)
             ELSE
                GOSUB PullHiLite
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
       'End of mouse handling code

       IF LEN(Ky$) THEN
          K = ASC(RIGHT$(Ky$, 1))
          IF LEN(Ky$) = 2 THEN
             IF AltKey THEN
                IF K >= 120 THEN K = K - 119
                K = ASC(MID$(AltChars$, K, 1))
             ELSE
                K = -K
             END IF
          END IF

          SELECT CASE K
             CASE 13, 27
                IF Stat(Choice, Menu) MOD 256 = 0 OR K = 27 THEN
                   IF Action = 0 THEN
                      GOSUB CleanUp
                      EXIT SUB
                   ELSE
                      Action = 4
                   END IF
                ELSEIF K = 13 THEN
                   Ky$ = ""
                END IF

             CASE 32 TO 254
                IF Wdth AND K <> 45 THEN 'See if User pressed a Choice Letter
                                                'Make Key Uppercase
                   IF K >= 97 AND K <= 122 THEN K = K - 32

                   Temp = 0
             
                   DO
                      Choice = Choice + 1
                      IF Choice > LastChoice THEN
                         IF Temp THEN EXIT DO
                         Choice = 1
                         Temp = Choice
                      END IF
                      Ltr = ASC(UCASE$(MID$(Choice$(Choice, Menu), Stat(Choice, Menu) \ 256 + 1, 1)))
                   LOOP WHILE K <> Ltr OR Stat(Choice, Menu) MOD 256

                   IF K <> Ltr OR Choice > LastChoice THEN
                      Choice = PrevChoice
                   ELSE
                      Ky$ = CHR$(13)
                      AltUsed = AltKey
                      IF Action = 0 THEN
                         GOSUB CleanUp
                         EXIT SUB
                      ELSE
                         Action = 4
                      END IF
                   END IF
                END IF

             CASE -72                   'Up Arrow Key
                IF Wdth THEN
                   Choice = Choice - 1 + (Choice$(Choice - 1, Menu) = "-")
                   IF Choice < 1 THEN Choice = LastChoice
                END IF

             CASE -80                   'Down Arrow Key
                IF Wdth THEN
                   IF Choice >= LastChoice THEN Choice = 0
                   Choice = Choice + 1 - (Choice$(Choice + 1, Menu) = "-")
                END IF

             CASE -71                   'Home Key
                IF Wdth THEN Choice = 1

             CASE -79                   'End Key
                IF Wdth THEN Choice = LastChoice

             CASE -75                   'Left Arrow Key
                IF Menu = 0 THEN        'If on Far Left Bar Choice, go to
                   Menu = LastMenu      '  Far Right Choice
                ELSE
                   Menu = Menu - 1      'Otherwise Decrement Bar Choice
                END IF
                GOSUB PullDisplay       'Display the New Choice Window

             CASE -77                   'Right Arrow Key
                IF Menu = LastMenu THEN 'If on Far Right Bar Choice, go to
                   Menu = 0             '  Far Left Choice
                ELSE
                   Menu = Menu + 1      'Otherwise Increment Bar Choice
                END IF
                GOSUB PullDisplay       'Display the New Choice Window

             CASE ELSE
          END SELECT

          GOSUB PullHiLite
       END IF

       PrevChoice = Choice
       PrevMenu = Menu
    LOOP WHILE Action = 0

    
    EXIT SUB

PullHiLite:
    HideCursor
    IF Wdth AND Choice <> PrevChoice THEN
       IF PrevChoice THEN
          IF Stat(PrevChoice, Menu) MOD 256 THEN
             Clr = GPDat%(77)   'Inactive menu choice
          ELSE
             Clr = GPDat%(76)   'Active menu choice
          END IF
          GPrint2VE GPDat%(71) * (PrevChoice + BarLine - 1) + 1, StartCol, "  " + Choice$(PrevChoice, Menu) + STRING$(Wdth - LEN(Choice$(PrevChoice, Menu)) + 2, " "), Clr
          UnderlineEntryMSG GPDat%(71) * (PrevChoice + BarLine) - 1, StartCol + 2 + Stat(PrevChoice, Menu) \ 256, Clr
       END IF

       IF Choice THEN
          GPrint2VE GPDat%(71) * (Choice + BarLine - 1) + 1, StartCol, "  " + Choice$(Choice, Menu) + STRING$(Wdth - LEN(Choice$(Choice, Menu)) + 2, " "), GPDat%(78)
          UnderlineEntryMSG GPDat%(71) * (Choice + BarLine) - 1, StartCol + 2 + Stat(Choice, Menu) \ 256, GPDat%(78)
          IF Stat(Choice, Menu) MOD 256 THEN
             DotPatternMSG Choice + BarLine, StartCol + 1, LEN(Choice$(Choice, Menu)), GPDat%(78) \ 256
          END IF
       END IF
    END IF
    ShowCursor
RETURN


PullDisplay:
    HideCursor
                                        'Restore the screen
    IF Menu <> PrevMenu OR Action < 2 THEN
       IF Wdth THEN
          GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, -1
          Wdth = 0
       END IF
       IF StartCol THEN
                                        'Re-paint the Menu bar
         GPrint0VE BarLine, StartCol, " " + Choice$(0, PrevMenu) + " ", GPDat%(74)
         UnderlineEntryMSG BarLine * GPDat%(71) - 2, StartCol + 1 + Stat(0, PrevMenu) \ 256, GPDat%(74)
       END IF
       IF Menu <> PrevMenu OR Choice = 0 THEN Choice = 1
       PrevChoice = Choice
    END IF
    PrevMenu = Menu                     'Save the menu number

    StartCol = BarLCol + 2              'Find the column positions to start
    FOR C = 0 TO Menu - 1               '  and end the highlight on Bar Menu
        StartCol = StartCol + LEN(Choice$(0, C)) + 2 + Stat(0, C + 1) MOD 256
    NEXT
    EnCol = StartCol + LEN(Choice$(0, Menu)) + 1
                                       
                                        'Hilite the Bar Menu Choice
    GPrint0VE BarLine, StartCol, " " + Choice$(0, Menu) + " ", GPDat%(78)
    UnderlineEntryMSG BarLine * GPDat%(71) - 2, StartCol + 1 + Stat(0, Menu) \ 256, GPDat%(78)

    ShowCursor
   
    Wdth = 0                            'Find the Width and # of Choices of
                                        '  the new menu
    FOR C = 1 TO ArrayEnd
       ChLen = LEN(Choice$(C, Menu))
       IF ChLen = 0 THEN EXIT FOR
       IF ChLen > Wdth THEN Wdth = ChLen
    NEXT
    LastChoice = C - 1

    IF StartCol + Wdth + 2 > 80 THEN    'If the Right Side of the window is
       StartCol = 80 - Wdth - 2         '  off the screen, adjust the Left
    END IF                              '  Side of the window

    EnBar = StartCol + Wdth + 1         'Set the Right Side of the Window

    IF Wdth THEN                        'If there are window choices, print
                                        '  them
       HideCursor
  
       Save1Pos = BarLine * GPDat%(71)
       Save2Pos = StartCol - 1                     'The - 1 will take care of the line drawn down the left side
       Save3Pos = (LastChoice + 1) * GPDat%(71)    'The + 1 is for the shadow region
       Save4Pos = Wdth + 4 + 2 + 1                 'The + 1 is for the shadow region
       GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, 0
       GPDat%(72) = SaveToAddress + &H100 + (Save3Pos * Save4Pos + 16) \ 16
     
       CALL LineBFVE(StartCol * 8 - 8, BarLine * GPDat%(71), (StartCol + Wdth + 3) * 8 - 1, (BarLine + LastChoice) * GPDat%(71), GPDat%(76) \ 256)    'pc
       CALL LineBVE(StartCol * 8 - 9, BarLine * GPDat%(71), (StartCol + Wdth + 3) * 8, (BarLine + LastChoice) * GPDat%(71) + 1, GPDat%(76) MOD 256)   'pc

       FOR C = 1 TO LastChoice
           IF Choice$(C, Menu) = "-" THEN
               CALL LineVE(StartCol * 8 - 8, (BarLine + C) * GPDat%(71) - GPDat%(71) \ 2, (StartCol + Wdth + 3) * 8 - 1, (BarLine + C) * GPDat%(71) - GPDat%(71) \ 2, GPDat%(76) MOD 256)  'pc
           ELSE
               IF Stat(C, Menu) MOD 256 THEN
                 Clr = GPDat%(77)
               ELSE
                 Clr = GPDat%(76)
               END IF
               GPrint2VE GPDat%(71) * (C + BarLine - 1) + 1, StartCol + 2, Choice$(C, Menu), Clr
               UnderlineEntryMSG GPDat%(71) * (C + BarLine) - 1, StartCol + 2 + Stat(C, Menu) \ 256, Clr
           END IF
       NEXT
       ShowCursor

       PrevChoice = 0
       Choice = 1
       GOSUB PullHiLite

       'You can REM out the shadow effect here if it does not produce
       ' satisfactory effects with your background screen.
       GPaintBox EnBar + 3, GPDat%(71) * (BarLine + 1) - 6, EnBar + 3, GPDat%(71) * (C + BarLine - 1) + 8, -1, 0
       GPaintBox StartCol + 1, GPDat%(71) * (C + BarLine - 1) + 1, EnBar + 3, GPDat%(71) * (C + BarLine - 1) + 8, -1, 0
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

CleanUp:
    HideCursor
    GMove2VE 1, (BarLine - 1) * GPDat%(71), 80, GPDat%(71), SaveToAddress, -1
    IF Wdth THEN
      GMove2VE Save2Pos, Save1Pos, Save4Pos, Save3Pos, SaveToAddress + &H100, -1
      Wdth = 0
    END IF
    ShowCursor
RETURN

END SUB

'****************************************************************************
'Checks for menu bar hot keys (Alt+Menu Letter).  Also checks for mouse
'presses on the menu bar.  Can be polled by your program to see if the User
'has done any thing to invoke the pull down menu.
'
'   Ky$ -
'     Passes the key string to check.
'
'   Choice$() -
'     The "Choice$" Array holds the Menu Choices.
'     Choice$(0, Menus) hold the Bar Titles.
'
'   Stat() -
'     This is an integer array parallel to the Choice$ array.
'     The high byte of the element indicates the offset of the hot key letter.
'
'  The function will return -1 if no menu was selected, otherwise it will
'  return the menu number of the User's choice.
'****************************************************************************
'
FUNCTION PullMenKeyMSG% (Ky$, Choice$(), Stat()) STATIC

    SHARED HotKeys$

    IF LEN(Ky$) = 2 THEN
       Menu = INSTR(HotKeys$, RIGHT$(Ky$, 1)) - 1
    ELSE
       Menu = -1
    END IF

    GetCursor MCol, MRow, Button
    IF Button THEN
       LastMenu = UBOUND(Choice$, 2)
       MRow = (MRow \ GPDat(71)) + 1           'PC
       IF MRow = BarLine THEN
          MCol = (MCol \ 8) + 1
          Temp = BarLCol + 2
          FOR N = 0 TO LastMenu
              IF MCol >= Temp AND MCol <= Temp + LEN(Choice$(0, N)) + 1 THEN
                 Menu = N
                 EXIT FOR
              END IF
              IF N < LastMenu THEN
                 Temp = Temp + Stat(0, N + 1) MOD 256 + LEN(Choice$(0, N)) + 2
              END IF
          NEXT
       END IF
    END IF

    IF AltUsed THEN AltUsed = AltKey
   
    IF Menu = -1 AND NOT AltUsed THEN
       IF AltKey THEN
          IF WasDown = 0 THEN
             WasDown = -1
          ELSEIF LEN(Ky$) THEN
             WasDown = 0
             KeyWasPressed = -1
          END IF

       ELSEIF WasDown THEN
          WasDown = 0
          IF Bar OR LEN(Ky$) OR KeyWasPressed OR InStat THEN
             GOSUB UndoBar
             KeyWasPressed = 0
          ELSE
             Bar = -1
             BarCh = 0
             PrevBarCh = 0
             GOSUB HiLiteBar
          END IF
       END IF

       IF Bar AND Menu = -1 THEN
          IF LEN(Ky$) THEN
             IF LEN(Ky$) = 1 THEN
                Ky$ = UCASE$(Ky$)
                K = ASC(Ky$)
             ELSE
                K = -ASC(RIGHT$(Ky$, 1))
             END IF
             SELECT CASE K
                CASE 13, -72, -80
                   Menu = BarCh
                   Ky$ = ""
                CASE 27, -83
                   GOSUB UndoBar
                CASE 32 TO 255
                   FOR N = 0 TO LastMenu
                       IF Ky$ = UCASE$(MID$(Choice$(0, N), Stat(0, N) \ 256 + 1, 1)) THEN
                          Menu = N
                          EXIT FOR
                       END IF
                   NEXT
                   IF N > LastMenu THEN
                      GOSUB UndoBar
                   ELSE
                      Ky$ = ""
                   END IF
                CASE -75
                   BarCh = BarCh - 1
                   IF BarCh < 0 THEN BarCh = LastMenu
                   GOSUB HiLiteBar
                   Ky$ = ""
                CASE -77
                   BarCh = BarCh + 1
                   IF BarCh > LastMenu THEN BarCh = 0
                   GOSUB HiLiteBar
                   Ky$ = ""
                CASE ELSE
                   GOSUB UndoBar
             END SELECT
           
          END IF
       END IF
    END IF

    IF Menu > -1 THEN
       GOSUB UndoBar
       WasDown = 0
    END IF

    PullMenKeyMSG% = Menu

    EXIT FUNCTION


HiLiteBar:
    HideCursor
    IF BarCh <> PrevBarCh THEN
       IF StartCol THEN
          GPrint0VE BarLine, StartCol, " " + Choice$(0, PrevBarCh) + " ", GPDat%(74)
          UnderlineEntryMSG BarLine * GPDat%(71) - 2, StartCol + 1 + Stat(0, PrevMenu) \ 256, GPDat%(74)
       END IF
    END IF
    PrevBarCh = BarCh                   'Save the menu number
                                     
    StartCol = BarLCol + 2              'Find the column positions to start
    FOR N = 0 TO BarCh - 1              '  and end the highlight on Bar Menu
        StartCol = StartCol + LEN(Choice$(0, N)) + 2 + Stat(0, N + 1) MOD 256
    NEXT
    'EnCol = StartCol + LEN(Choice$(0, N)) + 1

    GPrint0VE BarLine, StartCol, " " + Choice$(0, N) + " ", GPDat%(78)
    UnderlineEntryMSG BarLine * GPDat%(71) - 2, StartCol + 1 + Stat(0, N) \ 256, GPDat%(78)
    ShowCursor
RETURN

UndoBar:
    Bar = 0
    BarPrintMSG Choice$(), Stat()
RETURN

END FUNCTION

'****************************************************************************
'Sets the low byte of a word (Stat() element) without affecting the high byte.
'Used to set the Status byte of an element of the "Stat" array without
'disturbing the "Hot key offset" byte.
'
'  Status -
'    Status word to be set.  ie. Stat(Choice, Menu)
'
'  Truth -
'    Value to set.  ie. "Truth = LEN(FileName$) = 0"
'
'Example: CALL SetStatus(Stat(5, 0), LEN(FileName$) = 0)
'****************************************************************************
'
SUB SetStatus (Status, Truth) STATIC

    Status = 256 * (Status \ 256) + ABS(Truth)

END SUB

SUB UnderlineEntryMSG (Y, UnderScorePos, ScoreColor) STATIC

  LineVE UnderScorePos * 8 - 8, Y, UnderScorePos * 8 - 1, Y, ScoreColor MOD 256

END SUB

