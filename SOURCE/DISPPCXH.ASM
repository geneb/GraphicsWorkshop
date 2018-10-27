;***** DISPPCXH.BAS - This routine loads a PCX from disk to the Hercules video
;                     screen.  The routine OpenPCXFile must be called prior to
;                     calling this routine.

;Copyright (c) 1990 Brian C. Giedt

;Syntax:
;
;     CALL DispPCXH (BYVAL Display%)
;
;Note: The routine OpenPCXFile must be called prior to calling this routine, as
;      it defines which file is to be displayed.  The displaying of a PCX file
;      was broken into two parts both to save code space for routines like
;      those in the routine OpenPCXFile which are screen independant.  Also
;      it is beneficial to be able to read the header information, like the
;      routine OpenPCXFile does, and then to display the PCX file to the
;      appropriate screen mode.

.Model Medium, Basic
.Data

Include EXTERNAL.GW
Include PCXEXTRN.GW

.Code

EXTRN PCX_ReadBlock:Proc

DispPCXH PROC Display:Ptr

Include BC7Start.GW

      MOV  AX,0800h
      MOV  DX,Display
      MUL  DX
      ADD  AX,HERCBaseVideoSeg
      MOV  VideoSeg,AX

      Lea  DX,PCX_TheBuffer
      CALL PCX_ReadBlock

      XOR  BX,BX
      MOV  PCX_Y,0
      MOV  DI,0
      Lea  SI,PCX_TheBuffer
      MOV  ES,VideoSeg

DoAnother:
      Cmp  PCX_CountDown,0
      Jg   Continue
      ;Insert file stuff here
      Push DX
      Lea  DX,PCX_TheBuffer
      Mov  SI,DX
      Jl   SkipByteMove
      Mov  AL,PCX_TheBuffer[512]
      Mov  [SI],AL
      Inc  DX
SkipByteMove:
      Neg  PCX_CountDown
      Add  PCX_CountDown,512
      CALL PCX_ReadBlock
      Pop  DX
      Jc   ExitSub
Continue:
      MOV  AL,[SI]
      Dec  PCX_CountDown
      CMP  AL,193
      JB   SingleByte

      SUB  AL,192
      MOV  CL,AL
      XOR  CH,CH
      INC  SI
      MOV  AL,[SI]
      Dec  PCX_CountDown

SendAnother:
      STOSB
      INC  BX
      CMP  BX,PCX_BytesPerLine
      JB   NoOverlap

      CMP  CX,1
      JE   NoOverlap
      XOR  BX,BX
      INC  PCX_Y
      MOV  AX,PCX_Y
      AND  AL,3
      JZ   Interlace

      ADD  DI,8102
      JMP  Short ResetAL
Interlace:
      SUB  DI,3*8192
ResetAL:
      MOV  AL,[SI]
NoOverlap:
      LOOP SendAnother

      INC  SI
      JMP  Short CompareX

SingleByte:
      STOSB                 ;move the byte to video memory
      INC  SI
      INC  BX

CompareX:
      CMP  BX,PCX_BytesPerLine
      JB   DoAnother

      XOR  BX,BX
      INC  PCX_Y
      MOV  AX,PCX_Y
      AND  AL,3
      JZ   DoInterlace

      ADD  DI,8102
      JMP  Short CheckforEnd
DoInterlace:
      SUB  DI,3*8192
CheckforEnd:
      MOV  AX,PCX_YMax
      CMP  PCX_Y,AX
      JA   ExitSub
DoMore:
      JMP  DoAnother

ExitSub:
      MOV  BX,PCX_FileHandle
      Mov  AH,3Eh           ;close file service
      Int  21h              ;do it

Include BC7End.GW
      RET

DispPCXH EndP

END
