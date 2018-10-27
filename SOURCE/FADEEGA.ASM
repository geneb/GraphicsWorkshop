;**** FadeEGA.ASM - Complex EGA transfer routine

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;   CALL FadeEGA(BYVAL GridX%, BYVAL GridY%, BYVAL FadeNum%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

Extrn ClearVE : Proc
Include FADEDATA.GW

FadeEGA PROC GridX:Word, GridY:Word, FadeNum:Word

Include BC7Start.GW

      Mov  AX,EGAVideoSeg    ;Set the Segment register to the EGA/VGA segment
      Mov  ES,AX

      Mov  DI,8000h          ;DI = 8000h will point to the second video segment
      Mov  AX,GridX          ;Get the X Grid Point
      Dec  AX                ;Adjust the grid from 1 to 4 downto 0 to 3
      Mov  DL,20             ;Grids are 20 bytes wide
      Mul  DL                ;Multiply to get byte offset
      Add  DI,AX             ;Add it to the screen offset
      Mov  AX,GridY          ;Get the Y Grid Point
      Dec  AX                ;Adjust the grid from 1 to 11 downto 0 to 10
      Mov  DX,32*80          ;Grids are 32 lines high (by 80 bytes)
      Mul  DX                ;Multiply to get line offset
      Add  DI,AX             ;Add it to the screen offset

      Mov  AX,FadeNum        ;Get Fade Number (value 1 to 10)
      Dec  AX                ;Make it from 0 to 9

      Mov  DX,16*20          ;Random spots are 20 bytes wide by 16 lines down
                             ; Lines will be doubled to produce 32 lines down
      Mul  DX                ;Get Offset into random data

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
      Mov  CX,16             ;Do the 16 lines
AnotherLine:
      Push CX
      Mov  CX,2              ;Double each line
DoubleLine:
      Push CX
      Push DI                ;Store DI for easy readjustment of lines
      Mov  CX,20             ;Do 20 bytes accross
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
      Sub  SI,20             ;Backtrack 20 bytes in Data
      Add  DI,80             ;Move to next video line (at same X position)
      Pop  CX                ;Get Back the Doubling value
      Loop DoubleLine        ;Repeat it once more

      Add  SI,20             ;We moved back 20 bytes above, move forward 20
      Pop  CX                ;Get Back the number of lines left to do
      Loop AnotherLine

Exit: Call ClearVE
Include BC7End.GW
      Ret
FadeEGA Endp

End
