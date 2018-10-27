;DrawPoin.Asm - Draws a pixel in the specified color at the specified address

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  CALL DrawPointVE(BYVAL X%, BYVAL Y%, BYVAL PointColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

DrawPointVE PROC XPosition:Word, YPosition:Word, PointColor:Byte

Include BC7Start.GW

        Mov  LastWasGet,0          ;Release Cache for GetPoint routine
        Mov  AX,EGAVideoSeg        ;Store EGA Video Segment in ES
        Mov  ES,AX

        Mov  BX,XPosition          ;Store the X pixel position in BX and
        Mov  LastLineX,BX          ; in the LastLineX variable for LineToVE
        Mov  AX,YPosition          ;Store the Y pixel position in AX and
        Mov  LastLineY,AX          ; in the LastLineY variable for LineToVE

        Mov  DX,EGABytesPerLine    ;Multiply Row position by byte per line
        IMul DX
        Mov  CL,BL                 ;Place low 8 bits of X Postion in CL
        Shr  BX,1                  ;Divide X Postion by 8 to get Byte position
        Shr  BX,1
        Shr  BX,1
        Add  BX,AX                 ;Add X Byte postion to modified Y Position
        Add  BX,FirstEGAOffset     ;Add Beginning EGA Offset to screen offset

        MOV  DX,03CEh              ;Setup EGA port
        MOV  AX,0205h              ;Set EGA write mode 2
        OUT  DX,AX

        And  CL,07h                ;Only keep the low 3 bits
        MOV  AH,128                ;Rotate 1 bit right CL times to form a bit
        Shr  AH,CL                 ; mask
        MOV  AL,08h                ;Send Bit Mask to EGA registers
        OUT  DX,AX
        MOV  AL,ES:[BX]            ;Load EGA latches
        MOV  AL,PointColor         ;Assign the color for the pixel
        MOV  ES:[BX],AL            ;Send Pixel to the screen

        MOV  AX,0FF08h             ;Reset bit mask to all bits
        OUT  DX,AX
        MOV  AX,0005h              ;Reset EGA write mode to 0
        OUT  DX,AX

Include BC7End.GW
        RET
DrawPointVE ENDP

End
