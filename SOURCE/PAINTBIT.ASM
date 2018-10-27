;PaintBit.ASM - Changes the specified colors in specified bits in a byte

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  CALL PaintBits(X%, Y%, BitPattern%, InColor%, OutColor%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

;PaintByte paints the pixels in the byte locate by an x column value and y row
;
PaintBits PROC XPosition:Word, YPosition:Word, BitPattern:Byte, ColrIn:Byte, ColrOut:Byte

Include BC7Start.GW

        Mov  BX,XPosition
        Dec  BX                  ;Convert BX to a value between 0 and 79
        Mov  AX,YPosition

        Mov  DX,EGABytesPerLine  ;Multiply Y value by the bytes per line
        Mul  DX
        Add  BX,AX               ;Add Modified Y position to X Byte position
        Add  BX,FirstEGAOffset   ;Add Starting EGA Offset
        Mov  DI,BX               ;Use the DI register for the screen offset

        Mov  AX,EGAVideoSeg      ;Place EGA segment in ES
        Mov  ES,AX

        Mov  BL,ColrIn           ;Get the color we want to change

        Mov  BH,BitPattern       ;Get Only the bits we want

        Mov  CX,4                ;We are going to look at the four planes
        Mov  DX,03CEh            ;This is the port for the EGA
        Mov  AH,00h              ;Setup to only access plane 0
NextPlane:
        Mov  AL,04h              ;EGA Port 4h will do this for us
        Out  DX,AX
        Mov  AL,ES:[DI]          ;Get Byte from the screen
        Shr  BL,1                ;Place color bit in the carry flag
        Jc   WasAOne             ;Was the bit a one
        Not  AL                  ;Switch the 0's to 1's
WasAOne:
        And  BH,AL               ;And now keep those that are 1's

        Inc  AH                  ;Setup to access the next plane
        Loop NextPlane           ;Do for each of the 4 planes

        Mov  AX,0205h            ;Reset EGA write mode to 2
        Out  DX,AX

        Mov  AH,BH               ;Place the bit pattern of the pixels to change
        Mov  AL,08h              ; in AH from BH
        Out  DX,AX               ;Now send it to the EGA register
        Mov  AL,ES:[DI]          ;Load the EGA latches
        Mov  AL,ColrOut          ;Set the color of the bits we're changing
        Mov  ES:[DI],AL          ;Send the byte to the screen
AllDone:
        Mov  AX,0FF08h             ;Reset bit pattern to all bits
        Out  DX,AX
        Mov  AX,0005h              ;Reset EGA write mode to 0
        Out  DX,AX

Include BC7End.GW
        RET

PaintBits EndP

         End
