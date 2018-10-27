;LineVE.ASM - This sub-program draws a line from (x1,y1) to (x2,y2)

;Copyright (c) 1990 Brian Giedt

;Syntax:
;
;  CALL LineVE (BYVAL x1, BYVAL y1, BYVAL x2, BYVAL y2, BYVAL Colr)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

StraightCount  DW   0
DiagCount      DW   0

.Code

MainRoutine    DW   Offset GWMainLoop1
               DW   Offset GWMainLoop3
               DW   Offset GWMainLoop5
               DW   Offset GWMainLoop7
               DW   Offset GWMainLoop9
               DW   Offset GWMainLoop11

LineVE PROC x1:Word, y1:Word, x2:Word, y2:Word, Colr:Word

Include BC7Start.GW

     Mov  AX, EGAVideoSeg    ;Set ES to segment of EGA\VGA display
     Mov  ES, AX

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

     XOR  BX,BX              ;Set BX = 0 (This holds the line direction type)
     Mov  DI, y2             ;Load DI with (y2 - y1)
     Mov  LastLineY,DI       ;Save the y2 variable for use by LineToVE
     Sub  DI, y1
     JE   Across             ;Going to draw a vertical line
     JG   YPositive
     INC  BX                 ;If go through here the line type will be 2
     NEG  DI                 ;Obtain Positive distance
     JMP  Short YPositive
Across:
     MOV  BX, 8              ;Line across so BX should equal 9
     MOV  DX, 9              ;Use DX to determine if type should be 10
YPositive:
     INC  BX                 ;So far, the line type will be 1 or 2

     MOV  CX, x2             ;Load SI with (x2 - x1)
     Mov  LastLineX,CX       ;Save the x2 variable for use by LineToVE
     SUB  CX, x1
     JE   UpDown             ;Going to draw a horizontal line
     JG   XPositive
     ADD  BX,2               ;So far the line type will be 3 or 4
     INC  DX
     NEG  CX                 ;Obtain Positive distance
     JMP  Short XPositive
UpDown:
     ADD  BX,6               ;Up-Down line so BX will be 11 or 12
     CMP  BX,15              ;This will occur when Line is only a pixel
     Jl   XPositive
     SUB  BX,6
XPositive:
     CMP  CX,DI              ;Which distance is greater?
     JGE  SaveValues

     XCHG CX,DI
     ADD  BX,4               ;The Type will be 5, 6, 7, or 8 depending on above

SaveValues:
     Mov  AX,DI
     SHL  AX,1
     Mov  StraightCount, AX
     SUB  AX,CX
     MOV  SI,AX
     SUB  AX,CX
     Mov  DiagCount, AX
     INC  CX

     PUSH CX             ; Number of pixels to plot
     PUSH BX             ; Line Direction Flag
     MOV  CX,x1          ; CX = Starting X Position
     MOV  AX,y1          ; AX = Starting Y Position
     CMP  DX,10          ; Compare if line type = 10
     JNE  GetAddress
     MOV  CX,x2          ; If Type = 10 then switch start to be x2
     POP  BX
     PUSH DX
GetAddress:
     MOV  DX,80
     MUL  DX
     MOV  DI,CX
     SHR  DI,1
     SHR  DI,1
     SHR  DI,1
     ADD  DI,AX

     AND  CX,7
     XOR  CX,107h
     SHL  CH,CL
     MOV  BL,CH
     MOV  BH,CH

     MOV  DX,03CEh       ; Setup the EGA Writing Register
     MOV  AL,8
     OUT  DX,AL
     INC  DX             ; Point DX to the second register

     POP  AX             ; Line Direction Flag in AX
     POP  CX             ; Number of pixels to plot

     Push BP             ; Store away BP for later restore
     PUSH BX             ; Store Away the bit location
     MOV  BX,80          ; Bytes Per Line to ADD

     DEC  AX             ; Set Line Direction Flag to values 0-7
     SHR  AX,1           ; Divide by 2
     JNC  DontNegate
     NEG  BX             ; Effectively makes the ADD's below a SUB
DontNegate:
     SHL  AX,1           ; Multiply by 2 for Word Offset in MainRoutine table
     ADD  AX,Offset MainRoutine
     MOV  BP,AX

     POP  AX             ;Place BX from the routine GetAddress into AX
     CALL CS:[BP]        ;Call the individual line segment section pertaining
                         ; to the direction of the line we're drawing

     POP  BP             ;Restore BP
ExitSub:
     Mov  DX,03CEh
     Mov  AX,0001h       ;reset EGA register 1
     Out  DX,AX
     Mov  AX,0003h       ;reset EGA register 3
     Out  DX,AX
     Mov  AX,0FF08h      ;reset EGA register 8
     Out  DX,AX

Include BC7End.GW
     RET
LineVE ENDP


;*************************************************************
;***** Procedure MainLoop1
;*************************************************************
GWMainloop1 Proc Near

     DEC  CX

SkipPoint1:
;     DEC  CX               ;Decriment Counter on how many pixels to plot
;     JZ   Exit1
     CMP  SI,0             ;If SI is positive then we are
     JGE  DiagLine1        ;going to draw diagonally
PrepNext1a:
     ROR  AH,1             ;Rotate Bit in AH
     JNC  NextLine1a       ;If Rotate goes across byte boundaries then
     OUT  DX,AL            ; Send the current byte in AL to the screen
     XCHG AL,ES:[DI]       ;This XCHG is faster than two MOV's
     XOR  AL,AL            ;Clear the settings in AL
     INC  DI               ;Move our offset to the next byte
NextLine1a:
     ADD  SI, StraightCount ;Add the StraightCount to SI to determine next
                            ; diagonal move
     JGE  PrepDiag1         ;If SI is positive then draw diagonally
     OR   AL,AH             ;Add in the bit in AH into AL
     LOOP PrepNext1a        ;Decriment Counter and continue Straight segment
     OUT  DX,AL
     XCHG AL,ES:[DI]
     JMP  Short Exit1       ;All Done so exit

PrepDiag1:
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP DiagLine1         ;Decriment Counter and goto Diagonal segment
     OUT  DX,AL
     XCHG AL,ES:[DI]
     JMP  Short Exit1       ;All Done so exit

DiagLine1:
     OUT  DX,AL             ;Send bits in AL to Screen
     XCHG AL,ES:[DI]        ;This XCHG will do the work faster than two MOV's
     XOR  AL,AL             ;Clear the bit settings in AL
     ROR  AH,1              ;Rotate Bit to be set in AH
     JNC  NextLine1b        ;If crossed byte boundaries in the above shift then
     INC  DI                ; increment the screen pointer
NextLine1b:
     ADD  DI,BX             ;Since this is a diagonal line change screen pointer
     ADD  SI, DiagCount     ;Add Diagonal Count to SI to determine next action
     JGE  PrepDiag1         ;If SI is positive then we are going to draw diagonally
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP PrepNext1a        ;Decriment Counter and goto Straight segment
;     OUT  DX,AL
;     XCHG AL,ES:[DI]

Exit1:
     RET

GWMainLoop1 ENDP

;*************************************************************
;***** Procedure MainLoop3
;*************************************************************
GWMainloop3 Proc Near

     DEC  CX

SkipPoint3:
;     DEC  CX               ;Decriment Counter on how many pixels to plot
;     JZ   Exit3
     CMP  SI,0             ;If SI is positive then we are
     JGE  DiagLine3        ;going to draw diagonally
PrepNext3a:
     ROL  AH,1             ;Rotate Bit in AH
     JNC  NextLine3a       ;If Rotate goes across byte boundaries then
     OUT  DX,AL            ; Send the current byte in AL to the screen
     XCHG AL,ES:[DI]       ;This XCHG is faster than two MOV's
     XOR  AL,AL            ;Clear the settings in AL
     DEC  DI               ;Move our offset to the next byte
NextLine3a:
     ADD  SI, StraightCount ;Add the StraightCount to SI to determine next
                            ; diagonal move
     JGE  PrepDiag3         ;If SI is positive then draw diagonally
     OR   AL,AH             ;Add in the bit in AH into AL
     LOOP PrepNext3a        ;Decriment Counter and continue Straight segment
     OUT  DX,AL
     XCHG AL,ES:[DI]
     JMP  Short Exit3       ;All Done so exit

PrepDiag3:
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP DiagLine3         ;Decriment Counter and goto Diagonal segment
     OUT  DX,AL
     XCHG AL,ES:[DI]
     JMP  Short Exit3       ;All Done so exit

DiagLine3:
     OUT  DX,AL             ;Send bits in AL to Screen
     XCHG AL,ES:[DI]        ;This XCHG will do the work faster than two MOV's
     XOR  AL,AL             ;Clear the bit settings in AL
     ROL  AH,1              ;Rotate Bit to be set in AH
     JNC  NextLine3b        ;If crossed byte boundaries in the above shift then
     DEC  DI                ; decrement the screen pointer
NextLine3b:
     ADD  DI,BX             ;Since this is a diagonal line change screen pointer
     ADD  SI, DiagCount     ;Add Diagonal Count to SI to determine next action
     JGE  PrepDiag3         ;If SI is positive then we are going to draw diagonally
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP PrepNext3a        ;Decriment Counter and goto Straight segment

Exit3:
     RET

GWMainLoop3 ENDP

;*************************************************************
;***** Procedure MainLoop5
;*************************************************************
GWMainloop5 Proc Near

SkipPoint5:
;     DEC  CX               ;Decriment Counter on how many pixels to plot
;     JZ   Exit5
     CMP  SI,0             ;If SI is positive then we are
     JGE  DiagLine5        ;going to draw diagonally
PrepNext5a:
     OUT  DX,AL            ; Send the current byte in AL to the screen
     XCHG AL,ES:[DI]       ;This XCHG is faster than two MOV's
     XOR  AL,AL            ;Clear the settings in AL
     ADD  DI,BX             ;Move to the next line
     ADD  SI, StraightCount ;Add the StraightCount to SI to determine next
                            ; diagonal move
     JGE  PrepDiag5         ;If SI is positive then draw diagonally
     OR   AL,AH             ;Add in the bit in AH into AL
     LOOP PrepNext5a        ;Decriment Counter and continue Straight segment
     JMP  Short Exit5       ;All Done so exit

PrepDiag5:
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP DiagLine5         ;Decriment Counter and goto Diagonal segment
     JMP  Short Exit5       ;All Done so exit

DiagLine5:
     OUT  DX,AL             ;Send bits in AL to Screen
     XCHG AL,ES:[DI]        ;This XCHG will do the work faster than two MOV's
     XOR  AL,AL             ;Clear the bit settings in AL
     ROR  AH,1              ;Rotate Bit to be set in AH
     JNC  NextLine5b        ;If crossed byte boundaries in the above shift then
     INC  DI                ; increment the screen pointer
NextLine5b:
     ADD  DI,BX             ;Since this is a diagonal line change screen pointer
     ADD  SI, DiagCount     ;Add Diagonal Count to SI to determine next action
     JGE  PrepDiag5         ;If SI is positive then we are going to draw diagonally
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP PrepNext5a        ;Decriment Counter and goto Straight segment

Exit5:
     RET

GWMainLoop5 ENDP

;*************************************************************
;***** Procedure MainLoop7
;*************************************************************
GWMainloop7 Proc Near

SkipPoint7:
;     DEC  CX               ;Decriment Counter on how many pixels to plot
;     JZ   Exit7
     CMP  SI,0             ;If SI is positive then we are
     JGE  DiagLine7        ;going to draw diagonally
PrepNext7a:
     OUT  DX,AL            ; Send the current byte in AL to the screen
     XCHG AL,ES:[DI]       ;This XCHG is faster than two MOV's
     XOR  AL,AL            ;Clear the settings in AL
     ADD  DI,BX             ;Move to next line
     ADD  SI, StraightCount ;Add the StraightCount to SI to determine next
                            ; diagonal move
     JGE  PrepDiag7         ;If SI is positive then draw diagonally
     OR   AL,AH             ;Add in the bit in AH into AL
     LOOP PrepNext7a        ;Decriment Counter and continue Straight segment
     JMP  Short Exit7       ;All Done so exit

PrepDiag7:
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP DiagLine7         ;Decriment Counter and goto Diagonal segment
     JMP  Short Exit7       ;All Done so exit

DiagLine7:
     OUT  DX,AL             ;Send bits in AL to Screen
     XCHG AL,ES:[DI]        ;This XCHG will do the work faster than two MOV's
     XOR  AL,AL             ;Clear the bit settings in AL
     ROL  AH,1              ;Rotate Bit to be set in AH
     JNC  NextLine7b        ;If crossed byte boundaries in the above shift then
     DEC  DI                ; decrement the screen pointer
NextLine7b:
     ADD  DI,BX             ;Since this is a diagonal line change screen pointer
     ADD  SI, DiagCount     ;Add Diagonal Count to SI to determine next action
     JGE  PrepDiag7         ;If SI is positive then we are going to draw diagonally
     OR   AL,AH             ;Add in the bit from AH into AL
     LOOP PrepNext7a        ;Decriment Counter and goto Straight segment

Exit7:
     RET

GWMainLoop7 ENDP

;*************************************************************
;***** Procedure MainLoop9
;*************************************************************
GWMainloop9 Proc Near

;Notes  Don't Need BX or SI

SkipPoint9:
;     DEC  CX               ;Decriment Counter on how many pixels to plot
;     JZ   Exit9
Small9:
     OR   AL,AH
     ROR  AH,1
     JC   PrepRest9
     LOOP Small9
     OUT  DX,AL
     XCHG AL,ES:[DI]
     JMP  Short Exit9       ;Were Done Early

PrepRest9:
     OUT  DX,AL
     XCHG AL,ES:[DI]
     DEC  CX
     INC  DI

     Push CX
     Shr  CX,1
     Shr  CX,1
     Shr  CX,1
     JCXZ PrepEnd9
     MOV  AL,0FFh
     OUT  DX,AL
Loop9:
     XChg AL,ES:[DI]
     Inc  DI
     Loop Loop9

PrepEnd9:
     Pop  CX
     And  CX,7
     JCXZ Exit9
     XOR  AL,AL
End9:
     OR   AL,AH
     ROR  AH,1             ;Rotate Bit in AH
     LOOP End9
     OUT  DX,AL            ; Send the current byte in AL to the screen
     XCHG AL,ES:[DI]       ;This XCHG is faster than two MOV's

Exit9:
     RET

GWMainLoop9 ENDP

;*************************************************************
;***** Procedure MainLoop11
;*************************************************************
GWMainloop11 Proc Near

     OUT  DX,AL             ;Send bit in AL to Screen
DiagLine11:
     XCHG AH,ES:[DI]        ;This XCHG will do the work faster than two MOV's
     ADD  DI,BX             ;Since this is a vertical line change screen pointer
     LOOP DiagLine11        ;Decriment Counter and goto Straight segment

Exit11:
     RET

GWMainLoop11 ENDP

END
