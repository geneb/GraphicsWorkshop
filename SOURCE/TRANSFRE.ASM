;**** TransfrE.ASM - Transfer contents of one EGA screen to another selectively

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;    CALL TransferEGA (XPos, YPos, Cols, Rows)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

HoldCols         DW  0

TransferEGA PROC XPos:Word, YPos:Word, Cols:Word, Rows:Word

Include BC7Start.GW

         PUSH DS
         MOV  DX,3CEh         ;Set to the EGA's Write Mode 1
         MOV  AX,0105h
         OUT  DX,AX

         MOV  AX,Cols         ;Store away the number of Columns
         MOV  CS:HoldCols,AX
         MOV  CX,Rows         ;And rows we are going to move into local memory

         MOV  AX,YPos         ;Calculate the beginning offset for the move
         MOV  BX,EGABytesPerLine ;Multiply it by the number of Bytes Per line
         IMUL BX
         ADD  AX,XPos         ;Add the X position to the offset
         MOV  DI,AX           ;Store the offset in DI, SI, and DX
         MOV  SI,AX
         MOV  DX,AX

         MOV  BX,EGABytesPerLine

         MOV  AX,EGAVideoSeg  ;Segment of EGA Page 0
         MOV  ES,AX
         MOV  AX,EGAVideoSeg2 ;Segment of EGA Page 1
         MOV  DS,AX

NextRow: PUSH CX
         MOV  CX,CS:HoldCols
REP      MOVSB
         ADD  DX,BX
         MOV  DI,DX
         MOV  SI,DX
         POP  CX
         LOOP NextRow

         POP  DS

         MOV  DX,3CEh                ;Reset to the EGA's Write Mode 0
         MOV  AX,0005h
         OUT  DX,AX

Include BC7End.GW
         RET
TransferEGA ENDP

END
