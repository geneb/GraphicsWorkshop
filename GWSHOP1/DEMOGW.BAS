'***** DemoGW.BAS

'Copyright 1990, Brian C. Giedt

'This Demonstrates the routines:
'   DrawText     - A basic subroutine which displays one of the GraphPak
'                  fonts.
'   OutlineText  - A basic subroutine which displays the GW vector font.
'                  These fonts are very large scale and should be used for
'                  drawing large fonts (small fonts should be drawn using
'                  DrawText above).

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB ShadeV (Col1%, Line1%, Col2%, Line2%, NumColors%, StepChoice%, Colors%())

'$INCLUDE: 'GetVideo.Bas'

'$INCLUDE: 'GPFont.GW'   'Setup font arrays for GraphPak fonts
FontFile$ = "Helv12"
CALL SetGPFont(1)               'specify loading font number 1
CALL LoadFont(FontFile$)        'load fonts from disk into the Font$() array

'$INCLUDE: 'GWFont.GW'  'Setup font arrays for GW vector fonts
FontFile$ = "HELV"
CALL SetGWFont(1)              'specify loading GW font number 1
CALL LoadOutlineFont(FontFile$) 'load fonts from disk into the Font$() array


GPDat%(31) = 5  'Force EGA for this demo

CALL SetVideo                   'Using this routine to set the screen mode
				'gives you variables for the edge of the
				'screen, aspect ratio of the screen, and
				'more...

PRINT "Prepping..."

'First Draw the Title of the package to the background screen
SCREEN , , 1, 0
CLS
CALL SetGWPages(1, 1)
Text$ = "Graphics"
A1 = GetOutlineWidth%(Text$)
CALL OutlineText(320 - A1, 10, Text$, 0, 12, 2, 1)
Text$ = "Workshop"
A2 = GetOutlineWidth%(Text$)
CALL OutlineText(320 - A2 \ 2, 110, Text$, 0, 13, 1, 1)
REDIM Colors%(4)
Colors%(0) = 0
Colors%(1) = 1
Colors%(2) = 9
CALL ShadeV(1, 180, 80, 349, 2, 11, Colors%())
SCREEN , , 0, 0
CALL SetGWPages(1, 0)

CLS
CALL SplitHorizontal(1, 10, 80, 109, 1, 10)
CALL SplitHorizontal(1, 110, 80, 110 + GPDat%(85), 1, 110)
CALL SlideUp(1, 180, 80, 349, 1, 180)

Text$ = "Routines already demonstrated :"
CALL DrawText(10, 180, Text$, 0, 15, 1#)
Text$ = "OutlineText,  GMove3VE,  ShadeVertical,  GMove1VE"
CALL DrawText(50, 200, Text$, 0, 14, 1#)
Text$ = "Routines to come:"
CALL DrawText(10, 220, Text$, 0, 15, 1#)
Text$ = "Printing :"
CALL DrawText(50, 240, Text$, 0, 14, 1#)
Text$ = "GPrint0VE,  GPrint1VE,  GPrint2VE,  GPrint3VE"
CALL DrawText(130, 240, Text$, 0, 14, 1#)
Text$ = "Pixels :"
CALL DrawText(50, 260, Text$, 0, 14, 1#)
Text$ = "GetPointVE,  DrawPointVE,  ReDrawVE,  PaintByte"
CALL DrawText(130, 260, Text$, 0, 14, 1#)
Text$ = "Lines :"
CALL DrawText(50, 280, Text$, 0, 14, 1#)
Text$ = "LineVE (with a XOR ability)"
CALL DrawText(130, 280, Text$, 0, 14, 1#)
Text$ = "Press any key to continue"
CALL DrawText(320 - GetWidth%(Text$) / 2, 320, Text$, 0, 15, 1#)

WHILE INKEY$ = "": WEND

CALL LineBFVE(0, 0, GPDat%(43), GPDat%(44), 1)
GPDat%(57) = 1    'Tell the GPaintBox routine what color is our overall
		  ' background color

FOR T = 1 TO 50            'Make a backdrop for the demo
   X = RND * 230
   Y = RND * 50
   XD = RND * 200
   C = RND * 15 + 1
   CIRCLE (X, Y), XD, C
NEXT


'----- Define the Menu Choices here
REDIM Stat(16, 8)                       'define the choice status array
Stat(12, 1) = 1                         'this is how you'd deactivate an item
					'  in this case, item 12 in menu 1

REDIM Choice$(16, 8)                    'Allocate space for the Menu Choices
FOR C = 0 TO 16                         'read the Menu Choices into the Array
    FOR M = 1 TO 8
	READ Choice$(C, M)              'read the list of choices
    NEXT
NEXT

DATA "File",            "Edit",                 "View",               "Search",                   "Run",                "Debug",                   "Calls",        "F1=Help"
DATA "New Program",     "Undo   Alt+Backspace", "SUBS...         F2", "Find...",                  "Start     Shift+F5", "Add Watch...",            "DEMOPULL.BAS", ""
DATA "Open Program...", "Cut        Shift+Del", "Next SUB  Shift+F2", "Selected Text     Ctrl+\", "Restart",            "Watchpoint...",           "",             ""
DATA "Merge...",        "Copy        Ctrl+Ins", "Split",              "Repeat Last Find      F3", "Continue        F5", "Delete Watch...",         "",             ""
DATA "Save",            "Paste      Shift+Ins", "-",                  "Change...",                "Modify COMMAND$...", "Delete All Watch",        "",             ""
DATA "Save As...",      "-",                    "Next Statement",     "Label",                    "-",                  "-",                       "",             ""
DATA "Save All",        "New SUB...",           "Output Screen   F4", "",                         "Make EXE File...",   "Trace On",                "",             ""
DATA "-",               "New FUNCTION...",      "-",                  "",                         "Make Library...",    "History On",              "",             ""
DATA "Create File...",  "-",                    "Include File",       "",                         "",                   "-",                       "",             ""
DATA "Load File...",    "û Syntax Checking",    "Included Lines",     "",                         "",                   "Toggle Breakpoint    F9", "",             ""
DATA "Unload File...",  "",                     "-",                  "",                         "",                   "Clear All BreakPoints",   "",             ""
DATA "-",               "",                     "Options...",         "",                         "",                   "Set Next Statement",      "",             ""
DATA "Print",           "",                     "",                   "",                         "",                   "",                        "",             ""
DATA "-",               "",                     "",                   "",                         "",                   "",                        "",             ""
DATA "DOS Shell",       "",                     "",                   "",                         "",                   "",                        "",             ""
DATA "-",               "",                     "",                   "",                         "",                   "",                        "",             ""
DATA "Exit",            "",                     "",                   "",                         "",                   "",                        "",             ""

Choice$(0, 0) = "ð"       'This is the old Microsoft Help Icon.  There are no
			  'choices for this selection.  This is to illustrate
			  'that you may include a choice that has no menu,
			  'when there are no further options.

GPrint0VE 12, 40, "The GPrint0VE routine allows you to", 1 * 256 + 15
GPrint0VE 13, 40, "create this wonderful Pulldown menu ", 1 * 256 + 15
GPrint0VE 14, 40, "system in graphics mode.  BASIC just", 1 * 256 + 15
GPrint0VE 15, 40, "couldn't do it.", 1 * 256 + 15

GPrint0VE 17, 40, "Another thing no-one else has is this", 1 * 256 + 15
GPrint0VE 18, 40, "shadow effect for graphics mode.", 1 * 256 + 15


Action = 0                'Action 1 will setup the PullDown Menu and return
Menu = 1                  'start PullDown by displaying Menu 1
Choice = 1                'start with Choice #1 highlighted

CALL PullDownG(Choice$(), Stat(), Menu, Choice, Ky$, Action)

'When User hits a key we are done

CLS

CIRCLE (400, 175), 150, 4
PAINT (400, 175), 4, 4

GPrint1VE 12, 10, "The GPrint1VE routine allows you to ignore the background", 1 * 256 + 15
GPrint1VE 13, 10, "color and print text directly over any graphics image.", 1 * 256 + 15

WHILE INKEY$ = "": WEND

CLS
CALL LineBFVE(63, 8, 568, 340, 1)
CALL LineBVE(63, 8, 568, 340, 15)
T = 10
WHILE T < 350
    'Notice that GPrint2VE wipes out part of the earlier printed strings with
    ' its background color, while GPrint3EGA merely adds to the image already
    ' on the screen
    GPrint2VE T, 11, "GPrint2VE and", 15 + 256 * 1
    GPrint3VE T, 25, "GPrint3VE can print text at any line position", 15 + 256 * 1
    T = T * 1.2
WEND
WHILE INKEY$ = "": WEND

CLS
PRINT "Can BASIC do this? (The Answer in case you are wondering is NO)"
PRINT "Only Graphics Workshop can do rubberbanding lines and its using"
PRINT "the same routine that is used to draw normal lines."

CALL LineVE(0, 0, 0, 349, 14 + 24 * 256)
FOR M = 1 TO 5
   FOR T = M TO 639 STEP M
      CALL LineVE(0, 0, T, 175, 14 + 24 * 256)
      CALL LineVE(T, 176, 0, 349, 14 + 24 * 256)
      CALL LineVE(0, 0, T - M, 175, 14 + 24 * 256)
      CALL LineVE(T - M, 176, 0, 349, 14 + 24 * 256)
   NEXT
   FOR T = T - M - M TO 0 STEP -M
      CALL LineVE(0, 0, T, 175, 14 + 24 * 256)
      CALL LineVE(T, 176, 0, 349, 14 + 24 * 256)
      CALL LineVE(0, 0, T + M, 175, 14 + 24 * 256)
      CALL LineVE(T + M, 176, 0, 349, 14 + 24 * 256)
   NEXT
   FOR T = M TO 639 STEP M
      CALL LineVE(0, 0, T, 175, 14 + 24 * 256)
      CALL LineVE(T, 176, 0, 349, 14 + 24 * 256)
   NEXT
   FOR T = T - M - M TO 0 STEP -M
      CALL LineVE(0, 0, T + M, 175, 14 + 24 * 256)
      CALL LineVE(T + M, 176, 0, 349, 14 + 24 * 256)
   NEXT
   IF M = 1 THEN
     CALL LineVE(0, 0, 0, 349, 14 + 24 * 256)
     PRINT
     PRINT "To use this effect on a slower machine, all that is necessary is"
     PRINT "to increase the increments of where the line is placed."
     CALL LineVE(0, 0, 0, 349, 14 + 24 * 256)
   END IF
NEXT
CALL LineVE(0, 0, 0, 349, 14 + 24 * 256)

CLS
Text$ = "And Don't Forget"
CALL OutlineText(40, 160, Text$, 25, 9, 1, 1)
Text$ = "Fonts . . ."
CALL OutlineText(180, 200, Text$, 25, 12, 2, 1)

WHILE INKEY$ = "": WEND

