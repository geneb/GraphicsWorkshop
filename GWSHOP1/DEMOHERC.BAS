'DemoHerc.BAS - Demonstrates the ability to draw points, lines, and circles on
'               the Hercules screen mode without requiring the MSHERC.COM TSR

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB CircleBAS (XCenter%, YCenter%, Radius%, Colr%, XAspect%, YAspect%)
DECLARE SUB LineBAS (x1%, y1%, x2%, y2%, Colr%)


'Turn on the Hercules Graphics Mode using the GW screen mode routine
CALL Screen3(0)

'Draw some text on the top of the screen.
CALL GPrint0H(1, 26, "This is the Hercules Screen mode", 1)

'Draw two pixels near each other
CALL DrawPointH(100, 100, 1)
CALL DrawPointH(116, 100, 1)

'Draw a line across the screen
CALL LineBAS(10, 10, 500, 200, 1)

'Draw a circle using the proper aspect ratio
CALL CircleBAS(320, 200, 100, 1, 0, 0)

'Get pixel values off the screen a reprint their values to the screen
CALL GPrint0H(7, 13, MID$(STR$(GetPointH(100, 100)), 2), 1)
CALL GPrint0H(7, 14, MID$(STR$(GetPointH(108, 100)), 2), 1)
CALL GPrint0H(7, 15, MID$(STR$(GetPointH(116, 100)), 2), 1)

CALL GPrint0H(25, 28, " Press any key to continue ", 1 * 256)
WHILE INKEY$ = "": WEND

'Reset the screen back to text mode
CALL Screen0(0)

