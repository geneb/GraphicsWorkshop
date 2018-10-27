;***** DISPPCXV.BAS - This routine loads a PCX from disk to the VGA 256 color
;                     video screen.  The routine OpenPCXFile must be called
;                     prior to calling this routine.

;Copyright (c) 1990 Brian C. Giedt

;Syntax:
;
;     CALL DispPCXV256 (BYVAL Display%)
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

DispPCXV256 PROC Display:Ptr

Include BC7Start.GW

      Mov  AX,320
      Mov  ScrnBytesPerLine,AX

      MOV  AX,0800h
      MOV  DX,Display
      MUL  DX
      ADD  AX,EGABaseVideoSeg
      MOV  VideoSeg,AX

      Lea  DX,PCX_TheBuffer
      CALL PCX_ReadBlock

      XOR  BX,BX
      MOV  DI,PCX_YMin
      MOV  PCX_Y,DI
      XOR  DI,DI
      Lea  SI,PCX_TheBuffer
      MOV  ES,VideoSeg
;      MOV  DX,DataSeg

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

      ADD  DI,ScrnBytesPerLine
      SUB  DI,PCX_BytesPerLine
      INC  PCX_Y
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

      INC  PCX_Y
      ADD  DI,ScrnBytesPerLine
      SUB  DI,PCX_BytesPerLine
      MOV  BX,PCX_YMax
      CMP  PCX_Y,BX
      JA   ExitSub
DoMore:
      XOR  BX,BX
      JMP  DoAnother

ExitSub:
      MOV  BX,PCX_FileHandle
      Mov  AH,3Eh           ;close file service
      Int  21h              ;do it
Include BC7End.GW
      RET

DispPCXV256 EndP

END
