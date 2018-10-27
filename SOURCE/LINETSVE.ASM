;**** LineTSVE.ASM - This program draws a line from the last point drawn to
;                    to the point specified by the Step values given to this
;                    routine.

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineToStepVE (BYVAL StepX%, BYVAL StepY%, BYVAL Colr)
;

.Model Medium, Basic
.Data

Include External.GW

.Code

  EXTRN LineVE:Proc

;This routine does not require any modification for BC7 as it does not modify
;any of the registers (ES, DS, SI, DI).

LineToStepVE PROC StepX:Word, StepY:Word, Colr:Word

     Mov  AX,LastLineX
     Push AX               ;Push the new X1 variable
     Mov  BX,LastLineY
     Push BX               ;Push the new Y1 variable
     Add  AX,StepX         ;Calculate the next X position
     Push AX               ;Push the new X2 variable
     Add  BX,StepY         ;Calculate the next Y position
     Push BX               ;Push the new Y2 variable
     Push Colr
     CALL LineVE

     Ret
LineToStepVE Endp

END
