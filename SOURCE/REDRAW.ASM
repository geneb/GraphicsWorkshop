; ReDraw.Asm - Draws a pixel in the specified color at the address specified
;              by the previous call to GetCacheVE%.  You must either call
;              GetCacheVE for the specified address or place the address
;              into variables LastOffset and LastBitPattern

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;     CALL ReDrawVE(BYVAL PointColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

  EXTRN LastPixel : Word
  EXTRN LastLine : Word
  EXTRN LastOffset : Word
  EXTRN LastBitPattern : Byte

.Code

ReDrawVE PROC PointColor:Byte

Include BC7Start.GW

        Mov  AX,LastLine           ;Save the coordinate we are drawing to
        Mov  LastLineY,AX
        Mov  AX,LastPixel
        Mov  LastLineX,AX

        MOV  AX,EGAVideoSeg        ;Place EGA segment in ES
        MOV  ES,AX

        Mov  DI,LastOffset         ;Get last offset used by GetPoint routine

        MOV  DX,03CEh              ;Setup the EGA register
        MOV  AX,0205h              ;Set EGA write mode to 2
        OUT  DX,AX

        Mov  AH,LastBitPattern     ;Get last bit pattern specified by GetPoint
        MOV  AL,08h                ;Send Bit pattern to EGA registers
        OUT  DX,AX
        MOV  AL,ES:[DI]            ;Load EGA latches
        MOV  AL,PointColor         ;Send the color for the bit
        MOV  ES:[DI],AL            ;Send tht bit to the screen

        MOV  AX,0FF08h             ;Reset bit pattern to all bits
        OUT  DX,AX
        MOV  AX,0005h              ;Reset EGA write mode to 0
        OUT  DX,AX

Include BC7End.GW
        RET
ReDrawVE ENDP

End
