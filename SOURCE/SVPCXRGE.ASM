;***** SvPcxRgE.ASM - This file demostrates saving a file using the .PCX
;                     file format used in PC Paintbrush for EGA and VGA
;                     screens.  A partial screen image is saved and left
;                     adjusted into the .PCX file.

;Copyright (c), 1990 Brian C. Giedt

.Model Medium, Basic
.Data

Include EXTERNAL.GW
Include PCXEXTRN.GW

SaveShift  DB ?
TempBuffer DB 83 DUP (?)
SaveOffset DW ?

.Code

ifdef bc7
  EXTRN StringInfo:Proc
endif
  EXTRN GetPalTripleVGA:Proc
  EXTRN GetPaletteVGA:Proc

SavePCXRegionVE PROC Filename:Ptr, Startx:Word, Starty:word, Endx:Word, Endy:Word

Include BC7Start.GW

    Cld                          ;Make sure all moves are in the forward direction
    Mov  PCX_AllDone,0           ;Set a flag to say we are not done yet

    Mov  PCX_XSize,639
    Mov  PCX_YSize,479            ;Assume we are using a VGA monitor
    Mov  AH,0Fh                  ;Ask BIOS what monitor is currently active
    Push BP
    Int  10h                     ;using Interrupt 10h
    Pop  BP

    Cmp  AL,10h                  ;Is it in EGA high-resolution mode?
    Jg   NotEGA                  ;No so save an VGA image
    Mov  PCX_YSize,349           ;Give it the resolution of an EGA Image

NotEGA:
    Mov  AX,Endx
    Sub  AX,Startx
    Dec  AX
    Mov  PCX_XMax,AX
    Mov  AX,Endy
    Sub  AX,Starty
    Dec  AX
    Mov  PCX_YMax,AX

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
    Mov  byte ptr [DI],0         ;Append an ASCII NULL for DOS's sake

    Push ES                      ;Return our data segment to its original value
    Pop  DS

    Mov  AH,3Ch                  ;Function 3C of Int 21h will create the file
    Int  21h                     ;Let BIOS do the work
    Jnc  OpenWasOk               ;The Carry flag would tell us of a problem
    Jmp  HadAProblem             ;Carry was set, a problem, so stop.
OpenWasOk:
    Mov  PCX_FileHandle,AX       ;We'll need the file handle for later Int's

    Lea  DI,PCX_TheBuffer        ;Address of our internal buffer
    Mov  PCX_BeginBuff,DI        ;Store it away for later arithmetic use
    Mov  Byte Ptr [DI],10        ;Mimick that we are ZSoft as the publisher
    Inc  DI
    Mov  Byte Ptr [DI],5         ;Version 5 of the .PCX format
    Inc  DI
    Mov  Byte Ptr [DI],1         ;Specify Run Length Encoding
    INC  DI
    Mov  Byte Ptr [DI],1         ;EGA is setup with 1 bit per pixel (ignoring planes here)
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

    ;The palette information comes next.  Since it is not possible to physically
    ;read the EGA palette registers, we will just use a version of this file
    ;format which does not pass palette information, and below will send 48
    ;bytes containing ASCII NULL's
    Cmp  PCX_YSize,479
    Je   DoVGAPalette
DoEGAPalette:
    Mov  CX,48
    Lea  SI,PaletteVE
Rep Movsb
    Jmp  AfterPalette

DoVGAPalette:
    Mov  CX,16
NextPalette:
    Push CX
    Push DI

    Mov  AX,16
    Sub  AX,CX
    Push AX
    Call GetPaletteVGA
    Push AX
    Push DI
    Inc  DI
    Push DI
    Inc  DI
    Push DI
    Call GetPalTripleVGA

    Pop  DI
    Mov  AL,[DI]
    Shl  AL,1
    Shl  AL,1
    Mov  [DI],AL
    Inc  DI
    Mov  AL,[DI]
    Shl  AL,1
    Shl  AL,1
    Mov  [DI],AL
    Inc  DI
    Mov  AL,[DI]
    Shl  AL,1
    Shl  AL,1
    Mov  [DI],AL
    Inc  DI
    Pop  CX
    Loop NextPalette

AfterPalette:
    Mov  Byte Ptr [DI],0         ;This byte is unused in the format (Reserved)
    INC  DI
    Mov  Byte Ptr [DI],4         ;The EGA and VGA have 4 color planes
    INC  DI

    ;Next calculate the number of bytes per scan line in the image.  For the
    ;EGA and VGA this is going to be 80 bytes, but for completeness, it will
    ;be calculated.
    Mov  AX,PCX_XMax
    Add  AX,8
    Shr  AX,1
    Shr  AX,1
    Shr  AX,1
    Inc  AX
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
    Mov  AX,Starty           ;Let local variable PCX_Y hold the line number
    Mov  PCX_Y, 0            ; we're currently on

    POP  BX                  ;BX now holds the number of bytes per scan line
    Mov  PCX_BytesPerLine,BX ;So does local variable PCX_BytesPerLine

    Mov  DX,EGABytesPerLine  ;Calculate the starting address
    Mul  DX
    Mov  BX,Startx
    Mov  CL,BL
    And  CL,7
    Mov  SaveShift,CL
    Shr  BX,1
    Shr  BX,1
    Shr  BX,1
    Add  AX,BX
    Push AX                  ;Store that away for later

    MOV  AX,EGAVideoSeg      ;Get the EGA\VGA video segment
    MOV  ES,AX

    Mov  AX,0004h
    Mov  PCX_Plane,AH        ;Store Which of the planes we're on
    MOV  DX,03CEh            ;Out to the proper EGA port to turn on only one
    OUT  DX,AX               ; of the planes for reading a value

    Pop  BX                  ;Get our screen address
    Mov  SaveOffset,BX

NextBitShift:
    Mov  BX,SaveOffset
    Push DI                  ;Save our offset into the output file.
    Push DX                  ;Save the VGA out location
    Mov  DX,PCX_BytesPerLine

    Lea  DI,TempBuffer       ;Clear our buffer of any leftover info

    Push ES
    Push DS
    Pop  ES
    Mov  CX,83
    Xor  Ax,Ax
    Rep  Stosb
    Pop  ES

    Lea  DI,TempBuffer
    Mov  CL,SaveShift
NextByteOfLine:
    Xor  AX,AX
    MOV  AL,ES:[BX]          ;Get the first byte from the screen
    INC  BX                  ;Point to next address
    ;AH is clear from above

    Shl  AX,CL
    Or   [DI],AH
    Inc  DI
    Or   [DI],AL
    Sub  DX,1
    Jge  NextByteOfLine

    Pop  DX
    Pop  DI

    Mov  CL,1                ;Start the count at 1
    Lea  BX,TempBuffer       ;Get the data from our new buffer
    Inc  BX                  ;Skip past the first waste byte
    Mov  AH,[BX]
    Inc  BX
    Mov  PCX_ByteAtOnLine,1  ;This will hold the number of bytes looked at

;***************************************************************
;                 END OF INITIALIZATION CODE
;***************************************************************

NextOfBuffer:
;get a byte
    Mov  AL,[BX]          ;AL will hold its value
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

    Mov  AH,PCX_Plane        ;Go to the next plane
    Inc  AH
    And  AH,3                ;If its > 3 then make it 0
    Mov  PCX_Plane,AH
    MOV  DX,03CEh            ;Out to the proper EGA port and request that plane
    MOV  AL,04               ; be accessed
    OUT  DX,AX
    Xor  DX,DX               ;Restore the count on the current line to 0
    Cmp  AH,DL               ;Compare the plane value to see if its 0
    Jne  SkipIt              ;If not then skip this next code

    ;otherwise, we are going to increment the line we're on
    Mov  BX,SaveOffset
    Add  BX,EGABytesPerLine  ;Push the address pointer one line below
    Mov  SaveOffset,BX
    Inc  PCX_Y               ;Increment the linenumber
    Mov  AX,PCX_Y            ;Compare the line number with the lines in the image
    Cmp  AX,PCX_YMax
    Jle  SkipIt              ;If its less or equal, we're not done yet
    Dec  PCX_AllDone         ;Specifies that we are done

SkipIt:
    Mov  BX,-1

NotEndOfLine:
    Mov  DX,DI               ;Check if we have written 512 bytes yet
    Sub  DX,PCX_BeginBuff
    Cmp  DX,512
    Jge  SendBytes2          ;If we've done 512 bytes or more, then send 512
    Cmp  PCX_AllDone,-1      ;If we're all done, then send what we've got.
    Je   SendBytes3
    Cmp  BX,-1               ;Are we done with this buffer?
    Jne  NextOfBufferLoc     ;No, Get more data
    Jmp  NextBitShift        ;Otherwise continue to add to the buffer
NextOfBufferLoc:
    Jmp  NextOfBuffer

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
    Cmp  BX,-1               ;Were we done with this buffer
    Jne  NextOfBufferLoc     ;No, get more data.
    Jmp  NextBitShift

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

SavePCXRegionVE ENDP

END
