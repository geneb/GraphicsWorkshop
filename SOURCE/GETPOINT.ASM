;GetPoint.ASM - Gets the color of the pixel specified

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  V = GetPointVE(BYVAL X%, BYVAL Y%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

;GetPointVE returns the color in the AX register as a function expects
;
GetPointVE PROC XPosition:Word, YPosition:Word

Include BC7Start.GW

        MOV  BX,XPosition
        MOV  AX,YPosition

        Mov  CL,BL               ;Store low 8 bits of X position in CL
        Shr  BX,1                ;Divide BX by 8 to get byte position
        Shr  BX,1
        Shr  BX,1
        Mov  DX,EGABytesPerLine  ;Multiply Y value by the bytes per line
        Mul  DX
        Add  BX,AX               ;Add Modified Y position to X Byte position
        Add  BX,FirstEGAOffset   ;Add Starting EGA Offset
        Mov  DI,BX               ;Use the DI register for the screen offset

        MOV  AX,EGAVideoSeg      ;Place EGA segment in ES
        MOV  ES,AX

        And  CL,07h              ;Only keep the low 3 bits
        Mov  CH,128              ;Shift a single bit right CL times to
        Shr  CH,CL               ; get a bit mask for the pixel
        Xor  CL,CL               ;Clear CL

        MOV  DX,03CEh            ;This is the port for the EGA
        Mov  AX,0004h            ;Setup to only access plane 0
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        And  BL,CH               ;Compare with bit mask
        JZ   b1                  ;Was bit set?
        Or   CL,01h              ;Yes, add Blue to the color
b1:
        INC  AH                  ;Setup to only access plane 1
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        And  BL,CH               ;Compare with bit mask
        JZ   b2                  ;Was bit set?
        Or   CL,02h              ;Yes, add Green to the color
b2:
        INC  AH                  ;Setup to only access plane 2
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        And  BL,CH               ;Compare with bit mask
        JZ   b3                  ;Was bit set?
        Or   CL,04h              ;Yes, add Red to the color
b3:
        INC  AH                  ;Setup to only access plane 3
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        And  BL,CH               ;Compare with bit mask
        JZ   b4                  ;Was bit set?
        Or   CL,08h              ;Yes, add high intensity to the color
b4:
        Mov  AL,CL               ;AL holds the return value for the function
        Xor  AH,AH               ;Clear high byte of AX since function returns
                                 ; an integer
Include BC7End.GW
        RET
GetPointVE ENDP

End
