'GPaintBx - a routine to paint a box region in a specified color
'           Actually it replaces a specified color with another specified
'           color, everywhere within the specified region.

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'$INCLUDE: 'Common.GW'

SUB GPaintBox (Col1, Line1, Col2, Line2, OldColor%, NewColor%)

   'An OldColor = -1 means that the routine should take the color which
   'is present at the upper-leftmost pixel and change all occurances of that
   'color

   TmpOldColor = OldColor
   IF TmpOldColor = -1 THEN
      IF GPDat%(57) <> 0 THEN
        TmpOldColor = GPDat%(57)
      ELSE
        TmpOldColor = GetPointVE(Col1% * 8, Row1%)
      END IF
   END IF
  
   HideCursor
   FOR T = Line1% TO Line2%
       FOR S = Col1% TO Col2%
           CALL PaintByte(S, T, TmpOldColor, NewColor)
       NEXT
   NEXT
   ShowCursor

END SUB

