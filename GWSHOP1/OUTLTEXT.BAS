'***** OutlText.BAS - Routines for drawing the outline fonts

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB SetGWFont (FontNumber%)
DECLARE SUB OutlineChar (X1%, Y1%, Letter%, Colr%, Mult%, Divide%)
DECLARE SUB OutlineCharA (X1%, Y1%, Letter%, Colr%, Mult%, Divide%, CAngle!, SAngle!)

'$INCLUDE: 'Common.GW'

FUNCTION GetOutlineWidth% (Text$)

	FW = 0
	FOR T = 1 TO LEN(Text$)
	L = ASC(MID$(Text$, T, 1)) - 31
	FW = FW + FontSize%(L, GPDat%(82)) + GPDat%(83)
	NEXT
	GetOutlineWidth% = FW

END FUNCTION

SUB LoadOutlineFont (FontFile$) STATIC

  LocalFile$ = FontFile$ + ".QFN"
  FileLeft = GWFileSize&(LocalFile$)
  Filenum = FREEFILE
  OPEN LocalFile$ FOR RANDOM AS #Filenum LEN = 512
  FIELD #Filenum, 512 AS n1$
  t2 = 0   'File Record (512 bytes)
  t3 = 1   'Letter number
  BufPointer = 513   'Force a read on the first pass
  DO
	IF BufPointer > 512 THEN GOSUB NextBlock
	t4 = ASC(MID$(n1$, BufPointer, 1))
	BufPointer = BufPointer + 1
	IF BufPointer > 512 THEN GOSUB NextBlock
	t4 = t4 + 256 * ASC(MID$(n1$, BufPointer, 1))
	BufPointer = BufPointer + 1
	IF BufPointer > 512 THEN GOSUB NextBlock
	OutlineFont$(t3, GPDat%(82)) = STRING$(t4, 0)
	IF BufPointer + t4 > 513 THEN  'Not a complete string
	  LSET OutlineFont$(t3, GPDat%(82)) = MID$(n1$, BufPointer)
	  t5 = t4 - (513 - BufPointer) + 1
	  t4 = 513 - BufPointer
	  BufPointer = t5
	  t2 = t2 + 1
	  GET #Filenum, t2
	  FileLeft = FileLeft - 512
	  MID$(OutlineFont$(t3, GPDat%(82)), t4 + 1, BufPointer - 1) = MID$(n1$, 1, BufPointer - 1)
	ELSE
	  LSET OutlineFont$(t3, GPDat%(82)) = MID$(n1$, BufPointer, t4)
	  BufPointer = BufPointer + t4
	END IF
	FontSize(t3, GPDat%(82)) = ASC(OutlineFont$(t3, GPDat%(82)))
	t3 = t3 + 1
  LOOP UNTIL (FileLeft <= 0) AND (BufPointer > 512 + FileLeft)
  CLOSE #Filenum
  FontSize(1, GPDat%(82)) = GPDat%(83)
  Height% = 0
  In% = 4
  t1 = 0
  n$ = OutlineFont$(ASC("g") - 31, GPDat%(82))
  WHILE ((t1 < 64) OR (t1 > 127 AND t1 < 192)) AND In% < LEN(n$)
	  t1 = ASC(MID$(n$, In%, 1))
	  IF t1 > 127 THEN t1 = t1 - 128
	  IF t1 > Height% THEN Height% = t1
	  In% = In% + 1
	  t1 = ASC(MID$(n$, In%, 1))
	In% = In% + 1
  WEND
  OutLineHeight%(GPDat%(82)) = Height%
 
  CALL SetGWFont(GPDat%(82) + 1)

  EXIT SUB

NextBlock:
  t2 = t2 + 1
  GET #Filenum, t2
  BufPointer = 1
  FileLeft = FileLeft - 512
  RETURN

END SUB

SUB OutlineChar (X1%, Y1%, Letter%, Colr%, Mult%, Divide%) STATIC

	LineNum = 0
	PaintNum = 0
	A = Letter - 31
	A$ = OutlineFont$(A, GPDat%(82))
	IF LEN(A$) < 3 THEN EXIT SUB
	BaseLine = ASC(MID$(A$, 2, 1))
	t3 = 3
	t1 = 0
	WHILE (t1 < 64 OR (t1 > 127 AND t1 < 192)) AND t3 < LEN(A$)
	  t1 = ASC(MID$(A$, t3, 1))
	  t2 = ASC(MID$(A$, t3 + 1, 1))
	  IF t1 > 127 AND t1 < 192 THEN
	L1 = t1 - 128
	L2 = t2 - 128
	xd1 = Mult * L1 \ Divide
	yd1 = Mult * L2 \ Divide
	PSET (xd1 + X1, yd1 + Y1), Colr
	t3 = t3 + 2
	  ELSEIF t1 < 64 THEN
	LineNum = LineNum + 1
	xd2 = Mult * t1 \ Divide
	yd2 = Mult * t2 \ Divide
	LINE -(xd2 + X1, yd2 + Y1), Colr
	t3 = t3 + 2
	  END IF
	WEND
	WHILE t3 < LEN(A$)
	  t1 = ASC(MID$(A$, t3, 1))
	  t2 = ASC(MID$(A$, t3 + 1, 1))
	  PaintNum = PaintNum + 1
	  IF t1 > 63 THEN
	t1 = t1 - 64
	t2 = t2 - 64
	xd1 = Mult * t1 \ Divide
	yd1 = Mult * t2 \ Divide
	IF GPDat%(86) = 0 THEN PAINT (xd1 + X1, yd1 + Y1), Colr, Colr
	t3 = t3 + 2
	  ELSE
	t1 = t1 - 192
	t2 = t2 - 192
	xd1 = Mult * t1 \ Divide
	yd1 = Mult * t2 \ Divide
	C = ASC(MID$(A$, t3 + 2, 1))
	IF GPDat%(86) = 0 THEN PAINT (xd1 + X1, yd1 + Y1), C, Colr
	t3 = t3 + 3
	  END IF
	WEND

END SUB

SUB OutlineCharA (X1, Y1, Letter, Colr, Mult, Divide, CAngle!, SAngle!) STATIC

	LineNum = 0
	PaintNum = 0
	A = Letter - 31
	A$ = OutlineFont$(A, GPDat%(82))
	IF LEN(A$) < 3 THEN EXIT SUB
	BaseLine = ASC(MID$(A$, 2, 1))
	t3 = 3
	t1 = 0
	WHILE (t1 < 64 OR (t1 > 127 AND t1 < 192)) AND t3 < LEN(A$)
	  t1 = ASC(MID$(A$, t3, 1))
	  t2 = ASC(MID$(A$, t3 + 1, 1))
	  IF t1 > 127 AND t1 < 192 THEN
	L1 = t1 - 128
	L2 = t2 - 128
	xd1 = INT(Mult * (CAngle! * L1 + SAngle! * L2)) \ Divide
	yd1 = INT(Mult * (CAngle! * L2 - SAngle! * L1)) \ Divide
	PSET (xd1 + X1, yd1 + Y1), Colr
	t3 = t3 + 2
	  ELSEIF t1 < 64 THEN
	LineNum = LineNum + 1
	xd2 = INT(Mult * (CAngle! * t1 + SAngle! * t2)) \ Divide
	yd2 = INT(Mult * (CAngle! * t2 - SAngle! * t1)) \ Divide
	LINE -(xd2 + X1, yd2 + Y1), Colr
	t3 = t3 + 2
	  END IF
	WEND
	WHILE t3 < LEN(A$)
	  t1 = ASC(MID$(A$, t3, 1))
	  t2 = ASC(MID$(A$, t3 + 1, 1))
	  PaintNum = PaintNum + 1
	  IF t1 > 63 THEN
	t1 = t1 - 64
	t2 = t2 - 64
	xd1 = INT(Mult * (CAngle! * t1 + SAngle! * t2)) \ Divide
	yd1 = INT(Mult * (CAngle! * t2 - SAngle! * t1)) \ Divide
	IF GPDat%(86) = 0 THEN PAINT (xd1 + X1, yd1 + Y1), Colr, Colr
	t3 = t3 + 2
	  ELSE
	t1 = t1 - 192
	t2 = t2 - 192
	xd1 = INT(Mult * (CAngle! * t1 + SAngle! * t2)) \ Divide
	yd1 = INT(Mult * (CAngle! * t2 - SAngle! * t1)) \ Divide
	C = ASC(MID$(A$, t3 + 2, 1))
	IF GPDat%(86) = 0 THEN PAINT (xd1 + X1, yd1 + Y1), C, Colr
	t3 = t3 + 3
	  END IF
	WEND

END SUB

SUB OutlineText (X, Y, A$, Angle, Colr, Mult, Divide) STATIC

	LocalX = X
	LocalY = Y
	IF Angle = 0 THEN
	FOR B = 1 TO LEN(A$)
		Letter = ASC(MID$(A$, B, 1))
		CALL OutlineChar(LocalX, LocalY, Letter, Colr, Mult, Divide)
		LocalX = LocalX + (FontSize(Letter - 31, GPDat%(82)) + GPDat%(83)) * Mult / Divide
	NEXT
	ELSE
	CAngle! = COS(Angle * 11 / 630)
	SAngle! = SIN(Angle * 11 / 630) * .7
	FOR B = 1 TO LEN(A$)
		Letter = ASC(MID$(A$, B, 1))
		CALL OutlineCharA(LocalX, LocalY, Letter, Colr, Mult, Divide, CAngle!, SAngle!)
		LocalX = LocalX + (FontSize(Letter - 31, GPDat%(82)) + GPDat%(83)) * CAngle! * Mult / Divide
		LocalY = LocalY - (FontSize(Letter - 31, GPDat%(82)) + GPDat%(83)) * SAngle! * Mult / Divide
	NEXT
	END IF

END SUB

'This Routine changes the current Graphics Workshop font
'
SUB SetGWFont (FontNumber%) STATIC

	'Check for invalid FontNumber
	IF FontNumber% < 0 OR FontNumber% > GPDat%(81) THEN EXIT SUB

	GPDat%(82) = FontNumber% - 1     'Change the current font to FontNumber%
	GPDat%(85) = GPDat%(84) + OutLineHeight%(GPDat%(82))

END SUB

'This sub-program sets the character spacing for the Graphics Workshop fonts
'
SUB SetGWSpacing (SpacingH%, SpacingV%) STATIC

	GPDat%(83) = SpacingH%
	GPDat%(84) = SpacingV%
	GPDat%(85) = GPDat%(84) + OutLineHeight%(GPDat%(82))

END SUB

