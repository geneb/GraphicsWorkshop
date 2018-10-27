;**** GPrint06.ASM

;Copyright 1990 Brian C. Giedt

;Syntax:
;
;    CALL GPrint0V256 (BYVAL Row, BYVAL Column, Text$, BYVAL Colr)
;
;    Row, Column  Cooridinates of Character Locations Similar to
;       LOCATE Row, Column
;
;    Text$ any Basic String
;
;    Colr = BackColor * 256 + ForeColor
;

.MODEL MEDIUM, BASIC
.DATA

Include EXTERNAL.GW

.CODE

ifdef bc7
  EXTRN StringInfo:Proc
endif

GPrint0V256 PROC Row:Ptr, Column:Ptr, TextString:Ptr, Colr:Ptr

Include BC7Start.GW

ifdef bc7
       Push ES
endif

; Monitor Segment
       Mov  AX,EGAVideoSeg             ;Video Segment of the EGA
       Mov  VideoSeg,AX

; Calculate Video Offset
       Mov  AX,Row                     ;Get passed parameter Row into AX
       Dec  AX                         ;Decrement it for graphics offset use
       Mov  YSave,AX
       Mov  BX,Column                  ;Get passed parameter Column into BX
       Dec  BX                         ;Decrement it for graphics offset use
       Mov  CX,BX                      ;Put a duplicate in CX
       Shl  CX,1
       Shl  CX,1
       Shl  CX,1

       Mov  AX,YSave
       Mov  DX,V256BytesPerLine
       Mul  DX
       Shl  AX,1      ;8 lines per character
       Shl  AX,1
       Shl  AX,1

       Add  CX,AX                      ;Add Column position to the video offset
       Mov  VideoOffset,CX             ;Store Video Offset away
       Mov  DI,CX                      ;Store Video Offset into DI

; String information
       Mov  SI,TextString              ;Obtain String Length and Offset
ifdef bc7
       Pop  ES                         ;Get the BASIC ES register
       Call StringInfo                 ;Get the string address
       Mov  ES,DX                      ;Place the address into ES:SI
       Mov  SI,AX
else
       Mov  CX,[SI]                    ;Place String Length in CX
       Mov  SI,[SI+2]                  ;Place the address of the string in SI
       Push DS                         ;Make the ES register point to our
       Pop  ES                         ; data segment
endif
       Jcxz NearExit                   ;Exit if Null String
       Mov  DX,CGABytesPerLine         ;Check if string will cross side
       Sub  DX,BX                      ;boundary of the screen
       Mov  BX,0                       ;Assume no, and assume 0 length on
                                       ; next line
       Cmp  CX,DX                      ;Is CX < DX ?
       Jl   ThisIsAll                  ;Yes, so string is small enough
       Mov  BX,CX                      ;No, store total length in BX
       Sub  BX,DX                      ; Subtract Length on this line
       Mov  CX,DX                      ; Print characters til end of line
ThisIsAll:
       Mov  MoreString,BX              ;Store String Length away
       Mov  StringOffset,SI            ;Store Offset away for later use
       Mov  StringSegment,ES           ;Store the segment away as well
       Jmp  NextLine

NearExit:
       Jmp  Exit                 ;Used to allow jump above to be conditional

;****************************************************************************
;
; Below is the main loop for printing the characters that make up the string
;
;****************************************************************************

NextLine:
       Mov  BX,Colr              ;Get Colors for the string
                                 ;store it in BX (BL - foreground,
                                 ;                BH - background)
;       Sub  BL,1
       Mov  SI,StringOffset      ;Restore StringOffset into SI
       Mov  ES,VideoSeg          ;Reload video segment into ES

NextChar:
       Push ES
       Mov  ES,StringSegment
       Mov  DL,ES:[SI]                 ;Get Character from string
       Pop  ES

       Push CX                         ;Store away number of characters
       Push SI                         ;Store away the string offset
       Push DS                         ;Store away the local DATA Segment
       Push ES                         ;Store away the Video Segment

; obtain address of character in bios
       Mov  AX,40h                     ;Ask for information from the video bios
       Mov  ES,AX                      ; about the characters
       Mov  CH,ES:[85h]                ;Get the number of rows from 40h:85h

       Xor  AX,AX                      ;Set ES to the
       Mov  ES,AX                      ; absolute zero segment

       Mov  AL,DL                      ;Set AL to the character
       Cmp  AL,80h
       Jae  After80h

       Lds  SI,ES:[010Ch]              ;Set DS:[SI] to the start of character
                                       ; table
       Jmp  CalAddress

After80h:
       Lds  SI,ES:[1Fh*4]
       Sub  AL,80h
CalAddress:
       Mul  CH                         ;Multiply by the number of pixel rows
       Add  SI,AX                      ;Add to create the address of character
                                       ; definition for desired character

       Mov  CL,CH                      ;Store CH into CX
       Xor  CH,CH
;       Shr  CX,1
       Pop  ES                         ;Restore VideoSegment

DrawChar:
       Xor  AX,AX
       Mov  AL,DS:[SI]                 ;byte at DS:[SI] is part of the char
       Push CX
       Mov  CX,8
DrawBit:
       Shl  AX,1
       Mov  ES:[DI],BH
       Or   AH,AH
       Je   SkipBit
       Mov  ES:[DI],BL                 ; foreground color in BL
SkipBit:
       Inc  DI
       Xor  AH,AH
       Loop DrawBit
       Pop  CX

       Inc  SI                         ;Increment the character table pointer
       Add  DI,320-8                   ;Move the Video Offset to the next line
       Loop DrawChar                   ;Do the next segment of the character

       Pop  DS                         ;Restore the DATA Segment
       Mov  DI,VideoOffset             ;Increment the VideoOffset from
       Add  DI,8                       ; the location where the last character
       Mov  VideoOffset,DI             ; started
       Pop  SI                         ;Restore the StringOffset
       Inc  SI                         ;Set offset to next char. in string
       Pop  CX                         ;Restore the number of chars left
       Loop NextChar                   ;Do another character

       Mov  StringOffset,SI            ;Store the String Offset away
       Mov  CX,MoreString              ;Any more string to print?
       Jcxz Exit                       ;No, so exit
       Mov  AX,CGABytesPerLine         ;Check if more than a lines worth left
       Mov  BX,0                       ;Assume there isn't
       Cmp  CX,AX                      ;Is CX < AX ?
       Jl   ThisIsAll2                 ;There isn't more than a lines worth
       Mov  BX,CX                      ;Store total length in BX
       Sub  BX,AX                      ;Take away one lines worth
       Mov  CX,AX                      ;Store One lines worth into CX
ThisIsAll2:
       Mov  MoreString,BX              ;Store String Length left away
       Mov  DX,14                      ;Multiply the CGABytesPerLine
       Dec  DX                         ; by one less than the
       Mul  DX                         ; number of lines per character
       Add  DI,AX                      ;Set offset to beginning of next line
       Mov  VideoOffset,DI             ;Store the Video Offset away
       Jmp  NextLine                   ;Print the next line

Exit:
Include BC7End.GW
       Ret

GPrint0V256 ENDP

END
