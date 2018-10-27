'**** Font64.BAS - Vector Font Editor

'Copyright 1990 Brian C. Giedt, Modified by Phil Cramer 4/92
'
' To Compile FONT64.EXE use:
'
' BC FONT64/O;
' BC DRAWTEXT/O;
' BC EDITOR/O;
' BC PULLDOWN/O;
' BC FILLPOLY/O;
' BC SETVIDEO/O;
' BC GPAINTBX/O;
' BC MSGBOX/O;
' LINK /E /NOE FONT64+DRAWTEXT+EDITOR+PULLDOWN+FILLPOLY+SETVIDEO+GPAINTBX+MSGBOX,,NUL,GW.LIB;

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB ClearDiffSizes ()
DECLARE SUB DisplayMessage (Message$)
DECLARE SUB FillPoly (A%, B%, C%, d%, e%, f%, g%, H%, Colr%)
DECLARE SUB Capture (A$)
DECLARE SUB MoveCursor (X%, Y%, i%)
DECLARE SUB UpDateLines (X1%, Y1%, X2%, Y2%, Colr%)
DECLARE SUB UpDatePaint (X%, Y%, Colr%)


DECLARE SUB GetInput (Row%, Col%, Prompt$, Edit$, KeyCode%)
DECLARE SUB GEditor (Edit$, LeftCol%, KeyCode%, TxtPos%)
DECLARE SUB DrawBaseLine (Clr%)


DIM Lx1(200), Ly1(200), Lx2(200), Ly2(200), Lu(200)
DIM Mx1(200), My1(200), Mp1(200), Mp2(200)
DIM Px(30), Py(30), Pc(30)

'---- Coordinates of editing grid
DIM SHARED EditX1, EditY1, EditX2, EditY2, BaseLine, HSpace, VSpace, BGClr, SampleFont

'$INCLUDE: 'GetVideo'           'gets monitor type, and EGA memory
				'GetVideo also contains COMMON and SHARED
				'  declarations needed to make certain key
				'  variables available in the subprograms

EuroGPFonts% = -1
'$INCLUDE: 'GPFont.GW'
FontFile$ = "Helv12"
CALL SetGPFont(1)             'specify loading font number 1
CALL LoadFont(FontFile$)      'load fonts from disk into the Font$() array

EuroGWFonts% = -1
'$INCLUDE: 'GWFont.GW'
'In this program it is not necessary to load an Outline font at this time, as
'this program is the font editor for outline fonts.

IF GPDat%(31) = 8 THEN GPDat%(31) = 5
IF GPDat%(31) <> 5 THEN
   PRINT "Font64 requires at least an EGA display"
   END
END IF

CALL SetVideo

InitMouse There            'Initialize the mouse driver
GPDat(74) = 7 * 256
GPDat(75) = GPDat(74)
GPDat(76) = GPDat(74)
GPDat(57) = 1

EditX1 = 15  '1
EditY1 = 20  '21
EditX2 = EditX1 + 256
EditY2 = EditY1 + 256'277
HSpace = 16
VSpace = 16
BGClr = 1
SampleFont = -1

BotRow = 25
EditCol = 1
Edit$ = SPACE$(70)
H$ = SPACE$(80)
Curr$ = SPACE$(17)

'---- Alt Key translation table
CONST AltChars$ = "1234567890     QWERTYUIOP    ASDFGHJKL     ZXCVBNM"

GOSUB ClearFont

LINE (0, 0)-(2, 2), 14, B               'Create the square cursor
DIM Cursor(100)
GET (0, 0)-(2, 2), Cursor
PUT (0, 0), Cursor, XOR

'---- Draw the background
'CALL SetPaletteEGA(1, 16)
LINE (0, 0)-(GPDat(43) - 1, GPDat(44) - 1), BGClr, BF
LINE (EditX1 - 1, EditY1 - 1)-(EditX2 + 2, EditY2 + 1), 15, B
CALL GPrint0VE(BotRow, 1, H$, GPDat(74))

CALL SetGPFont(1)

'---- Clear the sample boxes
CALL ClearDiffSizes

'----- Define the Menu Choices here
REDIM Stat(12, 3)                       'define the choice status array

REDIM Choice$(12, 3)                    'Allocate space for the Menu Choices
RESTORE MenuData
FOR C = 0 TO 12                         'read the Menu Choices into the Array
    FOR M = 0 TO 3
	READ Choice$(C, M)              'read the list of choices
    NEXT
NEXT

MenuData:
DATA "File",            "Edit",           "Draw",          "Help"
DATA "New Font",        "Pick Character", "Line Draw",     ""
DATA "Open Font...",    "Pick ASCII",     "Connect Ends",  ""
DATA "Save Font",       "Duplicate",      "End Line Draw", ""
DATA "Save As...",      "-",              "Paint Draw",    ""
DATA "-",               "Move Lines",     "-",             ""
DATA "Simulate Font...","Move Paint",     "Set Baseline",  ""
DATA "-",               "Delete Paint",   "-",             ""
DATA "DOS Shell",       "-",              "Redraw Letter", ""
DATA "-",               "Delete Segment", "",              ""
DATA "Exit",            "Break Segment",  "",              ""
DATA "",                "-",              "",              ""
DATA "",                "Clear Character","",             ""

'---- Define menu help strings
REDIM HelpMsg$(12, 3)

HelpMsg$(0, 0) = "Loads, Saves or clears the current font. Exits the program or shells to DOS"
HelpMsg$(1, 0) = "Clears the current font from memory and allows you create a new font"
HelpMsg$(2, 0) = "Open an existing font file. The default extension is .QFN"
HelpMsg$(3, 0) = "Save the current font to disk. The default extension is .QFN"
HelpMsg$(4, 0) = "Lets you save the current font under a new name"
HelpMsg$(6, 0) = "Loads a Graphpak (.GFN) font file to use as a reference"
HelpMsg$(8, 0) = "Exits to DOS while Font64 remains in memory. Type EXIT to return from DOS"
HelpMsg$(10, 0) = "Ends the program and returns to DOS"

HelpMsg$(0, 1) = "Selects procedures for editing the current character"
HelpMsg$(1, 1) = "Selects a character for editing and displays a reference character"
HelpMsg$(2, 1) = "Selects a character for editing without displaying a reference character"
HelpMsg$(3, 1) = "Displays a different reference character without changing the ASCII value"
HelpMsg$(5, 1) = "Repositions line segments. Place cursor over an intersection and press Enter"
HelpMsg$(6, 1) = "Repositions paint points. Place the cursor over a paint point and press Enter"
HelpMsg$(7, 1) = "Deletes a paint point. Place the cursor over a paint point and press Enter"
HelpMsg$(9, 1) = "Removes an existing line segment. Use the spacebar to select the segment"
HelpMsg$(10, 1) = "Breaks an existing line segment. Use the spacebar to select the segment"
HelpMsg$(12, 1) = "Clears the current character's font definition"

HelpMsg$(0, 2) = "Selects procedures for creating a new font definition"
HelpMsg$(1, 2) = "Enables line drawing. Position the cursor and press F2 to draw a line"
HelpMsg$(2, 2) = "Connects the current end point to the starting point. Ends line drawing"
HelpMsg$(3, 2) = "Terminates line drawing mode"
HelpMsg$(4, 2) = "Draws a paint point at the current cursor position"
HelpMsg$(6, 2) = "Positions the baseline at the current cursor position"
HelpMsg$(8, 2) = "Redraws the current character and cleans up the editing grid"

HelpMsg$(0, 3) = "Displays a help window"

Menu = 0                  'start PullDown by displaying Menu 1
Choice = 0                'start with Choice #1 highlighted

CALL BarPrintG(Choice$(), GPDat%(74))
CALL GPrint0VE(1, 40, "(  0,   0)", GPDat%(74))
A$ = " "
CALL Capture(A$)
HBGClr = BGClr

'---- Draw help text
CALL GPrint0VE(22, 2, "F1 - Help        F2 - Draw Line   F3 - Connect Line  F4 - End Line  F5 - Paint", 7 + HBGClr * 256)
CALL GPrint0VE(23, 2, "F6 - Move Lines  F7 - Pick Char   F8 - Redraw        F9 - Save      F10 - Menu", 7 + HBGClr * 256)
LINE (4, 21 * GPDat(71) - 2)-(636, 23 * GPDat(71)), 7, B

X = 0
Y = 0

ChangesMade = 0
Running = -1
NumTicks& = PDQTimer&

ShowCursor                 'Show the mouse cursor

WHILE Running
    i$ = ""
    i$ = INKEY$

    GetCursor MouseX, MouseY, Button

    IF Button = 2 THEN
      i$ = CHR$(0) + CHR$(68)
      IF Menu = 3 THEN Menu = 0
    END IF

    IF Button = 1 THEN
      IF MouseX >= EditX1 AND MouseX <= EditX2 AND MouseY >= EditY1 AND MouseY <= EditY2 THEN
	GOSUB CursorOff
	X = (MouseX - EditX1) \ 4
	Y = (MouseY - EditY1 + 1) \ 4
	TX = X
	TY = Y
	GOSUB CursorPos
      ELSEIF MouseY < GPDat(71) THEN
	i$ = CHR$(0) + CHR$(68)
	SELECT CASE MouseX
	  CASE IS < 8 * 6
	    Menu = 0
	  CASE IS < 12 * 8
	    Menu = 1
	  CASE IS < 18 * 8
	    Menu = 2
	  CASE IS < 23 * 8
	    Menu = 3
	  CASE ELSE
	END SELECT
      END IF
    END IF

    GOSUB Cursor

    '---- Handle extended keys
    IF LEN(i$) = 2 THEN
       i = ASC(MID$(i$, 2))
       IF i <> 68 THEN
	 Bypass = -1       'Forces a Bypass on using the menu system below
       ELSE
	 Bypass = 0        'If Menu Key is pressed the use the menu system
       END IF
       IF i < 59 THEN
	 i = ASC(MID$(AltChars$, i, 1))
	 Choice = 1         'Assume that an Alt-MenuKey has been pressed
	 Bypass = 0         'We want to start up the menu system if possible
	 IF i = ASC("F") THEN
	   Menu = 0         'Select Menu 0, the Files Menu
	   i = 68           'We are going to bring up that menu
	 ELSEIF i = ASC("E") THEN
	   Menu = 1         'Select Menu 1, the Edit Menu
	   i = 68           'We are going to bring up that menu
	 ELSEIF i = ASC("D") THEN
	   Menu = 2         'Select Menu 2, the Draw Menu
	   i = 68           'We are going to bring up that menu
	 ELSEIF i = ASC("H") THEN
	   Menu = 3         'Select Menu 3, the Help Menu
	   i = 68           'We are going to bring up that menu
	 ELSE
	   i = 0            'Alt-MenuKey used does not exist, so disable menu
	 END IF

       '---- Handle function keys
       ELSEIF i = 59 THEN   '<F1> key was pressed
	 Menu = 3           'Select Menu 3
	 Choice = 1         'Select Choice 1
	 i = 68             'Force the Menu System Key
       ELSEIF i = 60 THEN   '<F2> key was pressed
	 Menu = 2: Choice = 1: i = 68
       ELSEIF i = 61 THEN   '<F3> key was pressed
	 Menu = 2: Choice = 2: i = 68
       ELSEIF i = 62 THEN   '<F4> key was pressed
	 Menu = 2: Choice = 3: i = 68
       ELSEIF i = 63 THEN   '<F5> key was pressed
	 Menu = 2: Choice = 4: i = 68
       ELSEIF i = 64 THEN   '<F6> key was pressed
	 Menu = 1: Choice = 5: i = 68
       ELSEIF i = 65 THEN   '<F7> key was pressed
	 Menu = 1: Choice = 1: i = 68   'picks new character
       ELSEIF i = 66 THEN   '<F8> key was pressed
	 Menu = 2: Choice = 8: i = 68   'does nothing
       ELSEIF i = 67 THEN   '<F9> key was pressed
	 Menu = 0: Choice = 3: i = 68
       END IF

       '---- F10, Display the menu
       IF i = 68 OR AltKey THEN
	 IF FirstPoint THEN
	   Choice$(1, 2) = "Draw Another Line"
	 ELSE
	   Choice$(1, 2) = "Line Draw"
	 END IF
	 Ky$ = ""
	 IF NOT Bypass THEN

	 Action = 1
	 LastMenu = 10
	 LastChoice = 10
	 DO
	   CALL PullDownG(Choice$(), Stat(), Menu, Choice, Ky$, Action)

	   IF Menu <> LastMenu OR Choice <> LastChoice THEN
	     LSET H$ = HelpMsg$(Choice, Menu)
	     HideCursor
	     GPrint0VE BotRow, 1, H$, GPDat(74)
	     ShowCursor
	     LastMenu = Menu
	     LastChoice = Choice
	   END IF

	 LOOP UNTIL Action = 4
	 CALL PullDownG(Choice$(), Stat(), Menu, Choice, Ky$, 5)
	 LSET H$ = ""
	 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))

	 END IF
	 IF Ky$ = CHR$(27) THEN    '<ESCape> was Pressed

	 ELSE

'===== From Here

	   '---- File menu
	   IF Menu = 0 THEN

	     '---- New Font
	     IF Choice = 1 THEN
	       IF ChangesMade THEN GOSUB SaveChanges
	       CALL GPrint0VE(1, 54, STRING$(25, " "), GPDat%(74))
	       CALL GPrint0VE(1, 54, "New File", GPDat%(74))

	       '---- Clear the samples and editing grid
	       ClearDiffSizes
	       Capture (" ")
	       CsrOn = 0                'Reset blink to off
	       REDIM OutlineFont$(223, MaxGWFonts% - 1)
	       LineNum = 0
	       PaintNum = 0
	       GOSUB ClearFont          'Clear to Font$ array
	       FileName$ = ""
	       ChangesMade = 0

	     '---- Open Font
	     ELSEIF Choice = 2 THEN
	       
	       IF ChangesMade THEN GOSUB SaveChanges
	       A$ = " "
	       CALL Capture(A$)
	       CsrOn = 0

	       DO
		 LSET Edit$ = FileName$
		 CALL GetInput(BotRow, EditCol, "File Name:", Edit$, KeyCode)
		 IF KeyCode = 27 THEN EXIT DO

		 FileName$ = UCASE$(LTRIM$(RTRIM$(Edit$)))

		 P = INSTR(FileName$, ".")
		 IF P = 0 THEN FileName$ = FileName$ + ".QFN"
		 FileLeft& = GWFileSize&(FileName$)

		 IF FileLeft& < 1 THEN FileName$ = ""

	       LOOP UNTIL FileLeft& > 0

	       IF KeyCode = 13 THEN
		 HideCursor
		 CALL GPrint0VE(1, 54, STRING$(25, " "), GPDat%(74))
		 CALL GPrint0VE(1, 54, FileName$, GPDat%(74))
		 ShowCursor

		 LSET H$ = "Loading..."
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 IF 0 <> 0 THEN 'The first section contains code for loading
			      'old vector fonts
		   OPEN FileName$ FOR RANDOM AS #1 LEN = 230
		   FIELD #1, 230 AS n1$
		   FOR t = 1 TO 95
		     GET #1, t + 1
		     L = 230
		     WHILE MID$(n1$, L, 1) = CHR$(0) AND L > 1: L = L - 1: WEND
		     OutlineFont$(t, 0) = LEFT$(n1$, L)
		   NEXT
		   CLOSE #1
		 ELSE
		   OPEN FileName$ FOR RANDOM AS #1 LEN = 512
		   FIELD #1, 512 AS n1$
		   t2 = 0   'File Record (512 bytes)
		   t3 = 1   'Letter number
		   BufPointer = 513   'Force a read on the first pass
		   DO
		     IF BufPointer > 512 THEN
		       t2 = t2 + 1
		       GET #1, t2
		       BufPointer = 1
		       FileLeft& = FileLeft& - 512
		     END IF
		     t4 = ASC(MID$(n1$, BufPointer, 1))
		     BufPointer = BufPointer + 1
		     IF BufPointer > 512 THEN
		       t2 = t2 + 1
		       GET #1, t2
		       BufPointer = 1
		       FileLeft& = FileLeft& - 512
		     END IF
		     t4 = t4 + 256 * ASC(MID$(n1$, BufPointer, 1))
		     BufPointer = BufPointer + 1
		     IF BufPointer > 512 THEN
		       t2 = t2 + 1
		       GET #1, t2
		       BufPointer = 1
		       FileLeft& = FileLeft& - 512
		     END IF
		     OutlineFont$(t3, 0) = STRING$(t4, 0)
		     IF BufPointer + t4 > 513 THEN  'Not a complete string
		       LSET OutlineFont$(t3, 0) = MID$(n1$, BufPointer)
		       t5 = t4 - (513 - BufPointer) + 1
		       t4 = 513 - BufPointer
		       BufPointer = t5
		       t2 = t2 + 1
		       GET #1, t2
		       FileLeft& = FileLeft& - 512
		       MID$(OutlineFont$(t3, 0), t4 + 1, BufPointer - 1) = MID$(n1$, 1, BufPointer - 1)
		     ELSE
		       LSET OutlineFont$(t3, 0) = MID$(n1$, BufPointer, t4)
		       BufPointer = BufPointer + t4
		     END IF
		     t3 = t3 + 1
		   LOOP UNTIL (FileLeft& <= 0) AND (BufPointer > 512 + FileLeft&)
		   CLOSE #1
		 END IF
	       END IF

	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor
	       ChangesMade = 0
	       
	     '---- Save font, Save As
	     ELSEIF Choice = 3 OR Choice = 4 THEN
	       
	       GOSUB FileSave

	     '---- Simulate Font
	     ELSEIF Choice = 6 THEN
	       Esc = 0
	       DO
		 LSET Edit$ = SimuName$
		 CALL GetInput(BotRow, EditCol, "File Name:", Edit$, KeyCode)

		 IF KeyCode = 27 THEN
		   Esc = -1
		 ELSE
		   SimuName$ = UCASE$(LTRIM$(RTRIM$(Edit$)))
		   P = INSTR(SimuName$, ".")
		   IF P = 0 THEN SimuName$ = SimuName$ + ".GFN"
		   FileLeft& = GWFileSize&(SimuName$)
		   IF FileLeft& < 1 AND NOT NewFile THEN SimuName$ = ""
		 END IF

	       LOOP UNTIL FileLeft& > 0 OR Esc

	       IF KeyCode = 13 THEN
		 SimuName$ = UCASE$(LTRIM$(RTRIM$(Edit$)))
		 P = INSTR(SimuName$, ".")
		 IF P > 0 THEN SimuName$ = LEFT$(SimuName$, P - 1)
		 CALL SetGPFont(1)
		 CALL LoadFont(SimuName$)
	       END IF
	       HideCursor
	       CALL GPrint0VE(1, 54, STRING$(25, " "), GPDat%(74))
	       CALL GPrint0VE(1, 54, FileName$, GPDat%(74))
	       LSET H$ = ""
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	     '---- DOS shell
	     ELSEIF Choice = 8 THEN
	       HideCursor
	       PCOPY 0, 1
	       CLS
	       SHELL ("")   'As Long as the user doesn't say Mode Co80 were Ok.
	       PCOPY 1, 0
	       ShowCursor

	     '---- Exit
	     ELSEIF Choice = 10 THEN
	       
	       LSET H$ = "Are you sure (Y/N)"
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor
	       Q$ = ""
	       WHILE Q$ = "" OR INSTR("YyNn", Q$) = 0: Q$ = INKEY$: WEND
	       IF INSTR("Yy", Q$) > 0 THEN
		   IF ChangesMade THEN GOSUB SaveChanges
		   END
	       END IF
	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor
	     END IF

	   '---- Edit menu
	   ELSEIF Menu = 1 THEN

	     '---- Pick Character
	     IF Choice = 1 OR Choice = 2 THEN

	       LSET H$ = "Enter new character: "
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	       DO
		 Char$ = INKEY$
		 IF Char$ = CHR$(27) THEN EXIT DO
	       LOOP WHILE Char$ = "" OR (Char$ < " ") OR (Char$ > "~" AND UBOUND(OutlineFont$, 1) < 96) OR (Char$ > CHR$(254))

	       IF Char$ <> CHR$(27) THEN
		 FirstPoint = 0
		 GOSUB StoreChar
		 A$ = Char$
		 DrawBaseLine BGClr
		 CALL ClearDiffSizes

		 SampleFont = -1
		 IF Choice = 2 THEN SampleFont = 0

		 CALL Capture(A$)

		 CsrOn = 0
		 GOSUB RetrieveChar

		 FOR t2 = 1 TO LineNum
		   HideCursor
		   CALL LineVE(Lx1(t2) * 4 + EditX1 + 2, Ly1(t2) * 4 + EditY1 + 2, Lx2(t2) * 4 + EditX1 + 2, Ly2(t2) * 4 + EditY1 + 2, 15)
		   ShowCursor
		   CALL UpDateLines(Lx1(t2), Ly1(t2), Lx2(t2), Ly2(t2), 15)
		 NEXT
		 FOR t2 = 1 TO PaintNum
		   HideCursor
		   CIRCLE (Px(t2) * 4 + EditX1 + 3, Py(t2) * 4 + EditY1 + 2), 3, 15
		   ShowCursor
		   CALL UpDatePaint(Px(t2), Py(t2), Pc(t2))
		 NEXT

		 DrawBaseLine 15
	       END IF

	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor
	       
	     '---- Duplicate character
	     ELSEIF Choice = 3 THEN
	       
	       LSET H$ = "Enter new character"
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	       DO
		 A2$ = INKEY$
		 IF A2$ = CHR$(27) THEN EXIT DO
	       LOOP WHILE A2$ = "" OR (A2$ < " ") OR (A2$ > "~" AND UBOUND(OutlineFont$, 1) < 96) OR (A2$ > CHR$(254))

	       IF A2$ <> CHR$(27) AND ASC(A$) >= 31 THEN
		 GOSUB StoreChar
		 DrawBaseLine BGClr
		 CALL ClearDiffSizes
		 OutlineFont$(ASC(A$) - 31, 0) = OutlineFont$(ASC(A2$) - 31, 0)
		 CALL Capture(A$)
		 CsrOn = 0
		 GOSUB RetrieveChar
		 FOR t2 = 1 TO LineNum
		   HideCursor
		   CALL LineVE(Lx1(t2) * 4 + EditX1 + 2, Ly1(t2) * 4 + EditY1 + 2, Lx2(t2) * 4 + EditX1 + 2, Ly2(t2) * 4 + EditY1 + 2, 15)
		   ShowCursor
		   CALL UpDateLines(Lx1(t2), Ly1(t2), Lx2(t2), Ly2(t2), 15)
		 NEXT
		 FOR t2 = 1 TO PaintNum
		   HideCursor
		   CIRCLE (Px(t2) * 4 + EditX1 + 3, Py(t2) * 4 + EditY1 + 2), 3, 15
		   ShowCursor
		   CALL UpDatePaint(Px(t2), Py(t2), Pc(t2))
		 NEXT

		 DrawBaseLine 15
	       END IF

	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	     '---- Move Lines
	     ELSEIF Choice = 5 THEN
	       IF LineNum > 1 THEN
	       
	       i$ = ""
	       LastX = X
	       LastY = Y
	       LX = X
	       LY = Y

	       DO
		 t2 = 0
		 LSET H$ = "Select a point by clicking on it, or position the cursor and press <Enter>"
		 HideCursor
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor
		 i$ = ""
		 '---- Loop until we click on a point or until the cursor rests
		 '     on a point and we press an arrow key.
		 DO
		   GetCursor MouseX, MouseY, Button

		   IF Button = 1 THEN
		     IF MouseX >= EditX1 AND MouseX <= EditX2 AND MouseY >= EditY1 AND MouseY <= EditY2 THEN
		       GOSUB CursorOff
		       X = (MouseX - EditX1) \ 4
		       Y = (MouseY - EditY1 + 1) \ 4
		     ELSE
		       Button = 0
		     END IF
		   END IF

		   i$ = INKEY$
		   IF LEN(i$) = 2 THEN
		     GOSUB CursorOff
		     i = ASC(RIGHT$(i$, 1))
		     MoveCursor X, Y, i
		   END IF
		   
		   ChangesMade = -1
		   FirstPoint = 0

		   t2 = 0

		   '---- See which point we are on
		   IF t2 < 2 THEN
		     FOR t1 = 1 TO LineNum
		       IF Lx1(t1) = X AND Ly1(t1) = Y THEN
			 t2 = t2 + 1
			 Mx1(t2) = Lx2(t1)
			 My1(t2) = Ly2(t1)
			 Mp1(t2) = 1
			 Mp2(t2) = t1
		       ELSEIF Lx2(t1) = X AND Ly2(t1) = Y THEN
			 t2 = t2 + 1
			 Mx1(t2) = Lx1(t1)
			 My1(t2) = Ly1(t1)
			 Mp1(t2) = 2
			 Mp2(t2) = t1
		       END IF
		     NEXT
		   END IF

		   IF t2 <> 2 THEN t2 = 0
		   GOSUB Cursor

		 LOOP UNTIL (t2 = 2 AND (i$ = CHR$(13) OR Button = 1)) OR Button > 1 OR i$ = CHR$(27)

		 LSET H$ = "Press <Enter> to complete the move"
		 HideCursor
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor

		 IF i$ = CHR$(13) THEN i$ = ""

		 LastX = X
		 LastY = Y

		 '---- If we're on a point
		 IF t2 = 2 AND Button < 2 AND i$ <> CHR$(27) THEN
		   GOSUB Cursor

		   FOR t1 = 1 TO PaintNum
		     CALL UpDatePaint(Px(t1), Py(t1), 0)
		   NEXT

		   '---- Clear the two lines in the sample
		   CALL UpDateLines(Mx1(1), My1(1), LastX, LastY, 0)
		   CALL UpDateLines(Mx1(2), My1(2), LastX, LastY, 0)

		   WHILE i$ <> CHR$(13) AND i$ <> CHR$(27) AND Button < 2

		     i$ = INKEY$

		     GOSUB Cursor

		     GetCursor MouseX, MouseY, Button
		     
		     '---- Edit with mouse
		     IF Button = 1 THEN
		       IF MouseX >= EditX1 AND MouseX < EditX2 AND MouseY > EditY1 AND MouseY < EditY2 THEN
		       
			 GOSUB CursorOff
			 X = (MouseX - EditX1) \ 4
			 Y = (MouseY - EditY1 + 1) \ 4
			 
			 IF X <> LastX OR Y <> LastY THEN

			   GOSUB CursorPos
			   HideCursor
			   '---- Erase last lines
			   CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, LastX * 4 + EditX1 + 2, LastY * 4 + EditY1 + 2, 15 + 24 * 256)
			   CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, LastX * 4 + EditX1 + 2, LastY * 4 + EditY1 + 2, 15 + 24 * 256)

			   '---- Draw new lines
			   CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			   CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			   ShowCursor

			   '---- Remember last coordinates
			   LastX = X
			   LastY = Y

			 END IF
		       END IF

		     END IF

		     '---- Edit from keyboard
		     IF LEN(i$) = 2 THEN
			 i = ASC(MID$(i$, 2))

			 '---- Erase old lines
			 HideCursor
			 CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			 CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			 ShowCursor

			 GOSUB CursorOff
			 MoveCursor X, Y, i

			 '---- Draw new lines
			 HideCursor
			 CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			 CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			 ShowCursor

			 '---- Remember last coordinates
			 LastX = X
			 LastY = Y

		     END IF

		   WEND

		   IF Button < 2 AND i$ <> CHR$(27) THEN
		     CALL UpDateLines(Mx1(1), My1(1), X, Y, 15)
		     CALL UpDateLines(Mx1(2), My1(2), X, Y, 15)
		     FOR t1 = 1 TO PaintNum
		       CALL UpDatePaint(Px(t1), Py(t1), Pc(t1))
		     NEXT
		     FOR t2 = 1 TO 2
		       IF Mp1(t2) = 1 THEN
			 Lx1(Mp2(t2)) = X
			 Ly1(Mp2(t2)) = Y
		       ELSE
			 Lx2(Mp2(t2)) = X
			 Ly2(Mp2(t2)) = Y
		       END IF
		     NEXT
		   END IF

		 END IF

		 LSET H$ = ""
		 HideCursor
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor

		 LOOP UNTIL i$ = CHR$(27) OR Button > 1

	       END IF

	     '---- Move/Delete Paint points
	     ELSEIF Choice = 6 OR Choice = 7 THEN
	       IF PaintNum > 0 THEN
		 
		 ChangesMade = -1
		 FirstPoint = 0

		 IF Choice = 6 THEN
		   LSET H$ = "Press <Enter> to complete move"
		 ELSE
		   LSET H$ = "Press <Enter> to delete paint point"
		 END IF

		 HideCursor
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor
		 Mp1(1) = 0

		 '---- See if we're on a paint point
		 FOR t1 = 1 TO PaintNum
		   IF Px(t1) = X AND Py(t1) = Y THEN
		     Mp1(1) = t1
		     PaintEl = t1
		   END IF
		 NEXT

		 IF Mp1(1) <> 0 THEN
		   FOR t1 = 1 TO PaintNum
		     CALL UpDatePaint(Px(t1), Py(t1), 0)
		   NEXT
		   IF CsrOn THEN
		     OverRide = -1
		     GOSUB Cursor
		   END IF

		   IF Choice = 6 THEN

		     HideCursor
		     CIRCLE (X * 4 + EditX1 + 3, Y * 4 + EditY1 + 2), 3, 0
		     ShowCursor

		     i$ = ""
		     WHILE i$ <> CHR$(13)
		       i$ = INKEY$

		       GetCursor MouseX, MouseY, Button
		       IF Button = 1 THEN
			 GOSUB CursorOff
			 X = (MouseX - EditX1) \ 4
			 Y = (MouseY - EditY1 + 1) \ 4
			 TX = X
			 TY = Y
			 GOSUB CursorPos
		       END IF

		       IF LEN(i$) = 2 THEN
			 GOSUB CursorOff
			 i = ASC(MID$(i$, 2))
			 MoveCursor X, Y, i
		       END IF

		       GOSUB Cursor

		     WEND

		     GOSUB CursorOff
		     HideCursor
		     CIRCLE (X * 4 + EditX1 + 3, Y * 4 + EditY1 + 2), 3, 15
		     ShowCursor

		     Px(Mp1(1)) = X
		     Py(Mp1(1)) = Y
		     FOR t1 = 1 TO PaintNum
		       CALL UpDatePaint(Px(t1), Py(t1), Pc(t1))
		     NEXT

		   ELSE
		     '---- Delete paint point
		     DO
		       Ky$ = INKEY$
		     LOOP UNTIL Ky$ = CHR$(13) OR Ky$ = CHR$(27)

		     IF Ky$ = CHR$(13) THEN

		       HideCursor
		       CIRCLE (X * 4 + EditX1 + 3, Y * 4 + EditY1 + 2), 3, 0
		       ShowCursor

		       FOR i = PaintEl TO PaintNum
			 Px(i) = Px(i + 1)
			 Py(i) = Py(i + 1)
			 Pc(i) = Pc(i + 1)
		       NEXT

		       PaintNum = PaintNum - 1
		       GOSUB Redraw

		     END IF

		   END IF
		 END IF

	       ELSE
		 SOUND 70, 3
		 IF Choice = 6 THEN
		   DisplayMessage "Cannot move Paint Points before they have been created."
		 ELSE
		   DisplayMessage "Cannot delete Paint Points before they have been created."
		 END IF
	       END IF

	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	     '---- Delete Segment
	     ELSEIF Choice = 9 THEN
	       
	       IF LineNum > 0 THEN
		 
		 ChangesMade = -1
		 FirstPoint = 0
		 LSET H$ = "<SpaceBar> to Select Segment    <Enter> to Delete"
		 HideCursor
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor
		 t1 = 1
		 i$ = ""
		 FOR t2 = 1 TO PaintNum
		   CALL UpDatePaint(Px(t2), Py(t2), 0)
		 NEXT
		 HideCursor
		 CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		 ShowCursor

		 WHILE i$ <> CHR$(13) AND i$ <> CHR$(27)
		   i$ = INKEY$
		   IF i$ = " " THEN
		     HideCursor
		     CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		     t1 = (t1 MOD LineNum) + 1
		     CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		     ShowCursor
		   END IF
		 WEND

		 IF i$ = CHR$(27) THEN
		   HideCursor
		   CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		   ShowCursor
		 END IF

		 HideCursor
		 CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		 CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 15 + 24 * 256)
		 LSET H$ = "Are you sure? (Y/N)"
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))

		 Q$ = ""
		 WHILE Q$ = "" OR INSTR("yYnN", Q$) = 0: Q$ = INKEY$: WEND

		 IF INSTR("yY", Q$) THEN
		   IF LineNum > 0 THEN
		     Lx1(t1) = Lx1(LineNum)
		     Ly1(t1) = Ly1(LineNum)
		     Lx2(t1) = Lx2(LineNum)
		     Ly2(t1) = Ly2(LineNum)
		     LineNum = LineNum - 1

		     GOSUB Redraw

		   ELSE
		     SOUND 70, 3
		   END IF
		 END IF

		 LSET H$ = ""
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor
		 FOR t2 = 1 TO PaintNum
		   CALL UpDatePaint(Px(t2), Py(t2), Pc(t2))
		 NEXT
	       ELSE
		 SOUND 70, 3
		 DisplayMessage "Cannot delete line segments before they have been created."
	       END IF

	     '---- Break line
	     ELSEIF Choice = 10 THEN
	       IF LineNum > 0 THEN
		 
		 GOSUB CursorOff
		 ChangesMade = -1
		 FirstPoint = 0
		 HideCursor
		 LSET H$ = "<SpaceBar> to Select Segment    <Enter> to Break"
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor
		 t1 = 1
		 i$ = ""
		 FOR t2 = 1 TO PaintNum
		   CALL UpDatePaint(Px(t1), Py(t1), 0)
		 NEXT
		 HideCursor
		 CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		 ShowCursor

		 WHILE (i$ <> CHR$(13)) AND (i$ <> CHR$(27))
		   i$ = INKEY$
		   IF i$ = " " THEN
		     HideCursor
		     CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		     t1 = (t1 MOD LineNum) + 1
		     CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		     ShowCursor
		   END IF
		 WEND

		 IF i$ = CHR$(27) THEN   'Restore the line color
		   HideCursor
		   CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		   ShowCursor
		 END IF

		 IF i$ = CHR$(13) THEN
		   HideCursor
		   LSET H$ = "Press <Enter> to Select Positioning"
		   CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		   '---- Clear the red line
		   CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 3 + 24 * 256)
		   '---- Erase the existing line
		   CALL LineVE(Lx1(t1) * 4 + EditX1 + 2, Ly1(t1) * 4 + EditY1 + 2, Lx2(t1) * 4 + EditX1 + 2, Ly2(t1) * 4 + EditY1 + 2, 15 + 24 * 256)
		   X = (Lx1(t1) + Lx2(t1)) \ 2
		   Y = (Ly1(t1) + Ly2(t1)) \ 2
		   Mx1(1) = Lx1(t1)
		   My1(1) = Ly1(t1)
		   Mx1(2) = Lx2(t1)
		   My1(2) = Ly2(t1)
		   CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		   CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		   ShowCursor
		   CALL UpDateLines(Mx1(1), My1(1), Mx1(2), My1(2), 0)
		   i$ = ""
		   LX = X
		   LY = Y

		   WHILE i$ <> CHR$(13)

		     GetCursor MouseX, MouseY, Button

		     '---- Edit with mouse
		     IF Button = 1 THEN
		       IF MouseX >= EditX1 AND MouseX < EditX2 AND MouseY > EditY1 AND MouseY < EditY2 THEN

			 X = (MouseX - EditX1) \ 4
			 Y = (MouseY - EditY1 + 1) \ 4

			 GOSUB CursorPos
			 HideCursor
			 '---- Erase last lines
			 CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, LX * 4 + EditX1 + 2, LY * 4 + EditY1 + 2, 15 + 24 * 256)
			 CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, LX * 4 + EditX1 + 2, LY * 4 + EditY1 + 2, 15 + 24 * 256)

			 '---- Draw new lines
			 CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			 CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
			 ShowCursor

			 '---- Remember last coordinates
			 LX = X
			 LY = Y

		       END IF

		     END IF

		     i$ = INKEY$
		     IF LEN(i$) = 2 THEN
		       i = ASC(MID$(i$, 2))
		       HideCursor
		       CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		       CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		       ShowCursor

		       MoveCursor X, Y, i
		       'GOSUB CursorPos
		       HideCursor
		       CALL LineVE(Mx1(1) * 4 + EditX1 + 2, My1(1) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		       CALL LineVE(Mx1(2) * 4 + EditX1 + 2, My1(2) * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		       ShowCursor
		       LX = X
		       LY = Y

		     END IF
		   WEND

		   TX = X
		   TY = Y
		   CALL UpDateLines(Mx1(1), My1(1), X, Y, 15)
		   CALL UpDateLines(Mx1(2), My1(2), X, Y, 15)
		   FOR t2 = 1 TO PaintNum
		     CALL UpDatePaint(Px(t2), Py(t2), Pc(t2))
		   NEXT
		   Lx2(t1) = X
		   Ly2(t1) = Y
		   LineNum = LineNum + 1
		   Lx1(LineNum) = X
		   Ly1(LineNum) = Y
		   Lx2(LineNum) = Mx1(2)
		   Ly2(LineNum) = My1(2)
		 END IF

	       ELSE
		 SOUND 70, 3
		 DisplayMessage "Cannot break line segments before they have been created."
	       END IF

	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	     ELSEIF Choice = 12 THEN

	       '---- Clear current character font definition

	       LSET H$ = "Are you sure (Y/N)"
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor
	       Q$ = ""
	       WHILE Q$ = "" OR INSTR("YyNn", Q$) = 0: Q$ = INKEY$: WEND
	       IF INSTR("Yy", Q$) > 0 THEN
		 ChangesMade = -1
		 PaintNum = 0
		 LineNum = 0
		 FirstPoint = 0
		 OutlineFont$(ASC(A$), 0) = CHR$(0)
		 GOSUB Redraw
		 LSET H$ = ""
		 HideCursor
		 CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
		 ShowCursor
	       END IF

	       LSET H$ = ""
	       HideCursor
	       CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	       ShowCursor

	     END IF

	   '---- Draw Menu
	   ELSEIF Menu = 2 THEN

	     '---- Line draw
	     IF Choice = 1 THEN

	       ChangesMade = -1
	       IF FirstPoint THEN
		 IF LX <> X OR LY <> Y THEN

		   HideCursor
		   CALL LineVE(LX * 4 + EditX1 + 2, LY * 4 + EditY1 + 2, X * 4 + EditX1 + 2, Y * 4 + EditY1 + 2, 15 + 24 * 256)
		   ShowCursor

		   CALL UpDateLines(LX, LY, X, Y, 15)
		   LineNum = LineNum + 1
		   Lx1(LineNum) = LX
		   Ly1(LineNum) = LY
		   Lx2(LineNum) = X
		   Ly2(LineNum) = Y
		   LX = X
		   LY = Y
		 ELSE
		   SOUND 70, 3
		   DisplayMessage "You must move the cursor before drawing the next line."
		 END IF
	       ELSE
		 LX = X
		 LY = Y
		 Lcx = X
		 Lcy = Y
		 FirstPoint = -1
	       END IF

	     '---- Connect Ends
	     ELSEIF Choice = 2 THEN
	       'Connect Ends of the lines
	       ChangesMade = -1
	       IF LX <> Lcx OR LY <> Lcy THEN
		 HideCursor
		 CALL LineVE(LX * 4 + EditX1 + 2, LY * 4 + EditY1 + 2, Lcx * 4 + EditX1 + 2, Lcy * 4 + EditY1 + 2, 15 + 24 * 256)
		 ShowCursor
		 CALL UpDateLines(LX, LY, Lcx, Lcy, 15)
		 LineNum = LineNum + 1
		 Lx1(LineNum) = LX
		 Ly1(LineNum) = LY
		 Lx2(LineNum) = Lcx
		 Ly2(LineNum) = Lcy
		 FirstPoint = 0
	       ELSE
		 SOUND 70, 3
		 DisplayMessage "Lines are already connected."
	       END IF

	     '---- End Line Draw
	     ELSEIF Choice = 3 THEN
	       IF FirstPoint <> 0 THEN
		 ChangesMade = -1
		 FirstPoint = 0
	       ELSE
		 SOUND 70, 3
		 DisplayMessage "Must begin Line Draw before you can End the Line Drawing mode."
	       END IF
	       
	     '---- Draw paint point
	     ELSEIF Choice = 4 THEN
	       
	       ChangesMade = -1
	       PaintNum = PaintNum + 1
	       Px(PaintNum) = X
	       Py(PaintNum) = Y
	       Pc(PaintNum) = 15
	       CALL UpDatePaint(Px(PaintNum), Py(PaintNum), Pc(PaintNum))
	       HideCursor
	       CIRCLE (X * 4 + EditX1 + 3, Y * 4 + EditY1 + 2), 3, 15
	       ShowCursor

	     '---- Set BaseLine
	     ELSEIF Choice = 6 THEN
	       'set Baseline
	       ChangesMade = -1
	       DrawBaseLine BGClr
	       BaseLine = Y
	       DrawBaseLine 15

	     '---- Redraw Letter
	     ELSEIF Choice = 8 THEN
	       'Redraw Character
	       GOSUB Redraw

	     END IF

	   '---- Help menu
	   ELSEIF Menu = 3 THEN
	     'Help Menu
	     Help$ = STRING$(23, " ") + "HELP "
	     Help$ = Help$ + STRING$(50, ASC("-"))
	     Help$ = Help$ + " <F1>  - Brings up this message    ³ Alternatively"
	     Help$ = Help$ + " <F2>  - Draws a line segment      ³ you can start"
	     Help$ = Help$ + " <F3>  - Connects Line segments    ³ the menu     "
	     Help$ = Help$ + " <F4>  - Ends Line Drawing         ³ system with  "
	     Help$ = Help$ + " <F5>  - Places a Paint Point      ³ one of the   "
	     Help$ = Help$ + " <F6>  - Moves Connected Lines     ³ Alt-MenuKey  "
	     Help$ = Help$ + " <F7>  - Picks editing character   ³ combinations "
	     Help$ = Help$ + " <F8>  - Re-draws the screen       ³ like Alt-F   "
	     Help$ = Help$ + " <F9>  - Saves the Currect Font    ³ for the File "
	     Help$ = Help$ + " <F10> - Activates the Menu System ³ Menu         "

	     DisplayMessage Help$
	   END IF
'===== up to here are the menu and choices functions

	 END IF
       ELSE
	 MoveCursor TX, TY, i
	 IF TX <> X OR TY <> Y THEN       'If we've moved and the cursor
	   GOSUB CursorOff
	   X = TX
	   Y = TY
	 END IF

       END IF
    END IF

WEND

END


'===========================================================================
'============================= Subroutines =================================
'===========================================================================
'LineNum is the total number of line segments in the font definition for each
'        character
'

StoreChar:
  A = ASC(A$) - 31           'Calculate offset into the OutLineFont$ array
  IF A >= 0 THEN
    MaxSize = 0
    FOR t1 = 1 TO LineNum
       IF Lx1(t1) > MaxSize THEN MaxSize = Lx1(t1)
       IF Lx2(t1) > MaxSize THEN MaxSize = Lx2(t1)
    NEXT
    OutlineFont$(A, 0) = CHR$(MaxSize) + CHR$(BaseLine) + STRING$(220, 0)
    FOR t1 = 1 TO LineNum
       Lu(t1) = 0
    NEXT
    t1 = 0
    t4 = 3
    WHILE t1 = 0
      t1 = -1
      L$ = STRING$(200, 0)
      t5 = 1
      t2 = 1
      WHILE t2 <= LineNum AND t5 = 1
	IF Lu(t2) = 0 THEN
	  MID$(L$, 1, 1) = CHR$(Lx1(t2) + 128)
	  MID$(L$, 2, 1) = CHR$(Ly1(t2) + 128)
	  MID$(L$, 3, 1) = CHR$(Lx2(t2))
	  MID$(L$, 4, 1) = CHR$(Ly2(t2))
	  l1 = Lx2(t2)
	  L2 = Ly2(t2)
	  t5 = 5
	  Lu(t2) = -1
	END IF
	t2 = t2 + 1
      WEND
      t3 = 0
      WHILE t3 = 0
	t3 = -1
	FOR t2 = 1 TO LineNum
	  IF NOT Lu(t2) THEN
	    IF l1 = Lx1(t2) AND L2 = Ly1(t2) THEN
	      MID$(L$, t5, 1) = CHR$(Lx2(t2))
	      MID$(L$, t5 + 1, 1) = CHR$(Ly2(t2))
	      l1 = Lx2(t2)
	      L2 = Ly2(t2)
	      Lu(t2) = -1
	      t5 = t5 + 2
	      t3 = 0
	    ELSEIF l1 = Lx2(t2) AND L2 = Ly2(t2) THEN
	      MID$(L$, t5, 1) = CHR$(Lx1(t2))
	      MID$(L$, t5 + 1, 1) = CHR$(Ly1(t2))
	      l1 = Lx1(t2)
	      L2 = Ly1(t2)
	      Lu(t2) = -1
	      t5 = t5 + 2
	      t3 = 0
	    END IF
	  END IF
	NEXT
      WEND
      MID$(OutlineFont$(A, 0), t4, t5 - 1) = LEFT$(L$, t5 - 1)
      t4 = t4 + t5 - 1
      FOR t2 = 1 TO LineNum
	IF NOT Lu(t2) THEN t1 = 0
      NEXT
    WEND
    FOR t2 = 1 TO PaintNum
      MID$(OutlineFont$(A, 0), t4, 1) = CHR$(Px(t2) + 64)
      MID$(OutlineFont$(A, 0), t4 + 1, 1) = CHR$(Py(t2) + 64)
      t4 = t4 + 2
    NEXT
    OutlineFont$(A, 0) = LEFT$(OutlineFont$(A, 0), t4 - 1)
  END IF
  RETURN

RetrieveChar:
  A = ASC(A$) - 31
  IF A >= 0 THEN
    LineNum = 0
    PaintNum = 0
    IF LEN(OutlineFont$(A, 0)) > 1 THEN BaseLine = ASC(MID$(OutlineFont$(A, 0), 2, 1))
    t3 = 3
    t1 = 0
    WHILE (t1 < 64 OR (t1 > 127 AND t1 < 192)) AND t3 < LEN(OutlineFont$(A, 0))
      t1 = ASC(MID$(OutlineFont$(A, 0), t3, 1))
      t2 = ASC(MID$(OutlineFont$(A, 0), t3 + 1, 1))
      IF t1 > 127 AND t1 < 192 THEN
	l1 = t1 - 128
	L2 = t2 - 128
	t3 = t3 + 2
      ELSEIF t1 < 64 THEN
	LineNum = LineNum + 1
	Lx1(LineNum) = l1
	Ly1(LineNum) = L2
	Lx2(LineNum) = t1
	Ly2(LineNum) = t2
	l1 = t1
	L2 = t2
	t3 = t3 + 2
      END IF
    WEND
    WHILE t3 < LEN(OutlineFont$(A, 0))
      t1 = ASC(MID$(OutlineFont$(A, 0), t3, 1))
      t2 = ASC(MID$(OutlineFont$(A, 0), t3 + 1, 1))
      PaintNum = PaintNum + 1
      IF t1 > 63 THEN
	Px(PaintNum) = t1 - 64
	Py(PaintNum) = t2 - 64
	Pc(PaintNum) = 15
	t3 = t3 + 2
      ELSE
	Px(PaintNum) = t1 - 192
	Py(PaintNum) = t2 - 192
	Pc(PaintNum) = ASC(MID$(OutlineFont$(A, 0), t3 + 2, 1))
	t3 = t3 + 3
      END IF
    WEND
  END IF
  RETURN

SaveChanges:
    LSET H$ = "Save Changes? (Y/N)"
    CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
    Q$ = ""

    WHILE Q$ = "" OR INSTR("YyNn" + CHR$(27), Q$) = 0: Q$ = INKEY$: WEND
    LSET H$ = ""
    CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
    IF INSTR("Yy", Q$) = 0 THEN RETURN
    'Otherwise we are going to save the font file
FileSave:
    GOSUB StoreChar
    NewFile = LEN(FileName$) = 0

    IF Choice = 4 OR NewFile THEN
      DO

	LSET Edit$ = FileName$
	CALL GetInput(BotRow, EditCol, "File Name:", Edit$, KeyCode)

	IF KeyCode = 27 THEN
	  LSET H$ = ""
	  CALL GPrint0VE(BotRow, 1, H$, GPDat(74))
	  RETURN
	END IF

	FileName$ = UCASE$(LTRIM$(RTRIM$(Edit$)))
	IF LEN(FileName$) = 0 THEN EXIT DO
	P = INSTR(FileName$, ".")
	IF P = 0 THEN FileName$ = FileName$ + ".QFN"
	FileLeft& = GWFileSize&(FileName$)
	IF FileLeft& < 1 AND NOT NewFile THEN FileName$ = ""

      LOOP UNTIL FileLeft& > 0 OR NewFile
    END IF

    IF LEN(FileName$) THEN

      CALL GPrint0VE(1, 54, STRING$(25, " "), GPDat%(74))
      CALL GPrint0VE(1, 54, FileName$, GPDat%(74))

      OPEN "O", 1, FileName$
      FOR t2 = 1 TO 95
	l1 = LEN(OutlineFont$(t2, 0))
	PRINT #1, MKI$(l1); OutlineFont$(t2, 0);
      NEXT
      l1 = 0
      FOR t2 = 96 TO 223
	IF LEN(OutlineFont$(t2, 0)) > 1 THEN l1 = -1
      NEXT
      IF l1 THEN
	FOR t2 = 96 TO 223
	  l1 = LEN(OutlineFont$(t2, 0))
	  PRINT #1, MKI$(l1); OutlineFont$(t2, 0);
	NEXT
      END IF
      CLOSE #1
      ChangesMade = 0

    END IF

    LSET H$ = ""
    CALL GPrint0VE(BotRow, 1, H$, GPDat(74))

RETURN

CursorOff:
  IF CsrOn THEN
    OverRide = -1
    GOSUB Cursor
  END IF
RETURN

Cursor:
  IF NumTicks& < PDQTimer& OR OverRide THEN
    HideCursor
    PUT (X * 4 + EditX1 + 2, Y * 4 + EditY1 + 1), Cursor, XOR
    ShowCursor
    CsrOn = NOT CsrOn
    NumTicks& = PDQTimer& + 6   'Delay of 1/3 sec
    OverRide = 0
  END IF
RETURN

ClearFont:
  FOR t1 = 1 TO UBOUND(OutlineFont$, 1)
    OutlineFont$(t1, 0) = CHR$(0)
  NEXT
RETURN

CursorPos:
  IF X >= 0 AND X <= 63 AND Y >= 0 AND Y <= 63 THEN
    HideCursor
    S$ = RIGHT$("  " + STR$(X), 3)
    CALL GPrint0VE(1, 41, S$, GPDat%(74))
    S$ = RIGHT$("  " + STR$(Y), 3)
    CALL GPrint0VE(1, 46, S$, GPDat%(74))
    ShowCursor
  END IF
RETURN

Redraw:
  CALL ClearDiffSizes
  CALL Capture(A$)
  CsrOn = 0
  FOR t2 = 1 TO LineNum
    HideCursor
    CALL LineVE(Lx1(t2) * 4 + EditX1 + 2, Ly1(t2) * 4 + EditY1 + 2, Lx2(t2) * 4 + EditX1 + 2, Ly2(t2) * 4 + EditY1 + 2, 15)
    ShowCursor
    CALL UpDateLines(Lx1(t2), Ly1(t2), Lx2(t2), Ly2(t2), 15)
  NEXT
  FOR t2 = 1 TO PaintNum
    HideCursor
    CIRCLE (Px(t2) * 4 + EditX1 + 3, Py(t2) * 4 + EditY1 + 2), 3, 15
    ShowCursor
    CALL UpDatePaint(Px(t2), Py(t2), Pc(t2))
  NEXT
RETURN

ID:
  RSET Curr$ = Choice$(Choice, Menu)
  HideCursor
  CALL GPrint0VE(1, 64, Curr$, GPDat(74))
  ShowCursor
RETURN

ClearID:
  RSET Curr$ = ""
  HideCursor
  CALL GPrint0VE(1, 64, Curr$, GPDat(74))
  ShowCursor
RETURN

SUB Capture (A$) STATIC

    HideCursor
    LINE (EditX1, EditY1)-(EditX2, EditY2), 0, BF

    '---- Draw a GraphPak sample character
    IF SampleFont THEN CALL DrawText(EditX1, EditY1, A$, 0, 4, 15#)

    '---- Draw vertical grid lines
    FOR i = EditX1 + 3 TO EditX2 STEP HSpace
      LINE (i, EditY1 + 3)-(i, EditY2 - 3), 8
    NEXT

    '---- Draw horizontal grid lines
    FOR i = EditY1 + 2 TO EditY2 STEP VSpace
      LINE (EditX1 + 3, i)-(EditX2 - 3, i), 8
    NEXT

    '---- Draw the dot grid
    FOR i = EditY1 + 2 TO EditY2 STEP 4
      LINE (EditX1, i)-(EditX2, i), 7, , 4369
    NEXT

    CALL GPrint0VE(19, 40, "Character: [ ]", 7 + BGClr * 256)
    CALL GPrint0VE(19, 52, A$, 15 + BGClr * 256)


    ShowCursor

END SUB

SUB ClearDiffSizes STATIC

  HideCursor
  LINE (299, 19)-(366, 86), 0, BF
  LINE (299, 19)-(366, 86), 15, B
  LINE (379, 19)-(414, 54), 0, BF
  LINE (379, 19)-(414, 54), 15, B
  LINE (379, 69)-(398, 88), 0, BF
  LINE (379, 69)-(398, 88), 15, B
  LINE (299, 99)-(430, 230), 0, BF
  LINE (299, 99)-(430, 230), 15, B

  xd1 = 440 + (COS(11 / 21) * 68) * 2
  yd1 = 78 + (-.7 * SIN(11 / 21) * 68) * 2
  xd2 = 440 + (COS(11 / 21) * 68 + SIN(11 / 21) * 68 * .7) * 2
  yd2 = 78 + (COS(11 / 21) * 68 - SIN(11 / 21) * 68 * .7) * 2
  xd3 = 440 + (SIN(11 / 21) * 68 * .7) * 2
  yd3 = 78 + (COS(11 / 21) * 68) * 2
  
  CALL FillPoly(440, 78, xd1, yd1, xd3, yd3, xd2, yd2, 0)
  ShowCursor

END SUB

SUB DisplayMessage (Message$) STATIC

   HideCursor
   IF LEN(Message$) > 250 THEN
     LOCATE 4, 1         'If we need the full screen then position the message
			 ' higher on the screen
   ELSE
     LOCATE 12, 1
   END IF
   MsgBoxG Message$, 50
   WHILE INKEY$ = "": WEND
   MsgBoxG "", 50
   ShowCursor

END SUB

SUB DrawBaseLine (Clr)

  HideCursor
  CALL LineVE(EditX2 + 4, BaseLine * 4 + EditY1 + 2, EditX2 + 14, BaseLine * 4 + EditY1 + 2, Clr)
  CALL LineVE(EditX2 + 14, BaseLine * 4 + EditY1 - 1, EditX2 + 14, BaseLine * 4 + EditY1 + 5, Clr)
  ShowCursor

END SUB

SUB GetInput (Row, Col, Prompt$, Edit$, KeyCode)

  'GPrint0VE Row, Col, Prompt$, 15 + BGClr * 256
  GPrint0VE Row, Col, Prompt$, GPDat(74)'3 * 256
  L = LEN(Prompt$)
  EL = LEN(Edit$)
  LOCATE Row, Col + L
  LeftCol = Col + L
  TxtPos = 1
  DO
    GEditor Edit$, LeftCol, KeyCode, TxtPos
  LOOP UNTIL KeyCode = 13 OR KeyCode = 27

'  LINE (Col * 8 - 8, Row * GPDat(71) - GPDat(71))-STEP((L + EL + 1) * 8, GPDat(71)), BGClr, BF


END SUB

SUB MoveCursor (X, Y, i) STATIC

    SELECT CASE i
      CASE 71                                'Home
	X = 0
      CASE 72                                'Up
	Y = Y - 1: IF Y < 0 THEN Y = 0
      CASE 75                                'Left
	X = X - 1: IF X < 0 THEN X = 0
      CASE 77                                'Right
	X = X + 1: IF X > 63 THEN X = 63
      CASE 80                                'Down
	Y = Y + 1: IF Y > 63 THEN Y = 63
      CASE 81                                'PgDn
	Y = 63
      CASE 73                                'PgUp
	Y = 0
      CASE 79                                'End
	X = 63
      CASE ELSE
    END SELECT

    '---- Display the cursor coordinates
    HideCursor
    S$ = RIGHT$("  " + STR$(X), 3)
    CALL GPrint0VE(1, 41, S$, GPDat%(74))
    S$ = RIGHT$("  " + STR$(Y), 3)
    CALL GPrint0VE(1, 46, S$, GPDat%(74))
    ShowCursor

END SUB

SUB UpDateLines (X1, Y1, X2, Y2, Colr) STATIC

    HideCursor
    CALL LineVE(X1 + 301, Y1 + 21, X2 + 301, Y2 + 21, Colr)
    CALL LineVE(X1 / 2 + 381, Y1 / 2 + 21, X2 / 2 + 381, Y2 / 2 + 21, Colr)
    CALL LineVE(X1 / 4 + 381, Y1 / 4 + 71, X2 / 4 + 381, Y2 / 4 + 71, Colr)
    CALL LineVE(X1 * 2 + 301, Y1 * 2 + 101, X2 * 2 + 301, Y2 * 2 + 101, Colr)
    xd1 = (COS(11 / 21) * X1 + SIN(11 / 21) * Y1 * (GPDat%(49) / 1000)) * 2
    yd1 = (COS(11 / 21) * Y1 - SIN(11 / 21) * X1 * (GPDat%(49) / 1000)) * 2
    xd2 = (COS(11 / 21) * X2 + SIN(11 / 21) * Y2 * (GPDat%(49) / 1000)) * 2
    yd2 = (COS(11 / 21) * Y2 - SIN(11 / 21) * X2 * (GPDat%(49) / 1000)) * 2
    CALL LineVE(xd1 + 442, yd1 + 80, xd2 + 442, yd2 + 80, Colr)
    ShowCursor

END SUB

SUB UpDatePaint (X, Y, Colr) STATIC

    HideCursor
    C = Colr
    IF C = 15 THEN C = 7
    PAINT (X + 301, Y + 21), C, 15
    PAINT (X \ 2 + 381, Y \ 2 + 21), C, 15
    PAINT (X \ 4 + 381, Y \ 4 + 71), C, 15
    PAINT (X * 2 + 301, Y * 2 + 101), C, 15
    xd! = COS(11 / 21) * X + SIN(11 / 21) * Y * (GPDat%(49) / 1000)
    yd! = COS(11 / 21) * Y - SIN(11 / 21) * X * (GPDat%(49) / 1000)
    PAINT (xd! * 2 + 442, yd! * 2 + 80), C, 15
    ShowCursor

END SUB

