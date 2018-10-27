'**** ShadeV.Bas - Vertical Shading Routine

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

SUB ShadeV (Col1, Line1, Col2, Line2, NumColors, StepChoice, Colors()) STATIC

  Cols = Col2 - Col1 + 1
  ShadeX% = 32
  ShadeY% = 8
  Total% = ShadeX% * ShadeY%
  Speed% = Total% * NumColors \ ((Line2 - Line1 + 1) / ShadeY%)
  REDIM ShadeArray%(ShadeX% \ 8 - 1, ShadeY% - 1)
  IF StepChoice = 1 THEN
    StepSize% = (ShadeY% / 1.5 + .7) * ShadeX%
  ELSEIF StepChoice > 1 THEN
    StepSize% = (ShadeY% / StepChoice + .7) * ShadeX%
  END IF

  'Make Sure the shading doesn't clump up with the following to lines.
  IF (StepSize AND 1) = 0 THEN StepSize = StepSize + 1
  IF (StepSize MOD 5) = 0 THEN StepSize = StepSize + 2

  Color1 = Colors(0)
  Color2 = Colors(1)
  T5 = 2

  Coloring = -1
  'Array was just created, so it contains all zeroed bits

  bb = Line1 * 80
  FOR Y = Line1 TO Line2
    IF (Y - Line1) MOD ShadeY% = 0 THEN
      FOR TA2 = 1 TO Speed
	T1 = (T1 + StepSize%) MOD Total%
	T2 = 2 ^ (7 - (T1 AND 7))
	T3 = (T1 \ 8) AND 3
	T4 = (T1 \ 8) \ 4
	IF ((ShadeArray%(T3, T4) AND T2) = (Coloring AND T2)) AND (NumColors > 1) THEN
	  Color1 = Color2
	  Color2 = Colors(T5)
	  Coloring = NOT Coloring
	  NumColors = NumColors - 1
	  T5 = T5 + 1
	END IF
	ShadeArray%(T3, T4) = ShadeArray(T3, T4) XOR T2
      NEXT
    END IF

    FOR X = Col1 TO Col2
      cc = bb + X - 1
      dd = ShadeArray%((X - Col1) MOD (ShadeX% / 8), Y MOD ShadeY%)
      IF Coloring THEN
	CALL DrawByteVE(cc, NOT dd, Color1)
	CALL DrawByteVE(cc, dd, Color2)
      ELSE
	CALL DrawByteVE(cc, dd, Color1)
	CALL DrawByteVE(cc, NOT dd, Color2)
      END IF
    NEXT
    bb = bb + 80
  NEXT
 
  ERASE ShadeArray%

END SUB

SUB ShadeVertical (GWWindow AS Window1, NumColors, StepChoice, Colors()) STATIC

  ShadeX% = 40
  ShadeY% = 8
  Total% = ShadeX% * ShadeY%
  Speed% = Total% * NumColors \ ((GWWindow.Y2 - GWWindow.Y1) / ShadeY%)
  REDIM ShadeArray%(ShadeX% - 1, ShadeY% - 1)
  IF StepChoice = 1 THEN
    StepSize% = (ShadeY% / 1.5 + .7) * ShadeX%
  ELSEIF StepChoice > 1 THEN
    StepSize% = (ShadeY% / StepChoice + .7) * ShadeX%
  END IF

  'Make Sure the shading doesn't clump up with the following to lines.
  IF StepSize% / 2 = StepSize \ 2 THEN StepSize = StepSize + 1
  IF StepSize% / 5 = StepSize \ 5 THEN StepSize = StepSize + 2

  Color1 = Colors(0)
  Color2 = Colors(1)
  T5 = 2

  'Clear The Array
  FOR S1 = 0 TO ShadeX% - 1
    FOR S2 = 0 TO ShadeY% - 1
      ShadeArray%(S1, S2) = Color1
    NEXT
  NEXT

  FOR Y = GWWindow.Y1 TO GWWindow.Y2
    IF (Y - GWWindow.Y1) MOD ShadeY% = 0 THEN
      FOR T4 = 1 TO Speed
	T1 = (T1 + StepSize%) MOD Total%
	IF (ShadeArray%(T1 \ ShadeY%, T1 MOD ShadeY%) = Color2) AND (NumColors > 1) THEN
	  Color1 = Color2
	  Color2 = Colors(T5)
	  NumColors = NumColors - 1
	  T5 = T5 + 1
	END IF
	ShadeArray%(T1 \ ShadeY%, T1 MOD ShadeY%) = Color2
      NEXT
    END IF
    aa = (Y - GWWindow.Y1) MOD ShadeY%
    FOR X = GWWindow.x1 TO GWWindow.X2
      CALL DrawPointVE(X, Y, ShadeArray%((X - GWWindow.x1) MOD ShadeX%, (Y - GWWindow.Y1) MOD ShadeY%))
    NEXT
  NEXT
  ERASE ShadeArray%

END SUB

