'**************  PCXCap.Bas - PCX\Graphic Screen Capture TSR

'   Copyright (c) 1991 Crescent Software
'   Written by Nash Bly

'   PCXCAP is a simplified PopUp TSR whose Hot Key is ALT-S.  It combines
'   Graphics Workshop and PDQ routines to capture Hercules, CGA, EGA, and
'   VGA screens and saves them to a PCX file.  EGA and VGA screen files
'   include palette information.  Only the high resolution EGA and VGA
'   screens (SCREEN 9 Thru 13) can be captured.

'   When the Hot Key is pressed, the top line of the screen is saved in
'   memory and a file name prompt is given.  Users enter a file name without
'   an extension.  The screen is then restored and saved to disk.  PCXCap
'   will only pop up when a supported screen mode is active.
'
'   Critical error handling is disabled before any file operations take place
'   and re-enabled after they are complete.  This is important within a TSR
'   because improper return of control may result from the DOS critical error
'   handler.  Also note that the _NOVAL stub file is used, and this is also
'   important for the proper operation of a TSR.
'
'   PCXCAP must be compiled to disk before it can be run:
'
'   BC PCXCAP /O/S;
'   LINK /NOD/NOE/EX/FAR/PACKC PCXCAP _NOERROR _NOREAD _NOVAL STR01024,, NUL, SMALLDOS PDQ GW
'
'   Please see the Graphics Workshop VIEWPCX demonstration program for the
'   correct methods to display the screens saved with PCXCAP.  If you have
'   a color monitor, SCREEN 10 will still work but you will need to manually
'   set the screen mode before displaying the screen.


DEFINT A-Z

'-------- Declare PDQ extensions

DECLARE FUNCTION AllocMem% (NumBytes)
DECLARE FUNCTION BIOSInkey% ()
DECLARE FUNCTION CursorSave& ()
DECLARE FUNCTION PDQPeek2% (Address)
DECLARE FUNCTION PopDeinstall% (Segment, ID$)
DECLARE FUNCTION TSRInstalled% (ID$)
DECLARE SUB BlockCopy (FromSeg, FromAdr, ToSeg, ToAdr, NumBytes)
DECLARE SUB CritErrOff ()
DECLARE SUB CritErrOn ()
DECLARE SUB CursorRest (CursorMem&)
DECLARE SUB EndTSR (ID$)
DECLARE SUB Interrupt (IntNumber, Registers AS ANY)
DECLARE SUB PDQPoke2 (Address, Value)
DECLARE SUB PDQSound (Freq, Duration)
DECLARE SUB PopDown ()
DECLARE SUB PopUpHere (HotKey, ID$)

'-------- Declare Graphics Workshop routines

DECLARE SUB GetPalTripleVGA (BYVAL PalReg, Red, Green, Blue)
DECLARE SUB SavePCXC (FileName$)
DECLARE SUB SavePCXH (FileName$)
DECLARE SUB SavePCXVE (FileName$)
DECLARE SUB SavePCXV256 (FileName$)

'-------- Initialize type variable for call interrupt

TYPE RegType
     AX        AS INTEGER
     BX        AS INTEGER
     CX        AS INTEGER
     DX        AS INTEGER
     BP        AS INTEGER
     SI        AS INTEGER
     DI        AS INTEGER
     Flags     AS INTEGER
     DS        AS INTEGER
     ES        AS INTEGER
     SS        AS INTEGER
     SP        AS INTEGER
     BusyFlag  AS INTEGER
     Address   AS INTEGER
     Segment   AS INTEGER
     ProcAdr   AS INTEGER
     ProcSeg   AS INTEGER
     IntNum    AS INTEGER
END TYPE

'-------- Dimension Static Variables

DIM Registers AS RegType                        'used for call interrupt
DIM RGB(2)                                      'small array for RGB values
DIM PAL AS STRING * 48                          '17 byte palette buffer
DIM RAMTable(1 TO 14)                           '28 byte table of 7 pointers
DIM RAMArea(1 TO 128)                           '256 byte area of EGA data

'-------- Start of Execution

    ID$ = "PCXCAP 1.10 Copyright (c) 1991 Crescent Software"
    PRINT ID$                                   'always assign ID$ first
   
    EGASeg = &HA000                             'an often-used integer
    EOF$ = CHR$(26)                             'and string character
    Pointer = &H4A8                             'locates a ROM pointer table

'-------- Install, UnInstall and Help

    Segment = TSRInstalled%(ID$)                'get the installed segment
                                              
    Switch$ = UCASE$(COMMAND$)                  'get command line switch
    IF LEN(Switch$) = 0 THEN                    'if no switch then install
        IF Segment <> 0 THEN                    'if already installed then
            PRINT "PCXCAP is Already Installed" 'display a message and
            PRINT "Use PCXCAP /U to Uninstall"  'uninstall instructions
            PRINT "Press Alt-S to pop up."      'very beginning of a TSR
            END                                 'then end
        END IF
    ELSEIF Switch$ = "/U" THEN                  'if uninstall switch then
        IF Segment THEN                         'if the segment is not 0 then
            DEF SEG = Segment                   'look at the TSR segment
            ROMAdd = PDQPeek2%(VARPTR(ROMAdd))  'get the original ROM table
            ROMSeg = PDQPeek2%(VARPTR(ROMSeg))  'address saved earlier
            DEF SEG = 0                         'ready to peek at low memory
            PDQPoke2 Pointer, ROMAdd            'change low mem pointer to
            PDQPoke2 Pointer + 2, ROMSeg        'to original ROM address
            Success = PopDeinstall(Segment, ID$)'attempt deinstallation
            IF Success THEN                     'if successful then display
                PRINT "PCXCAP Removed from Memory"         'a success message
            ELSE                                           'otherwise display
                PRINT "Error Uninstalling - Please Reboot" 'an error message
            END IF                                         'if not installed
        ELSE                                               'display a message
            PRINT "PCXCAP Is Not Resident and Cannot be Uninstalled"
        END IF                                             'and end
        END
    ELSE                                               'if any other switch
        PRINT "PCXCAP - Usage:    Install - PCXCAP"    'then display a help
        PRINT "                 UnInstall - PCXCAP /U" 'message for user
        END                                            'and end
    END IF

'-------- Initialize storage for temporary screen save

    ArraySize = 2560                        'memory required to save one line
    BlueSeg = AllocMem%(ArraySize)          'in VGA screen mode 13
    GreenSeg = AllocMem%(ArraySize)         'more than enough for other
    RedSeg = AllocMem%(ArraySize)           'screen modes.  Need four planes
    IntenSeg = AllocMem%(ArraySize)         'for EGA and VGA screens.

'-------- Setup means to read EGA palette

    DEF SEG = 0                                 'low mem address &H4A8
    ROMAdd = PDQPeek2%(Pointer)                 'get ROM table address
    ROMSeg = PDQPeek2%(Pointer + 2)             'get ROM table segment

    RAMAdd = VARPTR(RAMTable(1))                'get RAM table address
    RAMSeg = VARSEG(RAMTable(1))                'get RAM table segment

    BlockCopy ROMSeg, ROMAdd, RAMSeg, RAMAdd, 28'copy ROM table to RAM table

    RAMTable(3) = VARPTR(RAMArea(1))            'set pointer in our RAM table
    RAMTable(4) = VARSEG(RAMArea(1))            'to the RAM area for EGA data

    PDQPoke2 Pointer, RAMAdd                    'change low mem pointer to
    PDQPoke2 Pointer + 2, RAMSeg                'to our new RAM table

    PRINT "PCXCAP is Resident in Memory"        'print installation message
    PRINT "Press Alt-S to pop up."

'-------- Setup Hot key and TSR entry point

    HotKey = &H81F                          'Alt-S is the Hot Key
    PopUpHere HotKey, ID$                   'set the Hot Key entry point
    GOTO EndIt                              'jump to finish installation

'-------- Determine the video mode          'start of resident program

    Registers.AX = &HF00                    'AH = Service 0Fh, Get Video Mode
    CALL Interrupt(&H10, Registers)         'BIOS Video Interrpt 10H
    VideoMode = Registers.AX MOD 256        'AL returns BIOS video mode

'-------- Save a one-line window and save some screen info

    MonSeg = &HB800                             'assume CGA color segment
    SELECT CASE VideoMode                       'video mode actions
    CASE 0 TO 3, 7                              'Text Screens
        PDQSound 2500, 2                        'sound a nice beep
        PopDown                                 'we do nothing
    CASE 4, 5, 6                                'CGA Graphic Screens
        IF VideoMode = 6 THEN                   'if BIOS video mode is 6
            ScrnMode = 2                        'SCREEN 2
            NumBytes = 640                      'bytes to save for a window
        ELSE                                    'if BIOS video mode 4 or 5
            ScrnMode = 1                        'SCREEN 1
            NumBytes = 320                      'bytes to save for a window
        END IF                                  'save window, CGA interlaced
        BlockCopy MonSeg, Zero, BlueSeg, Zero, NumBytes   'so save twice with
        BlockCopy MonSeg, &H2000, GreenSeg, Zero, NumBytes'an 8K offset
    CASE 8                                      'Hercules Graphic Screen
        MonSeg = &HB000                         'mono hercules segment
        ScrnMode = 3                            'SCREEN 3
        NumBytes = 360                          'bytes to save for a window
        BlockCopy MonSeg, Zero, BlueSeg, Zero, NumBytes   'Herc is interlaced
        BlockCopy MonSeg, &H2000, GreenSeg, Zero, NumBytes'into 4 blocks so we
        BlockCopy MonSeg, &H4000, RedSeg, Zero, NumBytes  'save from 4 places
        BlockCopy MonSeg, &H6000, IntenSeg, Zero, NumBytes'with 8K offsets
    CASE 13, 14                                 'EGA Screens 7,8
        PDQSound 2500, 2                        'sound a nice beep
        PopDown                                 'not supported so exit
    CASE 15, 16                                 'EGA Graphic Screens
        IF VideoMode = 15 THEN                  'If BIOS video mode 15
            ScrnMode = 10                       'SCREEN 10
        ELSE                                    'if BIOS video mode 16
            ScrnMode = 9                        'SCREEN 9
        END IF
        NumBytes = 1120                         'bytes to save for a window
        Size& = 28000                           'bytes to save entire screen
        GOTO EGASave                            'save window
    CASE 17, 18                                 'VGA Graphic Screens
        IF VideoMode = 17 THEN                  'if BIOS video mode 17
            ScrnMode = 11                       'SCREEN 11
        ELSE                                    'if BIOS video mode 18
            ScrnMode = 12                       'SCREEN 12
        END IF
        NumBytes = 1280                         'bytes to save window
        Size& = 38400                           'bytes to save entire screen
        GOTO EGASave                            'save window
    CASE 19                                     'VGA Screen 13
        ScrnMode = 13                           'SCREEN 13
        NumBytes = 2560                         'bytes to save window
        Size& = 64000                           'bytes to save entire screen
        GOTO EGASave                            'save window
    CASE ELSE                                   'some new unsupported mode?
        PDQSound 2500, 2                        'sound a nice beep
        GOTO PopDone                            'we do nothing but exit
    END SELECT

'-------- Input file name

EnterName:
    CursorMem& = CursorSave&                        'save cursor postion
    LOCATE 1, 1                                     'locate at top of screen
    PRINT "Enter a name for the screen:  --------  "; 'display a prompt
    MaxLen = 8: Text$ = STRING$(MaxLen, 32)         'init edit parameters
    GOSUB UserInput                                 'input filename
    FileName$ = RTRIM$(Text$)                       'trim input name
    CursorRest CursorMem&                           'restore cursor postion

'-------- Restore window saved above

    SELECT CASE ScrnMode                            'the opposite of saving
    CASE 1, 2                                       'the top screen line
        BlockCopy BlueSeg, Zero, MonSeg, Zero, NumBytes
        BlockCopy GreenSeg, Zero, MonSeg, &H2000, NumBytes
    CASE 3
        BlockCopy BlueSeg, Zero, MonSeg, Zero, NumBytes
        BlockCopy GreenSeg, Zero, MonSeg, &H2000, NumBytes
        BlockCopy RedSeg, Zero, MonSeg, &H4000, NumBytes
        BlockCopy IntenSeg, Zero, MonSeg, &H6000, NumBytes
    CASE 9 TO 13
        OUT &H3C4, 2: OUT &H3C5, 1
        BlockCopy BlueSeg, Zero, EGASeg, Zero, NumBytes
        OUT &H3C4, 2: OUT &H3C5, 2
        BlockCopy GreenSeg, Zero, EGASeg, Zero, NumBytes
        OUT &H3C4, 2: OUT &H3C5, 4
        BlockCopy RedSeg, Zero, EGASeg, Zero, NumBytes
        OUT &H3C4, 2: OUT &H3C5, 8
        BlockCopy IntenSeg, Zero, EGASeg, Zero, NumBytes
        OUT &H3C4, 2: OUT &H3C5, 15
    CASE ELSE: END SELECT

    IF Ky = 27 GOTO PopDone                         'exit if escape pressed
    IF LEN(FileName$) = 0 GOTO PopDone              'exit if no name given
    IF INSTR(FileName$, ".") GOTO PopDone           'exit if extension given

'-------- Save Screen to Disk

    CritErrOff                                      'disable crit err handling
    FileName$ = FileName$ + ".PCX"                  'add filname extension
    SELECT CASE ScrnMode                            'check screen mode
    CASE 1, 2                                       'CGA screen modes
        SavePCXC FileName$                          'save CGA PCX file
    CASE 3                                          'Hercules screen
        SavePCXH FileName$                          'save Herc PCX file
    CASE 9 TO 12                                    'EGA/VGA screen modes
        SavePCXVE FileName$                         'save EGA/VGA PCX file
    CASE 13                                         '256 color VGA screen
        SavePCXV256 FileName$                       'save 256 color PCX file
        GOTO PopDone                                'skip save palette
    CASE ELSE: END SELECT

'-------- Add EGA/VGA palette information to PCX file

    OPEN FileName$ FOR BINARY AS #1             'open PCX file
    SEEK #1, 17                                 'seek to the palette section
    SELECT CASE ScrnMode                        'check the screen mode
    CASE 9, 10                                  'EGA screens
        K = 1
        DEF SEG = RAMTable(4)                   'set segment to EGA data area
        FOR I = 0 TO 15                         'for each of the 16 palettes
            PalReg = PEEK(RAMTable(3) + I)                  'read palette byte
            RGB(0) = (PalReg AND 4) \ 2 + (PalReg AND 32) \ 32  'parse red
            RGB(1) = (PalReg AND 2) + (PalReg AND 16) \ 16      'parse green
            RGB(2) = (PalReg AND 1) * 2 + (PalReg AND 8) \ 8    'parse blue
            FOR J = 0 TO 2                      'store a byte for R,G, and B
                MID$(PAL, K) = CHR$(RGB(J) * 64)'whose value ranges 0 to 255
                K = K + 1                       'using a scaling factor of 64
            NEXT
        NEXT
        PUT #1, , PAL                           'drop in our palette data
    CASE 11, 12                                 'VGA screens
        K = 1
        FOR I = 0 TO 15                         'for each of the 16 palettes
            GetPalTripleVGA I, RGB(0), RGB(1), RGB(2)   'read the VGA palette
            FOR J = 0 TO 2                      'store a byte for R, G, and B
                MID$(PAL, K) = CHR$(RGB(J) * 4) 'whose value ranges 0 to 255
                K = K + 1                       'using a scaling factor of 4
            NEXT
        NEXT
        PUT #1, , PAL                           'drop in our palette data
    CASE ELSE: END SELECT
    CLOSE #1                                    'close the file

'-------- Return to underlying program

PopDone:

    CritErrOn                                   'enable crit err handling
    PopDown                                     'before returning

'-------- Exit but stay resident

EndIt:

    EndTSR ID$

'***************************************************************************
'*****************************  Subroutines  *******************************
'***************************************************************************

'-------- Save a portion of EGA/VGA Screen

EGASave:

    DEF SEG = EGASeg                                'set the proper segment
    OUT &H3CE, 4: OUT &H3CF, 0                      'and save the 4 planes
    BlockCopy EGASeg, Zero, BlueSeg, Zero, NumBytes 'of the top line to our
    OUT &H3CE, 4: OUT &H3CF, 1                      'memory storage area
    BlockCopy EGASeg, Zero, GreenSeg, Zero, NumBytes
    OUT &H3CE, 4: OUT &H3CF, 2
    BlockCopy EGASeg, Zero, RedSeg, Zero, NumBytes
    OUT &H3CE, 4: OUT &H3CF, 3
    BlockCopy EGASeg, Zero, IntenSeg, Zero, NumBytes
    OUT &H3CE, 4: OUT &H3CF, 0
    GOTO EnterName

'-------- Graphic Mode Keyboard Input

UserInput:

    LOCATE 1, 31                                    'locate at start of field
    Curpos = 1                                      'cursor position counter
    DO                                              'character input loop
        Ky = BIOSInkey%                             'get a key press
        SELECT CASE Ky                              'actions for the key press
        CASE 33 TO 126                              'if a normal key press
            IF Curpos <= MaxLen THEN                'if not past end of field
                MID$(Text$, Curpos, 1) = CHR$(Ky)   'add the char to string
                LOCATE , 30 + Curpos                'position the cursor
                PRINT CHR$(Ky);                     'print the character
                Curpos = Curpos + 1                 'increment cursor counter
            ELSE                                    'if past end of field
                PDQSound 2500, 2                    'sound a nice beep
            END IF
        CASE 8                                      'if key is backspace
            IF Curpos > 1 THEN                      'if not at start of field
                Curpos = Curpos - 1                 'decrement cursor counter
                MID$(Text$, Curpos, 1) = " "        'remove char from string
                LOCATE , 30 + Curpos                'position the cursor
                PRINT "-";                          'display a dash character
                LOCATE , 30 + Curpos                'reposition the cursor
            END IF
        CASE ELSE
        END SELECT                                  'loop until CR or ESC key
    LOOP UNTIL Ky = 13 OR Ky = 27
    RETURN

