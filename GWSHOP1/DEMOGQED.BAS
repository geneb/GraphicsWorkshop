'********** DEMOGQED.BAS
'Copyright (c) 1988-1991 Don Malin and Phil Cramer
'Copyright (c) 1988-1991 Crescent Software


DEFINT A-Z

DECLARE SUB QEdit (Array$(), Ky$, Action, Ed AS ANY)

'----- this file contains a TYPE variable for several of QEdit's parameters
'$INCLUDE: 'QEditype.BI'              'Type structure used by QEdit
'$INCLUDE: 'GWDecl.bas'               'Standard GWS code
'$INCLUDE: 'GetVideo.bas'             'Standard GWS code
CALL SetVideo                         'Standard GWS code

CALL InitMouse(MouseThere)            'Initialize the mouse driver (if any)

DIM Ed AS EditInfo                    'create the editor's data structure



'-----------------------------------------------------------------------------
'Note: The Action parameter can be used to operate the editor in a polled
'      (multitasking) mode.  The "Action" values and corresponding meanings
'      are as follows:
'
'      Action =-1:  Initialize the editor for polled mode.  The underlying
'                   screen is saved, the edit window will be drawn, and the
'                   text displayed.  Control is returned to the caller without
'                   checking the keyboard.  The Action flag is reset to 3
'                   automatically (see below).  Action = -1 saves to
'                   conventional memory using the GMove4VE subroutine.
'
'      Action =-2:  Same as Action = -1 except that the underlying screen is
'                   saved to video memory using the GMove2VE subroutine.
'
'      Action = 0:  Use the editor in a non-polled mode.  The editor will
'                   take control and return only when the user presses the
'                   Escape key.
'
'      Action = 1:  Same as Action set to -2 or -1 except that the underlying
'                   screen is NOT saved.
'
'      Action = 2:  Redisplays the edit window and text.  Control is returned
'                   to the caller without checking the keyboard.  As above,
'                   the Action parameter will be reset to 3.  Note: If you
'                   change a window size or location parameter, use this code
'                   to force a redisplay to the new size.
'
'                   Note that if word wrap is on, Actions -2, -1, 0, 1, and 2
'                   will cause the text to be wrapped to the value of Ed.Wrap.
'
'      Action = 3:  This is the idle state of the editor.  Each time the
'                   editor is called with this value, it will check the
'                   keyboard and perform tasks dictated by a key press.
'                   Control is then returned to the caller.
'
'                   While the editor is being polled, the caller can examine
'                   the Ky$ parameter to determine which if any keys were
'                   pressed.  The members of the Ed structure can also be
'                   examined and changed.  Note that if the caller does
'                   change these, the editor should next be called with an
'                   Action of 2 to redisplay the edit window.
'
'      Action = 5:  Clears the string buffers used by QEdit and restores the
'                   underlying screen if originally called with Action set to
'                   -1 or -2.
'
'----------------------------------------------------------------------------
  

    '---- Determine bottom row for screen modes 9 and 12
    IF GPDat(31) = 5 THEN           'EGA
      BotRow = 25
      LRow = 6
    ELSE                            'VGA
      BotRow = 30
      LRow = 8
    END IF
   
    '---- Un-REM for EGA 43 line mode
    'GPDat(31) = 5  '(Un-REM this line if you are running on a VGA)
    'CALL SetVideo  '(Un-REM this line if you are running on a VGA)
    'WIDTH , 43
    'GPDat(71) = 8
    'BotRow = 43
    '-----------

    '---- Un-REM for VGA 60 line mode
    'WIDTH , 60
    'GPDat(71) = 8
    'BotRow = 60
    '-----------


    F2$ = CHR$(0) + CHR$(60)        'extended code for the F2 function key
		    '(used in this demo to change margins)
		   
    REDIM Array$(200)                'holds the main editor string array
    FOR X = 1 TO 76                  'read some sample text into our array
    READ Array$(X)
    NEXT
       
    '----- Fill in editing parameters
    GPDat(57) = 15                   'Text Background color
    Ed.AColor = GPDat(57) * 256      'Text
   
    Ed.Wrap = 62   'word wrap at column 62 (use 0 to disable word wrap)
    Ed.Rows = 15   'number of text lines to display on the screen (3 - 25)
    Ed.Wide = 64   'width of the active screen (10 - 80)
    Ed.HTab = 4    'set tab stops to 4 spaces

    LOCATE LRow, 8    'locate the upper left corner of the edit window frame

    '---- Paint the background cyan
    LineBFVE 0, 0, GPDat(43) - 1, GPDat(44) - 1, 3
    FOR i = 1 TO 50  'Draw something to show we're in graphics mode
      S! = S! + .05
      CIRCLE (320, GPDat(44) \ 2), 150, 0, , , S!
    NEXT
    CIRCLE (320, GPDat(44) \ 2), 50, 11
    PAINT (320, GPDat(44) \ 2), 11, 11

    '---- Print instructions on bottom of screen
    CALL GPrint0VE(BotRow, 1, " ESC - Quit    F2 - Change Margin ", 15 + 8 * 256)
		    ' edit window
    CALL ShowCursor          'Turn on mouse cursor

    Action = -2               'Action -2 to display text, operate in polled
			      'mode and save the underlying screen

    '----- main loop for editing
    DO
      QEdit Array$(), Ky$, Action, Ed      'call QEdit in polled mode
    
      IF Ky$ = F2$ THEN GOSUB ChangeMargin 'F2 function key pressed?
					   '  change margin
    LOOP UNTIL Ky$ = CHR$(27)        'keep calling QEdit until Esc is pressed


    '----- call QEdit again with an Action flag of 5 restore screen and
    '      to clean up memory
    QEdit Array$(), Ky$, 5, Ed
    CALL HideCursor                  'turn the mouse cursor off

END


'----- subroutine to change the right margin
ChangeMargin:

    DO
    IF Ed.Wrap THEN                         'is Word Wrap on?
       HideCursor
       GPrint0VE BotRow, 1, "LEFT or RIGHT arrow keys change margin.  ENTER to set.  ESC to enter manually.", 15 + 4 * 256
       ShowCursor

       DO                                   'wait for a key press
	   X$ = INKEY$
       LOOP UNTIL LEN(X$)

       IF X$ = CHR$(27) THEN                'Escape key pressed?
	  LOCATE BotRow, 1
	  CALL GPrint0VE(BotRow, 1, SPACE$(80), 0)
	  INPUT ; "Enter new right margin: "; Ed.Wrap
	  Action = 2                        'set Action flag to re-display

       ELSEIF X$ = CHR$(0) + CHR$(75) THEN  'Left-Arrow key pressed?
	  Ed.Wrap = Ed.Wrap - 1             'decrement right margin
	  Action = 2                        'set Action flag to re-display
			'call QEdit to re-display
	  QEdit Array$(), Ky$, Action, Ed

       ELSEIF X$ = CHR$(0) + CHR$(77) THEN  'right arrow key pressed?
	  Ed.Wrap = Ed.Wrap + 1             'increment right margin
	  Action = 2                        'set Action flag to re-display
			'call QEdit to re-display
	  QEdit Array$(), Ky$, Action, Ed
       END IF

    ELSE                                    'word wrap was off
       LOCATE BotRow, 1
       HideCursor
       CALL GPrint0VE(BotRow, 1, SPACE$(80), 0)
       ShowCursor

       INPUT ; "Enter new right margin: "; Ed.Wrap
       Action = 2                           'set Action flag to re-display
       X$ = CHR$(27)                        'set X$ to Escape so we fall
    END IF                                  '  out of the loop below

    LOOP UNTIL X$ = CHR$(13) OR X$ = CHR$(27)   'wait for Enter or Escape

    HideCursor
    CALL GPrint0VE(BotRow, 1, SPACE$(80), 3 * 256)  'Clear bottom line
    CALL GPrint0VE(BotRow, 1, " ESC - Quit    F2 - Change Margin ", 15 + 8 * 256)
    ShowCursor

RETURN

DATA "                     QEdit Instructions"
DATA ""
DATA "All of the standard editing keys are supported.  For example,"
DATA "Home and End move to the beginning and end of the line, the"
DATA "PgUp and PgDn keys scroll the screen by pages, and Ctrl-PgUp"
DATA "and Ctrl-PgDn move to the first and last lines respectively."
DATA "The cursor may also be moved to the top or bottom of the edit"
DATA "window with the Ctrl-Home and Ctrl-End keys."
DATA ""
DATA "Similar to the QuickBASIC editor, QEdit uses the Ctrl-Left"
DATA "and Ctrl-Right arrow keys to move the cursor by words. Ctrl-Y"
DATA "will delete a line of text and Shift-Ins will paste the"
DATA "deleted line at the current cursor row."
DATA ""
DATA "The call for QEdit is fairly simple to set up, as illustrated"
DATA "in the DEMOGQED.BAS demonstration program.  Your program will"
DATA "need to dimension a conventional (not fixed-length) string"
DATA "array to hold the lines of text.  The size to which the"
DATA "string array is dimensioned dictates the maximum number of"
DATA "lines that may be entered."
DATA ""
DATA "If you intend to present a blank screen to your user, then no"
DATA "additional steps are needed to prepare the array.  If you"
DATA "already have text that is to be edited, it may be placed in"
DATA "the array before QEdit is called. The text may also be sent"
DATA "to QEdit as a single long line in the lowest array element."
DATA "In that case, it will be wrapped automatically before being"
DATA "presented for editing."
DATA ""
DATA "If you do pre-load the array with individual lines of text,"
DATA "an extra blank space should be present at the end of each"
DATA "line.  When QEdit wraps words to the next or previous line,"
DATA "the space is needed to prevent the end of one word from"
DATA "running into the beginning of another.  Comments in the"
DATA "QEdit source code show how to insure that every line has at"
DATA "least one trailing space."
DATA ""
DATA "The current cursor location indicates where to position the"
DATA "upper left corner of the editing window.  Five additional"
DATA "parameters are then used to indicate the width and height of"
DATA "the window the right margin, the window color, and edit"
DATA "action.  Let's take a closer look at each of these in turn."
DATA ""
DATA "The width and height parameters (Wide and Rows in the demo)"
DATA "tell QEdit the size of the editing window.  The width can"
DATA "range up to 80 characters. The height may range from 25 lines"
DATA "on a normal EGA monitor or up to 30 lines on a standard VGA"
DATA "monitor. If the WIDTH statement is used to set more screen"
DATA "lines before QEdit is called, then the window may occupy up"
DATA "to 43 or 60 lines respectively. In this case you will have to"
DATA "set GPDat(71) (Text height variable) to 8."
DATA ""
DATA "The right margin (Wrap in the demo) indicates at what column"
DATA "word wrapping is to occur.  This is independent of the"
DATA "rightmost visible column, and may be set to nearly any value."
DATA "If the right margin extends beyond the right edge of the"
DATA "screen, QEdit will scroll the text to accommodate it.  Word"
DATA "wrap may also be disabled entirely by setting Wrap to zero."
DATA ""
DATA "The final parameter is an action flag, which allows you to"
DATA "call QEdit more than once without having to re-display the"
DATA "screen.  Similar to the action flag used by PullDownG and"
DATA "VertMenuG, a value of zero means to enter the editor and wait"
DATA "there until Escape is pressed.  Action set to -2, -1 or 1 start"
DATA "QEdit in polled mode.  These values also indicate to QEdit if"
DATA "and how the underlying screen is to be saved.  Action set to -1"
DATA "saves the underlying screen to conventional memory while Action"
DATA "set to -2 saves it to video memory.  Generally, setting Action"
DATA "to -2 would be preferred since the use of video memory has no"
DATA "effect on the amount of memory available to your program and is"
DATA "otherwise unused.  Action set to -1 is useful in those instances"
DATA "where there is insufficient video memory to hold the underlying"
DATA "screen or when video memory is otherwise being used.  If the"
DATA "amount of memory required is greater than 64k, you will need"
DATA "to start Quick BASIC and compile your program with the /ah"
DATA "switch.  Action set to 1 does not save the underlying screen."

