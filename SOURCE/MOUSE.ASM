;----- Mouse.Asm - generic mouse service

;Copyright (c) 1988 Ethan Winer


;Syntax - Call Mouse(Service%, BX%, CX%, DX%)
;    Service% is the mouse service number, BX%, CX%, DX% let you communicate
;    directly with the BX, CX, and DX registers (set them before calling,
;    and read them afterwards.)


.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

Mouse PROC Service:Ptr, BXReg:Ptr, CXReg:Ptr, DXReg:Ptr

Include BC7Start.GW

    Xor  AX,AX            ;assume no mouse is installed
    Mov  BX,AX            ;clear all registers in case it's true
    Mov  CX,AX            ;this will assign all output variables to zero later
    Mov  DX,AX
                          ;now see if the mouse is really installed
    Cmp  Byte Ptr MouseThere,0
    Jz   NoMouse          ;no mouse interrupt installed, so assign all zeros

    Mov  AX,DS            ;some mouse services assume ES holds BASIC's DGROUP
    Mov  ES,AX
    Mov  SI,Service       ;put the service number into AX
    Mov  AX,[SI]
    Mov  SI,BXReg         ;and so forth
    Mov  BX,[SI]
    Mov  SI,CXReg
    Mov  CX,[SI]
    Mov  SI,DXReg
    Mov  DX,[SI]
    Int  51

NoMouse:
    Mov  SI,Service       ;reassign variables from the registers
    Mov  [SI],AX
    Mov  SI,BXReg
    Mov  [SI],BX
    Mov  SI,CXReg
    Mov  [SI],CX
    Mov  SI,DXReg
    Mov  [SI],DX

Include BC7End.GW
    Ret                   ;return to BASIC
Mouse Endp
End
