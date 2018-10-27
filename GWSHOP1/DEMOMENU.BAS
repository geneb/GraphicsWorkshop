'****************************************************************************
' PullDownG/VertMenuG  Demonstration program
' Demonstrates polling technics for both modules.  See also "DemoPull.Bas"
' and "DemoVert.Bas".
'
' by Don Malin   (C) Crescent Software 1988-1989
' Modified for Graphics WorkShop by Brian C. Giedt
'****************************************************************************

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'----- BASIC subprograms
'
DECLARE SUB SetUpScreen (ScrTxt$())
DECLARE SUB GetColor ()
DECLARE SUB GetFiles (FilName$)

'Get information about the current video screens available, and set up the
'GPDat%() array
'$INCLUDE: 'GetVideo.BAS'

CONST InActive = -1
CONST Active = 0

DIM SHARED BotRow                       'Bottom most screen row

REDIM MMenu$(9, 5)                      'holds the menu choice strings
REDIM Stat(9, 5)                        'holds the choice status flags
REDIM Help$(9, 5)                       'holds Help strings
REDIM ScrTxt$(50)                       'holds the screen text

MMenu$(0, 0) = "ð"                      'this was the MS Help Icon

'******* Define Main Menu
RESTORE MenuStrngs                      'read the menu choices into the Array
FOR R = 0 TO 9                          'for each menu choice,
    FOR C = 1 TO 5                      '  read each menu.
	READ MMenu$(R, C)
    NEXT C
NEXT R

'*** Set Inactive menu choices
Stat(2, 1) = InActive                   'can't save file until it's loaded
Stat(2, 3) = InActive                   'can't cut a block until its marked
Stat(3, 3) = InActive                   'ditto for copying and pasting.
Stat(4, 3) = InActive
Stat(2, 4) = InActive                   'can't repeat last find before find

'*** Some help strings need to be built up since contsant string assignments
'*** can only be 255 characters in length.
Help$(0, 0) = "Use the Left or Right arrow keys to move from menu to menu.  Inside a menu use the Up or Down arrow keys to move from item to item.  Once your selection has been hi-lited, press the Enter key to confirm the choice and continue.  "
Help$(0, 0) = Help$(0, 0) + "  Low-intensity choices are not selectable."
Help$(1, 1) = "Use this choice to simulate selecting and retrieving a file.  After selecting this choice, a vertical menu will be displayed containing all of the file names in the current directory."
Help$(2, 1) = "Selecting this menu choice will simulate saving the current file to disk.  Note that this item will be inactive (displayed in low intensity) until either a file has been retrieved or a new file is created."
Help$(4, 1) = "Use this choice to simulate marking a file as Read Only.  After selecting this function, a menu of all files in the current directory will be displayed from which you can pick the file to protect."
Help$(5, 1) = "This is the opposite of the previous choice.  You can remove the Read Only status of a file by selecting its name from the menu of files that are displayed."
Help$(7, 1) = "Use this menu item to simulate changing the current drive or directory.  After making this selection, a menu of directory names will be displayed from which you can choose the directory to be made current."
Help$(8, 1) = "Don't panic, this choice does nothing."
Help$(9, 1) = "Temporarily exit to the operating system.  This program stays in memory.  To return, type EXIT."

Help$(1, 2) = "The Colors menu item can be used to change the color of the text displayed on the screen.  After making this choice, a second menu will be displayed allowing you to choose a new Foreground, Background or color Intensity.  "
Help$(1, 2) = Help$(1, 2) + "If you choose Foreground or Background, a third menu will be displayed containing the range of possible colors."
Help$(3, 2) = "This setting is used to change the way text searches could be done.  If this setting is active, searches would ignore capitalization, otherwise words would be found only if they match the case of each letter in the text.  "
Help$(3, 2) = Help$(3, 2) + "Pressing Enter on this choice will toggle between the two modes.  A Check mark is displayed if case insensitivity is active."
Help$(4, 2) = "Due to the laziness of the author of this demo, there is no help for this item."
Help$(6, 2) = Help$(4, 2)

Help$(1, 3) = Help$(4, 2)
Help$(2, 3) = Help$(4, 2)
Help$(3, 3) = Help$(4, 2)
Help$(4, 3) = Help$(4, 2)
Help$(6, 3) = Help$(4, 2)

Help$(1, 4) = Help$(4, 2)
Help$(2, 4) = Help$(4, 2)
Help$(3, 4) = Help$(4, 2)


RESTORE Screentxt                       'read the text we are displaying on
FOR R = 1 TO 26                         '  body of the screen
    READ ScrTxt$(R)
NEXT

CALL SetVideo                           'Set screen mode based on current monitor

BotRow = 25                             'EGA number of lines
IF GPDat%(31) = 8 THEN BotRow = 30      'VGA number of lines


GPDat(74) = 15 * 256

CALL SetUpScreen(ScrTxt$())

SetCursor 1, 1                          'Locate it at upper right of screen

BarPrintG MMenu$(), GPDat%(74) 'Print the Bar Choices

ShowCursor                              'Turn it on

Action = 1                              'set Action flag to 1 - init PullDown
Tim& = PDQTimer&                        'init the time

DO
   DO                                   'call the Pull Down menu routine
      PullDownG MMenu$(), Stat(), Menu, Choice, Ky$, Action

      GOSUB ShowTime                    'update the time every second
      

      '---- Tranlate Ky$ to ASCII value (integer) for more efficient processing
      L = LEN(Ky$)
      SELECT CASE L
	CASE 0
	  Ky = 0
	CASE 1
	  Ky = ASC(Ky$)
	CASE 2
	  Ky = -ASC(RIGHT$(Ky$, 1))
      END SELECT
	

      IF L THEN                 'Was a key pressed?

	SELECT CASE Ky
	  CASE -59     'F1, show help screen

	    GOSUB ShowHelp

	  CASE -81     'PgDn, display next page

	    PullDownG MMenu$(), Stat(), Menu, Choice, Ky$, 5
	    Fld$ = SPACE$(79)
	    Lca = 3
	    FOR R = 23 TO 44
	      LSET Fld$ = ScrTxt$(R)
	      GPrint0VE Lca, 1, Fld$, GPDat%(80)
	      Lca = Lca + 1
	    NEXT
	    Action = 1

	  CASE -73     'PgUp, display previous page

	    PullDownG MMenu$(), Stat(), Menu, Choice, Ky$, 5
	    Fld$ = SPACE$(79)
	    Lca = 3
	    FOR R = 1 TO 22
	      LSET Fld$ = ScrTxt$(R)
	      GPrint0VE Lca, 1, Fld$, GPDat%(80)
	      Lca = Lca + 1
	    NEXT
	    Action = 1

	  CASE 27   'Escape
	    Action = 3

	END SELECT

      END IF

   LOOP UNTIL Action = 4                'keep calling PullDown until User
					'  makes a selection












   Again = -1                           'default flag to loop again.
   Action = 2                           'default Action flag to redisplay the
					'  menu contents
   IF Ky$ = CHR$(27) THEN               'if user pressed escape, exit this
   ' Again = 0                          '  demo (only if REM is removed)
   ELSE                                 'otherwise,
     SELECT CASE Menu                   '  process selection.

       CASE 0                           'help Icon
	 GOSUB ShowHelp

       CASE 1                           'File Menu
	 SELECT CASE Choice
	   CASE 1, 4, 5                 'Retrieve, Protect or Unprotect File
	     LOCATE Choice + 2, 32
	     GetFiles FilName$
					'if user didn't Escape from file routine
	     IF Choice = 1 AND LEN(FilName$) THEN
	       GPrint0VE BotRow, 7, FilName$, 0 + 256 * 7'print file name
	       Stat(2, 1) = Active        'User can now save his file
	     END IF
	   CASE 2                       'Save File
	   CASE 7                       'Change Drive
	   CASE 8                       'Format Disk
	   CASE 9                       'DOS Shell
	     SCREEN 0
	     PRINT "Type EXIT to return to demo."
	     SHELL
	     CALL SetVideo
	     CALL SetUpScreen(ScrTxt$())
	     Action = 1
	   CASE ELSE
	 END SELECT

       CASE 2                           'Settings Menu
	 SELECT CASE Choice
	   CASE 1                       'Colors
	     LstClr = GPDat%(80)        'save the current color attribute
	     GetColor                   'show color options, get color
					'if user made a choice,
	     Action = 5                 'set to restore screen
	     PullDownG MMenu$(), Stat(), Menu, Choice, Ky$, Action
					'paint screen new color
	     IF GPDat%(80) MOD 256 <> LstClr MOD 256 THEN
	       GPaintBox 1, 0, 80, GPDat%(44), LstClr MOD 256, GPDat%(80) MOD 256
	     END IF
	     IF GPDat%(80) \ 256 <> LstClr \ 256 THEN
	       GPaintBox 1, 0, 80, GPDat%(44), LstClr \ 256, GPDat%(80) \ 256
	     END IF
	     Action = 1                 'set to redisplay whole menu
	   CASE 3, 4                    'Search options
	     Psn = LEN(MMenu$(Choice, 2))  'get length of choice
					   'see if its marked
	     mark$ = MID$(MMenu$(Choice, 2), Psn, 1)
	     IF mark$ = "û" THEN           'if it is, then unmark it
	       mark$ = " "
	     ELSE
	       mark$ = "û"              'otherwise mark it
	     END IF
	     MID$(MMenu$(Choice, 2), Psn) = mark$
	   CASE 6
	   CASE ELSE
	 END SELECT

       CASE 3                           'Edit Menu

	 SELECT CASE Choice
	   CASE 1                       'Mark Block
	     Stat(2, 3) = Active        'block can now be cut, copied
	     Stat(3, 3) = Active        '  or moved
	     Stat(4, 3) = Active
	   CASE 2                       'Cut Block
	     Stat(2, 3) = InActive      'once cut, it can't be cut again
	   CASE 3                       'Copy
	   CASE 4                       'Paste
	   CASE 6                       'New File
	     Stat(2, 1) = Active        'make "Save File" active
	   CASE ELSE
	 END SELECT

       CASE 4                           'Search Menu
	 SELECT CASE Choice
	   CASE 1                       'Find
	     Stat(2, 4) = Active        'ake Repeat Find active
	   CASE 2                       'Repeat Last Find
	   CASE 3                       'Change
	   CASE ELSE
	 END SELECT

       CASE ELSE                        'Quit Program (no choices)
	 Again = 0                      'set loop flag to terminate
     END SELECT
   
   END IF

LOOP WHILE Again                        'go back to the PullDown menu unless











					'  flag set to terminate
'Restore the Screen
Action = 5
PullDownG MMenu$(), Stat(), Menu, Choice, Ky$, Action
END


'----- Display the apropriate help message
ShowHelp:

   LOCATE 14, 1                         'position the starting line for box
   Wdth = 62                            'set text width
   MsgBoxG Help$(Choice, Menu), Wdth
   DO UNTIL LEN(INKEY$)
      GOSUB ShowTime                    'Update the time every second
   LOOP
   MsgBoxG "", 1

RETURN



'----- Update the time every second
ShowTime:

   IF PDQTimer& > Tim& + 18 THEN
      Tim& = PDQTimer&
      GPrint0VE BotRow, 73, TIME$, 0 + 256 * 7
   END IF

RETURN


MenuStrngs:                             'define the menu choices
DATA "File",                    "Settings",                   "Edit",          "Search",            "Quit"
DATA "Retrieve File...",        "Colors...",                  "Mark Block...", "Find...",           ""
DATA "Save Current File...",    "-",                          "Cut",           "Repeat Last Find",  ""
DATA "-",                       "Ignore upper/lower Case ",   "Copy",          "Change...",         ""
DATA "Protect a File...",       "Match whole word ",          "Paste",         "",                  ""
DATA "Unprotect a file...",     "-",                          "-",             "",                  ""
DATA "-",                       "Margins...",                 "New File",      "",                  ""
DATA "Change Drive/Directory",  "",                           "",              "",                  ""
DATA "Format a Disk",           "",                           "",              "",                  ""
DATA "DOS Shell",               "",                           "",              "",                  ""


Screentxt:
DATA "                    PULLDOWN/VERTMENU Demonstration Program."
DATA ""
DATA "  This demo illustrates some of the things that can be done with the features"
DATA "  and multi-tasking capabilities of the PullDown and VertMenu routines."
DATA ""
DATA "  Notice that menus can have dividing lines to separate a group of choices."
DATA "  This can be accomplished by using a ``-'' as a choice string.  Menu items"
DATA "  can also be made inactive (non selectable) by placing a value in a parallel"
DATA "  array that corresponds to the items string array."
DATA ""
DATA "  Both PullDown and Vertmenu can be used in a multi-tasking (polled) mode."
DATA "  Notice that the time is being displayed and updated at the bottom of the"
DATA "  screen.  This is being done from outside of the two menuing routines.  To"
DATA "  accomplish this you would call the menu routines in the same way you would"
DATA "  use the INKEY$ function in a loop.  A control flag can be used to make the"
DATA "  menus perform certain tasks.  (See subprogram headers for details.)"
DATA ""
DATA "  Notice also that help can be displayed for any menu item.  This is being"
DATA "  done outside of the PullDown menu routine by trapping the F1 key, reading"
DATA "  the Menu and Choice numbers and then displaying the appropriate help message."
DATA "  Another function that is performed outside the menu routine is paging of"
DATA "  this text.  Try the PgDn key to see."
DATA "  Other possible uses for polled menus are background communications or self-"
DATA "  modifying menus.  Examples of a self modifying menu are the ``Ignore Case''"
DATA "  or ``Match Whole Word'' choices from the ``Settings'' Menu, where a check
DATA "  mark is placed to the right of the text on the menu.

SUB GetColor STATIC

    REDIM Atrib$(2)
    Atrib$(1) = "Foreground"
    Atrib$(2) = "Background"
   
    REDIM Clrs$(16)
    Clrs$(1) = "Black      "
    Clrs$(2) = "Blue       "
    Clrs$(3) = "Green      "
    Clrs$(4) = "Cyan       "
    Clrs$(5) = "Red        "
    Clrs$(6) = "Magenta    "
    Clrs$(7) = "Brown      "
    Clrs$(8) = "Grey       "
    Clrs$(9) = "Dark Grey  "
    Clrs$(10) = "Lt. Blue   "
    Clrs$(11) = "Lt. Green  "
    Clrs$(12) = "Lt. Cyan   "
    Clrs$(13) = "Lt. Red    "
    Clrs$(14) = "Lt. Magenta"
    Clrs$(15) = "Yellow     "
    Clrs$(16) = "White      "

    Bkgrnd = GPDat%(80) \ 256
    Frgrnd = GPDat%(80) MOD 256

    DO
       LOCATE 3, 42
       VertAction = 1
       Tim& = PDQTimer& - 18
       DO
	   VertMenuG Atrib$(), Atrb, 10, 24, Ky$, VertAction

	   IF PDQTimer& > Tim& + 18 THEN
	      Tim& = PDQTimer&
	      GPrint0VE BotRow, 73, TIME$, 0 + 256 * 7
	   END IF
       LOOP UNTIL VertAction = 4
       VertMenuG Atrib$(), Atrb, 10, 24, Ky$, 5



       IF Ky$ = CHR$(13) THEN
	  LOCATE 9, 42
	  VertAction = 1
	  IF Atrb = 1 THEN Clr = Frgrnd + 1
	  IF Atrb = 2 THEN Clr = Bkgrnd + 1
	  Tim& = PDQTimer& - 18

	  DO
	      VertMenuG Clrs$(), Clr, 11, 24, Ky$, VertAction
	      IF PDQTimer& > Tim& + 18 THEN
		 Tim& = PDQTimer&
		 GPrint0VE BotRow, 73, TIME$, 0 + 256 * 7
	      END IF
	  LOOP UNTIL VertAction = 4

	  VertMenuG Clrs$(), Clr, 7, 24, K$, 5
       END IF

    LOOP UNTIL Ky$ = CHR$(13) OR Ky$ = CHR$(27)

    IF Ky$ = CHR$(13) THEN
       IF Atrb = 1 THEN Frgrnd = Clr - 1
       IF Atrb = 2 THEN Bkgrnd = Clr - 1
       GPDat%(80) = Frgrnd + 256 * Bkgrnd
    END IF

    ERASE Atrib$, Clrs$

END SUB

SUB GetFiles (FilName$) STATIC

    REDIM File$(10)
    File$(1) = "FONTS1.PCX  "
    File$(2) = "FONTS2.PCX  "
    File$(3) = "FONTS3.PCX  "
    File$(4) = "XORBOX.PCX  "
    File$(5) = "FONTEDIT.PCX"
    File$(6) = "ZOOMED.PCX  "
    File$(7) = "DEMOSHAD.PCX"
    File$(8) = "MOUNTAIN.PCX"
    File$(9) = "SALES1.PCX  "
    File$(10) = "SALES2.PCX  "

    VertAction = 1
    Tim& = PDQTimer&
    DO
	VertMenuG File$(), FlNo, 12, 24, Ky$, VertAction
	IF PDQTimer& > Tim& + 18 THEN
	   Tim& = PDQTimer&
	   GPrint0VE BotRow, 73, TIME$, 0 + 256 * 7
	END IF
    LOOP UNTIL VertAction = 4
    IF Ky$ <> CHR$(27) THEN FilName$ = File$(FlNo)

    VertMenuG File$(), FlNo, 12, 24, K$, 5

END SUB

SUB SetUpScreen (ScrTxt$()) STATIC

  CALL LineBFVE(0, 0, GPDat%(43), GPDat%(44), GPDat%(80) \ 256)
  GPDat%(57) = GPDat%(80) \ 256
  FOR R = 1 TO 22
    GPrint0VE R + 2, 1, ScrTxt$(R), GPDat%(80)
  NEXT

  '*** Print the 25th line
  GPrint0VE BotRow, 1, "File: ", 7 + 256 * 1
  GPrint0VE BotRow, 7, SPACE$(12), 0 + 256 * 7
  GPrint0VE BotRow, 62, DATE$, 0 + 256 * 7
  GPrint0VE BotRow, 73, TIME$, 0 + 256 * 7
  GPrint0VE BotRow, 24, "F1-Help", 0 + 256 * 3
  GPrint0VE BotRow, 34, "PgDn-More", 0 + 256 * 3
  GPrint0VE BotRow, 46, "PgUp-Prev.", 0 + 256 * 3

END SUB

