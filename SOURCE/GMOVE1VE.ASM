;**** GMOVE1VE.ASM - Transfer contents of one VGA or EGA screen to another
;                    selectively

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;    CALL GMove1VE (BYVAL XPos, BYVAL YPos, BYVAL Cols, BYVAL Rows, BYVAL DestXPos, BYVAL DestYPos)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

GMove1VE PROC XPos:Word, YPos:Word, Cols:Word, Rows:Word, DestXPos:Word, DestYPos:Word

Include BC7Start.GW

         PUSH DS
         MOV  DX,3CEh         ;Set to the EGA's Write Mode 1
         MOV  AX,0105h
         OUT  DX,AX

         MOV  CX,Rows         ;And rows we are going to move into local memory
         PUSH CX

         MOV  AX,YPos         ;Calculate the beginning offset for the move
         MOV  BX,EGABytesPerLine ;Multiply it by the number of Bytes Per line
         MUL  BX
         ADD  AX,XPos         ;Add the X position to the offset
         DEC  AX
         MOV  SI,AX           ;Store the offset in SI

         MOV  AX,DestYPos     ;Calculate Address for upper left corner of destination
         MUL  BX
         ADD  AX,DestXPos
         DEC  AX
         MOV  DI,AX           ;Store the offset in DI and BX
         MOV  BX,AX

         MOV  AX,EGAVideoSeg  ;Segment of EGA Page 0
         MOV  ES,AX
         MOV  AX,EGAVideoSeg2 ;Segment of EGA Page 1
         MOV  CX,EGABytesPerLine  ;Store a local copy of EGABytesPerLine
         MOV  DS,AX           ;Now have modified our Data Segment
         MOV  AX,CX

         MOV  DX,SI           ;Give DX the value of SI so we can build off it

         POP  CX              ;Restore our Row counter

NextRow: PUSH CX
         MOV  CX,Cols
REP      MOVSB
         ADD  BX,AX           ;Add EGABytesPerLine to change line
         ADD  DX,AX           ;NOTE: We don't have DS pointing to it and value
                              ; is in AX from above
         MOV  DI,BX           ;Put in new values to the pointers
         MOV  SI,DX
         POP  CX
         LOOP NextRow

         MOV  DX,3CEh                ;Reset to the EGA's Write Mode 0
         MOV  AX,0005h
         OUT  DX,AX
         POP  DS

Include BC7End.GW
         RET
GMove1VE ENDP

END
