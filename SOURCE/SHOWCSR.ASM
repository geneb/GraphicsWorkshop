;----- ShowCsr.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - Call ShowCursor

.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

ShowCursor Proc

Include BC7Start.GW

    Cmp  Byte Ptr MouseThere,0
    Je   NoMouse          ;no mouse installed, say goodnight Dick

    Mov  AX,1             ;service 1
    Int 51

NoMouse:
Include BC7End.GW
    Ret
ShowCursor Endp

End
