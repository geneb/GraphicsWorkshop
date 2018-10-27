;**** LinBF2VE.ASM - This program draws a filled box from (x1,y1) to (x2,y2)

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineBF2VE (BYVAL x1, BYVAL y1, BYVAL x2, BYVAL y2, BYVAL Colr)
;

.Model Medium, Basic
.Data

Include External.GW

.Code

Var1 DB ?
Var2 DW ?
Var3 DB ?

LineBF2VE PROC x1:Word, y1:Word, x2:Word, y2:Word, Colr:Word

Include BC7Start.GW

     Push ES

     Mov  DX,x2
     Mov  CX,x1
     Cmp  DX,CX
     Jg   DXIsHigher
     XChg DX,CX
DXIsHigher:
     Sub  DX,CX
     Inc  DX

     Mov  SI,y2     ;Get one of the y values
     Mov  AX,y1     ;Get the other
     Cmp  SI,AX     ;We want the larger of the two in SI, and the other in DI
     Jg   AXIsLower
     XChg SI,AX     ;Need to swap the two variables
AXIsLower:
     Sub  SI,AX     ;SI will now hold the total number of vertical lines that
     Inc  SI        ; the box will encompass on the screen

     Push DX                      ;Store Away the X Pixels
     Push SI                      ;Store Away the number of lines     ;BCG

     Mov  DX,EGABytesPerLine
     IMul DX
     Mov  DI,CX
     Shr  DI,1
     Shr  DI,1
     Shr  DI,1
     Add  DI,AX

     ;DI address on screen, CX xpos

     MOV  DX, 03CEh          ;Initialize the EGA
     MOV  AX, 0005h          ; to readmode 0 and writemode 0
     OUT  DX, AX
     MOV  BX, Colr
     MOV  AH, BL             ;Set the EGA Set\Reset Register to the
     XOR  AL, AL             ; desired color
     OUT  DX, AX
     MOV  AH, BH             ;Set the Data\Rotate  0 = REPLACE w/ no rotate
     MOV  AL, 3
     OUT  DX, AX
     MOV  AX, 0F01h          ;Set the EGA Set\Reset Enable Register to all on
     OUT  DX, AX

     MOV  AL,8
     OUT  DX,AL
     INC  DX             ; Point DX to the second register

     Mov  AX,EGAVideoSeg
     Mov  ES,AX

     And  CX,7
     Mov  AX,8000h
     Shr  AH,CL

     Pop  CX
     Pop  BX

;Next, we are going to repeat drawing a horizontal line, CX times.  The first
;horizontal line is at the value of the BX register
     Push CX        ; their values
     Push DI
     Push AX

     Mov  CX,BX     ;Use the number of pixels

;*********************************************************************
Small9a:
     OR   AL,AH
     ROR  AH,1
     JC   PrepRest9a
     LOOP Small9a
     OUT  DX,AL
     Mov  Var1,AL
     Mov  Var2,CX
     XCHG AL,ES:[DI]
     JMP  Short Exit9a       ;Were Done Early

PrepRest9a:
     OUT  DX,AL
     Mov  Var1,AL
     XCHG AL,ES:[DI]
     DEC  CX
     INC  DI
     Mov  Var2,CX
     Mov  AL,0FFh

     Push CX
     Shr  CX,1
     Shr  CX,1
     Shr  CX,1
     JCXZ PrepEnd9a

     OUT  DX,AL
     Rep  Stosb

PrepEnd9a:
     Pop  CX
     AND  CX,7
     JCXZ Exit9a
     Not  AL
End9a:
     OR   AL,AH
     ROR  AH,1             ;Rotate Bit in AH
     LOOP End9a
     OUT  DX,AL            ; Send the current byte in AL to the screen
     Mov  Var3,AL
     XCHG AL,ES:[DI]          ;This XCHG is faster than two MOV's

Exit9a:
;*************************************************************************

     Pop  AX        ;Get back our pixel orientation
     Pop  DI        ;Get back our starting address for the line
     Add  DI,EGABytesPerLine  ;Move to the next line
     Pop  CX        ;Get back our count of how many lines to draw

     Dec  CX
     JCXZ DoneBF
     Mov  AH,80h
     Mov  BH,0FFh

NextHorzLine:
     Push CX        ; their values
     Push DI
     Push AX

;*********************************************************************
Small9:
     Mov  AL,Var1
     Mov  CX,Var2
     OUT  DX,AL
     XCHG AL,ES:[DI]
     JCXZ Exit9

PrepRest9:
     Mov  AL,BH
     INC  DI

     Push CX
     Shr  CX,1
     Shr  CX,1
     Shr  CX,1
     JCXZ PrepEnd9

     OUT  DX,AL
     Rep  Stosb

PrepEnd9:
     Pop  CX
     AND  CX,7
     JCXZ Exit9
End9:
     Mov  AL,Var3
     OUT  DX,AL            ; Send the current byte in AL to the screen
     XCHG AL,ES:[DI]          ;This XCHG is faster than two MOV's

Exit9:
;*************************************************************************

     Pop  AX        ;Get back our pixel orientation
     Pop  DI        ;Get back our starting address for the line
     Add  DI,EGABytesPerLine ;Move to the next line
     Pop  CX        ;Get back our count of how many lines to draw
     Loop NextHorzLine

DoneBF:
     Mov  DX,03CEh
     Mov  AX,0001h       ;reset EGA register 1
     Out  DX,AX
     Mov  AX,0003h       ;reset EGA register 3
     Out  DX,AX
     Mov  AX,0FF08h      ;reset EGA register 8
     Out  DX,AX

     Pop  ES
Include BC7End.GW
     Ret
LineBF2VE Endp

END
