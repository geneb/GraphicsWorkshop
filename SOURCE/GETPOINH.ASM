;GetPoinH.Asm - Gets a pixel at the specified address on the Hercules screen

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  V% = GetPointH%(BYVAL X%, BYVAL Y%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

GetPointH PROC XPosition:Word, YPosition:Word

Include BC7Start.GW

        MOV  AX,HERCVideoSeg       ;Store Hercules Video Segment in ES
        MOV  ES,AX

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
        Add  BX,AX                 ;Add X Byte postion to modified Y Position

        And  CL,07h                ;Only keep the low 3 bits
        MOV  AH,128                ;Rotate 1 bit right CL times to form a bit
        Shr  AH,CL                 ; mask
        Xor  CH,CH
        Mov  CL,ES:[BX]            ;Get information from the screen
        And  CL,AH
        JCXZ AllDone
        Mov  CL,1
AllDone:
        Mov  AX,CX
Include BC7End.GW
        RET
GetPointH ENDP

End
