'**** ShadeH.Bas - Horizontal Color Shading Routine

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

SUB ShadeH (Col1, Line1, Col2, Line2, NumColors, StepChoice, Colors()) STATIC

  Cols = Col2 - Col1 + 1
  ShadeX% = 8
  ShadeY% = 40
  Total% = ShadeX% * ShadeY%
  Speed% = Total% * NumColors \ Cols
  REDIM ShadeArray%(ShadeY% - 1)
  IF StepChoice = 1 THEN
    StepSize% = (ShadeX% / 1.5 + .7) * ShadeY%
  ELSEIF StepChoice > 1 THEN
    StepSize% = (ShadeX% / StepChoice + .7) * ShadeY%
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
  FOR X = Col1 TO Col2
    FOR T4 = 1 TO Speed
      T1 = (T1 + StepSize%) MOD Total%
      T2 = 2 ^ (7 - (T1 AND 7))
      T3 = T1 \ 8
      IF (NumColors > 1) AND ((ShadeArray(T3) AND T2) = (Coloring AND T2)) THEN
	Color1 = Color2
	Color2 = Colors(T5)
	Coloring = NOT Coloring
	NumColors = NumColors - 1
	T5 = T5 + 1
      END IF
      ShadeArray(T3) = ShadeArray(T3) XOR T2
    NEXT

    cc = bb + X - 1
    FOR Y = 0 TO Line2 - Line1
      IF Coloring THEN
	CALL DrawByteVE(cc, NOT ShadeArray%(Y MOD ShadeY%), Color1)
	CALL DrawByteVE(cc, ShadeArray%(Y MOD ShadeY%), Color2)
      ELSE
	CALL DrawByteVE(cc, ShadeArray%(Y MOD ShadeY%), Color1)
	CALL DrawByteVE(cc, NOT ShadeArray%(Y MOD ShadeY%), Color2)
      END IF
      cc = cc + 80
    NEXT
  NEXT
  ERASE ShadeArray%

END SUB

SUB ShadeHorizontal (GWWindow AS Window1, NumColors, StepChoice, Colors()) STATIC

  ShadeX% = 8
  ShadeY% = 40
  Total% = ShadeX% * ShadeY%
  Speed% = Total% / (((GWWindow.X2 - GWWindow.X1) / ShadeX%) / NumColors)
  REDIM ShadeArray%(ShadeX% - 1, ShadeY% - 1)
  IF StepChoice = 1 THEN
    StepSize% = (ShadeX% / 1.5 + .7) * ShadeY%
  ELSEIF StepChoice > 1 THEN
    StepSize% = (ShadeX% / StepChoice + .7) * ShadeY%
  END IF

  'Make Sure the shading doesn't clump up with the following to lines.
  IF StepSize% / 2 = StepSize \ 2 THEN StepSize = StepSize + 1
  IF StepSize% / 5 = StepSize \ 5 THEN StepSize = StepSize + 2

  Color1 = Colors(0)
  Color2 = Colors(1)
  T5 = 2

  'Clear The Shading Array
  FOR S1 = 0 TO ShadeX% - 1
    FOR S2 = 0 TO ShadeY% - 1
      ShadeArray%(S1, S2) = Color1
    NEXT
  NEXT

  FOR X = GWWindow.X1 TO GWWindow.X2
    IF (X - GWWindow.X1) MOD ShadeX% = 0 THEN
      FOR T4 = 1 TO Speed
	T1 = (T1 + StepSize%) MOD Total%
	IF (NumColors > 1) AND (ShadeArray%(T1 \ ShadeY%, T1 MOD ShadeY%) = Color2) THEN
	  Color1 = Color2
	  Color2 = Colors(T5)
	  NumColors = NumColors - 1
	  T5 = T5 + 1
	END IF
	ShadeArray%(T1 \ ShadeY%, T1 MOD ShadeY%) = Color2
      NEXT
    END IF
    aa = (X - GWWindow.X1) MOD ShadeX%
    FOR Y = GWWindow.Y1 TO GWWindow.Y2
      CALL DrawPointVE(X, Y, ShadeArray%(aa, (Y - GWWindow.Y1) MOD ShadeY%))
    NEXT
  NEXT
  ERASE ShadeArray%

END SUB

