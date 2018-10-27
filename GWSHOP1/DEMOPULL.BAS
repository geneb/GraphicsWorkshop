'********** DemoPull.Bas - pull down menu demonstration for graphics mode

'Copyright (c) 1987,1990 Donald R. Malin & Brian C. Giedt
'Copyright (c) 1987 Crescent Software

'This demonstrates the routines:
'   PullDownG  - A basic subroutine which holds a complete pulldown menu
'                system.
'   GMove2VE   - An assembler routine used by PullDown to store and retrieve
'                sections of the EGA or VGA graphics screens.
'   GPrint0VE  - An assembler routine which is not only a replacement for the
'                BASIC PRINT statement in EGA and VGA graphics modes, but has
'                the ability to specify a unique background color for just
'                the string being printed.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo.Bas'

CALL SetVideo

CLS

'Change the background color of the entire screen to the color 1
CALL LineBFVE(0, 0, GPDat%(43), GPDat%(44), 1)

GPDat%(57) = 1    'Tell the GPaintBox routine what color is our overall
		  ' background color

FOR T = 1 TO 50            'Make a random backdrop for the demo
   X = RND * 230
   Y = RND * 100
   XD = RND * 400
   YD = RND * 250
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


Action = 0                'Action 0 is the easiest way to use PullDown
Menu = 1                  'start PullDown by displaying Menu 1
Choice = 1                'start with Choice #1 highlighted

SetCursor 1, 1

ShowCursor
CALL PullDownG(Choice$(), Stat(), Menu, Choice, Ky$, Action)
HideCursor

LOCATE 24, 1
IF Ky$ = CHR$(27) THEN
  GPrint0VE 24, 1, "Escape was pressed or the mouse was clicked outside of the menu", 15 + 1 * 256
ELSE
  A$ = "Selection" + STR$(Choice) + " was made from Menu" + STR$(Menu)
  GPrint0VE 24, 1, A$, 15 + 1 * 256
END IF

