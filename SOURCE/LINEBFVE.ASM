;**** LineBFVE.ASM - This program draws a filled box from (x1,y1) to (x2,y2)

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineBFVE (BYVAL x1, BYVAL y1, BYVAL x2, BYVAL y2, BYVAL Colr)
;

.Model Medium, Basic
.Data

Include External.GW

.Code

EXTRN LineVE:Proc

;LineBFVE does not require any changes for BC7 as it does not modify any
;of the registers (DS, ES, DI, SI).
LineBFVE PROC x1:Word, y1:Word, x2:Word, y2:Word, Colr:Word

     Mov  CX,y2     ;Get one of the y values
     Mov  BX,y1     ;Get the other
     Cmp  CX,BX     ;We want the larger of the two in CX, and the other in BX
     Jg   BXIsLower
     XChg CX,BX     ;Need to swap the two variables
BXIsLower:
     Sub  CX,BX     ;CX will now hold the total number of vertical lines that
     Inc  CX        ; the box will encompass on the screen

;Next, we are going to repeat drawing a horizontal line, CX times.  The first
;horizontal line is at the value of the BX register
NextHorzLine:
     Push CX        ;Save CX and BX so that the line routine does not destroy
     Push BX        ; their values

     Push X1        ;Pass the parameters for the horizontal line
     Push BX
     Push X2
     Push BX
     Push Colr
     CALL LineVE

     Pop  BX        ;Get back our Y location
     Inc  BX        ;Increment our Y location for the next line
     Pop  CX        ;Get back our count of how many lines to draw
     Loop NextHorzLine

     Ret
LineBFVE Endp

END
