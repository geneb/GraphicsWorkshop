'********** DemoByte.Bas - demonstrates the DrawByte routine for use with
'                          drawing graphics images

'Copyright (c) 1990 Brian C. Giedt
'Copyright (c) 1988 Crescent Software

'This demonstrates the routines:
'   DrawByte   - An assembly subroutine which draw up to eight pixels worth
'                of information to an EGA or VGA screen simultaneously.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'GetVideo.BAS'

CALL SetVideo

PRINT "First, the DrawByteVE routine can be used to set a pixel.  To set a pixel"
PRINT "at (200, 200) we are going to call MakeAddressVE%.  MakeAddressVE% will"
Address% = MakeAddressVE%(200, 200, BitPattern%)
PRINT "return"; Address%; "for the address in memory, and will return a bit pattern"
PRINT "to single out the pixel we were interested in.  That pattern is ";

FOR T = 7 TO 0 STEP -1
  IF (BitPattern% AND (2 ^ T)) <> 0 THEN PRINT "1";  ELSE PRINT "0";
NEXT
PRINT
PRINT "Now calling DrawByteVE with the above address and bit pattern and a color of"
PRINT "14, will draw a yellow pixel on the screen below."

CALL DrawByteVE(Address%, BitPattern%, 14)

CALL LineVE(210, 200, 250, 200, 15)
CALL LineVE(210, 200, 225, 185, 15)
CALL LineVE(210, 200, 225, 215, 15)

LOCATE 22, 1
PRINT "Press any key to continue"
WHILE INKEY$ = "": WEND

CLS
PRINT "But DrawByteVE can be told to color more than one pixel at a time.  In fact"
PRINT "it can color 8 pixels at a time, but it must use the same color for each pixel."
PRINT
PRINT "You can make it draw patterns."

FOR T = 80 TO 150
  FOR S = 1 TO 19
    CALL DrawByteVE((T * 80) + S, 104, 12)
  NEXT
NEXT

FOR T = 80 TO 150
  FOR S = 21 TO 39
    CALL DrawByteVE((T * 80) + S, 85, 13)
  NEXT
NEXT
 
FOR T = 80 TO 150 STEP 2
  FOR S = 41 TO 59
    CALL DrawByteVE((T * 80) + S, 85, 11)
  NEXT
  FOR S = 41 TO 59
    CALL DrawByteVE((T * 80) + S + 80, 170, 11)
  NEXT
NEXT

FOR T = 80 TO 150 STEP 2
  FOR S = 61 TO 79
    CALL DrawByteVE((T * 80) + S, 16 + 1, 10)
  NEXT
  FOR S = 61 TO 79
    CALL DrawByteVE((T * 80) + S + 80, 64 + 4, 10)
  NEXT
NEXT

LOCATE 13, 1
PRINT "You can make it paint pictures (i.e. Computer Van Goh)"
FOR T = 210 TO 320
  FOR S = 1 TO 79
    CALL DrawByteVE(T * 80 + S, 255, C)
    C = (C + 7) MOD 16
  NEXT
NEXT

WHILE INKEY$ = "": WEND

CLS
PRINT "Using the added feature of XOR, OR, AND, and PSET operations with the"
PRINT "DrawByteVE routine, you can invert region on the screen extremely fast."
PRINT
PRINT "For example, this line is being inverted by the DrawByteVE routine."

FOR T = 1 TO 40
  FOR S = 37 * 80 TO 78 * 80 - 1  'XOR lines 37 through 77
    CALL DrawByteVEOpts(S, 255, 15 + 24 * 256)
  NEXT
NEXT

'FOR T = 1 TO 4
'  FOR M = 0 TO 349
'    CALL LineVE(0, M, 639, M, 15 + 24 * 256)
'  NEXT
'NEXT

