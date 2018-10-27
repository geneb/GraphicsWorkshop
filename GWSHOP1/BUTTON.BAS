'Button.BAS - routine to draw a 3D button on screen

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

SUB Draw3DButton (X1, Y1, XD, YD, ThirdDimension, Colr) STATIC

   CALL LineBFVE(X1, Y1, X1 + XD, Y1 + YD, Colr)
   FOR T = 1 TO ThirdDimension
       CALL LineVE(X1 - T, Y1 - T, X1 + XD + T, Y1 - T, 15)
       CALL LineVE(X1 - T, Y1 - T, X1 - T, Y1 + YD + T, 15)
       CALL LineVE(X1 - T + 1, Y1 + YD + T, X1 + XD + T, Y1 + YD + T, 8)
       CALL LineVE(X1 + XD + T, Y1 + YD + T, X1 + XD + T, Y1 - T + 1, 8)
   NEXT
   LineBVE X1 - T, Y1 - T, X1 + XD + T, Y1 + YD + T, 0

END SUB

