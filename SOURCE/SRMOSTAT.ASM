;SRMoStat.asm
;
;Copyright (c) 1990 Crescent Software
;written by Jay Munro
;QB4, 4.5 & BASCOM 6 version

.Model Medium,BASIC
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code
;
;MBuffSize
;Function to return size of string needed to save/restore mouse state
;Syntax - DECLARE FUNCTION MBuffSize%()
;         Buffer$ = SPACE$(MBuffSize%)

MBuffSize Proc            ;returns size of string needed for saving state

                          ;now see if the mouse is really installed
    Xor  BX,BX
    Cmp  MouseThere,BL
    Jz   Exit             ;no mouse interrupt installed, so assign all zeros

    Mov  AX,15h           ;get mouse state buffer size
    Int  51

Exit:
    Mov  AX,BX            ;put buffers size into AX for function
    Ret                   ;return to BASIC

MBuffSize Endp


;MGetState
;Subroutine to save mouse state
;Syntax - CALL MGetState(Buffer$)
; (buffer$ must be sized with function above)

MGetState Proc Uses ES SI, StString:Ptr

                          ;now see if the mouse is really installed
    Cmp  Byte Ptr MouseThere,0
    Jz   NoMouse          ;no mouse interrupt installed, so assign all zeros

    Mov  AX,15h           ;get mouse state buffer size
    Int  51

    Mov  SI,StString      ;get string address
    Mov  CX,[SI]          ;get length into CX
    Cmp  CX,BX            ;is the length less than the needed size?
    Jb   NoMouse          ;no the bag out with a -1

    Push DS
    Pop  ES                ;segment of string into ES
    Mov  DX,[SI+2]         ;string address into AX
    Mov  AX,0016h
    Int  51               ;do the deed
    Xor  AX,AX            ;clear for function
    Jmp  Short Exit

NoMouse:
    Mov  AX,-1            ;do this as a function

Exit:
    Ret                   ;return to BASIC

MGetState Endp


;MSetState
;Subroutine to restore a previously saved mouse state
;Syntax - CALL MSetState(Buffer$)
MSetState Proc Uses ES SI, StString:Ptr

                          ;now see if the mouse is really installed
    Cmp  Byte Ptr MouseThere,0
    Jz   NoMouse          ;no mouse interrupt installed, so assign all zeros

    Mov  AX,15h           ;get mouse state buffer size
    Int  51

    Mov  SI,StString      ;get string address
    Mov  CX,[SI]
    Cmp  CX,BX            ;is the length less than the needed size?
    Jb   NoMouse          ;no the bag out with a -1

    Push DS               ;move string segment into ES
    Pop  ES
    Mov  DX,[SI+2]        ;and string address into AX
    Mov  AX,17h           ;save service
    Int  51               ;do the deed
    Xor  AX,AX            ;clear for function
    Jmp  Short Exit

NoMouse:
    Mov  AX,-1            ;do this as a function

Exit:
    Ret                   ;return to BASIC

MSetState EndP

End
