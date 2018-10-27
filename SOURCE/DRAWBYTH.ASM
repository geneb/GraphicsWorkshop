;DrawBytH.Asm - Draws up to 8 pixels in the specified color at the specified
;               address to the Hercules screen mode

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  CALL DrawByteH(BYVAL ScreenAddress%, BYVAL BitPattern%, BYVAL ByteColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

DrawByteH PROC ScreenAddress:Word, BitPattern:Byte, ByteColor:Word

Include BC7Start.GW

        MOV  LastWasGet,0          ;Release Cache for GetPoint routine
        MOV  AX,HERCVideoSeg       ;Store Hercules Video Segment in ES
        MOV  ES,AX

        Mov  DI,ScreenAddress

        Mov  AH,BitPattern
        Mov  AL,AH
        Not  AL
        Mov  CX,ByteColor
        Cmp  CL,0
        Jne  ColorIsWhite
        Xor  AH,AH
ColorIsWhite:

        Mov  CL,ES:[DI]            ;Get information from the screen
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
        Mov  ES:[DI],CL            ;Send Pixel to the screen
Include BC7End.GW
        RET
DrawByteH ENDP

End
