;----- GraphCsr.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - CALL GrafCursor(X%, Y%, Cursor$)
;         X% and Y% define the cursor "hot spot" (0,0 = top left corner)
;         Cursor$ is a 32 character string that defines the cursor shape


.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

GrafCursor PROC X:Ptr, Y:Ptr, Cursor:Ptr

                          ;see if the mouse is really installed
    Cmp  Byte Ptr MouseThere,0
    Jz   NoMouse          ;no mouse interrupt installed, so go away

    Mov  SI,Cursor        ;see if Cursor$ is at least 64 characters long
    Cmp  Word Ptr [SI],64
    Jb   NoMouse          ;oops, it's too short - exit

    Mov  AX,9             ;service 9 sets the graphics cursor
    Push DS               ;set ES to point to string data segment
    Pop  ES
    Mov  DX,[SI+02]       ;point ES:DX to the Cursor$ data
    Mov  SI,Y             ;put the Y hot spot into CX
    Mov  CX,[SI]
    Mov  SI,X             ;put the X hot spot into BX
    Mov  BX,[SI]
    Int  51               ;call the mouse driver

NoMouse:
    Ret                   ;return to BASIC

GrafCursor Endp

End
