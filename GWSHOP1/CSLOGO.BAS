'CSLOGO.BAS - Contains a routine to draw the Crescent Software Logo

'Copyright (c) 1990, Cresent Software
'Written by Phil Cramer

'Syntax:
'
'  CALL CSLogo (X, Y, Scale!, BClr)
'               ^  ^  ^
'               ³  ³  ³
'               ³  ³  ÀÄÄÄÄÄÄÄÄÄ Scaling factor (must be at least .75)
'               ³  ÀÄÄÄÄÄÄÄÄÄÄÄÄ Y Pixel for upper left corner of LOGO
'               ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ X Pixel for upper left corner of LOGO

DEFINT A-Z


'$INCLUDE: 'Common.GW'

SUB CSLogo (X, Y, Scale!, BClr)

  StepSize = 5 * Scale!
  LHite = 102
  LVCenter = 51
  IF GPDat(31) = 5 THEN
    LHite = 70
    LVCenter = 36
  END IF
  LHiteScale = LHite * Scale!

  Orange$ = CHR$(0) + CHR$(85) + CHR$(255) + CHR$(0) + CHR$(0) + CHR$(170) + CHR$(255) + CHR$(0) + CHR$(0)
  Orange$ = Orange$ + CHR$(85) + CHR$(255) + CHR$(0) + CHR$(0) + CHR$(170) + CHR$(255) + CHR$(0) + CHR$(0)
  Orange$ = Orange$ + CHR$(85) + CHR$(255) + CHR$(0) + CHR$(0) + CHR$(170) + CHR$(255) + CHR$(0) + CHR$(0)
  Orange$ = Orange$ + CHR$(85) + CHR$(255) + CHR$(0) + CHR$(0) + CHR$(170) + CHR$(255) + CHR$(0)
  LineClr = 4
             '102    '72
  FOR I = 0 TO LHiteScale STEP StepSize
    LINE (X, Y + I)-(X + (110 * Scale!), Y + I + (Scale!)), 7, BF
  NEXT
                       'Main Red Circle (1)         '36
  CIRCLE (X + (55 * Scale!) - (11 * Scale!), Y + (LVCenter * Scale!)), (52 * Scale!), 4' BClr
                       'Paint circle orange
  PAINT (X - 1, Y + INT(36 * Scale!)), Orange$, 4
                      
                       'Inner crescent (2)
  CIRCLE (X + (55 * Scale!) + (14 * Scale!), Y + (LVCenter * Scale!)), (52 * Scale!), 1, 1.8, 4.5
                      
                       'Right circle (3)
  CIRCLE (X + (55 * Scale!) - (11 * Scale!), Y + (LVCenter * Scale!)), (52 * Scale!), 1, 4.95, 1.33
                       'Fill in Circle with blue
  PAINT (X + (55 * Scale!) + (14 * Scale!), Y + (LVCenter * Scale!)), 1, 1

END SUB

