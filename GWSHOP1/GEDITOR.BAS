'GEDITOR.BAS - Graphics Line Input routines

DEFINT A-Z
DECLARE SUB DrawCursor (X%, Y%, CursorWidth%, CursorLength%, CursorIs%, CursorTime%)

'$INCLUDE: 'GWDECL.BAS'

'$INCLUDE: 'COMMON.GW'

'****************************************************************************
'          GEDITOR.BAS - graphics mode text input editor
'          by Don Malin
'          Modified for Graphics Workshop by Brian C. Giedt
'          (c) 1990 Crescent Software, Inc.
'
'Purpose:  Allows editing a string in graphics mode with a cursor
'
' Inputs:  Edit$ - The string to be edited.  Must be padded out to the
'                  number of spaces allowed for editing.
'          LeftCol - Character position where editing begins.
'Outputs:  KeyCode - ASCII code of the last character that was typed.
'                    Extended keys will be negative codes.
'          TxtPos - The current editing position within the string.
'****************************************************************************
'
SUB GEditor (Edit$, LeftCol, KeyCode, TxtPos) STATIC

    CursorTiming = 9   'A value of 9 will make the cursor blink once a second
		       'CursorTiming is measured in 1/18ths of a second per blink

    PixelsPerCol = 8                            'Assume 8 pixels horizontaly

    CursorRow = (CSRLIN - 1) * GPDat%(71)       'Find verticle pixel position

    TxtPos = POS(0) - LeftCol + 1               'Get the cursor's location to
    IF TxtPos < 1 THEN TxtPos = 1               '  see where to begin editing
    IF TxtPos > LEN(Edit$) THEN TxtPos = LEN(Edit$)

    GPrint0VE CSRLIN, LeftCol, Edit$, GPDat%(74) 'Print the editing string
    LastPos = 0

    '----- Main loop for handling key presses
    DO
       IF LastPos <> TxtPos THEN
	   GOSUB MoveCursor
	   LastPos = TxtPos
       END IF

       AtCol = LeftCol + TxtPos - 1

       'Blink the cursor
       CALL DrawCursor((AtCol - 1) * 8, CursorRow, 1 - 7 * Inserting, GPDat%(71) - 1, CursorIs, CursorTiming)

       Ky$ = INKEY$

       SELECT CASE LEN(Ky$)                     'Make a key code from Ky$
	  CASE 0
	     KeyCode = 0
	  CASE 1
	     KeyCode = ASC(Ky$)                 'Single character key
	  CASE 2
	     KeyCode = -ASC(RIGHT$(Ky$, 1))     'Extended keys are negative
	  CASE ELSE
       END SELECT

       '----- Branch according to the key pressed
       SELECT CASE KeyCode
	  CASE 0

	  '----- Backspace
	  CASE 8
	     TxtPos = TxtPos - 1                'Back up the text pointer
	     IF TxtPos > 0 THEN                 'Still within the field?
		IF Inserting THEN               'Truncate the string
		   MID$(Edit$, TxtPos) = MID$(Edit$, TxtPos + 1) + " "
		ELSE                            'Blank the letter
		   MID$(Edit$, TxtPos) = " "
		END IF
		GOSUB PrintTheString
	     END IF

	  '----- Enter or Escape
	  CASE 13, 27
	     GOSUB MoveCursor
	     EXIT DO                            'Bail out

	  '----- Letter keys
	  CASE 32 TO 254
	     IF Inserting THEN                  'Expand the text string
		MID$(Edit$, TxtPos) = Ky$ + MID$(Edit$, TxtPos)
	     ELSE
		MID$(Edit$, TxtPos) = Ky$       'Put the new letter in string
	     END IF
	     GOSUB PrintTheString
	     TxtPos = TxtPos + 1                'Increment the text pointer

	  '----- Left arrow
	  CASE -75
	     TxtPos = TxtPos - 1                'Decrement the text pointer

	  '----- Right arrow
	  CASE -77
	     TxtPos = TxtPos + 1                'Increment the text pointer

	  '----- Home
	  CASE -71
	     TxtPos = 1                         'Move text pointer to 1

	  '----- End
	  CASE -79
	     FOR N = LEN(Edit$) TO 1 STEP -1    'Look backwards for non-blank
		IF MID$(Edit$, N, 1) <> " " THEN EXIT FOR
	     NEXT
	     TxtPos = N + 1                     'Set pointer to last char +1
	     IF TxtPos > LEN(Edit$) THEN TxtPos = LEN(Edit$)

	  '----- Insert key
	  CASE -82
	     GOSUB MoveCursor
	     Inserting = NOT Inserting          'Toggle the Inserting flag

	  '----- Delete
	  CASE -83                              'Truncate the text
	     MID$(Edit$, TxtPos) = MID$(Edit$, TxtPos + 1) + " "
	     GOSUB PrintTheString
	     LastPos = 0

	  CASE ELSE                             'All other keys,
	     GOSUB MoveCursor
	     EXIT DO
       END SELECT

    LOOP UNTIL TxtPos < 1 OR TxtPos > LEN(Edit$) 'If cursor is out of field,
						 '  quit editing
    GOSUB MoveCursor

EXIT SUB

MoveCursor:
    IF CursorIs THEN
      CALL DrawCursor((AtCol - 1) * 8, CursorRow, 1 - 7 * Inserting, GPDat%(71) - 1, CursorIs, -1)
    END IF
    RETURN

PrintTheString:
    GOSUB MoveCursor
    GPrint0VE CSRLIN, LeftCol, Edit$, GPDat%(74)
    RETURN

END SUB

