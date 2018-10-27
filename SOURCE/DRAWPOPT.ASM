;DrawPOpt.Asm - Draws a pixel in the specified color at the specified address
;               using logical operations.

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  CALL DrawPointVEOpts(BYVAL X%, BYVAL Y%, BYVAL PointColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

DrawPointVEOpts PROC XPosition:Word, YPosition:Word, PointColor:Word

Include BC7Start.GW

        Mov  LastWasGet,0          ;Release Cache for GetPoint routine
        Mov  AX,EGAVideoSeg        ;Store EGA Video Segment in ES
        Mov  ES,AX

        Mov  DX,03CEh
        Mov  AX,PointColor
        Mov  AL,03h     ;Specify the VGA/EGA rotate and logical oper. register
        Out  DX,AX      ;Use the logical operation if specified

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

        Mov  DX,03CEh              ;Setup EGA port
        Mov  AX,0205h              ;Set EGA write mode 2
        Out  DX,AX

        And  CL,07h                ;Only keep the low 3 bits
        Mov  AH,128                ;Rotate 1 bit right CL times to form a bit
        Shr  AH,CL                 ; mask
        Mov  AL,08h                ;Send Bit Mask to EGA registers
        Out  DX,AX
        Mov  AL,ES:[BX]            ;Load EGA latches
        Mov  AL,PointColor         ;Assign the color for the pixel
        Mov  ES:[BX],AL            ;Send Pixel to the screen

        Mov  AX,0FF08h             ;Reset bit mask to all bits
        Out  DX,AX
        Mov  AX,0005h              ;Reset EGA write mode to 0
        Out  DX,AX
        Mov  AX,0003h              ;Reset the rotate and logical operations

Include BC7End.GW
        Ret
DrawPointVEOpts ENDP

End
