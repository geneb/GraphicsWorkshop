;DrawBytO.ASM - Draws a byte worth a data in the specified color
;               Also has the ability to do XOR, OR, and AND operations

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;     CALL DrawByteVEOpts(BYVAL Z%, BYVAL Bits%, BYVAL ByteColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

DrawByteVEOpts PROC ScreenPosition:Word, BitPattern:Byte, ByteColor:Word

Include BC7Start.GW

        Mov  LastWasGet,0          ;Reset Cache reading
        MOV  AX,EGAVideoSeg        ;Place EGA Segment in ES register
        MOV  ES,AX

        MOV  DI,ScreenPosition

        MOV  DX, 03CEh             ;Initialize the EGA
        MOV  AX, 0005h             ; to readmode 0 and writemode 0
        OUT  DX, AX
        MOV  BX, ByteColor
        MOV  AH, BL                ;Set the EGA Set\Reset Register to the
        XOR  AL, AL                ; desired color
        OUT  DX, AX
        MOV  AH, BH                ;Set the Data\Rotate  0 = REPLACE w/ no rotate
        MOV  AL, 3
        OUT  DX, AX
        MOV  AX, 0F01h             ;Set the EGA Set\Reset Enable Register to all on
        OUT  DX, AX

        MOV  AH,BitPattern         ;Send Bit pattern to the EGA register
        MOV  AL,8
        OUT  DX,AX

        XCHG AH,ES:[DI]            ;Send the byte to the screen

        MOV  AX,0FF08h              ;Reset bit pattern to all bits
        OUT  DX,AX

        MOV  AX,0003h              ;Reset the Data\Rotate options
        OUT  DX,AX
        MOV  AL,01h
        OUT  DX,AX

Include BC7End.GW
        RET
DrawByteVEOpts ENDP

End
