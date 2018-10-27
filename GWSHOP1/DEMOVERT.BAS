'********** DemoVert.Bas - demonstrates VertMenu in graphics mode

'Copyright (c) 1988,1990 Don Malin & Brian C. Giedt
'Copyright (c) 1988 Crescent Software

'This demonstrates the routines:
'   VertMenuG  - A basic subroutine which holds a complete vertical menu
'                system.
'   GMove2VE   - An assembler routine used by VertMenuG to store and retrieve
'                sections of the EGA or VGA graphics screens.
'   GPrint0VE  - An assembler routine which is not only a replacement for the
'                BASIC PRINT statement in EGA and VGA graphics modes, but has
'                the ability to specify a unique background color for just
'                the string being printed.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo.Bas'

CALL SetVideo

'Set the background color for the entire screen to 1 (blue)
CALL LineBFVE(0, 0, GPDat%(43), GPDat%(44), 1)

GPDat%(57) = 1   'Tell the routine GPaintBox the overall background color

'Set up some boxes for the demo
FOR T = 20 TO 171 STEP 10
    DO: C = RND * 15: LOOP UNTIL C <> 4
    CALL LineBVE(T, T, 640 - T, 350 - T, C)
NEXT
CALL InitMouse(There)
ShowCursor

'---- Remember the bottom most screen row for text display in polled mode
BotRow = 25
IF GPDat%(31) = 8 THEN BotRow = 30


DIM Choice$(80)         'dimension the choices

FOR X = 1 TO 80
    READ Choice$(X)
NEXT

DATA "Choice  1", "Moist   2", "Roast   3", "Toast   4", "Most    5"
DATA "Boast   6", "Ghost   7", "Post    8", "Past    9", "Last   10"
DATA "Raft   11", "Graft  12", "Rhyme  13", "Time   14", "Mine   15"
DATA "Line   16", "Sign   17", "Benign 18", "Tine   19", "Divine 20"
DATA "Crime  21", "Choice 22", "Choice 23", "Choice 24", "Choice 25"
DATA "Choice 26", "Choice 27", "Choice 28", "Choice 29", "Choice 30"
DATA "Choice 31", "Choice 32", "Choice 33", "Choice 34", "Choice 35"
DATA "Choice 36", "Choice 37", "Choice 38", "Choice 39", "Choice 40"
DATA "Choice 41", "Choice 42", "Choice 43", "Choice 44", "Choice 45"
DATA "Choice 46", "Choice 47", "Choice 48", "Choice 49", "Choice 50"
DATA "Choice 51", "Choice 52", "Choice 53", "Choice 54", "Choice 55"
DATA "Choice 56", "Choice 57", "Choice 58", "Choice 59", "Choice 60"
DATA "Choice 61", "Choice 62", "Choice 63", "Choice 64", "Choice 65"
DATA "Choice 66", "Choice 67", "Choice 68", "Choice 69", "Choice 70"
DATA "Choice 71", "Choice 72", "Choice 73", "Choice 74", "Choice 75"
DATA "Choice 76", "Choice 77", "Choice 78", "Choice 79", "Choice 80"



MaxLen = 9              'this is the menu width
BoxBot = 20             'limit the box length to go no lower than line 20
Action = 0              '0 means stay in the menu until they select something
'Choice = 12            'you could pre-load choice to highlight automatically

HideCursor
CALL GPrint0VE(1, 20, "     VertMenuG in non-Polled mode", 15 + 256)
ShowCursor

LOCATE 3, 6, 0          'set upper left corner of menu, turn off the cursor



'---- Non-Polled mode
Action = 0
CALL VertMenuG(Choice$(), Choice, MaxLen, BoxBot, Ky$, Action)


'---- Show 'em what happened
HideCursor
CALL GPrint0VE(BotRow - 1, 2, "Choice Number" + STR$(Choice) + " was selected", 14 + 256)
IF Ky$ = CHR$(27) THEN CALL GPrint0VE(BotRow - 1, 32, " - Escape was pressed", 14 + 256)
ShowCursor




'---- Wait for a keypress
CALL GPrint0VE(BotRow, 2, "Press a key", 15 + 256)
WHILE INKEY$ = "": WEND


HideCursor
CALL GPrint0VE(1, 20, "      VertMenuG in Polled mode   ", 15 + 256)
CALL GPrint0VE(BotRow - 1, 2, SPACE$(78), 1 + 256)
ShowCursor
LOCATE 3, 6, 0          'set upper left corner of menu, turn off the cursor



'---- Demonstrate polled mode
Action = 1                'Action 1 initiates polled mode
Choice = 1                'Need to reset choice from previous VertMenuG call
DO
  CALL VertMenuG(Choice$(), Choice, MaxLen, BoxBot, Ky$, Action)

  '---- Display the current choice
  IF Choice <> LastChoice THEN
    LastChoice = Choice
    HideCursor
    CALL GPrint0VE(BotRow, 2, "The current choice is: " + Choice$(Choice) + ", element number" + STR$(Choice), 15 + 256)
    ShowCursor
  END IF


  '---- Display the current time just to demonstrate that in polled mode
  '     you can do other things at the same time
  T$ = TIME$
  IF T$ <> LastTime$ THEN
    HideCursor
    CALL GPrint0VE(1, 72, T$, 15 + 256)
    ShowCursor
    LastTime$ = T$
  END IF


LOOP UNTIL Action = 4
CALL VertMenuG(Choice$(), Choice, MaxLen, BoxBot, Ky$, 5)

'---- Show 'em what happened
HideCursor
CALL GPrint0VE(BotRow - 1, 2, "Choice Number" + STR$(Choice) + " was selected", 14 + 256)
IF Ky$ = CHR$(27) THEN CALL GPrint0VE(BotRow - 1, 32, " - Escape was pressed", 14 + 256)
ShowCursor

