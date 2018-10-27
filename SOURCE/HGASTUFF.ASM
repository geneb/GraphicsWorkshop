;**** HGAStuff.ASM - Basic Hercules handling routines

;Copyright 1990, Brian C. Giedt

;
;  CALL Screen3(KeepData%)    'Set the Hercules 720x350 2-color mode
;
;  'Get the video address of a specified pixel location
;  Address% = MakeAddressH%(BYVAL X%, BYVAL Y%, BitPattern%)
;

GETLOC  MACRO   REG,LABNAME
        LOCAL   NEXTIP
        CALL    NEXTIP
NEXTIP: POP     REG
        SUB     REG,(OFFSET NEXTIP)-(OFFSET LABNAME)
        ENDM

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

GTable  DB      35H,2DH,2EH,07H,5BH,02H,58H,58H,02H,03H,00H,00H

Screen3 PROC KeepData:Ptr

Include BC7Start.GW

        Mov     DX,3BFH
        Mov     AL,1
        Out     DX,AL
        Mov     DL,0B8H
        Mov     AL,2
        Out     DX,AL
        GETLOC  SI,GTABLE
;        Mov     SI,Offset GTable
        Mov     DI,SI
        Add     DI,12
        Mov     DL,0B4H
        Xor     AL,AL
NXTREG: Out     DX,AL
        Inc     DX
        Push    AX
        Mov     AL,CS:[SI]
        Inc     SI
        Out     DX,AL
        Dec     DX
        Pop     AX
        Inc     AL
        Cmp     SI,DI
        Jne     NXTREG

        Mov     AX,0B000H          ;Clear the Hercules screen
        Mov     ES,AX
        Xor     DI,DI
        Xor     AX,AX
        Mov     CX,32768
Rep     Stosb

        Mov     DL,0B8H
        Mov     AL,10
        Out     DX,AL
        Mov     AL,0FFh            ;Place the screen mode in a local variable
        Mov     GWScrnMode,AL

Include BC7End.GW
        Ret
Screen3 ENDP

MakeAddressH PROC XPosition:Word, YPosition:Word, BitPattern:Ptr

Include BC7Start.GW

        MOV  AX,YPosition
        MOV  CH,AL                 ;Copy the lowest two bits
        And  CH,03h
        Xor  CL,CL                 ;Convert these bits to the Hercules
        Shl  CX,1                  ; Multiply by 512
        Shl  CX,1                  ;    "     "  1024
        Shl  CX,1                  ;    "     "  2048
        Shl  CX,1                  ;    "     "  4096
        Shl  CX,1                  ;    "     "  8192

        Shr  AX,1
        Shr  AX,1

        Mov  DX,HERCBytesPerLine   ;Multiply Row position by byte per line
        IMul DX
        Add  AX,CX

        MOV  BX,XPosition
        Mov  CL,BL                 ;Place low 8 bits of X Postion in CL
        Shr  BX,1                  ;Divide X Postion by 8 to get Byte position
        Shr  BX,1
        Shr  BX,1
        Add  AX,BX                 ;Add X Byte postion to modified Y Position

        Xor  BH,BH
        And  CL,07h                ;Only keep the low 3 bits
        MOV  BL,128                ;Rotate 1 bit right CL times to form a bit
        Shr  BL,CL                 ; mask

        Mov  SI,BitPattern         ;Get the address of our return variable
        Mov  [SI],BX               ;Return the bit pattern

Include BC7End.GW
        RET                        ;AX contains the address
MakeAddressH ENDP

END
