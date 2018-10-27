;----- HideCsr.Asm

;Copyright (c) 1988 Ethan Winer


;syntax - CALL HideCursor

.Model Medium, Basic

.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

HideCursor Proc

Include BC7Start.GW

    Cmp  Byte Ptr MouseThere,0
    Jz   NoMouse          ;no mouse interrupt installed, so bag out

    Mov  AX,2             ;service 2
    Int  51               ;call the Mouse driver

NoMouse:
Include BC7End.GW
    Ret                   ;return to BASIC
HideCursor Endp

End
