'********* VertMenu.Bas - A Vertical menu for graphics mode

'Copyright (c) 1989,1990 Don Malin & Brian C. Giedt
'Copyright (c) 1989 Crescent Software

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB GPaintBox (Col1%, Line1%, Col2%, Line2%, OldColor%, NewColor%)

'$INCLUDE: 'Common.GW'

'****************************************************************************
'   File Name: VertMenu.Bas
' Description: Vertical Menu Sub Program
'          by: Don Malin,  (C) Crescent Software 1988
'         and: Brian C. Giedt (c) 1990
'corrected by: Phil Cramer 12/14/93
'
' Parameters:
'
'   Choice$() -
'     The "Choice$" Array holds the menu Choices.
'
'   Choice -
'     Current Menu Choice.  A value on entry will cause that choice to be
'     displayed.
'
'   MaxLen -
'     Length of the incoming Choice strings
'
'   BoxBot -
'     Row number of the bottom of the menu box.
'
'   Ky$ -
'     This string will contain the character or key code that was used to
'     exit the routine.
'
'   Action -
'     Action is a flag which can be used to control the routine in a
'     multi tasking (polled) mode.  The Action commands are as follows:
'       0 - Routine will take control until a choice is selected or the
'           [Esc] key is pressed.  (Single Tasking Mode)
'       1 - Used on initial entry for multi-tasking mode.  Saves the
'           background screen, displays the Menu.  Resets itself to
'           Action = 3.
'       2 - Redisplay the menu contents only.  Reset Action to 3
'       3 - On entry means just check the keyboard and handle keys used by
'           the routine and exit back to the caller.  On exit means nothing
'           was selected.
'       4 - User made a selection or pressed Escape.
'           routine.
'       5 - Restore the screen, erase the screen buffer used by the routine.
'
' External Routines:  GMove2VE, GPaintBox, GPrint0VE, Mouse
'
' 12/14/93  Modified to correct errors in polled mode. When Enter or Escape
'           was pressed the screen was restored rather than waiting for
'           a subsequent call with Action set to 5. The code for Action 5
'           was never executed because the "DidVert" flag was never set.
'           This flag was unnecessary and has been removed.
'           Also added code to more accurately determine the number of
'           available screen rows and corrected the mouse code.
'           P. Cramer
'
'
'************************************************************************
SUB VertMenuG (Item$(), Choice, MaxLen, BoxBot, Ky$, Action) STATIC
                                             'Item$() has one dimension
                                             'Choice is the value returned
   
    SaveToAddress = &HA900
    IF GPDat%(31) = 8 THEN
       SaveToAddress = &HAB00
    END IF

    IF Action = 4 THEN Action = 1            'See if they forgot to reset
    IF Action = 5 THEN  'Restore the screen if action=5
       HideCursor
       GMove2VE Left.Margin, (Top - 2) * GPDat%(71), Right.Margin - Left.Margin + 2, (Bottom - Top + 4) * GPDat%(71), SaveToAddress, -1
       ShowCursor
       EXIT SUB
    END IF


    IF Action < 2 THEN

       ScRows = 25                              'Assume 25 line mode

       '---- Determine max screen rows available
       SELECT CASE GPDat(31)
         CASE 5
           IF GPDat(71) = 8 THEN ScRows = 43

         CASE 8
           ScRows = 30
           IF GPDat(71) = 8 THEN ScRows = 60

       END SELECT
       
       IF BoxBot = 0 THEN BoxBot = ScRows - 1
       IF BoxBot >= ScRows THEN BoxBot = ScRows - 1
       
       'Find the Inverse box color for the Scroll Bar
       ScrlClr = (GPDat%(75)) \ 256 + (GPDat%(75) MOD 256) * 256

       Fill$ = SPACE$(MaxLen + 1)              'used in Dsply to pad spaces

       '---- determine how many choices to display, and where to put the menu
       MaxNum = UBOUND(Item$)                  'find number of active items
       MaxNum = FindLast%(VARPTR(Item$(MaxNum)), MaxNum)
    
       Top = CSRLIN + 1                         'put the menu at the current
       Left.Margin = POS(0)                     '  cursor location
       Bottom = Top + MaxNum - 1
       More = 0
       LastRow = 0

       IF Bottom >= BoxBot THEN  '<---/-- BoxBot sets lowest row to display
          More = -1              '   /
          Bottom = BoxBot - 1    '<-/
       END IF
       WinSize = Bottom - Top + 1
       Right.Margin = Left.Margin + MaxLen + 3

       '----- Save the underlying screen area
       HideCursor
       GMove2VE Left.Margin, (Top - 2) * GPDat%(71), Right.Margin - Left.Margin + 2, (Bottom - Top + 4) * GPDat%(71), SaveToAddress, 0
       GPDat%(72) = SaveToAddress + ((Bottom - Top + 4) * GPDat%(71) * (Right.Margin - Left.Margin + 3) + 16) \ 16
       ShowCursor
      
       '----- Make sure the choice # is in range
       Offset = 0
       IF Choice = 0 OR Choice > MaxNum THEN
          Choice = 1
       END IF

       IF Choice > Offset + WinSize THEN
          Offset = Choice - WinSize
       END IF

       '----- draw border and display items on the screen
       HideCursor
       GPrint0VE CSRLIN, Left.Margin, "É" + STRING$(MaxLen + 2, "Í") + "»", GPDat%(75)
       FOR X = Top TO Bottom                  'Draw sides, display items
           APos = X - Top + 1

           IF Item$(APos + Offset) = "-" THEN
              Item$(APos + Offset) = STRING$(MaxLen, "Ä")
           END IF
           LSET Fill$ = Item$(APos + Offset)
                                                   'Left box side and choice
           GPrint0VE X, Left.Margin, "º ", GPDat%(75)
           GPrint0VE X, Left.Margin + 2, Fill$, GPDat%(76)
           IF X = Top AND More = -1 THEN           'Draw Up arrow box side
              GPrint0VE X, Right.Margin, CHR$(24), ScrlClr
           ELSEIF X = Bottom AND More = -1 THEN    'Draw Down arrow box side
              GPrint0VE X, Right.Margin, CHR$(25), ScrlClr
           ELSEIF More THEN                        'Draw Scroll bar
              GPrint0VE X, Right.Margin, "²", ScrlClr
           ELSE                                    'Draw normal box side
              GPrint0VE X, Right.Margin, "º", GPDat%(75)
           END IF
       NEXT
                                                   'Draw the bottom of box
       GPrint0VE X, Left.Margin, "È" + STRING$(MaxLen + 2, "Í") + "¼", GPDat%(75)

       GPaintBox Right.Margin + 1, GPDat%(71) * (Top - 1) - 7, Right.Margin + 1, GPDat%(71) * (Bottom + 2) - 7, -1, 0
       GPaintBox Left.Margin + 1, GPDat%(71) * (Bottom + 1), Right.Margin + 1, GPDat%(71) * (Bottom + 2) - 7, -1, 0
      
       ShowCursor

       Fill$ = ""
       LCol = Left.Margin + 1                      'Set variables for Hilite
       RCol = LCol + MaxLen + 1
       OPtr = 0
       GOSUB VertHiLite
    END IF

    IF Action = 2 THEN                        'Redisplay menu contents
       GOSUB VertDisplay
       GOSUB VertHiLite
    END IF

    IF Action THEN Action = 3                 'Reset Action = 3 (Idle state)


    DO

       DO                                     'Look for keys
           Ky$ = INKEY$

           'Start of mouse code
           '----- Get Mouse Coords. and Botton Info.
           IF LEN(MouseStor$) = 0 THEN
              MouseStor$ = SPACE$(MBuffSize%)
           END IF
           CALL MGetState(MouseStor$)

           ButtonPress 1, Down, Presses, X, Y
           IF Presses = 0 THEN
             GetCursor X, Y, Button
           END IF
           MRow = (Y \ GPDat%(71)) + 1          'Convert X, Y to Row and Column
           MCol = (X \ 8) + 1

           '----- If User pressed a button inside the Box, set flag.
           IF Presses THEN
              Inside = 0
              IF MRow >= Top - 1 AND MRow <= Bottom + 1 THEN
                 IF MCol > Left.Margin AND MCol < Right.Margin - More THEN
                    Inside = -1
                 END IF
              END IF
           END IF

           IF Down = 0 THEN LetGo2& = PDQTimer&

           IF (Down AND 2) THEN
              Ky$ = CHR$(27)

           '----- Button pressed outside the box
           ELSEIF Presses AND NOT Inside THEN
              IF PutBack THEN
                 PutBack = 0
              ELSEIF Presses AND LEN(MouseStor$) > 0 THEN
                 HideCursor
                 CALL MSetState(MouseStor$)
                 PutBack = -1
                 Presses = 0
              END IF

           '----- Handle only Mouse actions that were initiated inside the box
           ELSEIF Inside THEN
              IF Presses THEN WasPressed = -1

              '----- See if button pressed on the Scroll bar
              IF Presses AND More THEN
                 IF MCol = Right.Margin AND MRow > Top AND MRow < Bottom THEN
                                                'See if button pressed on the
                    IF MRow = BarPtr THEN       '  Scroll Bar Pointer
                       OnPtr = -1
                    END IF
                    ScrlBar = -1                'Set Scroll Bar action flag
                 END IF
              END IF
              
              '----- Handle Scroll Bar Mouse actions
              IF ScrlBar THEN
                 IF Down = 0 THEN               'If button let go
                    IF MRow > BarPtr THEN       'If Below the Scroll Pointer
                       Ky$ = CHR$(0) + CHR$(81)         'Page Down
                    ELSEIF MRow < BarPtr THEN           'Must be above Scroll Pointer
                       Ky$ = CHR$(0) + CHR$(73)         'Page Up
                    END IF
                    ScrlBar = 0                 'Action complete so reset flag
                    OnPtr = 0
                    WasPressed = 0

                 ELSEIF OnPtr THEN              'Move the Scroll Bar Pointer
                    IF LMRow <> MRow THEN
                       BarRow = MRow
                       IF BarRow >= Bottom THEN BarRow = Bottom - 1
                       IF BarRow <= Top THEN BarRow = Top + 1
                       Prcnt# = (BarRow - Top - 1) / (WinSize - 3)
                       Choice = FIX(Prcnt# * (MaxNum - 1)) + 1
                       Offset = Choice - 1
                       IF Offset + WinSize > MaxNum THEN Offset = MaxNum - WinSize
                       GOSUB VertDisplay
                       GOSUB VertHiLite
                    END IF
                 END IF

              '----- See if button pressed on Top or Bottom Arrow icons
              ELSEIF Down AND MCol = Right.Margin AND More THEN
                 IF PDQTimer& > LstScrl& + 1 THEN       'Delay between updates
                    IF MRow = Top THEN                  'If on top, do Up
                       IF Choice > Offset + 1 THEN Choice = Offset + 2
                       Ky$ = CHR$(0) + CHR$(72)         '  Arrow proc.
                    ELSEIF MRow = Bottom THEN           'If on Bottom, do
                       IF Choice < Offset + WinSize - 1 THEN Choice = Offset + WinSize - 1
                       Ky$ = CHR$(0) + CHR$(80)         '  Down Arrow Proc.
                    END IF
                    LstScrl& = PDQTimer&                'Update Delay
                    IF Presses THEN LstScrl& = PDQTimer& + 4 'If first press,
                 END IF                                 'leave more time
             
              '----- Button pressed on Box Bottom or Top
              ELSEIF More AND Down = 1 AND (MRow < Top OR MRow > Bottom) THEN
                 IF PDQTimer& > LstScrl& + 1 THEN       'Delay between updates
                    IF MRow < Top THEN                  'If higher than Top,
                       Ky$ = CHR$(0) + CHR$(72)         '  Arrow proc.
                    ELSEIF MRow > Bottom THEN           'If Lower than Bottom,
                       Ky$ = CHR$(0) + CHR$(80)         '  Down Arrow Proc.
                    END IF
                    LstScrl& = PDQTimer&                'Update Delay
                    IF Presses THEN LstScrl& = PDQTimer& + 4 'If first press,
                 END IF                                 'leave more time

              '----- Button Pressed or Down on a Choice
              ELSEIF Down THEN
                 IF MRow <> LMRow OR MCol <> LMCol OR Presses THEN
                    IF MRow <= Bottom AND MRow >= Top THEN
                       TChoice = MRow - Top + 1 + Offset 'Calc. Choice number
                       IF LEFT$(Item$(TChoice), 1) <> "Ä" THEN
                          Choice = TChoice
                          GOSUB VertHiLite              'Hi-Lite new choice
                       END IF
                    END IF
                 END IF
             
              '----- If the button was let go
              ELSEIF WasPressed AND Down = 0 THEN
                 IF MRow >= Top AND MRow <= Bottom THEN
                    IF MCol > Left.Margin AND MCol < Right.Margin THEN
                       IF PDQTimer& < LetGo& + 9 THEN 'If half second since the last
                          IF LEFT$(Item$(FstPrsChoice), 1) <> CHR$(196) THEN
                             Ky$ = CHR$(13)           '  press/release, do Enter
                             Choice = FstPrsChoice '  proc.
                          END IF
                       ELSE                        'Start last-press timer
                          LetGo& = PDQTimer&
                          FstPrsChoice = Choice
                       END IF
                    END IF
                 END IF
                 WasPressed = 0
              END IF
             
              IF Down = 0 THEN
                LMRow = -1
                LMCol = -1
              ELSE
                LMRow = MRow                    'Remember were we were so we
                LMCol = MCol                    '  can detect movement.
              END IF

           END IF
           
           'End of Mouse Code

       LOOP WHILE Ky$ = "" AND Action = 0

       KyLen = LEN(Ky$)

       IF KyLen = 1 THEN                      'Non-extended keys

          SELECT CASE ASC(Ky$)
             CASE 13, 27                      'Enter or Escape key
                IF Action THEN
                   Action = 4
                ELSE
                   HideCursor
                   GMove2VE Left.Margin, (Top - 2) * GPDat%(71), Right.Margin - Left.Margin + 2, (Bottom - Top + 4) * GPDat%(71), SaveToAddress, -1
                   ShowCursor
                END IF
                EXIT SUB

             CASE 33 TO 122                   'Letter key pressed
                                              'Reset color
                Ky$ = UCASE$(Ky$)             'Upper case version of letter
                K2$ = LCASE$(Ky$)             'dito for lower case
                Pass = -1                     'First pass through choices
                N = Choice                    'Start at current choice + 1
                DO
                   Pass = Pass + 1
                   IF N < MaxNum THEN
                      N = N + 1
                   ELSE N = 1
                   END IF

                   WHILE N < MaxNum AND Ky$ <> LEFT$(Item$(N), 1) AND K2$ <> LEFT$(Item$(N), 1)
                      N = N + 1
                   WEND
                   IF Ky$ = LEFT$(Item$(N), 1) OR K2$ = LEFT$(Item$(N), 1) THEN
                      Choice = N
                      IF Choice > Offset + (Bottom - Top + 1) THEN
                         Offset = Choice - (Bottom - Top + 1)
                         GOSUB VertDisplay
                      END IF
                      IF Choice <= Offset THEN
                         Offset = Choice - 1
                         GOSUB VertDisplay
                      END IF
                      EXIT DO
                   END IF
                LOOP WHILE Choice > 1 AND Pass = 0
                GOSUB VertHiLite

             CASE ELSE
          END SELECT

       ELSEIF KyLen = 2 THEN                  'Reset color

          SELECT CASE ASC(RIGHT$(Ky$, 1))

             CASE 72
                IF Choice > 1 THEN
                   DO
                      Choice = Choice - 1
                      IF Row - 1 < Top THEN Offset = Offset - 1
                   LOOP WHILE LEFT$(Item$(Choice), 1) = "Ä"
                   GOSUB VertDisplay
                ELSEIF More = 0 THEN
                   Choice = MaxNum
                END IF

             CASE 80
                IF Choice < MaxNum THEN
                   DO
                      Choice = Choice + 1
                      IF Row + 1 > Bottom THEN Offset = Offset + 1
                   LOOP WHILE LEFT$(Item$(Choice), 1) = "Ä"
                   GOSUB VertDisplay
                ELSEIF More = 0 THEN
                   Choice = 1
                END IF

             CASE 73
                IF Offset > 0 THEN
                   IF Offset - WinSize > 0 THEN
                      Offset = Offset - WinSize
                   ELSE Offset = 0
                   END IF
                   Choice = (Row - Top + 1) + Offset
                   GOSUB VertDisplay
                END IF

             CASE 81
                IF Offset + 2 * WinSize < MaxNum THEN
                   Offset = Offset + WinSize
                ELSE Offset = MaxNum - WinSize
                END IF
                Choice = (Row - Top + 1) + Offset
                GOSUB VertDisplay

             CASE 71
                Choice = 1
                Offset = 0
                GOSUB VertDisplay

             CASE 79
                Choice = MaxNum
                Offset = MaxNum - (Bottom - Top + 1)
                GOSUB VertDisplay

             CASE ELSE

          END SELECT
          GOSUB VertHiLite
       END IF

    LOOP WHILE Action = 0                     'get again if not multi-tasking

    MouseStor$ = ""

    EXIT SUB


VertHiLite:
    Row = Top + (Choice - Offset) - 1
    HideCursor
    IF LastRow > 0 AND Row <> LastRow THEN GPrint0VE LastRow, LCol, " " + Item$(Choice - Row + LastRow) + " ", GPDat%(76)
    GPrint0VE Row, LCol, " " + Item$(Choice) + " ", GPDat%(78) 'set inverse color
    ShowCursor
    LastRow = Row
   
    IF More THEN
       Prcnt# = Choice / (MaxNum - 1)
       BarPtr = FIX((WinSize - 3) * Prcnt#) + Top + 1
       HideCursor
       IF BarPtr <> OPtr THEN
          IF OPtr THEN
             GPrint0VE OPtr, Right.Margin, "²", ScrlClr
          END IF
          GPrint0VE BarPtr, Right.Margin, CHR$(8), GPDat%(75)
       END IF
       ShowCursor
       OPtr = BarPtr
    END IF

RETURN

'----- Print the choices in the window
VertDisplay:
    IF Choice <= Offset THEN Offset = Choice - 1
    IF Choice > Offset + WinSize THEN
       Offset = Choice - WinSize
    END IF

    HideCursor
    FOR C = 1 TO (Bottom - Top + 1)
       GPrint0VE Top + C - 1, Left.Margin + 2, Item$(Offset + C), GPDat%(76)
    NEXT
    ShowCursor

RETURN

END SUB

