'**** DemoMous.Bas - Demo of the Graphics Workshop Mouse routines

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB ChangeMouseCursor (Cursor$, CursorType%)


SCREEN 9

CLS

CALL InitMouse(HaveMouse%)

IF HaveMouse THEN
  PRINT "We have a mouse.  Move the mouse around the screen."
  PRINT "Notice the that the mouse cursor disappears behind boxes until you move it."
  PRINT "And that an old color appears in its place."
ELSE
  PRINT "No Mouse.  Program ending."
  END
END IF

CALL ShowCursor
CALL SetCursor(240, 100)
T& = PDQTimer& + 10
M = 1
WHILE M < 15
    CALL GetCursor(B, C, A)
    IF T& < PDQTimer& THEN
      CALL LineBFVE(RND * 200 + 100, RND * 180 + 50, RND * 300 + 300, RND * 180 + 100, RND * 15)
      T& = PDQTimer& + 10
      M = M + 1
    END IF
    LOCATE 25, 1: PRINT USING "  ###    #### , ####"; A; B; C;
WEND

HideCursor
CLS
PRINT
PRINT "What should be done when programming a graphics program to use the mouse is:"
PRINT "If you look at the code for this demo, you will notice a LINE statement which"
PRINT "is drawing random boxes.  Before this statement is reached, the mouse should"
PRINT "be turned off.  Then it should be turned on again.  The code would then look"
PRINT "like this:"
PRINT
PRINT "  HideCursor"
PRINT "  CALL LineBFVE(x1, y1, x2, y2, 15)"
PRINT "  ShowCursor"
PRINT
PRINT "Press any key to see how effective this code would be in preserving the"
PRINT "graphics content of the screen."
ShowCursor
A = 0
WHILE INKEY$ <> "": WEND
WHILE INKEY$ = "" AND A = 0: CALL GetCursor(B, C, A): WEND

T& = PDQTimer& + 10
M = 1
WHILE M < 15
    CALL GetCursor(B, C, A)
    IF T& < PDQTimer& THEN
      HideCursor
      CALL LineBFVE(RND * 200 + 100, RND * 180 + 50, RND * 300 + 300, RND * 180 + 100, RND * 15)
      ShowCursor
      T& = PDQTimer& + 10
      M = M + 1
    END IF
    LOCATE 25, 1: PRINT USING "  ###    #### , ####"; A; B; C;
WEND

HideCursor
CLS
PRINT "For this next test, don't move the mouse.  Just watch it flicker due to being"
PRINT "turned on and off.  ";
NumTicks1& = PDQTimer&: WHILE PDQTimer& < NumTicks1& + 36: WEND
PRINT "We'll place the mouse cursor over on the left side."
ShowCursor
CALL SetCursor(10, 190)
PRINT "And we'll draw lines on the right side, 50 at a time."

NumTicks1& = PDQTimer&
FOR M = 1 TO 20
    'Consider this next FOR NEXT loop the graphics content of the higher loop
    FOR S = 1 TO 50
        HideCursor
        CALL LineVE(RND * 400 + 200, RND * 290 + 60, RND * 400 + 200, RND * 290 + 60, RND * 15)
        ShowCursor
    NEXT
NEXT
NumTicks1& = PDQTimer& - NumTicks1&

CALL LineBFVE(200, 50, 600, 350, 0)
PRINT "Now we'll position the HideCursor and ShowCursor routines outside the loop."
NumTicks2& = PDQTimer&
FOR M = 1 TO 20
    'Consider this next FOR NEXT loop the graphics content of the higher loop
    HideCursor
    FOR S = 1 TO 50
        CALL LineVE(RND * 400 + 200, RND * 290 + 60, RND * 400 + 200, RND * 290 + 60, RND * 15)
    NEXT
    ShowCursor
NEXT
NumTicks2& = PDQTimer& - NumTicks2&

HideCursor
PRINT
PRINT "The speed difference"
PRINT "between the two methods"
PRINT USING "is ##.## to 1."; NumTicks1& / NumTicks2&

PRINT
PRINT "So you must weigh the"
PRINT "difference between speed"
PRINT "and flickering."
WHILE INKEY$ = "": WEND

CLS
PRINT "Now, using the GetCountLocation% and the GetMouseCount% functions, we can"
PRINT "determine wether or not the mouse cursor is currently visible on the screen."
PRINT "These routines can be helpful in determining how many calls to ShowCursor"
PRINT "will be required to make the cursor visible again as well"

SetCursor 320, 300
ShowCursor
T& = PDQTimer& + 58: WHILE PDQTimer& < T&: WEND

PRINT
PRINT "Step 1: Turn the mouse cursor off.  At the startup of your application,"
PRINT TAB(9); "the mouse cursor will have already been off, and you will not need"
PRINT TAB(9); "this step."
HideCursor
T& = PDQTimer& + 28: WHILE PDQTimer& < T&: WEND

PRINT
PRINT "Step 2: Find the location in the mouse environment of its internal count"
Position% = GetCountLocation% 'The function GetCountLocation% also turns the
                              'mouse cursor on so it should say its on
PRINT TAB(9); "It should also of turned on the mouse cursor"
T& = PDQTimer& + 28: WHILE PDQTimer& < T&: WEND

PRINT
PRINT "Step 3: Check to see if we see that the mouse cursor is visible"
IF GetMouseCount%(Position%) = 0 THEN  'This function tells us if its visible
   PRINT TAB(9); "Mouse is visible.  It's working fine."
ELSE
   PRINT TAB(9); "Mouse is not visible.  But, it really should have been."
END IF
T& = PDQTimer& + 28: WHILE PDQTimer& < T&: WEND

PRINT
PRINT "Step 4: Hide the Mouse Cursor to test it when it's off"
HideCursor
T& = PDQTimer& + 28: WHILE PDQTimer& < T&: WEND

IF GetMouseCount%(Position%) = 0 THEN
   PRINT TAB(9); "Mouse is visible.  But, it should be off now."
ELSE
   PRINT TAB(9); "Mouse is not visible.  This is exactly what should have happened."
END IF
T& = PDQTimer& + 28: WHILE PDQTimer& < T&: WEND

PRINT
PRINT
PRINT "Press any key to continue"
WHILE INKEY$ = "": WEND

LineBFVE 0, 0, 319, 174, 1
LineBFVE 80, 60, 239, 114, 2
LineBFVE 0, 175, 319, 349, 2
LineBFVE 80, 235, 239, 289, 4
LineBFVE 320, 0, 639, 174, 4
LineBFVE 400, 60, 559, 114, 7
LineBFVE 320, 175, 639, 349, 7
LineBFVE 400, 235, 559, 289, 1

GPrint1VE 1, 18, "The mouse cursor will have a different shape", 15
GPrint1VE 2, 20, "in each of the 4 quadrants of the screen", 15

OldMouseX = -1
OldMouseY = -1
ShowCursor

DO
   GetCursor MouseX, MouseY, Button
   IF MouseX < 320 THEN
     IF (MouseY < 175) AND ((OldMouseY > 174) OR (OldMouseX > 319)) THEN
       CALL ChangeMouseCursor(Cursor$, 1)
     ELSEIF (MouseY > 174) AND ((OldMouseY < 175) OR (OldMouseX > 319)) THEN
       CALL ChangeMouseCursor(Cursor$, 2)
     END IF
   ELSE
     IF (MouseY < 175) AND ((OldMouseY > 174) OR (OldMouseX < 320)) THEN
       CALL ChangeMouseCursor(Cursor$, 3)
     ELSEIF (MouseY > 174) AND ((OldMouseY < 175) OR (OldMouseX < 320)) THEN
       CALL ChangeMouseCursor(Cursor$, 4)
     END IF
   END IF
   OldMouseX = MouseX
   OldMouseY = MouseY
LOOP UNTIL Button <> 0 OR INKEY$ <> ""

SUB ChangeMouseCursor (Cursor$, CursorType) STATIC
  
  'We have to make the Cursor$ 64 characters in length and we will start
  'with all bits set to 1's
  Cursor$ = STRING$(64, 255)

  'The first 32 characters in the string will store the background mask.
  'A "1" in the background mask means that it should leave that pixel
  'location alone.  A "0" in the background mask means that the mouse
  'routines should blacken out that pixel location.

  'The last 32 characters in the string will store the mouse cursor.
  'A "1" in the mouse cursor mask means that the color white should be
  'XORed with whatever color is on the screen at that location after the
  'mask has been applied.  A "0" in the mouse cursor means that the mouse
  'routines should leave that pixel location alone after the mask has been
  'applied.

  SELECT CASE CursorType
    CASE 1:
       'Background Mask
        MID$(Cursor$, 1, 2) = MKI$(MakeBinary%("0001111111111111"))
        MID$(Cursor$, 3, 2) = MKI$(MakeBinary%("0000011111111111"))
        MID$(Cursor$, 5, 2) = MKI$(MakeBinary%("0000000111111111"))
        MID$(Cursor$, 7, 2) = MKI$(MakeBinary%("0000000001111111"))
        MID$(Cursor$, 9, 2) = MKI$(MakeBinary%("0000000000011111"))
       MID$(Cursor$, 11, 2) = MKI$(MakeBinary%("0000000000000111"))
       MID$(Cursor$, 13, 2) = MKI$(MakeBinary%("0000000000000001"))
       MID$(Cursor$, 15, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 17, 2) = MKI$(MakeBinary%("0000000000111111"))
       MID$(Cursor$, 19, 2) = MKI$(MakeBinary%("0000110000011111"))
       MID$(Cursor$, 21, 2) = MKI$(MakeBinary%("0001111000001111"))
       MID$(Cursor$, 23, 2) = MKI$(MakeBinary%("0011111100000111"))
       MID$(Cursor$, 25, 2) = MKI$(MakeBinary%("0111111110000011"))
       MID$(Cursor$, 27, 2) = MKI$(MakeBinary%("1111111111000001"))
       MID$(Cursor$, 29, 2) = MKI$(MakeBinary%("1111111111100001"))
       MID$(Cursor$, 31, 2) = MKI$(MakeBinary%("1111111111110011"))

       'Mouse Cursor
       MID$(Cursor$, 33, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 35, 2) = MKI$(MakeBinary%("0110000000000000"))
       MID$(Cursor$, 37, 2) = MKI$(MakeBinary%("0111100000000000"))
       MID$(Cursor$, 39, 2) = MKI$(MakeBinary%("0111111000000000"))
       MID$(Cursor$, 41, 2) = MKI$(MakeBinary%("0111111110000000"))
       MID$(Cursor$, 43, 2) = MKI$(MakeBinary%("0111111111100000"))
       MID$(Cursor$, 45, 2) = MKI$(MakeBinary%("0111111111111000"))
       MID$(Cursor$, 47, 2) = MKI$(MakeBinary%("0111111100000000"))
       MID$(Cursor$, 49, 2) = MKI$(MakeBinary%("0111001110000000"))
       MID$(Cursor$, 51, 2) = MKI$(MakeBinary%("0110000111000000"))
       MID$(Cursor$, 53, 2) = MKI$(MakeBinary%("0100000011100000"))
       MID$(Cursor$, 55, 2) = MKI$(MakeBinary%("0000000001110000"))
       MID$(Cursor$, 57, 2) = MKI$(MakeBinary%("0000000000111000"))
       MID$(Cursor$, 59, 2) = MKI$(MakeBinary%("0000000000011100"))
       MID$(Cursor$, 61, 2) = MKI$(MakeBinary%("0000000000001100"))
       MID$(Cursor$, 63, 2) = MKI$(MakeBinary%("0000000000000000"))
       CursorX = 0   'Hot spot is in the upper-left corner
       CursorY = 0

    CASE 2:
        MID$(Cursor$, 1, 2) = MKI$(MakeBinary%("0000000000000000"))
        MID$(Cursor$, 3, 2) = MKI$(MakeBinary%("0000000000000000"))
        MID$(Cursor$, 5, 2) = MKI$(MakeBinary%("0000000000000000"))
        MID$(Cursor$, 7, 2) = MKI$(MakeBinary%("0001111111111000"))
        MID$(Cursor$, 9, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 11, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 13, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 15, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 17, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 19, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 21, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 23, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 25, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 27, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 29, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 31, 2) = MKI$(MakeBinary%("0000000000000000"))
 
       MID$(Cursor$, 33, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 35, 2) = MKI$(MakeBinary%("0111111111111110"))
       MID$(Cursor$, 37, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 39, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 41, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 43, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 45, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 47, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 49, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 51, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 53, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 55, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 57, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 59, 2) = MKI$(MakeBinary%("0100000000000010"))
       MID$(Cursor$, 61, 2) = MKI$(MakeBinary%("0111111111111110"))
       MID$(Cursor$, 63, 2) = MKI$(MakeBinary%("0000000000000000"))
       CursorX = 7   'Hot spot is in the center
       CursorY = 7

    CASE 3:
        MID$(Cursor$, 1, 2) = MKI$(MakeBinary%("0000000000000000"))
        MID$(Cursor$, 3, 2) = MKI$(MakeBinary%("0000000000000000"))
        MID$(Cursor$, 5, 2) = MKI$(MakeBinary%("1000000000000001"))
        MID$(Cursor$, 7, 2) = MKI$(MakeBinary%("1100000000000011"))
        MID$(Cursor$, 9, 2) = MKI$(MakeBinary%("1110000000000111"))
       MID$(Cursor$, 11, 2) = MKI$(MakeBinary%("1111000000001111"))
       MID$(Cursor$, 13, 2) = MKI$(MakeBinary%("1111100000011111"))
       MID$(Cursor$, 15, 2) = MKI$(MakeBinary%("1111110000111111"))
       MID$(Cursor$, 17, 2) = MKI$(MakeBinary%("1111110000111111"))
       MID$(Cursor$, 19, 2) = MKI$(MakeBinary%("1111100000011111"))
       MID$(Cursor$, 21, 2) = MKI$(MakeBinary%("1111000000001111"))
       MID$(Cursor$, 23, 2) = MKI$(MakeBinary%("1110000000000111"))
       MID$(Cursor$, 25, 2) = MKI$(MakeBinary%("1100000000000011"))
       MID$(Cursor$, 27, 2) = MKI$(MakeBinary%("1000000000000001"))
       MID$(Cursor$, 29, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 31, 2) = MKI$(MakeBinary%("0000000000000000"))
 
       MID$(Cursor$, 33, 2) = MKI$(MakeBinary%("1111111111111111"))
       MID$(Cursor$, 35, 2) = MKI$(MakeBinary%("1000000000000001"))
       MID$(Cursor$, 37, 2) = MKI$(MakeBinary%("0101111111111010"))
       MID$(Cursor$, 39, 2) = MKI$(MakeBinary%("0010111111110100"))
       MID$(Cursor$, 41, 2) = MKI$(MakeBinary%("0001011111101000"))
       MID$(Cursor$, 43, 2) = MKI$(MakeBinary%("0000101111010000"))
       MID$(Cursor$, 45, 2) = MKI$(MakeBinary%("0000010110100000"))
       MID$(Cursor$, 47, 2) = MKI$(MakeBinary%("0000001001000000"))
       MID$(Cursor$, 49, 2) = MKI$(MakeBinary%("0000001001000000"))
       MID$(Cursor$, 51, 2) = MKI$(MakeBinary%("0000010110100000"))
       MID$(Cursor$, 53, 2) = MKI$(MakeBinary%("0000101111010000"))
       MID$(Cursor$, 55, 2) = MKI$(MakeBinary%("0001011111101000"))
       MID$(Cursor$, 57, 2) = MKI$(MakeBinary%("0010111111110100"))
       MID$(Cursor$, 59, 2) = MKI$(MakeBinary%("0101111111111010"))
       MID$(Cursor$, 61, 2) = MKI$(MakeBinary%("1000000000000001"))
       MID$(Cursor$, 63, 2) = MKI$(MakeBinary%("1111111111111111"))
       CursorX = 7   'Hot spot is in the center
       CursorY = 7

    CASE 4:
        MID$(Cursor$, 1, 2) = MKI$(MakeBinary%("1111110000111111"))
        MID$(Cursor$, 3, 2) = MKI$(MakeBinary%("1111000000001111"))
        MID$(Cursor$, 5, 2) = MKI$(MakeBinary%("1110000000000111"))
        MID$(Cursor$, 7, 2) = MKI$(MakeBinary%("1100000000000011"))
        MID$(Cursor$, 9, 2) = MKI$(MakeBinary%("1110000000000111"))
       MID$(Cursor$, 11, 2) = MKI$(MakeBinary%("1111000000001111"))
       MID$(Cursor$, 13, 2) = MKI$(MakeBinary%("1111110000111111"))
       MID$(Cursor$, 15, 2) = MKI$(MakeBinary%("1111111001111111"))
       MID$(Cursor$, 17, 2) = MKI$(MakeBinary%("1111111001111111"))
       MID$(Cursor$, 19, 2) = MKI$(MakeBinary%("1111110000111111"))
       MID$(Cursor$, 21, 2) = MKI$(MakeBinary%("1111000000001111"))
       MID$(Cursor$, 23, 2) = MKI$(MakeBinary%("1110000000000111"))
       MID$(Cursor$, 25, 2) = MKI$(MakeBinary%("1100000000000011"))
       MID$(Cursor$, 27, 2) = MKI$(MakeBinary%("1110000000000111"))
       MID$(Cursor$, 29, 2) = MKI$(MakeBinary%("1111000000001111"))
       MID$(Cursor$, 31, 2) = MKI$(MakeBinary%("1111110000111111"))
  
       MID$(Cursor$, 33, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 35, 2) = MKI$(MakeBinary%("0000001111000000"))
       MID$(Cursor$, 37, 2) = MKI$(MakeBinary%("0000111111110000"))
       MID$(Cursor$, 39, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 41, 2) = MKI$(MakeBinary%("0000111111110000"))
       MID$(Cursor$, 43, 2) = MKI$(MakeBinary%("0000001111000000"))
       MID$(Cursor$, 45, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 47, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 49, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 51, 2) = MKI$(MakeBinary%("0000000000000000"))
       MID$(Cursor$, 53, 2) = MKI$(MakeBinary%("0000001111000000"))
       MID$(Cursor$, 55, 2) = MKI$(MakeBinary%("0000111111110000"))
       MID$(Cursor$, 57, 2) = MKI$(MakeBinary%("0001111111111000"))
       MID$(Cursor$, 59, 2) = MKI$(MakeBinary%("0000111111110000"))
       MID$(Cursor$, 61, 2) = MKI$(MakeBinary%("0000001111000000"))
       MID$(Cursor$, 63, 2) = MKI$(MakeBinary%("0000000000000000"))
       CursorX = 7   'Hot spot is in the center
       CursorY = 7

    CASE ELSE
  END SELECT

  CALL GrafCursor(CursorX, CursorY, Cursor$)        'hot spot is at 0,0 (the arrow's tip)

END SUB

