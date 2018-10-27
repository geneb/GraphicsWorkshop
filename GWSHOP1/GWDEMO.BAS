'GWDEMO.BAS - Demo program for the Graphics Workshop Demo Disk

'Copyright (c) 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

DECLARE SUB Pause ()
DECLARE SUB DefineMenus (Menu$(), Stat%())
DECLARE SUB CheckForFiles ()
DECLARE SUB DisplayInitialScreen (UniformSpeed%, ButtonArray%(), ButtonString$(), FirstTime%, OriginalGPDat31%)
DECLARE SUB ShowPCXEffects (UniformSpeed%)
DECLARE SUB ShowPrimitives (UniformSpeed%, Menu$(), Stat%())
DECLARE SUB ShowBenchmarks (UniformSpeed%)
DECLARE SUB DemoHercules ()
DECLARE SUB LineBAS (x1%, y1%, x2%, y2%, Colr%)
DECLARE SUB CircleBAS (XCenter%, YCenter%, Radius%, Colr%, XAspect%, YAspect%)
DECLARE SUB CSLogo (X%, Y%, Scale!, BClr%)
DECLARE SUB DrawButton (X%, Y%, Text$, UpOrDown%)
DECLARE SUB ResetPalette ()
DECLARE SUB SimulateFontEditor ()
DECLARE SUB CheckButtonOver (ButtonArray%(), ButtonString$(), MouseX%, MouseY%)
DECLARE SUB ClearBenchArea ()
DECLARE SUB ClearBenchArea2 ()
DECLARE SUB ShowTime (Row%, Col%, T&)

DIM Colors%(5)
DIM GWWindow AS Window1

'$INCLUDE: 'GetVideo'

'Check to see if the demo files (.PCX and fonts) can be found in the current
'directory, before we go any further.
CALL CheckForFiles

'$INCLUDE: 'GPFont.GW'
FontFile$ = "HELV12"
CALL SetGPFont(1)
CALL LoadFont(FontFile$)

'$INCLUDE: 'GWFont.GW'
FontFile$ = "HELV"
CALL SetGWFont(1)
CALL LoadOutlineFont(FontFile$)

IF GPDat%(31) = 5 OR GPDat%(31) = 8 THEN
  OriginalGPDat31% = GPDat%(31)
  GPDat%(31) = 5
ELSEIF GPDat%(31) = 1 OR GPDat%(31) = 7 THEN
  PRINT "You have a monochrome adaptor.  This demo was created for color"
  PRINT "monitors and the colors may not appear properly on your display."
  OriginalGPDat31% = GPDat%(31)
  GPDat%(31) = 1
ELSE
  PRINT "Graphics Workshop is made up of mostly EGA and VGA graphics routines."
  IF GPDat%(31) = 4 OR GPDat%(31) = 6 THEN
    PRINT "Your CGA adapter is not capable of the EGA graphics resolutions."
  ELSEIF GPDat%(31) = 2 THEN
    PRINT "An example of Graphics Workshop's Hercules abilities follows."
    WHILE INKEY$ = "": WEND
    CALL DemoHercules
  ELSE
    PRINT "Your video adapter is not capable of these graphics modes."
  END IF
  END
END IF

'Some of the routines work too fast (you wouldn't think that's a problem) to
'be visually correct.  There are delays mixed throughout the demo.  If you
'want to see the fastest speed possible run this program using /NODELAY as a
'command line parameter.
UniformSpeed = -1
IF INSTR(COMMAND$, "/NODELAY") THEN UniformSpeed = 0

'Set up the button information for 4 buttons
'  ButtonArray%(xxx, 1) contains the X position of the button
'  ButtonArray%(xxx, 2) contains the Y position of the button
'  ButtonArray%(xxx, 3) contains the status of the button, up(-1) or down(0)
REDIM ButtonArray%(4, 3), ButtonString$(4)

ButtonString$(1) = "1"
ButtonString$(2) = "2"
ButtonString$(3) = "3"
ButtonString$(4) = "ESC=Quit"

ButtonArray%(1, 1) = 180  'X Position of button
ButtonArray%(1, 2) = 215  'Y Position of button
ButtonArray%(1, 3) = -1   'Button Depressed (0 = depressed)

ButtonArray%(2, 1) = 180  'X
ButtonArray%(2, 2) = 265  'Y
ButtonArray%(2, 3) = -1

ButtonArray%(3, 1) = 180  'X
ButtonArray%(3, 2) = 315  'Y
ButtonArray%(3, 3) = -1

ButtonArray%(4, 1) = 540  'X
ButtonArray%(4, 2) = 315  'Y
ButtonArray%(4, 3) = -1

'----- Define the Menu Choices here
REDIM Menu$(15, 8)                      'Allocate space for the Menu Choices
REDIM Stat%(15, 8)                      'Define the choice status array

CALL DefineMenus(Menu$(), Stat%())

'==========================================================================
'Main Loop Starts here
'==========================================================================
CALL SetVideo     'Set the video mode

FirstTime = -1

DO
    'Display the initial screen.  The variable FirstTime will state whether
    'the screen has been drawn slowly before.
    CALL DisplayInitialScreen(UniformSpeed%, ButtonArray%(), ButtonString$(), FirstTime%, OriginalGPDat31%)

GetKey:
    'Turn the mouse cursor on, for selecting the buttons.  It was initialized
    'in SetVideo.
    ShowCursor
   
    Down = 0
    WasDown = 0
    DO
      DO
	ButtonPress 1, Down, Presses, MouseX, MouseY
	IF Presses = 0 THEN GetCursor MouseX, MouseY, Button
	IF Down = 1 THEN
	  'If the left button is currently down, then depress any button
	  'under the cursor, or release a button if the mouse has moved off
	  'of it.  Also set a flag so that we now the button was down.
	  WasDown = -1
	  CheckButtonOver ButtonArray%(), ButtonString$(), MouseX, MouseY
	ELSEIF WasDown THEN
	  'If the mouse button was depressed at one time, check to see if
	  'a button on screen is under the mouse currently.
	  WasDown = 0
	  CheckButtonOver ButtonArray%(), ButtonString$(), MouseX, MouseY
	  FOR T = 1 TO 4
	    IF ButtonArray%(T, 3) = 0 THEN
	      'If the value in ButtonArray%(T, 3) is 0 that means the button
	      'is depressed visibly on screen, which means that is the one
	      'which will be selected.  Fake that a keyboard letter has been
	      'depressed.
	      IF T < 4 THEN
		a$ = ButtonString$(T)
	      ELSE
		a$ = CHR$(27)
	      END IF
	    END IF
	  NEXT
	ELSE
	  'Some people will be using the keyboard
	  a$ = INKEY$
	END IF
      LOOP UNTIL a$ <> ""
    LOOP UNTIL INSTR("123" + CHR$(27), a$) > 0
    'Hide the mouse cursor
    HideCursor
    SELECT CASE a$
      CASE "1"
	'The time delay will make the button appear depressed on screen.
	T& = PDQTimer& + 1
	'Depress the button
	CALL DrawButton(ButtonArray%(1, 1), ButtonArray%(1, 2), ButtonString$(1), 0)
	WHILE T& >= PDQTimer&: WEND
	'Release the button
	CALL DrawButton(ButtonArray%(1, 1), ButtonArray%(1, 2), ButtonString$(1), -1)
	CALL ShowPCXEffects(UniformSpeed)
      CASE "2"
	T& = PDQTimer& + 1
	CALL DrawButton(ButtonArray%(2, 1), ButtonArray%(2, 2), ButtonString$(2), 0)
	WHILE T& >= PDQTimer&: WEND
	CALL DrawButton(ButtonArray%(2, 1), ButtonArray%(2, 2), ButtonString$(2), -1)
	CALL ShowPrimitives(UniformSpeed, Menu$(), Stat%())
      CASE "3"
	T& = PDQTimer& + 1
	CALL DrawButton(ButtonArray%(3, 1), ButtonArray%(3, 2), ButtonString$(3), 0)
	WHILE T& >= PDQTimer&: WEND
	CALL DrawButton(ButtonArray%(3, 1), ButtonArray%(3, 2), ButtonString$(3), -1)
	CALL ShowBenchmarks(UniformSpeed)
      CASE CHR$(27)
	T& = PDQTimer& + 1
	CALL DrawButton(ButtonArray%(4, 1), ButtonArray%(4, 2), ButtonString$(4), 0)
	WHILE T& >= PDQTimer&: WEND
	CALL DrawButton(ButtonArray%(4, 1), ButtonArray%(4, 2), ButtonString$(4), -1)
	END
      CASE ELSE
    END SELECT
LOOP UNTIL 0 <> 0   'Loop forever

SUB CheckButtonOver (ButtonArray%(), ButtonString$(), MouseX, MouseY) STATIC

  FOR T = 1 TO 4
    GotDepressed = 0
    IF MouseY >= ButtonArray%(T, 2) AND MouseY <= ButtonArray%(T, 2) + 20 THEN
      XD = (2 + GetWidth%(ButtonString$(T)) \ 10) * 10
      IF MouseX >= ButtonArray%(T, 1) AND MouseX <= ButtonArray%(T, 1) + XD THEN
	'A button should be depressed under the mouse cursor
	IF ButtonArray%(T, 3) THEN
	  'Button was up, so draw it as being depressed
	  DrawButton ButtonArray%(T, 1), ButtonArray%(T, 2), ButtonString$(T), 0
	  ButtonArray%(T, 3) = 0
	END IF
	GotDepressed = -1
	'A button is depressed
      END IF
    END IF
    IF NOT GotDepressed THEN
      'If this particular button (T) was not supposed to be depressed, then
      'check if it was depressed already, and if so, release it.
      IF ButtonArray%(T, 3) = 0 THEN
	DrawButton ButtonArray%(T, 1), ButtonArray%(T, 2), ButtonString$(T), -1
	ButtonArray%(T, 3) = -1
      END IF
    END IF
  NEXT

END SUB

SUB CheckForFiles STATIC

  'If one of these files does not exist (GWFileSize& will return a -1) then
  'we should stop the demo now and let the user re-install the demo, so that
  'he gets all the necessary files in the current directory.
  Filename$ = "HELV12.GFN"
  IF GWFileSize&(Filename$) = -1 THEN GOTO FileError
  Filename$ = "HELV.QFN"
  IF GWFileSize&(Filename$) = -1 THEN GOTO FileError
  Filename$ = "SHADE.PCX"
  IF GWFileSize&(Filename$) = -1 THEN GOTO FileError
  Filename$ = "FONTS2.PCX"
  IF GWFileSize&(Filename$) = -1 THEN GOTO FileError
  Filename$ = "MOUNTAIN.PCX"
  IF GWFileSize&(Filename$) = -1 THEN GOTO FileError

  'All Files were found so return to the demo.
  EXIT SUB

FileError:
  PRINT "GWDEMO cannot find the file "; Filename$; " in the current directory."
  PRINT "Please re-install the Graphics Workshop Demo and then restart GWDEMO.EXE"
  END

END SUB

SUB ClearBenchArea STATIC
   
    LineBFVE 70, 80, 270, 280, 0
    LineBVE 69, 79, 271, 281, 15
    GPrint1VE 5, 19, "BASIC", 1
    LineBFVE 340, 80, 540, 280, 0
    LineBVE 339, 79, 541, 281, 15
    GPrint1VE 5, 47, "Graphics Workshop", 1

END SUB

SUB ClearBenchArea2 STATIC
   
    LineBFVE 69, 80, 271, 280, 0
    LineBVE 69, 79, 271, 161, 15
    LineBVE 69, 199, 271, 281, 15
    LineBFVE 339, 80, 541, 280, 0
    LineBVE 339, 79, 541, 161, 15
    LineBVE 339, 199, 541, 281, 15

END SUB

SUB DefineMenus (Menu$(), Stat%()) STATIC

  '----- Define the menues
Menu$(0, 0) = "File"
Menu$(1, 0) = "New Program"
Menu$(2, 0) = "Open Program..."
Menu$(3, 0) = "Merge..."
Menu$(4, 0) = "Save"
 Stat(4, 0) = 1
Menu$(5, 0) = "Save As..."
 Stat(5, 0) = 5 * 256
Menu$(6, 0) = "Save All"
 Stat(6, 0) = 2 * 256
Menu$(7, 0) = "-"
Menu$(8, 0) = "Create File..."
Menu$(9, 0) = "Load File..."
Menu$(10, 0) = "Unload File..."
 Stat(10, 0) = 1
Menu$(11, 0) = "-"
Menu$(12, 0) = "Print"
Menu$(13, 0) = "DOS Shell"
Menu$(14, 0) = "-"
Menu$(15, 0) = "Exit"
 Stat(15, 0) = 256

Menu$(0, 1) = "Edit"
Menu$(1, 1) = "Undo   Alt+Backspace"
 Stat(1, 1) = 1
Menu$(2, 1) = "Cut        Shift+Del"
 Stat(2, 1) = 2 * 256 + 1
Menu$(3, 1) = "Copy        Ctrl+Ins"
 Stat(3, 1) = 1
Menu$(4, 1) = "Paste      Shift+Ins"
Stat(4, 1) = 1
Menu$(5, 1) = "Clear            Del"
 Stat(5, 1) = 2 * 256 + 1
Menu$(6, 1) = "-"
Menu$(7, 1) = "New SUB..."
 Stat(7, 1) = 4 * 256
Menu$(8, 1) = "New FUNCTION..."
 Stat(8, 1) = 4 * 256

Menu$(0, 2) = "View"
Menu$(1, 2) = "SUBS...         F2"
Menu$(2, 2) = "Next SUB  Shift+F2"
 Stat(2, 2) = 1 * 256
Menu$(3, 2) = "Split"
 Stat(3, 2) = 1 * 256
Menu$(4, 2) = "-"
Menu$(5, 2) = "Next Statement"
 Stat(5, 2) = 1
Menu$(6, 2) = "Output Screen   F4"
 Stat(6, 2) = 1 * 256
Menu$(7, 2) = "-"
Menu$(8, 2) = "Included File"
 Stat(8, 2) = 1
Menu$(9, 2) = "Included Lines"
 Stat(9, 2) = 9 * 256

Menu$(0, 3) = "Search"
Menu$(1, 3) = "Find..."
Menu$(2, 3) = "Selected Text     Ctrl+\"
Menu$(3, 3) = "Repeat Last Find      F3"
Menu$(4, 3) = "Change..."
Menu$(5, 3) = "Label"

Menu$(0, 4) = "Run"
Menu$(1, 4) = "Start     Shift+F5"
Menu$(2, 4) = "Restart"
Menu$(3, 4) = "Continue        F5"
 Stat(3, 4) = 2 * 256
Menu$(4, 4) = "Modify COMMAND$..."
 Stat(4, 4) = 7 * 256
Menu$(5, 4) = "-"
Menu$(6, 4) = "Make EXE File..."
 Stat(6, 4) = 6 * 256
Menu$(7, 4) = "Make Library..."
 Stat(7, 4) = 5 * 256
Menu$(8, 4) = "-"
Menu$(9, 4) = "Set Main Module..."
 Stat(9, 4) = 4 * 256

Menu$(0, 5) = "Debug"
Menu$(1, 5) = "Add Watch..."
Menu$(2, 5) = "Instant Watch...   Shift+F9"
Menu$(3, 5) = "Watchpoint..."
Menu$(4, 5) = "Delete Watch..."
Menu$(5, 5) = "Delete All Watch"
 Stat(5, 5) = 2 * 256
Menu$(6, 5) = "-"
Menu$(7, 5) = "Trace On"
Menu$(8, 5) = "History On"
Menu$(9, 5) = "-"
Menu$(10, 5) = "Toggle Breakpoint        F9"
 Stat(10, 5) = 7 * 256
Menu$(11, 5) = "Clear All BreakPoints"
Menu$(12, 5) = "Break on Errors"
 Stat(12, 5) = 9 * 256
Menu$(13, 5) = "Set Next Statement"
 Stat(13, 5) = 1

Menu$(0, 6) = "Calls"
Menu$(1, 6) = "DEMOPLMS.BAS"

Menu$(0, 7) = "Options"
Menu$(1, 7) = " Display..."
 Stat(1, 7) = 1 * 256
Menu$(2, 7) = " Set Paths..."
 Stat(2, 7) = 5 * 256
Menu$(3, 7) = " Right Mouse..."
 Stat(3, 7) = 7 * 256
Menu$(4, 7) = "Syntax Checking"
 Stat(4, 7) = 1 * 256
Menu$(5, 7) = "Full Menus"
 Stat(5, 7) = 1 * 256

Menu$(0, 8) = "Help"
 Stat(0, 8) = 17

END SUB

SUB DemoHercules STATIC

  'Turn on the Hercules Graphics Mode using the GW screen mode routine
  CALL Screen3(0)

  'Draw some text on the top of the screen.
  CALL GPrint0H(1, 20, "This is the Hercules Graphics Screen mode", 1)
  CALL GPrint0H(2, 13, "It was set without requiring a TSR to have been loaded", 1)

  CALL GPrint0H(25, 28, " Press any key to continue ", 1 * 256)
  WHILE INKEY$ = "": WEND

  CALL GPrint0H(2, 12, "You can set individual pixels in Hercules Graphics modes", 1)
  'Draw random pixels on the screen
  FOR T = 1 TO 3000
    X = RND * 620 + 50
    Y = RND * 200 + 50
    CALL DrawPointH(X, Y, 1)
  NEXT

  CALL GPrint0H(25, 28, " Press any key to continue ", 1)
  WHILE INKEY$ = "": WEND

  'Clear the center section of the screen
  FOR Y = 50 TO 250
    CALL LineBAS(50, Y, 670, Y, 0)
  NEXT

  CALL GPrint0H(2, 12, "You can draw lines and circles in Hercules Graphics modes", 1)
  'Draw a line across the screen
  CALL LineBAS(100, 70, 500, 200, 1)
  CALL LineBAS(600, 90, 300, 260, 1)

  'Draw a circle in the center of the screen
  CALL CircleBAS(320, 200, 100, 1, 0, 0)
 
  CALL GPrint0H(25, 28, " Press any key to continue ", 1 * 256)
  WHILE INKEY$ = "": WEND

  'Clear the entire screen this time by drawing spaces
  FOR Row = 1 TO 25
    CALL GPrint0H(Row, 1, STRING$(80, 32), 1)
  NEXT
  CALL GPrint0H(11, 15, "Graphics Workshop's Hercules Abilities are limited to simple", 1)
  CALL GPrint0H(13, 15, "graphics primitives and .PCX file display.  More abilities", 1)
  CALL GPrint0H(15, 15, "will come in future versions of the Graphics Workshop.", 1)

  CALL GPrint0H(25, 28, " Press any key to continue ", 1)
  WHILE INKEY$ = "": WEND

  'Reset the screen back to text mode
  CALL Screen0(0)

END SUB

SUB DisplayInitialScreen (UniformSpeed%, ButtonArray%(), ButtonString$(), FirstTime, OriginalGPDat31%) STATIC

  CLS
  CALL SetGWSpacing(5, 5)
  Text$ = "Introducing"
  CALL OutlineText(60, 70, Text$, 20, 12, 4, 5)

  SetGWPages 0, 1   'Set the destination page to be the background page
  CALL GMove1VE(0, 0, 80, 349, 0, 0) 'copy the whole screen to the background
  SetGWPages 1, 0
 
  'Tell BASIC's graphics routines to work with the background screen (1) while
  'displaying the forground screen (0)
  SCREEN , , 1, 0

  CALL SetGWSpacing(2, 2)
  Text$ = "Graphics"
  CALL OutlineText(GPDat%(43) / 2 - GetOutlineWidth%(Text$) / (8 / 5), 65, Text$, 0, 14, 5, 4)
  Text$ = "Workshop"
  CALL OutlineText(GPDat%(43) / 2 - GetOutlineWidth%(Text$) / (8 / 5) - 5, 130, Text$, 0, 14, 5, 4)

  IF FirstTime THEN
    'If this is our first time through here, use the Fade2EGA routine to
    'transfer the small region of our background screen to this one.
    FOR a = 1 TO 5
      T = 0    'This variable is used to index into the grid region in the
	       'center of the screen.
      FOR S = 1 TO 4 * 17
	CALL Fade2EGA(T MOD 4 + 3, T \ 4 + 9, a)
	T = (T + 117) MOD 4 * 17
      NEXT
    NEXT
  ELSE
    'Transfer the entire background screen to the current screen
    'This will bring the words "Graphics Workshop" onto the visible screen
    CALL GMove1VE(0, 0, 80, 349, 0, 0)
  END IF

  CLS
  'Restore all of BASIC's commands to use the primary screen
  SCREEN , , 0, 0

  'Grab the shade created by the Graphics Workshop ShadeVertical routine that
  'was saved to the SHADE.PCX file.
  CALL DisplayPCXFile("SHADE.PCX", 1)
  IF OriginalGPDat31% = 8 AND FirstTime THEN
    'If the monitor that the demo is being shown on is a VGA, use its superior
    'palette abilities to bring in the shading effect gradually.
    'First set the bright-blue color to black (0,0,0)
    SetPalTripleVGA 1, 0, 0, 0
  END IF
  'Move the shading effect down to the bottom of the visual page.  Since the
  'palette is black for the color bright-blue (the only color in the .PCX
  'file) this next statement will appear to have no effect.
  GMove1VE 1, 0, 80, 252, 1, 198

  IF OriginalGPDat31% = 8 AND FirstTime THEN
    'Bring the color of the shade slowly up to bright-red
    FOR T = 10 TO 63
      T& = PDQTimer& + 1
      SetPalTripleVGA 1, T, 0, 0
      IF UniformSpeed THEN WHILE T& > PDQTimer&: WEND
    NEXT
    'Now make it bright-green
    FOR T = 10 TO 63
      T& = PDQTimer& + 1
      SetPalTripleVGA 1, 73 - T, T, 0
      IF UniformSpeed THEN WHILE T& > PDQTimer&: WEND
    NEXT
    'Finally, make it bright-blue
    FOR T = 10 TO 63
      T& = PDQTimer& + 1
      SetPalTripleVGA 1, 0, 73 - T, T
      IF UniformSpeed THEN WHILE T& > PDQTimer&: WEND
    NEXT
  END IF

  FirstTime = 0

  'Draw all four buttons on screen
  FOR T = 1 TO 4
    ButtonArray%(T, 3) = -1  'Make sure the button is not depressed at this time
    CALL DrawButton(ButtonArray%(T, 1), ButtonArray%(T, 2), ButtonString$(T), ButtonArray%(T, 3))
  NEXT

  CALL DrawText(220, 220, "PCX files and special effects", 0, 15, 1#)
  CALL DrawText(220, 270, "Additional Primitives Power", 0, 15, 1#)
  CALL DrawText(220, 320, "Graphics Primitives Benchmarks", 0, 15, 1#)

END SUB

SUB DrawButton (X%, Y%, Text$, UpOrDown%) STATIC

  HideCursor
  XD = (2 + GetWidth%(Text$) \ 10) * 10
  YD = 20
  Colr = 7
  IF UpOrDown% THEN ' Up
    Clr1 = 15
    Clr2 = 8
    LineBFVE X, Y, X + XD, Y + YD, Colr
    FOR T = 1 TO 2
      LineVE X - T, Y - T, X + XD + T, Y - T, Clr1
      LineVE X - T, Y - T, X - T, Y + YD + T, Clr1
      LineVE X - T + 1, Y + YD + T, X + XD + T, Y + YD + T, Clr2
      LineVE X + XD + T, Y + YD + T, X + XD + T, Y - T + 1, Clr2
    NEXT
    LineBVE X - T, Y - T, X + XD + T, Y + YD + T, 0
    CALL DrawText(X% + XD \ 2 - GetWidth%(Text$) \ 2, Y% + 5, Text$, 0, 0, 1#)
  ELSE
    Clr1 = 8
    LineBFVE X, Y, X + XD + 2, Y + YD + 2, Colr
    FOR T = 1 TO 2
      LineVE X - T, Y - T, X + XD + 2, Y - T, Clr1
      LineVE X - T, Y - T, X - T, Y + YD + 2, Clr1
    NEXT
    LineBVE X - T, Y - T, X + XD + T, Y + YD + T, 0
    LineBVE X - 2, Y - 2, X + XD + 2, Y + YD + 2, 0
    CALL DrawText(X% + XD \ 2 + 2 - GetWidth%(Text$) \ 2, Y% + 5 + 2, Text$, 0, 0, 1#)
  END IF
  ShowCursor

END SUB

SUB Pause STATIC

   'Pause until the user presses a key or presses either mouse button
   Down = 0
   WHILE INKEY$ = "" AND Down = 0
     ButtonPress 1, Down, Presses, MCol, MRow
   WEND

END SUB

SUB ResetPalette STATIC
  
   SetPaletteEGA 0, 0
   SetPaletteEGA 1, 1
   SetPaletteEGA 2, 2
   SetPaletteEGA 3, 3
   SetPaletteEGA 4, 4
   SetPaletteEGA 5, 5
   SetPaletteEGA 6, 18
   SetPaletteEGA 7, 7
   SetPaletteEGA 8, 56
   SetPaletteEGA 9, 57
   SetPaletteEGA 10, 58
   SetPaletteEGA 11, 59
   SetPaletteEGA 12, 60
   SetPaletteEGA 13, 61
   SetPaletteEGA 14, 62
   SetPaletteEGA 15, 63

END SUB

SUB ShowBenchmarks (UniformSpeed%) STATIC

CLS
GPrint0VE 1, 1, "                 Benchmark tests of BASIC vs. Graphics Workshop                 ", 15 + 4 * 256
GPrint0VE 25, 26, "Press any key to skip tests", 2
WHILE INKEY$ <> "": WEND

BenchLines:
'Defining a random list of lines to draw.  If the BASIC LINE statement were
'to have a different list of lines to draw than the Graphics Workshop LineVE
'routine, then the timing would not be reliable.  The reasoning is that it
'takes less time to draw a shorter line.  Using one set of random variables,
'will ensure that both routines perform the same amount of work.
REDIM LineData(999, 4)
FOR T = 0 TO 999
   LineData(T, 1) = RND * 198
   LineData(T, 2) = RND * 198
   LineData(T, 3) = RND * 198
   LineData(T, 4) = RND * 198
NEXT

ClearBenchArea
GPrint0VE 3, 20, "Testing BASIC's LINE statement 5000 times", 15 + 1 * 256

T1& = PDQTimer&
FOR T = 0 TO 4999
   a = LineData(T MOD 1000, 1) + 71
   B = LineData(T MOD 1000, 2) + 81
   c = LineData(T MOD 1000, 3) + 71
   d = LineData(T MOD 1000, 4) + 81
   Colr = (Colr + 1) MOD 16
   LINE (a, B)-(c, d), Colr
   IF InStat% > 0 THEN EXIT FOR
NEXT
T1& = PDQTimer& - T1&
ShowTime 22, 15, T1&

GPrint0VE 3, 12, "Testing Graphics Workshop's LineVE statement 5000 times", 15 + 1 * 256
T2& = PDQTimer&
IF InStat% = 0 THEN
   FOR T = 0 TO 4999
      a = LineData(T MOD 1000, 1) + 341
      B = LineData(T MOD 1000, 2) + 81
      c = LineData(T MOD 1000, 3) + 341
      d = LineData(T MOD 1000, 4) + 81
      Colr = (Colr + 1) MOD 16
      LineVE a, B, c, d, Colr
      IF InStat% > 0 THEN EXIT FOR
   NEXT
END IF
T2& = PDQTimer& - T2&
ShowTime 22, 51, T2&

GPrint0VE 3, 12, "    Timing the FOR NEXT loop used before 5000 times    ", 15 + 1 * 256
T3& = PDQTimer&
IF InStat% = 0 THEN
   FOR T = 0 TO 4999
      a = LineData(T MOD 1000, 1) + 341
      B = LineData(T MOD 1000, 2) + 81
      c = LineData(T MOD 1000, 3) + 341
      d = LineData(T MOD 1000, 4) + 81
      Colr = (Colr + 1) MOD 16
      IF InStat% > 0 THEN EXIT FOR
   NEXT
END IF
T3& = PDQTimer& - T3&
GPrint0VE 23, 18, "The FOR NEXT loop accounts for:", 2
ShowTime 23, 49, T3&
IF InStat% > 0 THEN
  LOCATE 12, 1
  MsgBoxG "Tests aborted by user.  Times shown below are for a pre-recorded test and reflect expected performance.", 40
  ShowTime 22, 15, 143
  ShowTime 22, 51, 127
  ShowTime 23, 49, 50
END IF
ERASE LineData
GPrint0VE 25, 23, "Press any key to perform next test", 2
 
IF InStat% > 0 THEN
  WHILE INKEY$ <> "": WEND
  Pause
  CALL MsgBoxG("", 40)
ELSE
  Pause
END IF

BenchCircle:
  WHILE INKEY$ <> "": WEND
  CLS
  Prop% = (GPDat%(49) * 32767&) / 1000
  GPrint0VE 1, 1, "                 Benchmark tests of BASIC vs. Graphics Workshop                 ", 15 + 4 * 256
  GPrint0VE 25, 23, "   Press any key to skip tests    ", 2
  'Defining a random list of lines to draw.  If the BASIC LINE statement were
  'to have a different list of lines to draw than the Graphics Workshop LineVE
  'routine, then the timing would not be reliable.  The reasoning is that it
  'takes less time to draw a shorter line.  Using one set of random variables,
  'will ensure that both routines perform the same amount of work.
  REDIM CircleData(999, 3)
  FOR T = 0 TO 999
    CircleData(T, 3) = RND * 98
    CircleData(T, 1) = CircleData(T, 3) + RND * (198 - CircleData(T, 3) * 2)
    CircleData(T, 2) = CircleData(T, 3) + RND * (198 - CircleData(T, 3) * 2)
  NEXT

  ClearBenchArea
  GPrint0VE 3, 17, "Testing BASIC's CIRCLE statement 1000 times", 15 + 1 * 256
  Colr = 0
  T1& = PDQTimer&
  FOR T = 0 TO 999
    a = CircleData(T MOD 1000, 1) + 71
    B = CircleData(T MOD 1000, 2) + 81
    c = CircleData(T MOD 1000, 3)
    Colr = (Colr + 1) MOD 16
    CIRCLE (a, B), c, Colr, , , GPDat%(49) / 1000
    IF InStat% > 0 THEN EXIT FOR
  NEXT
  T1& = PDQTimer& - T1&
  ShowTime 22, 15, T1&

  GPrint0VE 3, 14, "Testing Graphics Workshop's CircleVE statement 1000 times", 15 + 1 * 256
  Colr = 0
  T2& = PDQTimer&
  IF InStat% = 0 THEN
    FOR T = 0 TO 999
      a = CircleData(T MOD 1000, 1) + 341
      B = CircleData(T MOD 1000, 2) + 81
      c = CircleData(T MOD 1000, 3)
      Colr = (Colr + 1) MOD 16
      CircleVE a, B, c, Colr, 0, Prop%
      IF InStat% > 0 THEN EXIT FOR
    NEXT
  END IF
  T2& = PDQTimer& - T2&
  ShowTime 22, 51, T2&

  GPrint0VE 3, 14, "     Timing the FOR NEXT loop used before 1000 times     ", 15 + 1 * 256
  T3& = PDQTimer&
  IF InStat% = 0 THEN
    FOR T = 0 TO 999
      a = CircleData(T MOD 1000, 1) + 71
      B = CircleData(T MOD 1000, 2) + 81
      c = CircleData(T MOD 1000, 3)
      Colr = (Colr + 1) MOD 16
      IF InStat% > 0 THEN EXIT FOR
    NEXT
  END IF
  T3& = PDQTimer& - T3&
  GPrint0VE 23, 18, "The FOR NEXT loop accounts for:", 2
  ShowTime 23, 49, T3&

  IF InStat% > 0 THEN
    LOCATE 12, 1
    MsgBoxG "Tests aborted by user.  Times shown below are for a pre-recorded test and reflect expected performance.", 40
    ShowTime 22, 15, 117
    ShowTime 22, 51, 108
    ShowTime 23, 49, 2
  END IF
  ERASE CircleData
  GPrint0VE 25, 23, "Press any key to perform next text", 2
  IF InStat% > 0 THEN
    WHILE INKEY$ <> "": WEND
    Pause
    CALL MsgBoxG("", 40)
  ELSE
    Pause
  END IF

BenchPixels:
WHILE INKEY$ <> "": WEND
CLS
GPrint0VE 1, 1, "                 Benchmark tests of BASIC vs. Graphics Workshop                 ", 15 + 4 * 256
GPrint0VE 25, 23, "   Press any key to skip tests    ", 2
ClearBenchArea2
NumTests& = 3& * (160 - 81) * (270 - 71)
GPrint0VE 3, 19, "Testing the speed of changing" + STR$(NumTests&) + " pixels", 15 + 1 * 256
Text$ = "BASIC's"
DrawText 140, 105, Text$, 0, 9, 1#
Text$ = "POINT and PSET"
DrawText 106, 125, Text$, 0, 9, 1#
T1& = PDQTimer&
FOR M = 0 TO 2
  FOR S = 81 TO 159
    FOR T = 71 TO 269
      V = POINT(T, S)
      PSET (T, S), V + 1
    NEXT
    IF InStat% > 0 THEN EXIT FOR
  NEXT
  IF InStat% > 0 THEN EXIT FOR
NEXT
T1& = PDQTimer& - T1&
ShowTime 13, 15, T1&

Text$ = "GetPointVE% and"
DrawText 370, 105, Text$, 0, 9, 1#
Text$ = "DrawPointVE%"
DrawText 380, 125, Text$, 0, 9, 1#
T2& = PDQTimer&
IF InStat% = 0 THEN
  FOR M = 0 TO 2
    FOR S = 81 TO 159
      FOR T = 341 TO 539
	V = GetPointVE%(T, S)
	DrawPointVE T, S, V + 1
      NEXT
      IF InStat% > 0 THEN EXIT FOR
    NEXT
    IF InStat% > 0 THEN EXIT FOR
  NEXT
END IF
T2& = PDQTimer& - T2&
ShowTime 13, 51, T2&

Text$ = "GetCacheVE% and"
DrawText 100, 225, Text$, 0, 9, 1#
Text$ = "ReDrawVE"
DrawText 130, 245, Text$, 0, 9, 1#
T3& = PDQTimer&
IF InStat% = 0 THEN
  FOR M = 0 TO 2
    FOR S = 201 TO 279
      FOR T = 71 TO 269
	V = GetCacheVE%(T, S)
	ReDrawVE V + 1
      NEXT
      IF InStat% > 0 THEN EXIT FOR
    NEXT
    IF InStat% > 0 THEN EXIT FOR
  NEXT
END IF
T3& = PDQTimer& - T3&
ShowTime 22, 15, T3&

Text$ = "PaintByte and"
DrawText 390, 225, Text$, 0, 9, 1#
Text$ = "PaintBits"
DrawText 410, 245, Text$, 0, 9, 1#
T4& = PDQTimer&
'PaintBits and PaintBytes are structured differently, and perform a POINT
'and PSET in one statement.
IF InStat% = 0 THEN
  FOR M = 0 TO 2
    FOR T = 201 TO 279
      PaintBits 43, T, 7, M, M + 1
      FOR S = 44 TO 67
	PaintByte S, T, M, M + 1
	PaintByte S, T, M + 9, M + 10
      NEXT
      PaintBits 68, T, 240, M, M + 1
      IF InStat% > 0 THEN EXIT FOR
    NEXT
    IF InStat% > 0 THEN EXIT FOR
  NEXT
END IF
T4& = PDQTimer& - T4&
ShowTime 22, 51, T4&

T5& = PDQTimer&
IF InStat% = 0 THEN
  FOR M = 0 TO 2
    FOR S = 201 TO 279
      FOR T = 71 TO 269
      NEXT
      IF InStat% > 0 THEN EXIT FOR
    NEXT
    IF InStat% > 0 THEN EXIT FOR
  NEXT
END IF
T5& = PDQTimer& - T5&
GPrint0VE 23, 18, "The FOR NEXT loop accounts for:", 2
ShowTime 23, 49, T5&

IF InStat% > 0 THEN
  LOCATE 15, 1
  MsgBoxG "Tests aborted by user.  Times shown below are for a pre-recorded test and reflect expected performance.", 40
  ShowTime 13, 15, 262
  ShowTime 13, 51, 183
  ShowTime 22, 15, 168
  ShowTime 22, 51, 26
  ShowTime 23, 49, 24
END IF
GPrint0VE 25, 23, "Press any key to perform next text", 2
IF InStat% > 0 THEN
  WHILE INKEY$ <> "": WEND
  Pause
  CALL MsgBoxG("", 40)
ELSE
  Pause
END IF

BenchPrints:
WHILE INKEY$ <> "": WEND
CLS
GPrint0VE 1, 1, "                 Benchmark tests of BASIC vs. Graphics Workshop                 ", 15 + 4 * 256
GPrint0VE 25, 26, "Press any key to skip tests", 2
ClearBenchArea
GPrint0VE 3, 20, "Testing BASIC's PRINT statement 800 times", 15 + 1 * 256
T1& = PDQTimer&
FOR T = 0 TO 799
   LOCATE 7 + T MOD 14, 15
   PRINT "BASIC's PRINT"
   Colr = (Colr + 1) MOD 16
   COLOR Colr
   IF InStat% > 0 THEN EXIT FOR
NEXT
T1& = PDQTimer& - T1&
ShowTime 22, 17, T1&

GPrint0VE 3, 11, "Testing Graphics Workshop's GPrint0VE statement 800 times", 15 + 1 * 256
T2& = PDQTimer&
IF InStat% = 0 THEN
   FOR T = 0 TO 799
      GPrint0VE 7 + T MOD 14, 50, "GW's GPrint0VE", Colr
      Colr = (Colr + 1) MOD 16
      IF InStat% > 0 THEN EXIT FOR
   NEXT
END IF
T2& = PDQTimer& - T2&
ShowTime 22, 51, T2&

GPrint0VE 3, 11, "    Timing the FOR NEXT loop used before 800 times       ", 15 + 1 * 256
T3& = PDQTimer&
IF InStat% = 0 THEN
   FOR T = 0 TO 799
      Colr = (Colr + 1) MOD 16
      IF InStat% > 0 THEN EXIT FOR
   NEXT
END IF
T3& = PDQTimer& - T3&
GPrint0VE 23, 18, "The FOR NEXT loop accounts for:", 2
ShowTime 23, 49, T3&
IF InStat% > 0 THEN
  LOCATE 12, 1
  MsgBoxG  _
"Tests aborted by user.  Times shown below are for a pre-recorded test and reflect performance on only one machine.  BASIC uses the BIOS, so the speed is dependant upon the speed of your customers machine.  GPrint0VE is machine independant.", 60
  ShowTime 22, 15, 256
  ShowTime 22, 51, 38
  ShowTime 23, 49, 1
ELSE
  Text$ = "Note that the speed of the BASIC PRINT statement you just witnessed was for this particular machine.  "
  Text$ = Text$ + "BASIC uses the BIOS, and each machine's BIOS is different.  One of the worst VGA BIOS cases found "
  Text$ = Text$ + "was 25.0 seconds for BASIC versus 2.1 seconds for Graphics Workshop's GPrint0VE."
  MsgBoxG Text$, 60
END IF
GPrint0VE 25, 23, "Press any key to perform next test", 2
IF InStat% > 0 THEN
  WHILE INKEY$ <> "": WEND
  Pause
ELSE
  Pause
END IF
CALL MsgBoxG("", 60)

END SUB

SUB ShowPCXEffects (UniformSpeed%) STATIC

  '============== Draw a screen describing the Vector Fonts
  SetGWPages 0, 1
  SCREEN , , 1, 0
  LineBFVE 0, 0, 639, 349, 1
  LineBFVE 10, 10, 200, 209, 7
  CALL SetGWSpacing(3, 3)
  CALL OutlineText(30, 20, "G", 0, 15, 4, 1)
  GPDat%(86) = -1
  CALL OutlineText(30, 20, "G", 0, 0, 4, 1)
  GPDat%(86) = 0
  CALL OutlineText(210, 10, "raphics Workshop", 0, 0, 1, 1)
  GPDat%(86) = -1
  CALL OutlineText(210, 10, "raphics Workshop", 0, 15, 1, 1)
  GPDat%(86) = 0

  CALL SetGWSpacing(4, 4)
  CALL OutlineText(225, 90, "has  large", 0, 14, 7, 8)

  LineVE 0, 279, 639, 70, 14
  LineVE 165, 349, 639, 190, 14
  PAINT (0, 349), 4, 14
  CALL OutlineText(225, 220, "Vector", 27, 1, 9, 4)
  GPDat%(86) = -1
  CALL OutlineText(225, 220, "Vector", 27, 14, 9, 4)
  GPDat%(86) = 0

  CALL OutlineText(500, 253, "fonts", 0, 14, 7, 8)

  Text$ = "Press Any Key to Continue"
  CALL DrawText(320, 325, Text$, 0, 15, 1#)

  SetGWPages 1, 0
  SCREEN , , 0, 0

  'The screen has been drawn on the background screen.
  'Now use the GMove1VE routine to transfer small blocks of the image.
  'We will break up the screen into a grid region 40 blocks wide by 20
  'blocks high.
  '
  '              The values in the Grid represent the value of M that
  '              will access that grid location.
  '
  '     Col1   2   3  ...
  'Grid: +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  ' Row 1| 1 | 2 | 3 | 4 | 5 | 6 | 7 |  ...  | 33| 34| 35| 36| 37| 38| 39| 40|
  '      +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  ' Row 2| 41| 42| 43| 44| 45| 46| 47|  ...  | 73| 74| 75| 76| 77| 78| 79| 80|
  '      +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  ' Row 3| 81| 82| 83| 84| 85| 86| 87|  ...  |   |   |   |   |   |   |   |   |
  '   .
  '   .
  '   .
  '
  S = 0
  X = 1
  Y = 0
  M = 0    'M will tell us where in the grid we are
  'S will count to 50 and d will count to 16.  The combination will count to
  '800 blocks which is just the number we have to transfer.  The blocks are
  'done 16 at a time to make the timer work out on fast machines.
  WHILE S < 50
    T& = PDQTimer&
    FOR d = 1 TO 16
      'The MOD and \ operators allow us to take the value in M and break it
      'up into the grid.
      CALL GMove1VE((M MOD 40) * 2, (M \ 40) * 20, 2, 20, (M MOD 40) * 2, (M \ 40) * 20)
      M = (M + 277) MOD 40 * 20
    NEXT
    IF UniformSpeed THEN WHILE PDQTimer& <= T&: WEND
    S = S + 1
  WEND


  'The screen is completely visible, now load the next screen image from the
  'PCX file on the disk.  Load it before the pause is ready, to give the
  'appearance of being ready instantaneously.
  CALL DisplayPCXFile("Fonts2.PCX", 1)        'loaded to background screen
  Pause

  'Each of the four quadrants will be moved in from its respective sides.
  CALL SlideUp(1, 0, 40, 174, 1, 0)
  CALL SlideRight(41, 0, 80, 174, 41, 0)
  CALL SlideLeft(1, 175, 40, 349, 1, 175)
  CALL SlideDown(41, 175, 80, 349, 41, 175)

  Pause
  'Clear the current screen
  LineBFVE 0, 0, 639, 349, 0
  'Draw a red box in the center of the screen to act as a viewport.
  LineBVE 159, 86, 480, 262, 4
  Text$ = "Panning images"
  CALL DrawText(320 - GetWidth%(Text$) \ 2, 280, Text$, 0, 4, 1#)

  'When we load the image, its palette will take over and the screen will
  'turn yellow, however the box and the text will stay a shade of red.
  CALL DisplayPCXFile("MOUNTAIN", 1)

  'Use the GMove1VE routine to move a chunk of the image to our center
  'viewport.  The viewport is located at Column 21, Line 87.
  'Step to the right from the upper-left corner, successively placing the
  'image in the viewport.
  FOR T = 1 TO 41
    T& = PDQTimer&
    CALL GMove1VE(T, 0, 40, 175, 21, 87)
    IF UniformSpeed THEN WHILE T& >= PDQTimer&: WEND
  NEXT
  'This FOR NEXT loop will move down the right side of the image
  FOR T = 5 TO 175 STEP 5
    T& = PDQTimer&
    CALL GMove1VE(41, T, 40, 175, 21, 87)
    IF UniformSpeed THEN WHILE T& >= PDQTimer&: WEND
  NEXT
  'This FOR NEXT loop will move left along the bottom of the image
  FOR T = 41 TO 1 STEP -1
    T& = PDQTimer&
    CALL GMove1VE(T, 175, 40, 175, 21, 87)
    IF UniformSpeed THEN WHILE T& >= PDQTimer&: WEND
  NEXT
  'This FOR NEXT loop will move up along the left side of the image
  FOR T = 175 TO 5 STEP -5
    T& = PDQTimer&
    CALL GMove1VE(1, T, 40, 175, 21, 87)
    IF UniformSpeed THEN WHILE T& >= PDQTimer&: WEND
  NEXT
  'This FOR NEXT loop will move diagonally from the upper-left corner to the
  'center of the image.
  FOR T = 1 TO 21
    T& = PDQTimer&
    CALL GMove1VE(T, T * 4, 40, 175, 21, 87)
    IF UniformSpeed THEN WHILE T& >= PDQTimer&: WEND
  NEXT
  'This FOR NEXT loop will expand the image viewport to full size.
  FOR T = 21 TO 1 STEP -1
    T& = PDQTimer&
    CALL GMove1VE(T, T * 4, 40 + (21 - T) * 2, 175 + (21 - T) * 8, T, T * 4)
    IF UniformSpeed THEN WHILE T& >= PDQTimer&: WEND
  NEXT
  'Since it is possible to not always get the calculations right in the above
  'FOR NEXT loop so that the complete image was visible, this next statement
  'simply moves the entire image one last time to the whole screen.
  CALL GMove1VE(1, 0, 80, 350, 1, 0)
 
  'Set the background color of the screen (for shadow effects) to 15 which
  'in this particular graphic does not appear where we are going to place
  'the message box.
  GPDat%(57) = 15
  'Change the colors of the Message Box
  Old75% = GPDat%(75)
  GPDat%(75) = 13
  ' and the Message Box text
  Old76% = GPDat%(76)
  GPDat%(76) = 12
  LOCATE 20, 1
  MsgBoxG "Press Any Key To Continue", 25
  Pause

  'Restore the Message box colors.  The same colors are used by the menu
  'system in another section of the GWDEMO.BAS example program.  Not restoring
  'the colors might produce an unexpected color change in the other section
  'of the demo.
  GPDat%(75) = Old75%
  GPDat%(76) = Old76%
  SetPaletteEGA 0, 0 'First we are going to reset the color black's palette
  CLS                'Now when we clear the screen it will go to black
  CALL ResetPalette  'Now we can reset the rest of the palette

END SUB

SUB ShowPrimitives (UniformSpeed%, Menu$(), Stat%()) STATIC

  CLS
  'Draw some sample geometric shapes to draw over
  LineBFVE 100, 100, 200, 200, 2        'box
  LineBVE 100, 100, 200, 200, 15

  CircleVE 320, 200, 100, 15, 0, 0      'sphere
  PAINT (320, 200), 1, 15

  LineVE 450, 200, 550, 200, 15         'triangle
  LineVE 550, 200, 500, 120, 15
  LineVE 500, 120, 450, 200, 15
  PAINT (500, 150), 4, 15

  Text$ = "Lines and Circles can use an XOR ability to pass over existing objects."
  CALL DrawText(320 - GetWidth%(Text$) \ 2, 20, Text$, 0, 15, 1#)

  Text$ = "Press any key to skip"
  CALL DrawText(320 - GetWidth%(Text$) \ 2, 320, Text$, 0, 15, 1#)

  'This next algorithm has two parts.  One is a line which is spiralling
  'across the middle of the screen.  The other is a bouncing circle.
  'Variables beginning with the letter L are for the spiralling line, and
  'ones beginning with the letter C are for the bouncing circle.
  T = 100        'Relative position of both the circle and the line
  TD = 1         'Direction of the line and circle (1 means line going right and circle going left)
  CHeight = 50   'Y Pixel location of the center of the circle
  CBounce = 10   'Amount to change the position of the circle next time
		 'CBounce is modified below to look like a bouncing ball
  FOR M = 1 TO 2   'Simply repeat this two times
    'Force that the line and circle won't be removed on the first pass
    LXDeltaOld = -200
    LAngle! = 0
    WHILE T > 99 AND T < 541
      'Compute the locations of the two endpoints of the rotating line
      LXDelta = COS(LAngle!) * 100  's1
      LYDelta = SIN(LAngle!) * 100  't1
      'Draw the line and the circle on the screen
      CircleVE 590 - T, 50 + CHeight, 50, 15 + 24 * 256, 0, 0
      LineVE T - LXDelta, 175 + LYDelta, T + LXDelta, 175 - LYDelta, 15 + 24 * 256
      'If we've drawn them once before, then remove the old image
      IF LXDeltaOld <> -200 THEN
	CircleVE 590 + TD - T, 50 + CHeightOld, 50, 15 + 24 * 256, 0, 0
	LineVE T - TD - LXDeltaOld, 175 + LYDeltaOld, T - TD + LXDeltaOld, 175 - LYDeltaOld, 15 + 24 * 256
      END IF
      'Keep track of the last place the line and circle were located
      LXDeltaOld = LXDelta
      LYDeltaOld = LYDelta
      CHeightOld = CHeight
      'Change the position of the circle
      CHeight = CHeight + CBounce
      IF CHeight > 250 THEN
	'Reverse the direction of the bounce
	CBounce = -1 * CBounce
	CHeight = CHeight + CBounce
      END IF
      'Decrease the bounce value; if it is a negative value the ball will be
      'traveling upward.  Once it reaches the top of the screen the value
      'will slowly become negative.  When it reaches the bottom of the screen
      'it will be very positive.  At this time four code lines above it will
      'get multiplied by a -1 making it a very negative value.  Then it will
      'be moving in a upward direction again.
      CBounce = CBounce + 2
      LAngle! = LAngle! + .1
      T = T + TD
      a$ = INKEY$
      GetCursor MouseX, MouseY, Button
      IF Button <> 0 THEN a$ = " "'If they've pressed a mouse button fake a key
      IF a$ <> "" THEN
	CircleVE 590 + TD - T, 50 + CHeightOld, 50, 15 + 24 * 256, 0, 0
	LineVE T - TD - LXDeltaOld, 175 + LYDeltaOld, T - TD + LXDeltaOld, 175 - LYDeltaOld, 15 + 24 * 256
	EXIT FOR
      END IF
    WEND
    'Remove the line and circle from the screen.
    CircleVE 590 + TD - T, 50 + CHeightOld, 50, 15 + 24 * 256, 0, 0
    LineVE T - TD - LXDeltaOld, 175 + LYDeltaOld, T - TD + LXDeltaOld, 175 - LYDeltaOld, 15 + 24 * 256
    TD = TD * -1
    T = T + TD
  NEXT

  'Clear only the top of the screen where the previous text explanation was.
  LineBFVE 0, 0, 639, 80, 0
  Text$ = "Lines and Circles can use an XOR ability to give a rubber band effect."
  CALL DrawText(320 - GetWidth%(Text$) \ 2, 20, Text$, 0, 15, 1#)
 
  'This time the line and the circle will be streching over the objects, not
  'just passing over them, but changing in size.
  'First draw a copy of the lines and the circle
  LineVE 0, 0, 0, 99, 14 + 24 * 256
  LineVE 0, 100, 0, 349, 14 + 24 * 256
  CircleVE 320, 174, 0, 14 + 24 * 256, 0, 0
  T = 0
  TD = 7
  FOR M = 1 TO 4
    WHILE T >= 0 AND T <= 174
      LineVE 0, 0, T * 2, 99, 14 + 24 * 256
      LineVE 0, 349, T * 2, 100, 14 + 24 * 256
      T = T + TD
      LineVE 0, 0, T * 2, 99, 14 + 24 * 256
      LineVE 0, 349, T * 2, 100, 14 + 24 * 256
      T = T - TD
      CircleVE 320, 174, T, 14 + 24 * 256, 0, 0
      T = T + TD
      CircleVE 320, 174, T, 14 + 24 * 256, 0, 0
      a$ = INKEY$
      GetCursor MouseX, MouseY, Button
      IF Button <> 0 THEN a$ = " " 'If they've pressed a mouse button fake a key
      IF a$ <> "" THEN EXIT FOR
    WEND
    LineVE 0, 0, T * 2, 99, 14 + 24 * 256
    LineVE 0, 349, T * 2, 100, 14 + 24 * 256
    CircleVE 320, 174, T, 14 + 24 * 256, 0, 0
    TD = TD * -1
    T = T + TD
    LineVE 0, 0, T * 2, 99, 14 + 24 * 256
    LineVE 0, 349, T * 2, 100, 14 + 24 * 256
    CircleVE 320, 174, T, 14 + 24 * 256, 0, 0
  NEXT

  'Color the screen blue
  LineBFVE 0, 0, 639, 349, 1
  'and tell the menu system that the shadow color to replace is blue
  GPDat%(57) = 1

  'Draw three copies of the Crescent Software logo
  CALL CSLogo(20, 20, .75, 15)
  CALL CSLogo(120, 50, 1.5, 15)
  CALL CSLogo(320, 100, 2.5, 15)
  
  'Place an explantion message box at the bottom of the screen
  LOCATE 20, 1
  MsgBoxG "Included is an SAA compliant pull down menu system which runs in graphics mode and even has a shadow effect.", 60

  'Turn on the mouse cursor.  The pull down menu system is completely
  'mousable
  ShowCursor

  BarPrintMSG Menu$(), Stat()           'Display the menu bar and build a
					'  table of Hot Keys for menu bar.

  Action = 0                            'Action 0 (no polling) is the easiest
					'  way to use PullDown.
  DO
    Ky$ = INKEY$                        'Get a key press from the buffer
					'See if it's a hot-key or mouse
					'  pressed on menu bar.
    Menu = PullMenKeyMSG%(Ky$, Menu$(), Stat())
    IF Menu > -1 THEN                   'Yes
      PullDnMSG Menu$(), Stat(), Menu, Choice, Ky$, Action
      '----- Code to handle the selection would go here
      '----- Example:
      'IF Ky$ = CHR$(13) THEN
      '  SELECT CASE Menu                'Branch according to "Menu"
      '    '----- File Menu
      '    CASE 0
      '      SELECT CASE Choice          'Branch according to "Choice"
      '         '----- New Program
      '         CASE 1
      '            NewProgram            'Call your "NewProgram" procedure
      '         '----- Open Program
      '         CASE 2
      '            OpenProgram           'Call your "OpenProgram" procedure
      'Etc.
      'END IF
    END IF
    '----- Your code to handle key presses would go here
    '..
    '..
  LOOP UNTIL Ky$ = CHR$(13) OR Ky$ = CHR$(27)

  'Turn the mouse cursor off since the other demonstration sections don't
  'benefit from having the mouse cursor on.
  HideCursor

  'This next routine will draw what appears to be the font editor.  It is
  'not functional, but provides the users with the appearance of the font
  'editor.
  CALL SimulateFontEditor

  GPrint0VE 25, 27, "Press any key to continue", 14

  LOCATE 19, 1
  MsgBoxG "Simple Font Editors supplied with Graphics Workshop allow you to modify existing fonts, and to create new additional fonts.", 50

  Pause

END SUB

SUB ShowTime (Row, Col, T&) STATIC

    a = T& MOD 18
    T$ = STR$(T& \ 18) + "." + MID$(STR$(a \ 2), 2) + " Seconds  "
    GPrint0VE Row, Col, T$, 14

END SUB

SUB SimulateFontEditor STATIC

  'The contents of this subroutine will simulate the FONT64 vector font
  'editor
  CLS
  LINE (0, 0)-(2, 2), 14, B
  DIM Cursor(100)
  GET (0, 0)-(2, 2), Cursor
  PUT (0, 0), Cursor, XOR
  LINE (1, 21)-(257, 277), 1, BF
  LINE (0, 20)-(258, 278), 2, B
  CALL SetGPFont(1)
 
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

  '----- Draw the simulated Menu Choices here
  CALL GPrint0VE(1, 1, " File  Edit  Draw  F1=Help              (  0,   0)                              ", GPDat%(74))

  a$ = "A"
  LINE (1, 21)-(257, 277), 0, BF
  CALL DrawText(1, 21, a$, 0, 4, 15#)
  FOR T1 = 1 TO 64
    FOR T2 = 1 TO 64
      CALL DrawPointVE(T1 * 4 - 1, T2 * 4 + 19, 7)
    NEXT
  NEXT
  CALL GPrint0VE(19, 40, "Character: [" + a$ + "]", 7)

  CALL OutlineText(301, 21, "A", 0, 7, 1, 1)
  CALL OutlineText(381, 71, "A", 0, 7, 1, 4)
  CALL OutlineText(381, 21, "A", 0, 7, 1, 2)
  CALL OutlineText(301, 101, "A", 0, 7, 2, 1)
  CALL OutlineText(442, 80, "A", 30, 7, 2, 1)
 
  GPDat%(86) = -1
  CALL OutlineText(2, 22, "A", 0, 15, 4, 1)
 
  CALL OutlineText(301, 21, "A", 0, 15, 1, 1)
  CALL OutlineText(381, 21, "A", 0, 15, 1, 2)
  CALL OutlineText(381, 71, "A", 0, 15, 1, 4)
  CALL OutlineText(301, 101, "A", 0, 15, 2, 1)
  CALL OutlineText(442, 80, "A", 30, 15, 2, 1)
  GPDat%(86) = 0

END SUB

