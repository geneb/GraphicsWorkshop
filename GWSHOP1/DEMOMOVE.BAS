'********** DemoMove.Bas - demonstrates the GMove?VE routines emulating
'                          some of the tasks which BASIC GET and PUT can do

'Copyright (c) 1990 Brian C. Giedt
'Copyright (c) 1988 Crescent Software

'This demonstrates the routines:
'   GMove1VE - An assembly subroutine which copies a specified region to
'              another user specified location within video memory
'   GMove2VE - An assemlby subroutine which copies a specified region to
'              and from a storage area in higher video memory

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DrawImage (X1%, Y1%)  'Local sub used only for this demo
DECLARE SUB MirrorImage (Col1%, Line1%, Col2%, Line2%, DestCol%, DestLine%)

'$INCLUDE: 'GetVideo.BAS'

CALL SetVideo

CALL SetGWPages(0, 0)              'We only want to use the visible page

PRINT "This demo will show you alternative uses for the GMove1VE and GMove2VE"
PRINT "routines (besides their uses shown in DEMOPULL, DEMOVERT, and DEMOFX)."
PRINT
PRINT "First, the GMove1VE routine can be used to change a images appearance"

PRINT
PRINT TAB(7); "Original Image"; TAB(50); "Inverted Image"

CALL DrawImage(100, 120)

CALL MirrorImage(7, 120, 19, 207, 50, 120)

LOCATE 18, 1
PRINT "The Inverted Image was created by a routine, MirrorImage which uses the"
PRINT "GMove1VE routine to transfer the image."
PRINT
PRINT "Press any key to continue"
WHILE INKEY$ = "": WEND

CLS
PRINT "Now try to replicate an image many times."
CALL DrawImage(52, 30)
CALL MirrorImage(0, 30, 13, 117, 15, 30)

CALL GMove1VE(0, 30, 14, 88, 30, 30)
CALL GMove1VE(15, 30, 14, 88, 45, 30)
CALL GMove1VE(0, 30, 14, 88, 60, 30)

CALL GMove1VE(15, 30, 14, 88, 0, 130)
CALL GMove1VE(0, 30, 14, 88, 15, 130)
CALL GMove1VE(15, 30, 14, 88, 30, 130)
CALL GMove1VE(0, 30, 14, 88, 45, 130)
CALL GMove1VE(15, 30, 14, 88, 60, 130)

CALL GMove1VE(0, 30, 14, 88, 0, 230)
CALL GMove1VE(15, 30, 14, 88, 15, 230)
CALL GMove1VE(0, 30, 14, 88, 30, 230)
CALL GMove1VE(15, 30, 14, 88, 45, 230)
CALL GMove1VE(0, 30, 14, 88, 60, 230)

LOCATE 24, 1
PRINT "All these images were replicated with a GMove1VE routine.";
LOCATE 25, 1
PRINT "Press any key to continue";
WHILE INKEY$ = "": WEND

CLS
PRINT "Lets move the image around the screen now.  First using BASIC's GET and PUT"
PRINT "and then using the GMove2VE routine"
PRINT
PRINT "Using GET and PUT:"
CALL DrawImage(60, 80)
CALL DrawImage(140, 80)
CALL DrawImage(60, 170)
CALL DrawImage(140, 170)
CALL DrawImage(60, 260)
CALL DrawImage(140, 260)
DIM Array%(22000)
GET (0, 80)-(200, 347), Array%
FOR T = 2 TO 54
 PUT ((T - 1) * 8, 80), Array%, PSET
NEXT
FOR T = 53 TO 1 STEP -1
 PUT ((T - 1) * 8, 80), Array%, PSET
NEXT

LOCATE 4, 1
PRINT "Using the GMove2VE routine:"
SaveAddress = &HAA00
CALL GMove2VE(1, 80, 28, 268, SaveAddress, 0)
FOR T = 2 TO 54
  CALL GMove2VE(T, 80, 28, 268, SaveAddress, -1)
NEXT
FOR T = 53 TO 2 STEP -1
  CALL GMove2VE(T, 80, 28, 268, SaveAddress, -1)
NEXT

LOCATE 7, 35
PRINT "It is obvious that the GMove2VE routine"
LOCATE 8, 35
PRINT "can move images much faster than GET and"
LOCATE 9, 35
PRINT "PUT can.  And it doesn't require setting"
LOCATE 10, 35
PRINT "up a large array to store the image.  It"
LOCATE 11, 35
PRINT "instead uses video memory which already"
LOCATE 12, 35
PRINT "existed and simply wasn't being used."

LOCATE 14, 35
PRINT "Press any key to continue"
WHILE INKEY$ = "": WEND

CLS

SUB DrawImage (X1, Y1) STATIC

  CALL LineVE(X1, Y1, X1 - 50, Y1 + 70, 2)
  CALL LineVE(X1 - 50, Y1 + 70, X1 + 50, Y1 + 70, 2)
  CALL LineVE(X1 + 50, Y1 + 70, X1, Y1, 2)
  PAINT (X1, Y1 + 50), 2, 2
  CIRCLE (X1, Y1 + 47), 40, 15
  PAINT (X1, Y1 + 47), 4, 15

END SUB

