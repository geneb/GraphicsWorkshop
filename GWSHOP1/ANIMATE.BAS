DEFINT A-Z
'$INCLUDE: 'GWDecl.BAS'
'$INCLUDE: 'COMMON.GW'

'*****************************************************************************
' ANIMATE.BAS by Carl Franklin
' Demonstrates how to animate 3 small PCX files.
'
' Notes:
'
'   ANIMATE will only work with three PCX files of maximum size 100x80x16
'   although with some tinkering, you could make it work with more than
'   three smaller files.  This involves making the ImgSize variable smaller
'   which will create more space in off-screen video memory.
'
'   Strange things will occur if two or more files overlap each other in
'   off-screen memory (such as blinking and garbage on the screen).  Also,
'   if Dest1 (the first PCX file's off-screen address) is too close to
'   on-screen memory, then you will get garbage accross the bottom of your
'   screen.
'
'   When creating PCX files to use with ANIMATE, make sure you leave at least
'   10 pixels of background color (black) completely around the image in
'   order to avoid leaving "trails" when moving.  Use the file DEFAULT.PCX
'   as a template when you start a drawing in your paint program, and stay
'   within the black borders as you draw.
'
'   When using Microsoft Windows Paintbrush to create PCX files, you should
'   set the "Image Attributes" from the OPTIOINS menu to be 100 pixels wide
'   by 80 pixels long.  Then select "New" from the file menu, or load
'   DEFAULT.PCX and use that as a starting point for your file (see above).
'
'   Also, when animating Windows Paintbrush-generated PCX files, you may see
'   invalid colors.  You can get around this inconvenience by doing the
'   following to each file with Windows Paintbrush:
'
'       1) Using the "Scissors" icon, cut the entire file out of itself.
'       2) Select "New" from the File menu (do not save the edited version!)
'       3) Paste the cut (Shift-Insert) into the new file.
'       4) Paint any lines that may be left on the right and lower sides.
'       5) Save the file under the original filename.
'
'   This program is meant to be a means to study how simple animation can
'   be done using the Graphics Workshop, and is not meant to be used in
'   it's original state from within an application.
'
'   The method of animation demonstrated in ANIMATE is "destructive", meaning
'   that the images are written to the screen without preserving the under-
'   lying image.
'
'*****************************************************************************

DECLARE SUB AddDelay ()
DECLARE SUB CheckKeyboard ()
DECLARE SUB ExitProgram ()
DECLARE SUB GetSize (FileName$, Horiz%, Vert%, MaxH%, MaxV%)
DECLARE SUB HandlePCXPalette (Array$, ScrMode%)
DECLARE SUB InitializePCXFile (FileName$, Destination%)
DECLARE SUB Move ()
DECLARE SUB MoveDown ()
DECLARE SUB MoveLeft ()
DECLARE SUB MoveRight ()
DECLARE SUB MoveUp ()
DECLARE SUB Pause (Milis%, Fudge&)
DECLARE SUB PDQRestore ()
DECLARE SUB PressAnyKey ()
DECLARE FUNCTION FudgeFactor& ()
DECLARE FUNCTION Parse$ (ParseString$)

COMMON SHARED Cols
COMMON SHARED Dest1
COMMON SHARED Dest2
COMMON SHARED Dest3
COMMON SHARED Dir
COMMON SHARED Esc$
COMMON SHARED FromCol
COMMON SHARED FromLine
COMMON SHARED Fudge&
COMMON SHARED Lines
COMMON SHARED MaxCol
COMMON SHARED MaxLine
COMMON SHARED Moving
COMMON SHARED Ticks

'**[ Determine the filenames of the three PCX files, and allocate space ]*****
   
    IF LEN(COMMAND$) > 1 THEN
        GOSUB ParseCommand              'Get filenames and video mode from the
    ELSE                                '    command line.
        GOSUB InputFilenames            'Ask for file names and video mode.
    END IF

    Size1& = GWFileSize&(FileName1$)    'SizeX& is reflected in number of Bytes
    Size2& = GWFileSize&(FileName2$)
    Size3& = GWFileSize&(FileName3$)

    IF Size1& = -1 THEN                 'SizeX& returns -1 if the file isn't
        PRINT FileName1$; " Not Found"  '    there.
        END
    ELSEIF Size2& = -1 THEN
        PRINT FileName2$; " Not Found"
        END
    ELSEIF Size3& = -1 THEN
        PRINT FileName3$; " Not Found"
        END
    END IF

'**[ Assign Variables ]******************************************************

    Esc$ = CHR$(27)
    Fudge& = FudgeFactor&   'A timing variable used by Pause.
    Ticks = 100             'Another timing variable.
    Cols = 13               'How many columns to move (for GWMove2VE).
    Lines = 77              'How many lines to move (for GWMove2VE).
    FromCol = 1             'Original column position (for GWMove2VE)
    FromLine = 1            'Original line position (for GWMove2VE)
    ImgSize = &H37          'Size of the image for determining off-screen addresses.
    Dest1 = &HA959          'Off-Screen video address of first PCX file.
                              'If this value is to small, the first image will
                              'overlap on the screen.
    Dest2 = Dest1 + ImgSize 'Off-Screen video address of second PCX file.
    Dest3 = Dest2 + ImgSize 'Off-Screen video address of third PCX file.
    SetGWPages 0, 0         'Use Page 0 only.
    Moving = 1              'We are moving. 0 means standing still
    Dir = 2                 'Direction=Down
    MaxH = 100              'Maximum horizontal resolution
    MaxV = 80               'Maximum vertical resolution
    MaxCol = 69             'Rightmost column given a 100x80 PCX file (for GWMove2VE)
  
    IF Vga THEN
        MaxLine = 400       'Bottommost line given a 100x80 PCX file (VGA)
        ScrMode = 12
    ELSE
        MaxLine = 280       'Bottommost line given a 100x80 PCX file (EGA)
        ScrMode = 9
    END IF

'***[ Load PCX Files ]*******************************************************
   
    SCREEN ScrMode                                  'Set the Video mode.
   
    InitializePCXFile FileName1$, Dest1             'Call initialize routine
    GetSize FileName1$, Horiz1, Vert1, MaxH, MaxV   '  which opens and
    InitializePCXFile FileName2$, Dest2             '  displays each file
    GetSize FileName2$, Horiz2, Vert2, MaxH, MaxV   '  using the palette of
    InitializePCXFile FileName3$, Dest3             '  the first PCX file.
    GetSize FileName3$, Horiz3, Vert3, MaxH, MaxV
  
MainLoop:

    DO
        IF Moving <> 0 THEN
            SELECT CASE Dir
                CASE 1 'up
                    FromLine = FromLine - 8     'Adjust Line (Y) up 8 pixels.
                    IF FromLine <= 1 THEN       'Smallest possible Line value
                        FromLine = 1            '   is 1.
                        Moving = 0
                    END IF
                CASE 2 'down
                    FromLine = FromLine + 8      'Add 8 lines to current (Y).
                    IF FromLine > MaxLine THEN   'Largest possible Line value
                        FromLine = MaxLine       '   is the MaxLine constant.
                        Moving = 0
                    END IF
                CASE 3 'left
                    FromCol = FromCol - 1                 'subtract 1 to move
                    IF FromCol <= 1 THEN Moving = 0       '1 column to left.
                CASE 4 'right
                    FromCol = FromCol + 1                 'add 1 to move 1
                    IF FromCol >= MaxCol THEN Moving = 0  'column to right.
            END SELECT
        END IF
        CheckKeyboard             'scan for user input.
        Move
    LOOP

'***[ GOSUB Routines ]***

ParseCommand: '******* Get info if user entered the file names and video mode.

    Cmd$ = UCASE$(COMMAND$)             'Convert command line to uppercase.
    EGA = INSTR(Cmd$, "/E ")            'Get video mode.
    Vga = INSTR(Cmd$, "/V ")
    IF EGA THEN                                           'remove video mode
        Cmd$ = LEFT$(Cmd$, EGA - 1) + MID$(Cmd$, EGA + 3) 'switch from command
    ELSEIF Vga THEN                                       'line.
        Cmd$ = LEFT$(Cmd$, Vga - 1) + MID$(Cmd$, Vga + 3)
    ELSE
        PRINT "Video Mode Not Specified - Use /E for EGA and /V for VGA"
        PRINT "For Example:  ANIMATE /V DEMO1 DEMO2 DEMO3"
        END
    END IF
     
      'Parse out each file name and add the ".PCX" extension to them
      'if the user didn't type it in.
   
    FileName1$ = UCASE$(Parse$(Cmd$))
    IF INSTR(FileName1$, ".PCX") < 1 THEN FileName1$ = FileName1$ + ".PCX"
   
    FileName2$ = UCASE$(Parse$(Cmd$))
    IF INSTR(FileName2$, ".PCX") < 1 THEN FileName2$ = FileName2$ + ".PCX"
   
    FileName3$ = UCASE$(Parse$(Cmd$))
    IF INSTR(FileName3$, ".PCX") < 1 THEN FileName3$ = FileName3$ + ".PCX"
   
    RETURN

InputFilenames: '******* Prompts the user for file names and video mode ******
       
    CLS
    PRINT "********************************************************************************"
    PRINT "ANIMATE - Crescent Software Graphics Workshop animation demo by Carl Franklin."
    PRINT
    PRINT "This program loads three PCX files (max size = 100x80) and animates them by"
    PRINT "consecutively moving them into display memory from off-screen video memory."
    PRINT "You can use any three PCX files, but they may only be as large as 100x80x16"
    PRINT "This is not meant to be an end-all animation program, but simply an example"
    PRINT "of how to use the GWMove2VE routine with flashy results."
    PRINT
    PRINT "You can run this program with the following syntax:"
    PRINT
    PRINT "         ANIMATE [[/E] [/V]] File1 File2 File3"
    PRINT
    PRINT "Where [/E] is for EGA and [/V] is for VGA."
    PRINT
    PRINT "Example: ANIMATE /V DEMO1 DEMO2 DEMO3"
    PRINT "********************************************************************************"
    PRINT
    PRINT
   
    DO
        PRINT "<E>GA or <V>GA? ";                       'Get Video Mode
        DO: Mode$ = INKEY$: LOCATE , , 1: LOOP UNTIL LEN(Mode$)
        Mode = ASC(Mode$)
        IF Mode = 27 THEN END                   'Escape was pressed
        IF Mode <> 13 THEN
            PRINT CHR$(Mode)
            ELSE PRINT
        END IF
        IF Mode = 69 OR Mode = 101 THEN         'e or E was pressed
            EGA = 1
            EXIT DO
        ELSEIF Mode = 86 OR Mode = 118 THEN     'v or V was pressed
            Vga = 1
            EXIT DO
        END IF
    LOOP
   
    LOCATE , , 0    'Turn Cursor Off
   
    PRINT "Enter PCX File #1 (Enter=DEMO1.PCX): ";
    LINE INPUT FileName1$                               'Get File name #1,
    FileName1$ = UCASE$(FileName1$)                     'convert to uppercase.
    IF LEN(FileName1$) < 1 THEN
        FileName1$ = "DEMO1.PCX"                        'default file.
    ELSE                                             'add ".PCX" if nessecary.
        IF INSTR(FileName1$, ".PCX") < 1 THEN FileName1$ = FileName1$ + ".PCX"
    END IF
   
  
    PRINT "Enter PCX File #2 (Enter=DEMO2.PCX): ";
    LINE INPUT FileName2$                         'see above for File Name #1
    FileName2$ = UCASE$(FileName2$)
    IF LEN(FileName2$) < 1 THEN
        FileName2$ = "DEMO2.PCX"
    ELSE
        IF INSTR(FileName2$, ".PCX") < 1 THEN FileName2$ = FileName2$ + ".PCX"
    END IF

    PRINT "Enter PCX File #3 (Enter=DEMO3.PCX): ";
    LINE INPUT FileName3$                         'see above for File Name #1
    FileName3$ = UCASE$(FileName3$)
    IF LEN(FileName3$) < 1 THEN
        FileName3$ = "DEMO3.PCX"
    ELSE
        IF INSTR(FileName3$, ".PCX") < 1 THEN FileName3$ = FileName3$ + ".PCX"
    END IF

         '********************** Ready to Go! ************************
   
    CLS
    PRINT "During the demo, you can:"
    PRINT
    PRINT "Move the animation using the ARROW keys"
    PRINT "Freeze the animation using the END key"
    PRINT "Speed Up the animation using the PLUS key"
    PRINT "Slow Down the animation using the MINUS key"
    PRINT "or Press ESCAPE to quit."
    PRINT
    PRINT "Press Any Key";
    DO: LOOP UNTIL LEN(INKEY$)
    PRINT
    RETURN

SUB AddDelay

     Pause Ticks, Fudge&
    
END SUB

SUB CheckKeyboard
   
    Pressed$ = INKEY$
    IF LEN(Pressed$) THEN                           'A key was pressed..
        IF LEN(Pressed$) = 2 THEN                   'Get Scan code if 2 chars
            Pressed = ASC(RIGHT$(Pressed$, 1))      ' (INKEY$ returns 2 chars
            ELSE Pressed = ASC(Pressed$)            ' if an extended key was
        END IF                                      ' pressed).
        SELECT CASE Pressed
            CASE 27                         'Escape key (quit)
                ExitProgram
            CASE 43                         'Plus key (increase speed)
                Ticks = Ticks - 10
                IF Ticks < 1 THEN Ticks = 1
            CASE 45                         'Minus key (decrease speed)
                Ticks = Ticks + 10
            CASE 72                         'Up arrow key (Move Up)
                Dir = 1
                IF FromLine > 8 THEN Moving = -1
            CASE 80                         'Down arrow key (Move Down)
                Dir = 2
                IF FromLine < MaxLine THEN Moving = -1
            CASE 75                         'Left arrow key (Move Left)
                Dir = 3
                IF FromCol > 1 THEN Moving = -1
            CASE 77                         'Right Arrow key (Move Right)
                Dir = 4
                IF FromCol < MaxCol THEN Moving = -1
            CASE 79                         'End key (Freeze Image)
                Moving = 0
        END SELECT
     END IF

END SUB

SUB ExitProgram

    SCREEN 0
    SYSTEM

END SUB

FUNCTION FudgeFactor&
   
    DEF SEG = 0
    Fudge& = 0
   
    OldTime = PEEK(&H46C)                       'Get current timer value.
    DO: LOOP UNTIL PEEK(&H46C) = OldTime + 1    'Wait until it changes...
   
    DO                                          'Count the number of loops
        Fudge& = Fudge& + 1                     'from one tick to the next.
    LOOP UNTIL PEEK(&H46C) = OldTime + 2
   
    Fudge& = Fudge& / 130                       'Adjust and return
    IF Fudge& < 0 THEN Fudge& = 0
    FudgeFactor& = Fudge&

END FUNCTION

SUB GetSize (FileName$, Horiz%, Vert%, MaxH%, MaxV%)

    IF MaxH = 0 OR MaxV = 0 THEN
        MaxH = 640
        MaxV = 350
    END IF
   
    FileNum = FREEFILE
    HiByte13$ = " "                         'Initialize four bytes as spaces.
    LoByte13$ = HiByte13$
    HiByte15$ = HiByte13$
    LoByte15$ = HiByte13$
   
    OPEN FileName$ FOR BINARY AS FileNum
        GET #FileNum, 9, HiByte13$          'Get Bytes 9, 10, 11, and 12 of
        GET #FileNum, , LoByte13$           'PCX file.  These bytes specify
        GET #FileNum, 11, HiByte15$         'screen resolution of the PCX
        GET #FileNum, , LoByte15$           'file.
    CLOSE FileNum

    Horiz = CVI((HiByte13$) + LoByte13$) + 1      'Do a little byte swapping
    Vert = CVI((HiByte15$) + LoByte15$) + 1       'to produce the horizontal
                                                  'and vertical resolution
                                                  '(base 1).
   
    IF Horiz > MaxH OR Vert > MaxV THEN                 'error checking
        PRINT FileName$; " is "; Horiz; "x"; Vert
        PRINT "Maximum file size is "; MaxH; "x"; MaxV
        END
    END IF

END SUB

SUB HandlePCXPalette (Array$, WhichScreen) STATIC
 
  PCXVersion = ASC(MID$(Array$, 2, 1))
  IF PCXVersion <> 2 AND PCXVersion <> 5 THEN EXIT SUB

  i = 17
  IF WhichScreen = 9 THEN i = 69

  IF WhichScreen = 8 THEN
    IF GPDat%(31) = 5 THEN
      FOR T = 0 TO 15
    N = 0
    a = ASC(MID$(Array$, i, 1)) \ 64
    IF (a AND 1) = 1 THEN N = N + 32
    IF (a AND 2) = 2 THEN N = N + 4
    i = i + 1
    b = ASC(MID$(Array$, i, 1)) \ 64
    IF (b AND 1) = 1 THEN N = N + 16
    IF (b AND 2) = 2 THEN N = N + 2
    i = i + 1
    c = ASC(MID$(Array$, i, 1)) \ 64
    IF (c AND 1) = 1 THEN N = N + 8
    IF (c AND 2) = 2 THEN N = N + 1
    i = i + 1
    CALL SetPaletteEGA(T, N)
      NEXT
    ELSE
      FOR T = 0 TO 15
    CALL SetPaletteEGA(T, T)
      NEXT
      FOR T = 0 TO 15
    a = ASC(MID$(Array$, i, 1)) \ 4
    i = i + 1
    b = ASC(MID$(Array$, i, 1)) \ 4
    i = i + 1
    c = ASC(MID$(Array$, i, 1)) \ 4
    i = i + 1
    CALL SetPalTripleVGA(T, a, b, c)
      NEXT
    END IF
  ELSEIF WhichScreen = 5 THEN
    FOR T = 0 TO 15
      N = 0
      a = ASC(MID$(Array$, i, 1)) \ 64
      IF (a AND 1) = 1 THEN N = N + 32
      IF (a AND 2) = 2 THEN N = N + 4
      i = i + 1
      b = ASC(MID$(Array$, i, 1)) \ 64
      IF (b AND 1) = 1 THEN N = N + 16
      IF (b AND 2) = 2 THEN N = N + 2
      i = i + 1
      c = ASC(MID$(Array$, i, 1)) \ 64
      IF (c AND 1) = 1 THEN N = N + 8
      IF (c AND 2) = 2 THEN N = N + 1
      i = i + 1
      CALL SetPaletteEGA(T, N)
    NEXT
  ELSEIF WhichScreen = 9 THEN
    FOR T = 0 TO 255
      a = ASC(MID$(Array$, i, 1)) \ 4
      i = i + 1
      b = ASC(MID$(Array$, i, 1)) \ 4
      i = i + 1
      c = ASC(MID$(Array$, i, 1)) \ 4
      i = i + 1
      CALL SetPalTripleVGA(T, a, b, c)
    NEXT
  END IF

END SUB

SUB InitializePCXFile (FileName$, Destination%) STATIC
   
    IF NotFirstTime = 0 THEN Header$ = SPACE$(68 + 768)
   
'Open the file.
    Success = OpenPCXFile(FileName$, Header$)
   
'error checking
    IF NOT Success THEN
        SCREEN 0
        PRINT "Error Getting Header for "; FileName$
        END
    END IF
   
'If this is the first pass, get palette information.
    IF NotFirstTime = 0 THEN HandlePCXPalette Header$, ScrMode
   
'Display the file.
    CALL DispPCXVE(BYVAL 0)
   
'Move image to off screen video memory.
    CALL GMove2VE(BYVAL 0, BYVAL 1, BYVAL Cols, BYVAL Lines, BYVAL Destination, BYVAL 0)
    
    NotFirstTime = 1

END SUB

SUB Move
 
    'In the sequence, (File1, File2, File3, File2) do the following:
    '1) Move the PCX file from off screen memory to current column
    '       (FromCol) and line (FromLine).
    '2) Pause for a time adjustable with the PLUS and MINUS keys.
   
    'This routine can be modified (along with the AddDelay sub, to produce
    'different effects.  Try experimenting with them.

    CALL GMove2VE(BYVAL FromCol, BYVAL FromLine, BYVAL Cols, BYVAL Lines, BYVAL Dest1, BYVAL -1)
    AddDelay
    CheckKeyboard
   
    CALL GMove2VE(BYVAL FromCol, BYVAL FromLine, BYVAL Cols, BYVAL Lines, BYVAL Dest2, BYVAL -1)
    AddDelay
    CheckKeyboard

    CALL GMove2VE(BYVAL FromCol, BYVAL FromLine, BYVAL Cols, BYVAL Lines, BYVAL Dest3, BYVAL -1)
    AddDelay
    CheckKeyboard
   
    CALL GMove2VE(BYVAL FromCol, BYVAL FromLine, BYVAL Cols, BYVAL Lines, BYVAL Dest2, BYVAL -1)
    AddDelay
    CheckKeyboard

    EXIT SUB

END SUB

FUNCTION Parse$ (ParseString$) STATIC

'This function returns the next word (as being separated by spaces) from the
'string ParseString$.

    Temp$ = ""
    
    IF NotFirstPass = 0 THEN                            'Initialize pointer
        NextPos = 1                                     ' to 1.
        StrLen = LEN(ParseString$)
    END IF
   
    FOR i = NextPos TO StrLen
        IF i = StrLen THEN                              'At end of string?
            Parse$ = Temp$ + RIGHT$(ParseString$, 1)    'Set Char$ to be the
            ELSE Char$ = MID$(ParseString$, i, 1)       ' last character of
        END IF                ' the string.  Otherwise, set the next character.
        IF ASC(Char$) = 32 THEN                         'Space?
            Parse$ = Temp$                              ' stop here.
            NextPos = i + 1
            EXIT FOR
        ELSE
            Temp$ = Temp$ + Char$                       'Add selected character
        END IF                                          ' to returned string.
    NEXT
   
    NotFirstPass = 1

END FUNCTION

SUB Pause (Milis%, Fudge&)

    FOR i& = 1 TO Milis * Fudge&
    NEXT i&

END SUB

SUB WhichPCXScreen (Array$, WhichScreen) STATIC

  Manufacturer = ASC(MID$(Array$, 1, 1))
  PCXVersion = ASC(MID$(Array$, 2, 1))

  Compression = ASC(MID$(Array$, 3, 1))
  BitsPerPixel = ASC(MID$(Array$, 4, 1))

  XMin = CVI(MID$(Array$, 5, 2))          'Image locations
  YMin = CVI(MID$(Array$, 7, 2))
  XMax = CVI(MID$(Array$, 9, 2))
  YMax = CVI(MID$(Array$, 11, 2))

  XSize = CVI(MID$(Array$, 13, 2))        'Monitor Display Size
  YSize = CVI(MID$(Array$, 15, 2))

  NumPlanes = ASC(MID$(Array$, 66, 1))    'Number of video planes
  BytesPerLine = CVI(MID$(Array$, 67, 2)) 'Bytes Per Line

  'Determine Monitor Needed
  IF (XMax - XMin + 1) = 320 OR XSize = 320 THEN
    IF BitsPerPixel = 8 THEN
      WhichScreen = 9
    ELSE
      WhichScreen = 4
    END IF
  ELSEIF (XSize = 720) OR (XMax - XMin + 1) = 720 THEN
    WhichScreen = 2
  ELSEIF (XSize = 640) OR (XMax - XMin + 1) = 640 THEN
    IF (YSize = 200) OR (YMax - YMin + 1) = 200 THEN
      WhichScreen = 6
    ELSEIF (YSize = 350) OR (YMax - YMin + 1) <= 350 THEN
      WhichScreen = 5
    ELSEIF (YSize = 480) OR (YMax - YMin + 1) <= 480 THEN
      WhichScreen = 8
    END IF
  END IF

  IF WhichScreen = 0 THEN
    IF NumPlanes > 1 THEN WhichScreen = 8 ELSE WhichScreen = 6
    IF BitsPerPixel = 2 THEN WhichScreen = 4
    IF BitsPerPixel = 8 THEN WhichScreen = 9
  END IF


END SUB

