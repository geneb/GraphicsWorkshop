'DEMOEDIT.BAS - Demonstration of the Graphics Line Edit routines

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

DECLARE SUB GEditor (Edit$, LeftCol, KeyCode, TxtPos)


'$INCLUDE: 'GetVideo.BAS'

CALL SetVideo

'Draw a box around our edit field which is on row 11 of the screen
Row = 12
CALL LineBVE(150, (Row - 1) * GPDat%(71) - 2, 472, Row * GPDat%(71) + 1, 15)

PAINT (0, 0), "Don"                     'Paint/Tile the rest of the screen

Text$ = SPACE$(40)                      'Pad edit string to allowable length
LSET Text$ = "This is some editable text" 'Make some sample text

GPDat%(74) = 14 + 1 * 256               'Use the highlight bar color to place
					' our editing color in
LeftCol = 20                            'Set left column for editing
LOCATE Row, LeftCol                     'Set the line number for editing

DO
					'Edit the field
   GEditor Text$, LeftCol, KeyCode, TxtPos
					'Do until Enter or Escape pressed
LOOP UNTIL KeyCode = 13 OR KeyCode = 27

