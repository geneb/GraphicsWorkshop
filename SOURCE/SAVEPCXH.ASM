;***** SavePCXH.BAS - This file demostrates saving a file using the .PCX
;                     file format used in PC Paintbrush for Hercules screens

;Copyright (c), 1990 Brian C. Giedt

.Model Medium, Basic
.Data

Include EXTERNAL.GW
Include PCXEXTRN.GW

.Code

ifdef bc7
  EXTRN StringInfo:Proc
endif

SavePCXH PROC Filename:Ptr

Include BC7Start.GW

    Cld                          ;Make sure all moves are in the forward direction
    Mov  PCX_AllDone,0           ;Set a flag to say we are not done yet

    Mov  PCX_XMax,719            ;graphics screen mode
    Mov  PCX_YMax,349            ;Set up the header information for a Hercules
    Mov  PCX_BitsPerPixel,1

    Mov  SI,Filename             ;Get the filename
    Push DS                      ;Make the ES register point to our
    Pop  ES                      ; data segment

ifdef bc7
    Call StringInfo              ;Get the string address
    Mov  DS,DX                   ;Place the address into DS:SI
    Mov  SI,AX
else
    Mov  CX,[SI]                 ;Place String Length in CX
    Mov  SI,[SI+2]               ;Place the address of the string in SI
endif

    Lea  DI,PCX_LocalFilename    ;Address of local storage
    Mov  DX,DI                   ;BIOS will need this in DX later
Rep Movsb                        ;Move the filename to local storage
    Push ES                      ;Return our data segment to its original value
    Pop  DS
    Mov  byte ptr [DI],0         ;Append an ASCII NULL for DOS's sake

    Mov  AH,3Ch                  ;Function 3C of Int 21h will create the file
    Xor  CX,CX                   ;Create a Normal File (i.e. not hidden,...)
    Int  21h                     ;Let BIOS do the work
    Jnc  OpenWasOk               ;The Carry flag would tell us of a problem
    Jmp  HadAProblem             ;Carry was set, a problem, so stop.
OpenWasOk:
    Mov  PCX_FileHandle,AX       ;We'll need the file handle for later Int's

    Lea  DI,PCX_TheBuffer        ;Address of our internal buffer
    Mov  PCX_BeginBuff,DI        ;Store it away for later arithmetic use
    Mov  Byte Ptr [DI],10        ;Mimick that we are ZSoft as the publisher
    Inc  DI
    Mov  Byte Ptr [DI],3         ;Version 3 of the .PCX format
    Inc  DI
    Mov  Byte Ptr [DI],1         ;Specify Run Length Encoding
    INC  DI
    Mov  Byte Ptr [DI],1         ;Hercules has only one bit per pixel
    INC  DI

    ;Take the information we know about the size of the display and put it into
    ;the header now
    Mov  AX,PCX_XMin
    Mov  [DI],AX
    INC  DI
    INC  DI
    Mov  AX,PCX_YMin
    Mov  [DI],AX
    INC  DI
    INC  DI

    Mov  AX,PCX_XMax
    Mov  [DI],AX
    INC  DI
    INC  DI
    Mov  AX,PCX_YMax
    Mov  [DI],AX
    INC  DI
    INC  DI

    ;Now since all these saves are full screen, use the width of the screen
    ;to show the width of the image, and do the same for the height.  Place
    ;these values into the header now.
    Mov  AX,PCX_XMax
    INC  AX
    Mov  [DI],AX
    INC  DI
    INC  DI
    Mov  AX,PCX_YMax
    INC  AX
    Mov  [DI],AX
    INC  DI
    INC  DI

    ;The palette information comes next.
    ;For Hercules we will simply allow the palette to remain blank.
    Mov  CX,48
    Xor  AL,AL
Rep stosb

    Mov  Byte Ptr [DI],0         ;This byte is unused in the format (Reserved)
    INC  DI
    Mov  Byte Ptr [DI],1         ;The Hercules has 1 color plane
    INC  DI

    ;Next calculate the number of bytes per scan line in the image.  For the
    ;Hercules this is going to be 90 bytes, but for completeness, it will be
    ;calculated.
    Mov  AX,PCX_XMax
    Inc  AX
    Shr  AX,1
    Shr  AX,1
    Shr  AX,1
    Mov  CL,PCX_BitsPerPixel
    Dec  CL
    Shl  AX,CL
    PUSH AX                  ;save the number of bytes per line on the stack
    Mov  [DI],AX
    INC  DI
    INC  DI

    ;The remaining 60 bytes of the header are to be left blank (ASCII NULL's)
    Mov  AL,0
    Mov  CX,60
Rep Stosb

    Mov  BX,PCX_FileHandle   ;Get our DOS File handle
    Mov  AH,40h              ;Request a write to a file
    Mov  CX,128              ;The size will be 128 bytes (size of the header)
    Mov  DX,PCX_BeginBuff    ;It will start at the Beginning of the buffer
    Int  21h                 ;Let BIOS do all the rest
    Jnc  OkFirstSend         ;Check if no error occured
    Jmp  HadAProblem         ;Carry bit set, so there was an error

OkFirstSend:
    Mov  DI,PCX_BeginBuff    ;Move the Destination Index to the buffer
    Mov  AX,PCX_YMin         ;Let local variable PCX_Y hold the line number
    Mov  PCX_Y,AX            ; we're currently on

    POP  BX                  ;BX now holds the number of bytes per scan line
    Mov  PCX_BytesPerLine,BX ;So does local variable PCX_BytesPerLine

    Mov  DX,HercBytesPerLine ;Calculate the starting address
    Mul  DX
    Add  AX,PCX_XMin
    Push AX                  ;Store that away for later

    MOV  AX,HercVideoSeg     ;Get the Hercules video segment
    MOV  ES,AX

    Pop  BX                  ;Get our screen address
    MOV  AL,ES:[BX]          ;Get the first byte from the screen
    INC  BX                  ;Point to next address
    MOV  AH,AL               ;Return the byte in the parameter AL

    Mov  CL,1                ;Set the count to 1 time this byte has appeared
    Mov  PCX_ByteAtOnLine,1  ;This will hold the number of bytes looked at

;***************************************************************
;                 END OF INITIALIZATION CODE
;***************************************************************

DO1:      ;until we're all done
DO2:      ;until we've got a 512 byte buffer filled or we're all done

;get a byte
    Mov  AL,ES:[BX]          ;AL will hold its value
    INC  BX                  ;Update Address pointer

;check if byte can be compressed some more
    Cmp  AL,AH               ;AH holds the last byte value.  Are they the same?
    Jne  Diff1               ;If there different then store the last run
    Cmp  CL,62               ;How many times has it been the same so far?
    Jg   Diff1               ;If this is the 63 time, then store the last run
    Inc  CL                  ;Otherwise just increment it one time and
    Jmp  Short Done1         ;Go do some calculations for end of line
Diff1:
    Dec  CL                  ;Reduce the count by one to check for a single byte
    Je   CheckLarge1         ;If a single byte then go below to store it
    Add  CL,193              ;Add 192 to the count plus 1 more because we did
                             ; a DEC two lines above
    Mov  [DI],CL             ;Put the count into the buffer
    Inc  DI                  ;Increment our pointer into our file buffer
    Jmp  Short Rest1         ;Do the rest below
CheckLarge1:
    Cmp  AH,192              ;Was the single byte >= 192?
    Jb   Rest1               ;If no then only store the byte.
    Mov  Byte Ptr [DI],193   ;If so, too bad.  (This will add size to the file)
    Inc  DI                  ; but even compression scheme has its flaw
Rest1:
    Mov  [DI],AH             ;Now take the actual raw data and place it into
    Inc  DI                  ; the file buffer
    Mov  AH,AL               ;Make the current byte seen, the last byte seen
    Mov  CL,1                ;And reset the count to 1 time

Done1:
    Inc  PCX_ByteAtOnLine    ;Increment the number of bytes looked at
    Mov  DX,PCX_ByteAtOnLine ;DX is used as temporary storage
    Cmp  DX,PCX_BytesPerLine ;Compare it with the number of bytes to save/line
    Jl   NotEndOfLine

    Dec  CL                  ;If it is the end of the line, then store the run
    Je   CheckLarge2         ;If only one byte seen, then go below
    Add  CL,193              ;Add 192 plus 1 for the DEC we did above to the count
    Mov  [DI],CL             ;Store the count in the buffer
    Inc  DI
    Jmp  Short Rest2
CheckLarge2:
    Cmp  AH,192              ;If the data is less than 192 then go below
    Jb   Rest2
    Mov  Byte Ptr [DI],193   ;Otherwise store a run of 1 byte and get the
    INC  DI                  ; data below
Rest2:
    Mov  [DI],AH             ;Place the actual data in the file buffer
    INC  DI

    Xor  DX,DX               ;Restore the count on the current line to 0

    Cmp  BX,24576            ;If our screen offset is in one of the first three
    Jge  FirstInter          ;interlaces, then we don't want to add 90 bytes
    Sub  BX,HercBytesPerLine ;take back the 90 bytes added during the save
FirstInter:
    Add  BX,8192             ;Change the interlace by adding 8192
    And  BX,32767            ;If we are at the last interlace this will bring
                             ; us back to the first interlace

    Inc  PCX_Y               ;Increment the linenumber
    Mov  AX,PCX_Y            ;Compare the line number with the lines in the image
    Cmp  AX,PCX_YMax
    Jle  SkipIt              ;If its less or equal, we're not done yet
    Dec  PCX_AllDone         ;Specifies that we are done

SkipIt:
    Mov  AH,ES:[BX]          ;Get the first byte on this line
    INC  BX                  ;Update our address pointer
    Mov  CL,1                ;We've seen this value once
    Mov  PCX_ByteAtOnLine,1  ;We've looked at one byte on this line

NotEndOfLine:
    Mov  DX,DI               ;Check if we have written 512 bytes yet
    Sub  DX,PCX_BeginBuff
    Cmp  DX,512
    Jge  SendBytes2          ;If we've done 512 bytes or more, then send 512
    Cmp  PCX_AllDone,-1      ;If we're all done, then send what we've got.
    Je   SendBytes3
    Jmp  DO2                 ;Otherwise continue to add to the buffer

SendBytes3:
    Push CX                  ;Save CX, we'll need it back
    Mov  CX,DX               ;We want to send as many bytes as are left
    Jmp  Short SendBytes4
SendBytes2:
    Push CX                  ;Save CX, we'll need it back
    Mov  CX,512              ;We want to send 512 bytes.
SendBytes4:
    Push AX                  ;Save these registers also, cause BIOS will destroy them
    Push DX
    Push BX
    Mov  BX,PCX_FileHandle   ;Use the file handle to address the file
    Mov  AH,40h              ;Request a write service
    Mov  DX,PCX_BeginBuff    ;DS:DX points to our buffer
    Int  21h                 ;Let BIOS do the work
    Pop  BX                  ;Get back all of our registers
    Pop  DX
    Pop  AX
    Jc   HadAProblem         ;If there was a problem, then stop

    Mov  CX,DX
    Sub  CX,512
    Jle  Done2               ;If we had only 512 bytes to send then were done

    Push DI                  ;Save our pointer
    Mov  SI,DI
    Sub  DI,512
DoAgain:                     ;We're going to move data from the top of our
    Dec  SI                  ; buffer to the bottom.
    Dec  DI
    Mov  AL,[SI]
    Mov  [DI],AL
    Loop DoAgain
    POP  DI

Done2:
    Pop  CX                  ;Get back our old CX
    SUB  DI,512              ;Move DI back to the last position for data
    Cmp  PCX_AllDone,-1      ;Are we all done?
    Je   CloseFile           ;Yes, close the file.
    Jmp  DO1                 ;No, get more data.

CloseFile:
    Mov  AH,3Eh              ;Request that DOS close our file
    Mov  BX,PCX_FileHandle
    Int  21h
    Mov  AX,0                ;Ignore an error here.
    Jnc  Exit

HadAProblem:
    Mov  AX,-1               ;Say we had an error

Exit:
Include BC7End.GW
    Ret

SavePCXH ENDP

END
