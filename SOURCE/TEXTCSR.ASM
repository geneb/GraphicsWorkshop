;----- TextCsr.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - CALL TextCursor(FG%, BG%)
;
;  FG% and BG% set the mouse cursor colors
;  -1 for either values means don't change the colors currently on the screen
;  -2 means invert them

.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this is in InitMous.Asm

.Code

TextCursor PROC FG:Ptr, BG:Ptr

Include BC7Start.GW

    Cmp  Byte Ptr MouseThere,0
    Je  NoMouse           ;no mouse is installed, get out o' here pronto

    Mov  AX,10            ;service 10
    Xor  CX,CX            ;clear CX and DX so they can be set by ORing later
    Mov  DX,CX
    Dec  CL               ;set the screen mask to FF, don't disturb character

    Mov  SI,FG            ;get FG%
    Mov  BX,[SI]
    Cmp  BX,-1            ;maintain the foreground as the cursor moves around?
    Jne  TC1              ;no skip ahead
    Or   CH,0Fh           ;set up CH as needed
    Jmp  Short DoBG       ;skip ahead

TC1:
    Cmp  BX,-2            ;invert the foreground as the cursor moves around?
    Jne  TC2
    Or   CH,7
    Or   DH,7
    Jmp  Short DoBG

TC2:
    Or   DH,BL            ;force the foreground to the specified color

DoBG:
    Mov  SI,BG            ;get BG%
    Mov  BX,[SI]
    Cmp  BX,-1            ;maintain the background as the cursor moves around?
    Jne  TC3              ;no skip ahead
    Or   CH,0F0h
    Jmp  Short DoText

TC3:
    Cmp  BX,-2            ;invert the background as the cursor moves around?
    Jne  TC4
    Or   CH,70h
    Or   DH,70h
    Jmp  Short DoText

TC4:
    And  BL,7             ;clear any possibly illegal bits
    Push CX               ;save CX to shift BX to the correct position
    Mov  CL,4
    Shl  BL,CL
    Or   DH,BL            ;force the background to the specified color
    Pop  CX               ;get CX back again

DoText:
    Xor  BX,BX            ;specify the software text cursor (BX = 0)
    Int  51

NoMouse:
Include BC7End.GW
    Ret
TextCursor Endp

End
