;----- SetCsr.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - Call SetCursor(X%, Y%)      X% and Y% set the mouse cursor position
;                                     range depends on the current video mode


.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

SetCursor PROC X:Ptr, Y:Ptr

Include BC7Start.GW

    Cmp  Byte Ptr MouseThere,0
    Jz  NoMouse           ;no mouse installed, bye bye

    Mov  AX,4             ;service 4
    Mov  SI,X             ;put the X value into CX
    Mov  CX,[SI]
    Mov  SI,Y             ;put the Y value into DX
    Mov  DX,[SI]
    Int  51

NoMouse:
Include BC7End.GW
    Ret
SetCursor Endp

End
