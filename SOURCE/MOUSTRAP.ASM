;----- MousTrap.Asm

;Copyright (c) 1988 Ethan Winer


;Syntax - CALL MouseTrap(ULRow%, ULCol%, LRRow%, LRCol%)
;
;   where the mouse cursor will be confined to the specified boundaries
;   regardless of the current screen mode


.Model Medium, Basic
.Data

    Extrn MouseThere:Byte ;this byte is in InitMous.Asm

.Code

MouseTrap PROC ULRow:Ptr, ULCol:Ptr, LRRow:Ptr, LRCol:Ptr

Include BC7Start.GW

    Cmp  Word Ptr MouseThere,0
    Je   NoMouse          ;no mouse, bag out now

    Mov  AH,0Fh           ;get the video mode through BIOS
    Push BP
    Int  10h              ;returns mode in AL, page in BH, columns in AH
    Pop  BP

    Cmp  AH,80            ;are we in an 80-column mode?
    Mov  CL,8             ;assume 8 pixels per column
    Je   TrapHoriz        ;we were right
    Shl  CL,1             ;wrong, use 16 pixels each in 40 column mode

TrapHoriz:
    Mov  SI,LRCol         ;get the address for LRCol%
    Mov  AL,[SI]          ;put LRCol% into AL
    Dec  AL               ;adjust 1 down to 0
    Mul  CL               ;multiply times the correct pixels per column
    Mov  DX,AX            ;Mouse needs the right edge parameter in DX

    Mov  SI,ULCol         ;get the address for ULCol%
    Mov  AL,[SI]          ;put ULCol% in AL
    Dec  AL               ;adjust 1 down to 0
    Mul  CL               ;as above
    Mov  CX,AX            ;the left edge goes in CX
    Mov  AX,7             ;call the mouse service that limits the horizontal
    Int  51               ;  travel of the cursor

    Xor  AX,AX            ;look at the monitor type in low memory
    Mov  ES,AX            ;through ES
    Cmp  Byte Ptr ES:[463h],0B4h  ;is it a monochrome screen?
    Mov  BL,8                     ;assume 8 pixels per row in case it is
    Jz   TrapVert                 ;yes, don't bother to check for EGA/VGA

    Mov  AH,12h                   ;ask for EGA info to see if it's EGA or VGA
    Mov  BL,10h
    Push BP
    Int  10h
    Pop  BP
    Cmp  BL,10h                   ;BL will still hold 10h if it's not an EGA
    Mov  BL,8                     ;assume 8 pixels per line
    Jz   TrapVert                 ;not an EGA, we're outa' here with BX = 8

EGA:
    Cmp  Byte Ptr ES:[484h],42    ;this bytes holds the number of screen rows
    Jbe  TrapVert                 ;not in 50-line mode, skip ahead
    Push  BX                      ;for some strange reason DOS trashes this
    Mov  AH,30h                   ;see if we're running under OS/2
    Int  21h                      ;if so, use 7 pixels/character instead of 8
    Pop  BX                       ;get BX back again
    Cmp  AL,10                    ;version 10 is the "DOS compatibility box"
    Jb   TrapVert                 ;we're in regular DOS, skip ahead
    Dec  BL                       ;=> 50 lines uses 7 pixels per row in OS/2

TrapVert:
    Mov  SI,LRRow         ;get the address for LRRow%
    Mov  AL,[SI]          ;put LRRow% into AL
    Dec  AL               ;adjust 1 down to 0
    Mul  BL               ;multiply times the number of pixels in each row
    Mov  DX,AX            ;put the maximum bottom edge in DX for Mouse

    Mov  SI,ULRow         ;get the address for ULRow%
    Mov  AL,[SI]          ;put it into AL
    Dec  AL               ;adjust 1 down to 0
    Mul  BL               ;multiply this one too
    Mov  CX,AX            ;the top edge goes in CX
    Mov  AX,8             ;the service to set the vertical range
    Int  51               ;call the Mouse

NoMouse:
Include BC7End.GW
    Ret                   ;return to BASIC
MouseTrap Endp
End
