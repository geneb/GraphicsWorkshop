;**** ScrollE.ASM - Scroll contents of one EGA Window

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;   CALL GScrollVE (BYVAL Col1%, BYVAL Line1%, BYVAL Cols%, _
;                     BYVAL Lines%, BYVAL ColDelta%, BYVAL LineDelta%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

HoldCols     DW  0         ;Number of Columns to transfer
HoldLines    DW  0         ;Number of Lines to transfer
StartOffset  DW  0         ;Screen offset of upper-left corner
EndOffset    DW  0         ;Screen offset of lower-right corner
XDelta       DW  0         ;Delta X value for offset calculations
YDelta       DW  0         ;Delta Y value for offset calculations

.Code

GScrollVE PROC Col1:Ptr, Line1:Ptr, Cols:Ptr, Lines:Ptr, ColDelta:Ptr, LineDelta:Ptr

Include BC7Start.GW

         MOV  DX,3CEh                ;Set to the EGA's Write Mode 1
         MOV  AX,0105h
         OUT  DX,AX

         MOV  AX,Cols                ;Load the Columns in near memory
         MOV  HoldCols,AX
         MOV  AX,Lines               ;Load the Rows in near memory
         MOV  HoldLines,AX

         MOV  AX,Line1               ;Calculate the start offset
         MOV  DX,EGABytesPerLine     ;Starting Start Line * (EGABytesPerLine)
         IMUL DX
         ADD  AX,Col1                ;Add the X Column position
         DEC  AX
         MOV  StartOffset,AX         ;Store Start Offset in near memory

         MOV  BX,AX                  ;Store a second copy of the StartOffset
         MOV  AX,Lines               ;Add the Lines * (EGABytesPerLine)
         DEC  AX
         MOV  DX,EGABytesPerLine
         IMUL DX
         ADD  AX,BX
         ADD  AX,Cols                ;Add the Columns
         MOV  EndOffset,AX           ;Store End Offset in local memory

         MOV  AX,EGAVideoSeg         ;Store the video segment in ES
         MOV  ES,AX

         MOV  AX,ColDelta            ;Load the X Column Delta into local memory
         MOV  XDelta,AX
         CMP  AX,0
         JL   Part1Neg
         SUB  HoldCols,AX
         JMP  Short Part1Pos
Part1Neg:
         ADD  HoldCols,AX

Part1Pos:
         MOV  AX,LineDelta           ;Load the Line Delta into local memory
         CMP  AX,0
         JL   Part2Neg
         SUB  HoldLines,AX
         Jmp  Short Part2Pos
Part2Neg:
         ADD  HoldLines,AX
Part2Pos:
         MOV  DX,EGABytesPerLine     ;Multiply it by the bytes per line
         IMUL DX
         MOV  YDelta,AX

         Cmp  YDelta,0
         JL   Type1or2
         JMP  Type3or4

Type1or2:
         MOV  AX,StartOffset         ;Start AX and BX with the Starting Offset
         INC  AX
         MOV  BX,AX
         SUB  AX,YDelta              ;Make AX the "Copy To" Offset
         Cmp  XDelta,0
         JL   Type2

;========================================================
;
Type1:   MOV  DX,HoldCols            ;DX will hold number of columns to transfer
         ADD  AX,DX                  ;
         DEC  AX
         DEC  BX
         ADD  BX,XDelta
         MOV  SI,AX
         ADD  BX,HoldCols
         MOV  DI,BX
         MOV  DX,BX      ;Save DI in DX
         MOV  BX,SI      ;Save SI in BX
         MOV  CX,HoldLines
Loop1:   PUSH CX
         MOV  CX,HoldCols

Loop1a:  MOV  AL,ES:[SI]
         MOV  ES:[DI],AL
         DEC  DI
         DEC  SI
         LOOP Loop1a

         MOV  DI,DX
         ADD  DI,EGABytesPerLine
         MOV  DX,DI
         MOV  SI,BX
         ADD  SI,EGABytesPerLine
         MOV  BX,SI
         POP  CX
         LOOP Loop1

         JMP  AllDone

;========================================================
;
Type2:   SUB  AX,XDelta
         MOV  SI,AX
         MOV  DI,BX
         MOV  DX,BX      ;Save DI in DX
         MOV  BX,SI      ;Save SI in BX
         MOV  CX,HoldLines
Loop2:   PUSH CX
         MOV  CX,HoldCols

Loop2a:  MOV  AL,ES:[SI]
         MOV  ES:[DI],AL
         INC  DI
         INC  SI
         LOOP Loop2a

         MOV  DI,DX
         ADD  DI,EGABytesPerLine
         MOV  DX,DI
         MOV  SI,BX
         ADD  SI,EGABytesPerLine
         MOV  BX,SI
         POP  CX
         LOOP Loop2

         JMP  AllDone

Type3or4:
         MOV  AX,EndOffset
         MOV  BX,AX
         Cmp  XDelta,0
         JL   Type4

;========================================================
;
Type3:   SUB  AX,YDelta
         SUB  AX,XDelta
         MOV  SI,AX
         MOV  DI,BX
         MOV  DX,BX      ;Save DI in DX
         MOV  BX,SI      ;Save SI in BX
         MOV  CX,HoldLines
Loop3:   PUSH CX
         MOV  CX,HoldCols

Loop3a:  MOV  AL,ES:[SI]
         MOV  ES:[DI],AL
         DEC  DI
         DEC  SI
         LOOP Loop3a

         MOV  DI,DX
         SUB  DI,EGABytesPerLine
         MOV  DX,DI
         MOV  SI,BX
         SUB  SI,EGABytesPerLine
         MOV  BX,SI
         POP  CX
         LOOP Loop3

         JMP  AllDone

;========================================================
;
Type4:   SUB  AX,HoldCols
         INC  AX
         ADD  AX,XDelta
         MOV  BX,AX
         SUB  AX,YDelta
         SUB  AX,XDelta
         MOV  SI,AX
         MOV  DI,BX
         MOV  DX,BX      ;Save DI in DX
         MOV  AX,SI      ;Save SI in BX
         MOV  BX,AX
         MOV  CX,HoldLines
Loop4:   PUSH CX
         MOV  CX,HoldCols

Loop4a:  MOV  AL,ES:[SI]
         MOV  ES:[DI],AL
         INC  DI
         INC  SI
         LOOP Loop4a

         MOV  DI,DX
         SUB  DI,EGABytesPerLine
         MOV  DX,DI
         MOV  SI,BX
         SUB  SI,EGABytesPerLine
         MOV  BX,SI
         POP  CX
         LOOP Loop4

         JMP  AllDone


AllDone: MOV  DX,3CEh                ;Reset to the EGA's Write Mode 0
         MOV  AX,0005h
         OUT  DX,AX

Include BC7End.GW
         RET
GScrollVE ENDP

END
