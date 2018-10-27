;**** LineBVE.ASM - This program draws a box outline from (x1,y1) to (x2,y2)

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineBVE (BYVAL x1, BYVAL y1, BYVAL x2, BYVAL y2, BYVAL Colr)
;

.Model Medium, Basic
.Code

EXTRN LineVE:Proc

;This routine does not require any modification for BC7 as it does not modify
;any of the registers (ES, DS, SI, DI).

LineBVE PROC x1:Word, y1:Word, x2:Word, y2:Word, Colr:Word

     ;Draw 4 lines to create the box
     Push x1        ;Pass the parameters for the top horizontal line
     Push y1
     Push x2
     Push y1
     Push Colr
     CALL LineVE

     Push x1        ;Pass the parameters for the bottom horizontal line
     Push y2
     Push x2
     Push y2
     Push Colr
     CALL LineVE

     Push x1        ;Pass the parameters for the left vertical line
     Push y1
     Push x1
     Push y2
     Push Colr
     CALL LineVE

     Push x2        ;Pass the parameters for the right vertical line
     Push y1
     Push x2
     Push y2
     Push Colr
     CALL LineVE

     Ret
LineBVE Endp

END
