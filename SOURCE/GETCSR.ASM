;----- GetCsr.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - CALL GetCursor(X%, Y%, Button%)
;         Button% returns 1 if button 1 is pressed, 2 if button 2, 3 if both
;         X% and Y% return the mouse cursor position coordinates, which will
;         vary depending on the current video mode

.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

GetCursor PROC X:Ptr, Y:Ptr, Button:Ptr

Include BC7Start.GW

    Xor  BX,BX            ;assume no mouse is installed
    Mov  CX,BX            ;clear all registers in case it's true
    Mov  DX,BX            ;this will assign all output variables to zero later

                          ;now see if the mouse is really installed
    Cmp  Byte Ptr MouseThere,0
    Je   NoMouse          ;no mouse interrupt installed, so assign all zeros

    Mov  AX,3             ;service 3 gets the cursor and buttons
    Int  51               ;call the mouse driver
    And  BX,111b          ;keep only the bits we care about

NoMouse:
    Mov  SI,X             ;assign X% from CX
    Mov  [SI],CX
    Mov  SI,Y             ;assign Y% from DX
    Mov  [SI],DX
    Mov  SI,Button        ;assign Button% from BX
    Mov  [SI],BX

Include BC7End.GW
    Ret                   ;return to BASIC
GetCursor Endp

End
