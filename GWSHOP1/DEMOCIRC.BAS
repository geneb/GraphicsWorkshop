'DemoCirc.BAS - Demonstrates the CircleVE routine which can be used as a
'               replacement for BASIC's CIRCLE statement.
'
DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo'

CALL SetVideo

CALL GPrint0VE(1, 28, "Draw some random circles", 14)
FOR T = 1 TO 300
    CALL CircleVE(RND * 200 + 320, RND * 100 + 125, RND * 100, RND * 15, 0, 0)
NEXT

CALL GPrint0VE(1, 28, "   Draw some ellipses   ", 14)
B = 32000
WHILE B > 0
   CALL CircleVE(100, 100, 75, 1, B, 0)  'Draw the upper ellipse
   CALL CircleVE(100, 250, 75, 2, 0, B)  'Draw the lower ellipse
   B = B - 1000
WEND

CALL GPrint0VE(25, 28, "Press any key to continue", 14)
WHILE INKEY$ = "": WEND

CLS
CALL GPrint0VE(1, 20, "Draw an ellipse twice as wide as it is high", 12)
Prop% = (GPDat%(49) * 32767& / 2) / 1000
CALL CircleVE(320, 175, 300, 12, 0, Prop%)

CALL GPrint0VE(3, 19, "And a proportionally correct circle inside it", 14)
Prop% = (GPDat%(49) * 32767&) / 1000
CALL CircleVE(320, 175, 100, 14, 0, Prop%)

