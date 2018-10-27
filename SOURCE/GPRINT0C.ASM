;**** GPrint0C.ASM

;Copyright 1990 Brian C. Giedt

;Syntax:
;
;    CALL GPrint0C2 (BYVAL Row, BYVAL Column, Text$, BYVAL Colr)
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

Include CGADATA.GW

GPrint0C2 PROC Row:Ptr, Column:Ptr, TextString:Ptr, Colr:Ptr

Include BC7Start.GW

ifdef bc7
       Push ES
endif

; Monitor Segment
       Mov  AX,CGAVideoSeg             ;Video Segment of the CGA
       Mov  VideoSeg,AX

; Calculate Video Offset
       Mov  AX,Row                     ;Get passed parameter Row into AX
       Dec  AX                         ;Decrement it for graphics offset use
       Mov  YSave,AX
       Mov  BX,Column                  ;Get passed parameter Column into BX
       Dec  BX                         ;Decrement it for graphics offset use
       Mov  CX,BX                      ;Put a duplicate in CX

       Mov  DX,CGABytesPerLine         ;Multiply Row by the # of Bytes per line
       Mul  DX

       Mov  AX,YSave
       Mov  DX,CGABytesPerLine
       Mul  DX
       Shl  AX,1      ;8 lines per character / 2 for graphics interlace
       Shl  AX,1
       Mov  DX,AX
       And  DX,1
       Je   NoInterlace
       Add  AX,8192
NoInterlace:

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
       Sub  BL,1
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

       Xor  DH,DH
       Mov  AX,DX                      ;Put the character in AL
       Mov  DL,8                       ;Number of rows in character
       Mov  CX,DX                      ;Draw 14 rows
       Cmp  AL,32                      ;If it is a control character, use
       Jae  NotControlChar             ;the space character
       Mov  AL,32
NotControlChar:
       Sub  AL,32                      ;Adjust the character to our table
       IMul DX                         ;Multiply by the number of pixel rows

       Mov  SI,Offset CGACharTable     ;Offset of our CGA Character Table
       Add  SI,AX                      ;Add to create the address of character
                                       ; definition for desired character

       Shr  CX,1                       ;Do the loop half the number of times
       Pop  ES                         ;Restore VideoSegment
DrawChar:
       Mov  AH,CS:[SI]                 ;byte at DS:[SI] is part of the char
       Xor  AH,BL                      ;XOR all bits if BL equaled 0 before
       Mov  ES:[DI],AH                 ; foreground color in BL

       Inc  SI                         ;Increment the Character table pointer
       Add  DI,8192                    ;Move the Video Offset to the next line

       Mov  AH,CS:[SI]                 ;byte at DS:[SI] is part of the char
       Xor  AH,BL                      ;XOR all bits with background color
       Mov  ES:[DI],AH                 ;Move bits to the display

       Inc  SI                         ;Increment the character table pointer
       Sub  DI,8112                    ;Move the Video Offset to the next line
       Loop DrawChar                   ;Do the next segment of the character

       Pop  DS                         ;Restore the DATA Segment
       Mov  DI,VideoOffset             ;Increment the VideoOffset from
       Inc  DI                         ; the location where the last character
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

GPrint0C2 ENDP

END
