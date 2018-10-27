;***** ARAYPCXH.BAS - This routine sends a PCX file which is contained in an
;                     array in memory, and sends it to the Hercules video
;                     screen.

;Copyright (c) 1990 Brian C. Giedt

;Syntax:
;
;     CALL PCXArrayH (BYVAL ArraySeg%, BYVAL Display%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW
Include PCXEXTRN.GW

.Code

PCXArrayH PROC Array:Ptr, Display:Ptr

Include BC7Start.GW

      PUSH DS
      MOV  PCX_DataSeg,DS
      MOV  AX,Array
      MOV  PCX_ArraySeg,AX
      MOV  ES,AX

      MOV  AX,0800h
      MOV  DX,Display
      MUL  DX
      ADD  AX,HERCBaseVideoSeg
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
      MOV  DI,AX                       ;Let DI start at the XMin position
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

      XOR  BX,BX
      ADD  SI,62
      MOV  ES,VideoSeg
      MOV  DX,PCX_DataSeg

DoAnother:
      MOV  DS,PCX_ArraySeg
      MOV  AL,[SI]
      CMP  AL,193
      JB   SingleByte

      SUB  AL,192
      MOV  CL,AL
      XOR  CH,CH
      INC  SI
      JNZ  SkipFixupSeg1
      MOV  DS,DX
      ADD  PCX_ArraySeg,1000h
SkipFixupSeg1:
      MOV  AL,[SI]
      MOV  DS,DX

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
      MOV  DS,PCX_ArraySeg
      MOV  AL,[SI]
      MOV  DS,DX
NoOverlap:
      LOOP SendAnother

      INC  SI
      JNZ  CompareX
      ADD  PCX_ArraySeg,1000h
      JMP  Short CompareX

SingleByte:
      STOSB                 ;move the byte to video memory
      INC  SI
      MOV  DS,DX
      JNZ  SkipFixupSeg3
      ADD  PCX_ArraySeg,1000h
SkipFixupSeg3:
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
      POP  DS

Include BC7End.GW
      RET

PCXArrayH EndP

END
