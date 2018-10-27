;GetCache.ASM - Gets the color of the pixel specified (uses a simple Cache)

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  V = GetCacheVE%(BYVAL X%, BYVAL Y%)
;
;    This routine uses a simple cache system that avoids multiply's and
;  accessing the actual EGA planes when reading a point in the same screen
;  byte as the last execution of the GetPoint function
;
;  CALL ResetCache

.Model Medium, Basic
.Data

Include EXTERNAL.GW

Public LastPixel, LastLine, LastOffset, LastBitPattern

LastPixel         DW  0
LastLine          DW  0
LastOffset        DW  0
LastBitPattern    DB  0

.Code

LastColumn        DW  0
LastData0         DB  0
LastData1         DB  0
LastData2         DB  0
LastData3         DB  0

;GetCacheVE returns the color in the AX register as a function expects
;
GetCacheVE PROC XPosition:Word, YPosition:Word

Include BC7Start.GW

        MOV  BX,XPosition
        MOV  AX,YPosition

        Mov  LastPixel,BX        ;Save the X coordinate value for ReDrawVE

        Cmp  LastWasGet,0        ;Have we even done this once since last write?
        JZ   DoFromScratch       ;No, do it from scratch
        Cmp  LastLine,AX         ;Are we on the same row as before?
        JNE  DoFromScratch       ;No, do it from scratch
        Mov  CL,BL               ;Store low 8 bits in CL
        Shr  BX,1                ;Divide X poition by 8 to get byte position
        Shr  BX,1
        Shr  BX,1
        Cmp  LastColumn,BX       ;Are we on the same byte column as before?
        JNE  DoFromScratch2      ;No, do it from scratch bypassing setup of CL
                                 ; and BX as above

        And  CL,07h              ;Only keep the low 3 bits
        Mov  CH,128              ;Shift a single bit CL times to the right
        Shr  CH,CL               ; to acheive a bit mask for the pixel
        Xor  AX,AX               ;Clear AX

        Mov  CL,LastData0        ;Get screen byte for plane 0 from the cache
        And  CL,CH               ;Compare with bit mask
        JZ   GetSavedPlane1      ;Was Bit set?
        Or   AL,01h              ;Yes, add blue to the color
GetSavedPlane1:
        Mov  CL,LastData1        ;Get screen byte for plane 1 from the cache
        And  CL,CH               ;Compare with bit mask
        JZ   GetSavedPlane2      ;Was bit set?
        Or   AL,02h              ;Yes, add green to the color
GetSavedPlane2:
        Mov  CL,LastData2        ;Get screen byte for plane 2 from the cache
        And  CL,CH               ;Compare with bit mask
        JZ   GetSavedPlane3      ;Was bit set?
        Or   AL,04h              ;Yes, add red to the color
GetSavedPlane3:
        Mov  CL,LastData3        ;Get screen byte for plane 3 from the cache
        And  CL,CH               ;Compare with bit mask
        JZ   LocalAllDone        ;Was bit set?
        Or   AL,08h              ;Yes, add high intensity to the color
LocalAllDone:
        Jmp  AllDone             ;Were all done, AL holds the color

DoFromScratch:
        Mov  CL,BL               ;Store low 8 bits of X position in CL
        Shr  BX,1                ;Divide BX by 8 to get byte position
        Shr  BX,1
        Shr  BX,1
DoFromScratch2:
        Mov  LastLine,AX         ;Store Y Position in the Cache descriptor
        Mov  DX,EGABytesPerLine  ;Multiply Y value by the bytes per line
        Mul  DX
        Mov  LastColumn,BX       ;Store X Byte Position in the Cache descriptor
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
        Mov  LastData0,BL        ;Store Byte in Cache for later
        And  BL,CH               ;Compare with bit mask
        JZ   GetPlane1           ;Was bit set?
        Or   CL,01h              ;Yes, add Blue to the color
GetPlane1:
        INC  AH                  ;Setup to only access plane 1
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        Mov  LastData1,BL        ;Store Byte in Cache for later
        And  BL,CH               ;Compare with bit mask
        JZ   GetPlane2           ;Was bit set?
        Or   CL,02h              ;Yes, add Green to the color
GetPlane2:
        INC  AH                  ;Setup to only access plane 2
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        Mov  LastData2,BL        ;Store Byte in Cache for later
        And  BL,CH               ;Compare with bit mask
        JZ   GetPlane3           ;Was bit set?
        Or   CL,04h              ;Yes, add Red to the color
GetPlane3:
        INC  AH                  ;Setup to only access plane 3
        OUT  DX,AX
        MOV  BL,ES:[DI]          ;Get Byte from the screen
        Mov  LastData3,BL        ;Store Byte in Cache for later
        And  BL,CH               ;Compare with bit mask
        JZ   GotLastPlane        ;Was bit set?
        Or   CL,08h              ;Yes, add high intensity to the color
GotLastPlane:
        Mov  LastOffset,DI       ;Place last screen offset in DI for redraw
        Mov  LastWasGet,-1       ;Set flag to say Cache exists
        Mov  AL,CL               ;AL holds the return value for the function

AllDone:
        Xor  AH,AH               ;Clear high byte of AX since function returns
                                 ; an integer
        Mov  LastBitPattern,CH   ;Store last bit pattern for redraw

Include BC7End.GW
        Ret
GetCacheVE ENDP


ResetCache PROC

     MOV  LastWasGet,0
     RET

ResetCache ENDP

End
