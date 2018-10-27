;DrawByte.ASM - Draws a byte worth a data in the specified color

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;     CALL DrawByteVE(BYVAL Z%, BYVAL Bits%, BYVAL ByteColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

DrawByteVE PROC ScreenPosition:Word, BitPattern:Byte, ByteColor:Byte

Include BC7Start.GW

        Mov  LastWasGet,0           ;Reset Cache reading
        MOV  AX,EGAVideoSeg         ;Place EGA Segment in ES register
        MOV  ES,AX

        MOV  DI,ScreenPosition

        MOV  DX,03CEh               ;Setup register for EGA
        MOV  AX,0205h               ;Set EGA write mode to 2
        OUT  DX,AX

        MOV  AH,BitPattern          ;Send Bit pattern to the EGA register
        MOV  AL,08h
        OUT  DX,AX
        MOV  AL,ES:[DI]             ;Load EGA latches
        MOV  AL,ByteColor           ;Set the color
        Stosb                       ;Send the byte to the screen

        MOV  AX,0FF08h              ;Reset bit pattern to all bits
        OUT  DX,AX

        MOV  AX,0001h
        OUT  DX,AX
        MOV  AL,05h                 ;Reset EGA write mode to 0
        OUT  DX,AX

Include BC7End.GW
        RET
DrawByteVE ENDP

End
