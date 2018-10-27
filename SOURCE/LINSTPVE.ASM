;**** LinStpVE.ASM - This program draws a line a specified distance away from
;                    the last point drawn to, to another specified distance
;                    away from the same last point drawn.

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineStepVE (BYVAL StepX1%, BYVAL StepY1%, BYVAL StepX2%, BYVAL StepY2%, BYVAL Colr)
;

.Model Medium, Basic
.Data

Include External.GW

.Code

  EXTRN LineVE:Proc

;This routine does not require any modification for BC7 as it does not modify
;any of the registers (ES, DS, SI, DI).

LineStepVE PROC StepX1:Word, StepY1:Word, StepX2:Word, StepY2:Word, Colr:Word

     Mov  AX,LastLineX     ;Calculate the next X1 position
     Add  AX,StepX1
     Push AX               ;Push the new X1 variable
     Mov  BX,LastLineY     ;Calculate the next Y1 position
     Add  BX,StepY1
     Push BX               ;Push the new Y1 variable
     Mov  AX,LastLineX     ;Calculate the next X2 position
     Add  AX,StepX2
     Push AX               ;Push the new X2 variable
     Mov  BX,LastLineY     ;Calculate the next Y2 position
     Add  BX,StepY2
     Push BX               ;Push the new Y2 variable
     Push Colr
     CALL LineVE

     Ret
LineStepVE Endp

END
