;***** ARAYPCXE.BAS - This routine sends a PCX file which is contained in an
;                     array in memory, and sends it to the EGA/VGA video screen.

;Copyright (c) 1990 Brian C. Giedt

;Syntax:
;
;     CALL PCXArrayVE (BYVAL ArraySeg%, BYVAL Display%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW
Include PCXEXTRN.GW

.Code

PCXArrayVE PROC Array:Ptr, Display:Ptr

Include BC7Start.GW

      PUSH DS
      MOV  PCX_DataSeg,DS
      MOV  AX,Array
      MOV  PCX_ArraySeg,AX
      MOV  ES,AX

      MOV  AX,0800h
      MOV  DX,Display
      MUL  DX
      ADD  AX,EGABaseVideoSeg
      MOV  VideoSeg,AX

      MOV  SI,2                         ;Set the pointer into the header

      MOV  AH,1                         ;Check for Encoding type
      CMP  ES:[SI],AH                   ;Only works with encoding is style 1
      JE   EncodingOK
      JMP  ExitSub

EncodingOK:
      INC  SI
      MOV  AH,ES:[SI]
      MOV  PCX_BitsPerPixel,AH
      INC  SI
      MOV  AX,ES:[SI]
      INC  SI
      INC  SI
      MOV  AX,ES:[SI]
      MOV  PCX_Y,AX                    ;Let PCX_Y start at the YMin position
      INC  SI
      INC  SI
      MOV  AX,ES:[SI]
      MOV  PCX_XMax,AX
      INC  SI
      INC  SI
      MOV  AX,ES:[SI]
      MOV  PCX_YMax,AX

      INC  SI
      INC  SI
      MOV  AX,ES:[SI]
      MOV  PCX_XSize,AX
      INC  SI
      INC  SI          ;14
      MOV  AX,ES:[SI]
      MOV  PCX_YSize,AX

      ADD  SI,51
      MOV  AH,ES:[SI]
      MOV  PCX_NumPlanes,AH
      INC  SI
      MOV  AX,ES:[SI]
      MOV  PCX_BytesPerLine,AX

      Mov  DX,03C4h
      Mov  AX,0F02h
      Out  DX,AX
      Mov  DX,03CEh
      Mov  AX,0001h
      Out  DX,AX
      Mov  AX,0002h
      Out  DX,AX
      Mov  AX,0003h
      Out  DX,AX
      Mov  AX,0005h
      Out  DX,AX
      Mov  AX,0FF08h
      Out  DX,AX
      Mov  AX,0F07h
      Out  DX,AX

      Mov  BX,PCX_XMax
      Sub  BX,PCX_XMin
      Inc  BX
      Mov  PCX_CountBitsSave,BX
      Mov  PCX_CountBits,BX

      Mov  DI,PCX_StartAddress

      XOR  BX,BX
      MOV  PCX_Plane,1
      ADD  SI,62
      MOV  ES,VideoSeg
      MOV  CL,PCX_NumPlanes
      MOV  AH,1
      SHL  AH,CL
      MOV  PCX_HighPlane,AH
      ;Mov  AH,1

      MOV  DX,03C4h        ;Send the instruction to the monitor
      MOV  AX,0102h
      OUT  DX,AX           ;AH already holds the current plane
      MOV  DX,PCX_DataSeg

DoAnother:
      MOV  DS,PCX_ArraySeg
      MOV  AL,[SI]
      CMP  AL,193
      JNB  MultiByte
      Jmp  SingleByte

MultiByte:
      SUB  AL,192
      MOV  CL,AL
      XOR  CH,CH
      INC  SI
      JNZ  SkipFixupSeg1
      MOV  DS,DX
      Add  PCX_ArraySeg,1000h
      Mov  DS,PCX_ArraySeg
SkipFixupSeg1:
      MOV  AL,[SI]
      MOV  DS,DX
SendAnother:
      Cmp  PCX_CountBits,8
      Jge  DoSend1
      Inc  DI
      Cmp  PCX_CountBits,0
      Jle  SkipSend1
      Push CX
      Mov  CX,PCX_CountBits
      Dec  CL
      Mov  CH,128
      Or   CL,CL
      Jz   SkipShift1
MultiShift1:
      STC
      RCR  CH,1
      Dec  CL
      Jne  MultiShift1
;      STC
;      Shr  CH,CL
SkipShift1:
;      And  AL,CH
;      Not  CH
      Dec  DI

      Push DX
      Push AX
      Mov  DX,03CEh
      Mov  AH,CH
      Mov  AL,08h
      Out  DX,AX
      Pop  AX
      XCHG ES:[DI],AL
      Push AX
      Mov  AX,0FF08h
      Out  DX,AX
      Pop  AX
      Pop  DX

      ;And  ES:[DI],CH
      ;Or   ES:[DI],AL
      Inc  DI
      Pop  CX
      Jmp  Short SkipSend1
DoSend1:
      STOSB
      Sub  PCX_CountBits,8
SkipSend1:
      INC  BX
      CMP  BX,PCX_BytesPerLine
      JB   NoOverlap

      CMP  CX,1
      JE   NoOverlap
      SUB  DI,PCX_BytesPerLine
      Mov  BX,PCX_CountBitsSave
      Mov  PCX_CountBits,BX
      XOR  BX,BX
      SHL  AH,1
      CMP  AH,PCX_HighPlane
      JNE  NoLineChange

      MOV  AH,1
      ADD  DI,EGABytesPerLine
      INC  PCX_Y
NoLineChange:
      MOV  DX,03C4h        ;Send the instruction to the monitor
      MOV  AL,02
      OUT  DX,AX           ;AH already holds the current plane
      MOV  DX,PCX_DataSeg
      MOV  DS,PCX_ArraySeg
      MOV  AL,[SI]
      MOV  DS,DX
NoOverlap:
      DEC  CX
      JCXZ NoSendAnotra
      JMP  SendAnother

NoSendAnotra:
      INC  SI
      JNZ  CompareX
      ADD  PCX_ArraySeg,1000h
      JMP  Short CompareX

SingleByte:
      Mov  DS,DX
      Cmp  PCX_CountBits,8
      Jge  DoSend2
      Inc  DI
      Cmp  PCX_CountBits,0
      Jle  SkipSend2
      Push CX
      Mov  CX,PCX_CountBits
      Dec  CL
      Mov  CH,128
      Or   CL,CL
      Jz   SkipShift2
MultiShift2:
      STC
      RCR  CH,1
      Dec  CL
      Jne  MultiShift2
;      STC
;      Shr  CH,CL
SkipShift2:
;      And  AL,CH
;      Not  CH
      Dec  DI
      Push DX
      Push AX
      Mov  DX,03CEh
      Mov  AH,CH
      Mov  AL,08h
      Out  DX,AX
      Pop  AX
      XCHG ES:[DI],AL
      Push AX
      Mov  AX,0FF08h
      Out  DX,AX
      Pop  AX
      Pop  DX
      ;And  ES:[DI],CH
      ;Or   ES:[DI],AL
      Inc  DI
      Pop  CX
      Jmp  Short SkipSend2
DoSend2:
      STOSB
      Sub  PCX_CountBits,8
SkipSend2:
      INC  SI
      MOV  DS,DX
      JNZ  SkipFixupSeg3
      ADD  PCX_ArraySeg,1000h
SkipFixupSeg3:
      INC  BX

CompareX:
      CMP  BX,PCX_BytesPerLine
      JNB  DontDoAnother
      Jmp  DoAnother

DontDoAnother:
      SUB  DI,PCX_BytesPerLine
      Mov  BX,PCX_CountBitsSave
      Mov  PCX_CountBits,BX
      SHL  AH,1
      MOV  DX,03C4h        ;Send the instruction to the monitor
      MOV  AL,02
      OUT  DX,AX           ;AH already holds the current plane
      MOV  DX,PCX_DataSeg
      CMP  AH,PCX_HighPlane
      JNE  DoMore
      MOV  AH,1
      MOV  DX,03C4h        ;Send the instruction to the monitor
      MOV  AL,02
      OUT  DX,AX           ;AH already holds the current plane
      MOV  DX,PCX_DataSeg
      INC  PCX_Y
      ADD  DI,EGABytesPerLine

      MOV  BX,PCX_YMax
      CMP  PCX_Y,BX
      JA   ExitSub
DoMore:
      XOR  BX,BX
      JMP  DoAnother

ExitSub:
      POP  DS
      MOV  PCX_Plane,15
      MOV  AH,PCX_Plane
      MOV  DX,03C4h        ;Send the instruction to the monitor
      MOV  AL,02
      OUT  DX,AX           ;AH already holds the current plane
      MOV  DX,03CEh
      Mov  AX,0001h              ;reset EGA register 1
      Out  DX,AX
      Mov  AX,0003h              ;reset EGA register 3
      Out  DX,AX
      Mov  AX,0FF08h             ;reset EGA register 8
      Out  DX,AX
Include BC7End.GW
      RET

PCXArrayVE EndP

END
