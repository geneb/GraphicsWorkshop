;**** Fade2EGA.ASM - Complex EGA transfer routine

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;  CALL Fade2EGA(BYVAL GridX%, BYVAL GridY%, BYVAL FadeNumber%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

Extrn ClearVE : Proc
Include FADEDAT2.GW

Fade2EGA PROC GridX:Word, GridY:Word, FadeNum:Word

Include BC7Start.GW

      Mov  AX,EGAVideoSeg    ;Set the Segment register to the EGA/VGA segment
      Mov  ES,AX

      Mov  DI,8000h          ;DI = 8000h will point to the second video segment
      Mov  AX,GridX          ;Get the X Grid Point
      Dec  AX                ;Adjust the grid from 1 to 8 downto 0 to 7
      Mov  DL,10             ;Grids are 10 bytes wide
      Mul  DL                ;Multiply to get byte offset
      Add  DI,AX             ;Add it to the screen offset
      Mov  AX,GridY          ;Get the Y Grid Point
      Dec  AX                ;Adjust the grid from 1 to 22 downto 0 to 21
      Mov  DX,8*80           ;Grids are 16 lines high (by 80 bytes wide)
      IMul DX                ;Multiply to get line offset
      Add  DI,AX             ;Add it to the screen offset

      Mov  AX,FadeNum        ;Get Fade Number (value 1 to 5)
      Dec  AX                ;Make it from 0 to 4

      Mov  DX,8*10           ;Random spots are 10 bytes wide by 16 lines down
      IMul DX                ;Get Offset into random data

      Add  AX,Offset Fade1   ;Add to actual Data Offset of the table
      Mov  SI,AX             ;Place it in SI for easier index access

      Mov  DX,03CEh          ;Address of EGA register
      Mov  AX,0005h          ;EGA Read mode 0  Write Mode 0
      Out  DX,AX
      Mov  AX,0003h          ;Replace Data and don't rotate
      Out  DX,AX
      Mov  AL,01h            ;Enable Set/Reset register to 0000
      Out  DX,AX

      Mov  BL,0FFh
      Mov  CX,8              ;Do the 16 lines
AnotherLine:
      Push CX
      Push DI                ;Store DI for easy readjustment of lines
      Mov  CX,10             ;Do 10 bytes accross
AnotherByte:
      Push CX
      Mov  AH,CS:[SI]        ;Get Data to compare with
      Mov  AL,08h            ;Also set the Bit Mask Register
      Out  DX,AX

      Mov  CH,08h
      Mov  CL,04h            ;Going to read each of 4 video planes
AnotherPlane:
      Dec  CL
      Mov  AH,CL
      Mov  AL,04h            ;Set EGA Read Plane
      Out  DX,AX
      Mov  BH,ES:[DI]        ;Get Screen Data from invisible screen

      Mov  AH,CH             ;
      Mov  AL,02h            ;Set EGA Write Plane
      Push DX
      Mov  DX,03C4h          ;Address of EGA register
      Out  DX,AX
      Pop  DX

      Sub  DI,8000h          ;Change Address to visible screen
      Mov  AH,ES:[DI]        ;Load the EGA latch registers
      Mov  ES:[DI],BH        ;Store the new information
      Add  DI,8000h          ;Change Address to second screen
      Shr  CH,1              ;Shift EGA Write Plane value down (divide by 2)
      Cmp  CL,0              ;If did all four planes then were done
      Jne  AnotherPlane      ;Otherwise do another

DoneWithPlane:
      Pop  CX                ;Get back the number of bytes left
      Inc  DI                ;Move to the next byte and the next data value
      Inc  SI
      Loop AnotherByte

      Pop  DI                ;Get Back the begining line offset for this line
      Sub  SI,10             ;Backtrack 20 bytes in Data
      Add  DI,80             ;Move to next video line (at same X position)

      Add  SI,10             ;We moved back 20 bytes above, move forward 20
      Pop  CX                ;Get Back the number of lines left to do
      Loop AnotherLine

Exit: Call ClearVE
Include BC7End.GW
      Ret
Fade2EGA Endp

End
