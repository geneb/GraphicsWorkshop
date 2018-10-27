;----- Motion.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - Call Motion(Value%)     ;Value range: 0-255, 0 is most sensitive

.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

Motion PROC Value:Ptr

Include BC7Start.GW

    Cmp  MouseThere,0
    Je   NoMouse

    Mov  AX,15       ;service 15
    Mov  SI,Value
    Mov  CX,[SI]     ;set the horizontal sensitivity to Value%
    Mov  DX,[SI]     ;do the same for the vertical sensitivity
    Int  51

NoMouse:
Include BC7End.GW
    Ret
Motion Endp
End
