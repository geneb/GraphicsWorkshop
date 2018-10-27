;************ ScrnDmp2.Asm

;Copyright (c) 1988,1990 Brian Giedt

;syntax - CALL ScrnDump2(DPI$, LPTNo%, Translate%, XMult%, YMult%, LandOrPort%)

;Where DPI$ is "" to dump to an Epson type printer, or " 75", "100", "150",
;or "300" to indicate the HP LaserJet DPI resolution.  Note that if 75 is
;used, it MUST be preceded by a blank space to pad the length to three.
;
;LPTNo% specifies which parallel printer port to use (1, 2, or 3).
;If the printer is off line, runs out of paper, and so forth, LPTNo%
;will be returned as -1.  To Make the printer output Inverted, add 256 to
;the printer number.
;
;Translate% is either non-zero to tell ScrnDump to interpret the screen
;colors and convert them to a tile pattern, or 0 to print all colors black.
;
;XMult% and YMult% are used to change the size of the image when printed to
;the Hewlett Packard printer.  A value of 3 cannot be used because the Hewlett
;Packard LaserJet II is not designed to handle that many pixels in an image.
;
;LandOrPort% is either a non-zero value which means to print in Landscape mode,
;or is zero which means to print in Portrait Mode.

;A New feature of the ScrnDump2 routine allows you to invert all output sent
;to the printer.  Normally white on the screen would be shown as black on the
;paper.  To make black on the screen appear black on paper, and white on the
;screen appear white on the paper use this feature.  To activate this feature,
;add the value 256 to the printer number.  If you normally use LPT1 to print
;through, and want to use this feature then you would pass ScrnDump2 the
;following value in place of the printer number.

;   LPTNo% = 1 + 256

.Model Medium, Basic
.Data

MSave          DB   ?
EPSONInit      DB   1Bh, "3", 24
EPSONReset     DB   1Bh, 40h
EPSONBeginT    DB   13, 10, 27, "L", 208, 2
HPInit         DB   27, "*t150R", 27, "*r1A"
HPReset        DB   27, "*rB"
HPBeginT       DB   27, "*b90W"
TestInc        DW   0
UsePrinter     DW   0
UseInverter    DW   0

;The EGAToBW table is specifically designed to work with the bit plane
;structure of the EGA and VGA monitors.  The Result is and 8-bit wide by
;4 bits in height tile pattern for solid colors.
;
;                Plane 1    Plane 2    Plane 3    Plane4
;                =======    =======    =======    ======
EGAToBW    DB   00000001b, 01010100b, 11101110b, 0          ; (Line MOD 4) = 0
           DB   00010000b, 00101010b, 11011101b, 0          ; (Line MOD 4) = 1
           DB   00000100b, 00010101b, 10111011b, 01000000b  ; (Line MOD 4) = 2
           DB   01000000b, 10001010b, 01110111b, 0          ; (Line MOD 4) = 3
BWToBW     DB   255,       255,       255,       255
           DB   255,       255,       255,       255
           DB   255,       255,       255,       255
           DB   255,       255,       255,       255

WhichTable     DW   Offset EGAToBW
TakeOut        DW   1
LineBytes      DW   80
InterNumber    DW   1

OldStack       DW   1     ;these lines were added 8/6/88 EW
ErrCode        DW   1

XMultiplier    DW   1
YMultiplier    DW   1

TransPos       DW   0
TransTable     DB   720 DUP(0)

;NOTE:  Modifications to the next set of data will cause trouble if you are
;       not careful to also modify the code that accesses the data addresses.
;       Some variables are pointed to by addressing another and incrementing
;       the Offset pointer.  Search for "****" to see where the source code
;       must be changed.

Retrieve       DW   OffSet ByteCGAMono
VideoBufSeg    DW   0B800h
Wide           DW   639
Siz            DW   199
LineLength     DW   80
EndPoint       DW   3F40h
FirstInter     DW   8112, -8192, 8112, -8192
HPBegin        DB   27, "*b80W"
EPSONBegin     DB   13, 32, 27, "K", 144, 1
SavLineBytes   DW   80
EPSONInter     DW   8112, -8192, 8112, -8192
DoubleSize     DW   2

;
;Data Below this point is for all screen modes supported by BASIC
;

;CGA 4 color 320 x 200
FirstMonitor   DW Offset ByteCGAColor, 0B800h, 319, 199, 40, 3F40h
               DW -8192, 8112, -8192, 8112
               DB 27, "*b40W"
               DB 13, 10, 27, "K", 200, 0
               DW 80, 8111, -8193, 8111, -8193, 1

;CGA 2 color 640 x 200
               DW Offset ByteCGAMono, 0B800h, 639, 199, 80, 3F40h
               DW -8192, 8112, -8192, 8112
               DB 27, "*b80W"
               DB 13, 10, 27, "K", 144, 1
               DW 80, 8112, -8192, 8112, -8192, 2

;Herc 720 x 350
               DW Offset ByteCGAMono, 0B000h, 719, 349, 90, 3EF0h
               DW -8192 * 3, 8102, 8102, 8102
               DB 27, "*b90W"
               DB 13, 10, 27, "K", 94, 1
               DW 90, -8192, -8192, 8192 * 3 - 90, -8192, 1

;EGA 16 color 320 x 200
               DW Offset ByteEGAColor, 0A000h, 319, 199, 40, 1F40h
               DW 0, 0, 0, 0
               DB 27, "*b40W"
               DB 13, 10, 27, "K", 200, 0
               DW 40, -40, -40, -40, -40, 1

;EGA 16 color 640 x 200
               DW Offset ByteEGAColor, 0A000h, 639, 199, 80, 3E80h
               DW 0, 0, 0, 0
               DB 27, "*b80W"
               DB 13, 10, 27, "K", 144, 1
               DW 80, -80, -80, -80, -80, 2

;EGA mono 640 x 350
               DW Offset ByteEGAColor, 0A000h, 639, 349, 80, 6D60h
               DW 0, 0, 0, 0
               DB 27, "*b80W"
               DB 13, 10, 27, "K", 94, 1
               DW 80, -80, -80, -80, -80, 1

;EGA 16 color 640 x 350
               DW Offset ByteEGAColor, 0A000h, 639, 349, 80, 6D60h
               DW 0, 0, 0, 0
               DB 27, "*b80W"
               DB 13, 10, 27, "K", 94, 1
               DW 80, -80, -80, -80, -80, 1

;VGA mono 640 x 480
               DW Offset ByteEGAColor, 0A000h, 639, 479, 80, 9600h
               DW 0, 0, 0, 0
               DB 27, "*b80W"
               DB 13, 10, 27, "K", 224, 1
               DW 80, -80, -80, -80, -80, 1

;VGA 16 color 640 x 480
               DW Offset ByteEGAColor, 0A000h, 639, 479, 80, 9600h
               DW 0, 0, 0, 0
               DB 27, "*b80W"
               DB 13, 10, 27, "K", 224, 1
               DW 80, -80, -80, -80, -80, 1

.Code

ifdef bc7
  EXTRN StringInfo:Proc
endif

ScrnDump2 PROC DotsPerInch:Ptr, PrinterNO:Ptr, TranslateEGA:Ptr, XMult:Ptr, YMult:Ptr, LandOrPort:Ptr

Include BC7Start.GW

    Mov    OldStack,SP    ;save SP in case we have to bail out of a Call
    Mov    ErrCode,0      ;assume no errors for now

ifdef bc7
    Push   ES             ;BASIC 7 sometimes requires the value of the ES
endif                     ; register when examining far strings

    MOV    CX,720                   ;Clear the Translation Buffer
    XOR    AL,AL
    MOV    SI,Offset TransTable
LoopClear:
    MOV    [SI],AL
    INC    SI
    LOOP   LoopClear

    MOV    SI,XMult       ;Put XMult and YMult in local variables
    MOV    AX,[SI]
    MOV    XMultiplier,AX
    MOV    SI,YMult
    MOV    AX,[SI]
    MOV    YMultiplier,AX

;determine video display
    XOR    AX,AX          ;access segment zero through ES
    MOV    ES,AX          ;is it a monochrome screen?
    CMP    Byte Ptr ES:[0463h],0B4h
    PUSH   DS             ;make ES the same as DS for Movs later
    POP    ES
    JNE    ItIsColor      ;no, a color screen is active

                          ;check to see if Hercules
    MOV    CX,8000h       ;we're going to test this a bunch of times
    MOV    DX,3BAH        ;Hercules video status port
    IN     AL,DX          ;if bit 7 ever changes, it's a Herc card
    AND    AL,80h         ;isolate just the bit we care about
    MOV    AH,AL          ;save it in AH

CheckHERC:
    IN     AL,DX          ;now read register repeatedly
    AND    AL,80h         ;isolate the bit again
    CMP    AL,AH          ;has it changed?
    JNE    MonitorHerc    ;yes, a Herc card must be installed
    LOOP   CheckHERC      ;the bit hasn't changed yet, keep looping
                          ;if we got this far without AL changing,
                          ;it must be a plain ol' mono card, goodbye

TimeToLeave:              ;exit the routine at end of code
    JMP    AllDone

MonitorHerc:
    MOV    AL,7           ;Use Mode 7 as HERC and skip the BIOS monitor detect
    JMP    Short BypassBiosCheck

ItIsColor:
    MOV    AH,0Fh         ;Ask BIOS what monitor is currently active
    INT    10h

BypassBiosCheck:
    MOV    BL,AL          ;we'll need AL so put the monitor type in BL
    CMP    BL,4           ;if in text mode
    JB     TimeToLeave    ;then Exit
    JA     CheckTheNext   ;if mode is 4 then shift to mode 5
    INC    BL

CheckTheNext:
    CMP    BL,8           ;if in modes 4 - 7
    JB     MonitorOK      ;then Ok Graphics mode
    CMP    BL,13          ;if mode 8 - 12 then
    JB     TimeToLeave    ;  exit program
    CMP    BL,18          ;if Mode > 18 then
    JA     TimeToLeave    ;don't know these modes
    SUB    BL,5           ;adjust table to read continuously

MonitorOK:
    MOV    DI,PrinterNO   ;ask the host program which printer
    MOV    DX,[DI]        ;  to send it to LPT1: - LPT3: as 1-3
    Mov    Byte Ptr UseInverter, DH
    Xor    DH,DH
    DEC    DX             ;adjust 1 - 3 to 0 - 2 for use with INT 17h
    MOV    UsePrinter,DX  ;store it away for later
    MOV    MSave,BL       ;store the video mode for later too
    MOV    Word Ptr TakeOut,1 ;increment for Epson columns
    CMP    BL,5           ;if 320 x 200 graphics mode then
    JNE    DontTakeMore   ;  we need to move to screen columns
    INC    Word Ptr TakeOut ;for every printer column if Epson

DontTakeMore:
    SUB    BL,5           ;calculate offset into table based on
    MOV    AX,44          ;  monitor type
    MUL    BL
    MOV    SI,Offset FirstMonitor   ;offset of table
    MOV    DI,Offset Retrieve       ;offset of variables used by program
    ADD    SI,AX          ;add monitor offset
    MOV    CX,22          ;move 22 words of data
    REP    MOVSW          ;  into work variables

    MOV    BX,SavLineBytes    ;we need a copy to modify that tells how many
    MOV    LineBytes,BX       ;bytes per line, not how many columns

;Decide if we need to translate colors to BW
    MOV    DI,TranslateEGA    ;see if they want to translate colors
    MOV    DX,Offset BWToBW   ;assume not
    CMP    Word Ptr [DI],0    ;if true (not 0) then translate the
    JE     PickPrinter        ;  colors into tile patterns
    MOV    DX,Offset EGAToBW  ;load offset of tile patterns table

PickPrinter:
    MOV    WhichTable,DX      ;save the address of the correct table

;Need to make decision here as to which printer to use
    MOV    SI,DotsPerInch     ;loof at DPI$
ifdef bc7
    POP    ES
    Call   StringInfo
    MOV    ES,DX
    MOV    SI,AX
else
    MOV    CX,[SI]            ;a string of length 3 should have been passed
    MOV    SI,[SI+2]          ;ES:SI points to the string
    Push   DS
    Pop    ES
endif
    CMP    CX,3               ;Check the length of the string
    JNE    ChooseEPSON        ;otherwise do the EPSON
    MOV    DI,Offset HPInit   ;  string to place in the HP Init String
    ADD    DI,3               ;we want to insert three bytes into the string
MoveSBFake:
    MOV    AL,ES:[SI]
    MOV    [DI],AL
    INC    SI
    INC    DI
    Loop   MoveSBFake
    Mov    DI,LandOrPort
    Mov    AL,[DI]
    Or     AL,AL
    Jnz    HPLandScape
    JMP    HPPortrait

ChooseEPSON:
    Mov    DI,LandOrPort
    Mov    AL,[DI]
    Or     AL,AL
    Jnz    DoEPSONLandscape
    JMP    EPSONPortrait
DoEPSONLandscape:
    JMP    EPSONLandscape

;**************************************************************************;
;          PRINT TO THE HP PRINTER TYPE IN LANDSCAPE MODE                  ;
;**************************************************************************;
HPLandscape:
    CALL   InitHP                   ;initialize the HP
    MOV    ES,VideoBufSeg           ;we need the video segment in ES
    MOV    BX,EndPoint              ;calculate the last video offset
    SUB    BX,LineBytes             ;of the current column - in this case
                                    ;  the first column
    MOV    CX,LineLength            ;do this many columns

DoColumnHPL:
    PUSH   CX                       ;store the number of columns remaining
    XOR    CX,CX                    ;Keep a Rolling Number for the Translate
    MOV    TransPos,CX              ; table

DoMoreHPL:
    MOV    CX,4             ;do 4 steps for all possible interlace schemes

NextInterHPL:
    PUSH   CX                       ;store Interlace level away while we
                                    ;  find the screen contents
    DEC    CX                       ;calculate the offset
    SHL    CX,1                     ;  into the EGA to BW
    SHL    CX,1                     ;  buffer so the graphics
    MOV    InterNumber,CX           ;  routine will work fast

    CALL   Word Ptr Retrieve        ;get screen contents in AL

;Print the Character
    MOV    CX,YMultiplier           ;Number of times to repeat
DoubleRepeatHPL:
    CALL   PlaceInTable             ;Place Translated Character in the table
    INC    Word Ptr TransPos        ; NOTE PlaceInTable uses DX,AX,DI
    LOOP   DoubleRepeatHPL          ;Repeat the print function if YMultiplier>1
    INC    Word Ptr TestInc

;Calculate the Next Position
    POP    CX                       ;restore interlace into CX for LOOP
    CMP    BX,SavLineBytes          ;if just printed while in first row
    JB     NextColumnHPL            ;  then start at last row, next column
;****
    MOV    DI,Offset SavLineBytes   ;work the interlace
    ADD    DI,CX                    ;  by calculating the offset
    ADD    DI,CX                    ;  in table for Epson interlaces
    MOV    AX,[DI]                  ;then add that value
    ADD    BX,AX                    ;  to our Screen offset
    LOOP   NextInterHPL             ;get another byte and change
                                    ;  interlace number
    JMP    DoMoreHPL                ;do more interlaced bytes

NextColumnHPL:
    MOV    CX,TakeOut               ;take out the number of bytes
    MOV    DI,Offset LineBytes      ;  that make up an 8 bit output
    SUB    [DI], CX                 ;  from the variable

    MOV    CX,8                     ;Send eight lines
    MOV    DI,Offset TransTable     ;Use DI to hold the Offset of the Translate
                                    ; table

LoopLineHPL:
    PUSH   CX
    MOV    CX,XMultiplier
LoopXLinesHPL:                      ;Send XMultiplier Copies of the
    CALL   SendLinesHPL             ; translated lines to HP LaserJet
    SUB    DI,90
    LOOP   LoopXLinesHPL
    ADD    DI,90

    POP    CX                       ;Restore the number of lines out of 8 left
    LOOP   LoopLineHPL              ; to print

    MOV    CX,720                   ;Clear the Buffer for the next set of
    XOR    AL,AL                    ; lines
    MOV    SI,Offset TransTable
LoopClearHPL:
    MOV    [SI],AL
    INC    SI
    LOOP   LoopClearHPL

    MOV    BX,EndPoint              ;position us at the correct column
    SUB    BX,LineBytes             ;  on the last row of the current screen
    POP    CX                       ;restore the number of columns left
    LOOP   DoColumnHPL              ;  and do another column
    JMP    AllDoneHPP

;**************************************************************************;
;          PRINT TO THE HP PRINTER TYPE IN PORTRAIT MODE                   ;
;**************************************************************************;
HPPortrait:
    MOV    ES,VideoBufSeg     ;we need the Video Segment in ES
    XOR    BX,BX              ;we'll start at Offset 0 later
    CALL   InitHP             ;initialize the HP
    MOV    CX,6               ;tell the HP we're going to
    MOV    DI,OFFSET HPBegin  ;send LineLength bytes
    CALL   PrintBuffer

DoMoreHPP:
    MOV    CX,4           ;loops of 4 will handle all of the
                          ;interlace types used in graphics modes

NextInterHPP:
    PUSH   CX             ;after this we can modify CX without worry
    DEC    CX             ;calculate the offset
    SHL    CX,1           ;  into the EGA to BW
    SHL    CX,1           ;  buffer so the graphics
    MOV    InterNumber,CX ;  routine will work fast
    MOV    CX,LineLength  ;send LineLength bytes

NextByteHPP:
    PUSH   CX
    CALL   Word Ptr Retrieve  ;the variable Retrieve holds the offset
                              ;  of the correct routine to call
    POP    CX
    MOV    DX,UsePrinter      ;the printer number was stored here
    XOR    AH,AH              ;print a Character service
    INT    17h                ;print it
    CALL   PrntrOkay          ;did the byte get printed successfully?
    INC    BX                 ;point to the next screen location
    LOOP   NextByteHPP        ;loop until done

    POP    CX                 ;CX is which interlace
    CMP    BX,EndPoint        ;have we reached the last offset to print?
    JE     AllDoneHPP         ;yes

;Note when CX is 1 we want word offset 0 so we start with an address of
; 1 word lower in memory
;****
    MOV    DI,Offset EndPoint ;time to work the
    ADD    DI,CX              ;  interlace of some
    ADD    DI,CX              ;  graphics modes by
    MOV    AX,[DI]            ;  adding the appropriate
    ADD    BX,AX              ;  values
    PUSH   CX
    MOV    CX,6               ;tell the HP
    MOV    DI,OFFSET HPBegin  ;  we're going to
    CALL   PrintBuffer        ;  send LineLength bytes
    POP    CX
    LOOP   NextInterHPP
    JMP    Short DoMoreHPP

AllDoneHPP:
    CALL   UndoHP             ;tell the HP were done
    JMP    AllDone

;**************************************************************************;
;          PRINT TO THE EPSON PRINTER TYPE IN THE LANDSCAPE MODE           ;
;**************************************************************************;
EPSONLandscape:
    CALL   InitEPSON

    MOV    ES,VideoBufSeg ;we need the video segment in ES
    MOV    BX,EndPoint    ;calculate the last video offset
    SUB    BX,LineBytes   ;of the current column - in this case
                          ;  the first column
    MOV    CX,LineLength  ;do this many columns

DoColumnEL:
    PUSH   CX             ;store the number of columns remaining
    MOV    CX,6                 ;tell the Epson
    MOV    DI,OFFSET EPSONBegin ;  we're going to
    CALL   PrintBuffer          ;  send LineLength bytes

DoMoreEL:
    MOV    CX,4           ;do 4 steps for all possible interlace schemes

NextInterEL:
    PUSH   CX                 ;store Interlace level away while we
                              ;  find the screen contents
    DEC    CX                 ;calculate the offset
    SHL    CX,1               ;  into the EGA to BW
    SHL    CX,1               ;  buffer so the graphics
    MOV    InterNumber,CX     ;  routine will work fast

    CALL   Word Ptr Retrieve  ;get screen contents in AL

;Print the Character
    MOV    CX,DoubleSize      ;Number of times to repeat
DoubleRepeatEL:
    MOV    DX,UsePrinter      ;the printer number was stored here
    XOR    AH,AH              ;function to print a character
    INT    17h                ;print the character in AL
    CALL   PrntrOkay          ;did the byte get printed sucessfully?
    LOOP   DoubleRepeatEL     ;Repeat the print function if DoubleSize = 2
    INC    Word Ptr TestInc

;Calculate the Next Position
    POP    CX                 ;restore interlace into CX for LOOP
    CMP    BX,SavLineBytes    ;if just printed while in first row
    JB     NextColumnEL       ;  then start at last row, next column
;****
    MOV    DI,Offset SavLineBytes   ;work the interlace
    ADD    DI,CX                    ;  by calculating the offset
    ADD    DI,CX                    ;  in table for Epson interlaces
    MOV    AX,[DI]                  ;then add that value
    ADD    BX,AX                    ;  to our Screen offset
    LOOP   NextInterEL              ;get another byte and change
                                    ;  interlace number
    JMP    DoMoreEL                 ;do more interlaced bytes

NextColumnEL:
    MOV    CX,TakeOut               ;take out the number of bytes
    MOV    DI,Offset LineBytes      ;  that make up an 8 bit output
    SUB    [DI], CX                 ;  from the variable which will
    MOV    BX,EndPoint              ;  position us at the correct column
    SUB    BX,LineBytes             ;  on the last row of the current screen
    POP    CX                       ;restore the number of columns left
    LOOP   DoColumnEL               ;  and do another column

    Jmp    AllDone

;**************************************************************************;
;          PRINT TO THE EPSON PRINTER TYPE IN THE PORTRAIT MODE            ;
;**************************************************************************;
EPSONPortrait:
    CALL   InitEPSON

    MOV    ES,VideoBufSeg ;we need the video segment in ES
    XOR    BX,BX          ;Calculate the first video offset
    MOV    CX,2

DoMoreEP:
    Push   CX
    MOV    CX,4           ;do 4 steps for all possible interlace schemes

NextInterEP:
    PUSH   CX                 ;store Interlace level away while we
                              ;  find the screen contents
    DEC    CX                 ;calculate the offset
    SHL    CX,1               ;  into the EGA to BW
    SHL    CX,1               ;  buffer so the graphics
    MOV    InterNumber,CX     ;  routine will work fast

    Xor    CX,CX
    Mov    TransPos,CX
    Mov    CX,LineLength

NextByteEP:
    Push   CX
    CALL   Word Ptr Retrieve  ;get screen contents in AL

    CALL   PlaceInTableE            ;Place Translated Character in the table
                                    ; NOTE PlaceInTable uses DX,AX,DI
    INC    Word Ptr TestInc
    POP    CX
    INC    BX
    Loop   NextByteEP

    Cmp    BX,EndPoint
    Je     AllDoneEP

    Pop    CX
;Calculate the Next Position
    MOV    DI,Offset EndPoint       ;work the interlace
    ADD    DI,CX                    ;  by calculating the offset
    ADD    DI,CX                    ;  in table for Epson interlaces
    MOV    AX,[DI]                  ;then add that value
    ADD    BX,AX                    ;  to our Screen offset
    Loop   NextInterEP

    Pop    CX
    Loop   DoMoreEP

    MOV    DI,Offset TransTable     ;Use DI to hold the Offset of the Translate
                                    ; table
    CALL   SendLinesEP              ; translated lines to EPSON

    MOV    CX,720                   ;Clear the Buffer for the next set of
    XOR    AL,AL                    ; lines
    MOV    SI,Offset TransTable
LoopClearEP:
    MOV    [SI],AL
    INC    SI
    LOOP   LoopClearEP

    Mov    CX,2
    JMP    DoMoreEP                 ;do more interlaced bytes

AllDoneEP:
    Pop    CX
    Pop    BX
    Dec    BX
    Shl    BX,1
    Shl    BX,1
    Add    CX,BX
    Dec    CX
    Je     AllDoneEP3
    Xor    AX,AX
AllDoneEP1:
    Push   CX
    Mov    TransPos,0
    Mov    CX,90
AllDoneEP2:
    Push   CX
    CALL   PlaceInTableE
    Pop    CX
    Loop   AllDoneEP2
    Pop    CX
    Loop   AllDoneEP1
AllDoneEP3:
    Mov    DI,Offset TransTable
    CALL   SendLinesEP

AllDone:
    Mov    SP,OldStack              ;restore the stack EXACTLY as it was
    Cmp    ErrCode,-1               ;was there an error?
    Jnz    NoError                  ;no, leave
    Mov    SI,PrinterNO             ;yes, get the address for PrinterNo%
    Mov    Word Ptr [SI],-1         ;set it to -1

NoError:
Include BC7End.GW
    RET                            ;return to BASIC


PrintBuffer:
PrintAnother:
    XOR    AH,AH          ;Function 0 - print a char
    MOV    DX,UsePrinter  ;use this printer
    MOV    AL,[DI]        ;get character to print
    INC    DI             ;move to next position in buf
    INT    17h            ;print this character
    CALL   PrntrOkay      ;did the byte get printed successfully?
    LOOP   PrintAnother   ;print CX items
    RETN


InitEPSON:
    MOV    DI,OFFSET EPSONInit   ;offset of buffer to print
    MOV    CX,3                  ;number of bytes in the buffer
    CALL   PrintBuffer           ;print the buffer
    RETN


InitHP:
    MOV    DI,OFFSET HPInit      ;offset of buffer to print
    MOV    CX,12                 ;number of bytes in the buffer
    CALL   PrintBuffer           ;print the buffer
    RETN


UndoHP:
    MOV    DI,OFFSET HPReset     ;offset of buffer to print
    MOV    CX,4                  ;number of bytes in the buffer
    CALL   PrintBuffer           ;print the buffer
    RETN


PlaceInTable:
    PUSH   CX
    MOV    CX,TransPos
    MOV    DX,CX
    SHR    DX,1
    SHR    DX,1
    SHR    DX,1                  ;TablePos div 8
    ADD    DX,Offset TransTable
    AND    CX,7
    NOT    CX
    MOV    CH,8
    ADD    CL,CH
    PUSH   CX
    MOV    DI,DX
TableLoop:
    POP    CX
    XOR    AH,AH
    ROL    AL,1
    RCL    AH,1
    SHL    AH,CL
    OR     [DI],AH
    ADD    DI,90
    DEC    CH
    PUSH   CX
    INC    CH
    MOV    CL,CH
    XOR    CH,CH
    Loop   TableLoop

    POP    CX
    POP    CX
    RETN


PlaceInTableE:
    MOV    DI,TransPos
    ADD    DI,Offset TransTable
    MOV    CX,8
TableLoopE:
    Mov    AH,[DI]
    ROL    AL,1
    RCL    AH,1
    Mov    [DI],AH
    INC    DI
    INC    Word Ptr TransPos
    Loop   TableLoopE
    RETN


SendLinesHPL:
    PUSH   CX
    PUSH   DI
    MOV    CX,6                     ;tell the HP
    MOV    DI,OFFSET HPBeginT       ;  we're going to
    CALL   PrintBuffer              ;  send LineLength bytes
    POP    DI
;    Mov    CX,UseInverter
;    Or     CX,CX
;    Je     SendItHPL
;    Push   DI
;    Mov    CX,90
;InvLoopHPL:
;    Mov    AL,[DI]
;    Not    AL
;    Mov    [DI],AL
;    Inc    DI
;    Loop   InvLoopHPL
;    Pop    DI
;SendItHPL:
    MOV    CX,90
    CALL   PrintBuffer
    POP    CX
    RETN


SendLinesEP:
    PUSH   CX
    PUSH   DI
    MOV    CX,6                     ;tell the EPSON
    MOV    DI,OFFSET EPSONBeginT    ;  we're going to
    CALL   PrintBuffer              ;  send LineLength bytes
    Pop    DI
;    Mov    CX,UseInverter
;    Or     CX,CX
;    Je     SendItEP
;    Push   DI
;    Mov    CX,720
;InvLoopEP:
;    Mov    AL,[DI]
;    Not    AL
;    Mov    [DI],AL
;    Inc    DI
;    Loop   InvLoopEP
;    Pop    DI
;SendItEP:
    MOV    CX,720
    CALL   PrintBuffer
    POP    CX
    RETN


;also does Hercules
ByteCGAMono:
    MOV    AL,ES:[BX]            ;put byte straight from screen
    Push   DX
    Mov    DX,UseInverter
    Or     DX,DX
    Je     ByteCGAMonoRet
    Not    AL
ByteCGAMonoRet:
    Pop    DX
    RETN


ByteCGAColor:
    XOR    AL,AL                 ;clear the output byte
    MOV    DH,ES:[BX]            ;get one of the bytes needed
    INC    BX                    ;the outside routine will increment BX
                                 ;  resulting in two increments
    MOV    DL,ES:[BX]            ;get the next byte needed
    MOV    CX,8                  ;to retrieve 8 bits

CGALoop1:
    MOV    AH,1                  ;AH will be shifted into
                                 ;  the proper position
    SHL    DX,1                  ;shift to check Carry
    JC     CGAColor23            ;if Carry then COLOR > 1
    SHL    DX,1                  ;shift to check Carry
    JC     CGAColor1             ;if Carry then COLOR = 1
    JMP    Short CGANextSet      ;COLOR = 0, do nothing

CGAColor1:
    PUSH   CX                    ;store CX so we can use it
    MOV    DI,WhichTable         ;offset of EGA to B/W table
    ADD    DI,InterNumber        ;add (Interlace# - 1) * 4
    DEC    CX                    ;shift AH Left one less than
    SHL    AH,CL                 ;  bit number we are on
    AND    AH,[DI]               ;use EGAtoBW to Convert Color
    OR     AL,AH                 ;add Color of bit to output
    POP    CX                    ;get back bit number
    JMP    Short CGANextSet      ;do another bit

CGAColor23:
    SHL    DX,1                  ;shift to check Carry
    JC     CGAColor3             ;if Carry then COLOR = 3
    PUSH   CX                    ;COLOR = 2, Store CX away
    MOV    DI,WhichTable         ;offset to EGA to b/w table
    ADD    DI,InterNumber        ;modify offset to line number
    DEC    CX                    ;shift AH left one less than
    SHL    AH,CL                 ;  bit number we are on
    INC    DI                    ;get offset of plane 2 color
    AND    AH,[DI]               ;and check if color into BW
    OR     AL,AH                 ;if bit set, set output bit
    POP    CX                    ;get back bit number we're on
    JMP    Short CGANextSet      ;do another bit

CGAColor3:
    PUSH   CX                    ;COLOR = 3, store away bit #
    DEC    CX                    ;shift AH left one less than
    SHL    AH,CL                 ;  bit number we are on
    OR     AL,AH                 ;set output bit
    POP    CX                    ;get back bit number we're on

CGANextSet:
    LOOP   CGALoop1              ;do another bit in loop
    Push   DX
    Mov    DX,UseInverter
    Or     DX,DX
    Je     ByteCGAClrRet
    Not    AL
ByteCGAClrRet:
    Pop    DX
    RETN


;also does EGAMono and VGAMono and VGAColor
ByteEGAColor:
    MOV    CX, 4
    XOR    AX,AX
    PUSH   AX                    ;store blank screen
    PUSH   AX                    ;store first plane
    MOV    DI,WhichTable
    ADD    DI,InterNumber

EGALoop1:
    MOV    DX,03CEh              ;switch video planes
    MOV    AL, 4
    OUT    DX, AL
    INC    DX
    POP    AX                    ;retrieve stored value
    OUT    DX, AL
    INC    AX                    ;next plane
    MOV    DX,AX                 ;store plane in DL

    POP    AX                    ;previous screen value (AH)
    MOV    AL,ES:[BX]            ;value on screen
    AND    AL,[DI]               ;AND with pattern for plane
    OR     AH,AL                 ;OR with previous values
    PUSH   AX                    ;put back on stack (AH)
    PUSH   DX                    ;put plane on stack (DL)
    INC    DI                    ;next pattern
    LOOP   EGALoop1              ;loop 4 times

    POP    AX                    ;clean up stack
    POP    AX                    ;value to print (AL)
    MOV    AL, AH
    Push   DX
    Mov    DX,UseInverter
    Or     DX,DX
    Je     ByteEGAClrRet
    Not    AL
ByteEGAClrRet:
    Pop    DX
    RETN


PrntrOkay:                       ;check the status of the last Int 17h print
    Or   AH,10000000b            ;who cares if it's busy?
    And  AH,10111111b            ;ditto for the printer acknowledgment
    Cmp  AH,144                  ;see what happened
    Jnz  NoGood                  ;no good, bail out early
    RetN                         ;it was okay, return normally

NoGood:
    Mov  ErrCode, -1
    Jmp  AllDone                 ;an early exit is better than a hang any day

ScrnDump2 Endp

END

