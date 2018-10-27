;Coord.ASM - Routines to Get and Set last drawn coordinate values

;Copyright (c) 1991, Brian C. Giedt

;Syntax:
;
;  X% = GetLastXCoord%
;
;  Y% = GetLastYCoord%
;
;  CALL SetLastCoord(BYVAL X%, BYVAL Y%)
;

.Model Medium, Basic
.Data

Include External.GW

.Code

;These routines do not require any different code for BASIC PDS 7.x

GetLastXCoord Proc

      Mov  AX,LastLineX

      Ret
GetLastXCoord Endp

GetLastYCoord Proc

      Mov  AX,LastLineY

      Ret
GetLastYCoord Endp

SetLastCoord Proc X:Word, Y:Word

      Mov  AX,X           ;Save the X value
      Mov  LastLineX,AX
      Mov  AX,Y           ;Save the Y value
      Mov  LastLineY,AX

      Ret
SetLastCoord Endp

End
