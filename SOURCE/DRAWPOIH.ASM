;DrawPoiH.Asm - Draws a pixel in the specified color at the specified address
;               to the Hercules screen mode

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  CALL DrawPointH(BYVAL X%, BYVAL Y%, BYVAL PointColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

DrawPointH PROC XPosition:Word, YPosition:Word, PointColor:Word

Include BC7Start.GW

        MOV  LastWasGet,0          ;Release Cache for GetPoint routine
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
        Mov  AL,AH
        Not  AL
        Mov  CX,PointColor
        Cmp  CL,0
        Jne  ColorIsWhite
        Xor  AH,AH
ColorIsWhite:

        Mov  CL,ES:[BX]            ;Get information from the screen
        Cmp  CH,0
        Jne  CheckXOROperation
        And  CL,AL                 ;Mask out bits we don't want to change
        Or   CL,AH                 ;Set the bit to the specified color
        Jmp  Short Alldone

CheckXOROperation:
        Cmp  CH,24
        Jne  CheckOROperation
        Xor  CL,AH                 ;Use the XOR operation
        Jmp  Short AllDone

CheckOROperation:
        Cmp  CH,8
        Jne  CheckANDOperation
        Or   CL,AH                 ;Use the OR operation
        Jmp  Short AllDone

CheckANDOperation:
        And  CL,AH                 ;Use the AND operation (no other possibilities)

AllDone:
        Mov  ES:[BX],CL            ;Send Pixel to the screen
Include BC7End.GW
        RET
DrawPointH ENDP

End
