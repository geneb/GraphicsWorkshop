;ClrChar.ASM - Contains a routine for clearing the ScreenArray which is
;              maintained by the GPrint???? routines when they write letters
;              to the screen.

;Copyright(c) 1991, Brian C. Giedt

;Syntax:
;
;  CALL ClearScreenArray
;

.Model Medium, Basic

EXTRN ScreenArray:Byte

.Data

Include External.GW

.Code

ClearScreenArray PROC

Include BC7Start.GW

      Mov  AX,Seg ScreenArray
      Mov  ES,AX
      Mov  DI,Offset ScreenArray  ;Get the offset of ScreenArray in our CS

      Mov  CX,2000      ;Send 2000 spaces
      Mov  AL,32        ;ASCII 32 is the value for a space

Rep   Stosb             ;Clear the array

Include BC7End.GW
      Ret
ClearScreenArray Endp

End