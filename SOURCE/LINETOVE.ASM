;**** LineToVE.ASM - This program draws a line from the last point drawn to
;                    to the point specified by this routine.

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineToVE (BYVAL ToX%, BYVAL ToY%, BYVAL Colr)
;

.Model Medium, Basic
.Data

Include External.GW

.Code

  EXTRN LineVE:Proc

;This routine does not require any modification for BC7 as it does not modify
;any of the registers (ES, DS, SI, DI).

LineToVE PROC ToX:Word, ToY:Word, Colr:Word

     Mov  AX,LastLineX
     Push AX
     Mov  AX,LastLineY
     Push AX
     Push ToX
     Push ToY
     Push Colr
     CALL LineVE

     Ret
LineToVE Endp

END
