'********** DrawText.Bas - subprograms to draw a string of text

'Copyright (c) 1987,1990 Brian Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DrawChar (X%, Y%, Letter%, Colr%, Size#, Expand%)
DECLARE SUB DrawCharA (X%, Y%, SAngle#, CAngle#, Letter%, Colr%, Size#, Expand%)

'$INCLUDE: 'Common.GW'

SUB DrawChar (X, Y, Letter, Colr, Size#, Expand) STATIC

  Shift = INT(Size# - .1)
  IF GPDat%(23) THEN
	 Shift = Shift + INT(Size#) \ 3 + 1
  END IF
  I = 1
  Char$ = Font$(Letter, GPDat%(34))    'Obtain the font in a local variable
  L = LEN(Char$)                        'and length of the string
  WHILE I < L
	  P = ASC(MID$(Char$, I, 1))        'Break the first byte into two 4 bit
	  X1 = (P MOD 16) * Size#           'values showing x,y positioning of
	  Y1 = (P \ 16) * Size#             'the first point on a grid 16x16
	  Q = ASC(MID$(Char$, I + 1, 1))    'Do the same with the second number
	  X2 = (Q MOD 16) * Size#
	  Y2 = (Q \ 16) * Size#
	  'Draw the connecting line
	  LINE (X1 + X, Y1 + Y)-(X2 + Shift + X, Y2 + Shift + Y), Colr, BF
	  'position two bytes forward in the font string
	  I = I + 2
  WEND

END SUB

SUB DrawCharA (X, Y, SAngle#, CAngle#, Letter, Colr, Size#, Expand) STATIC

  'SEE DRAWCHAR FOR COMMENTS
  Shift# = INT(Size# - .5)
  IF GPDat%(23) THEN
	 Shift# = Shift# + INT(Size#) \ 3 + 1
  END IF
  IF Expand THEN Shift# = Shift# + 1 + INT(Size# / 10)
  I = 1
  Char$ = Font$(Letter, GPDat%(34))
  L = LEN(Char$)
  WHILE I < L
	  P = ASC(MID$(Char$, I, 1))
	  P1 = (P MOD 16) * Size#
	  P2 = (P \ 16) * Size#
	  Q = ASC(MID$(Char$, I + 1, 1))
	  Q1 = (Q MOD 16) * Size#
	  Q2 = (Q \ 16) * Size#
	  IF GPDat%(24) <> 90 THEN
	X1 = P1 + P2 * CAngle# + X 'These calculations will tilt the character
	X2 = Q1 + Q2 * CAngle# + X
	Y1 = P2 + Y
	Y2 = Q2 + Y
	  ELSE
	X1 = P1 * CAngle# + P2 * SAngle# + X 'These calculations will tilt the character
	X2 = Q1 * CAngle# + Q2 * SAngle# + X
	Y1 = P2 * CAngle# - P1 * SAngle# + Y
	Y2 = Q2 * CAngle# - Q1 * SAngle# + Y
	  END IF
	  Shift1# = Shift# * SAngle#
	  'The section below will fill in the font depending on whether
	  'the line is horizontal or vertical
	  IF P1 <> Q1 THEN            'line is horizontal
	 FOR T = 0 TO Shift#
		 Part = T * SAngle#
		 LINE (X1 + Part, Y1 + T - Part)-(X2 + Part + Shift1# + Shift#, Y2 + T - Shift1# - Part), Colr
	 NEXT
	  ELSEIF P2 = Q2 THEN         'just one pixel to be plotted
	 FOR T = 0 TO Shift#
		 Part = T * SAngle#
		 LINE (X1 + Part, Y1 + T - Part)-(X2 + Shift1# + Shift# + Part, Y2 + T - Shift1# - Part), Colr
	 NEXT
	  ELSE                        'Line is vertical
	 FOR T = 0 TO Shift#
		 Part = T * SAngle#
		 LINE (X1 + T + Part, Y1 - Part)-(X2 + T + Shift1# + Part, Y2 - Part + Shift# - Shift1#), Colr
	 NEXT
	  END IF
	  I = I + 2
  WEND

END SUB

'This sub-program draws characters horizontally, or at an angle
'
SUB DrawText (Xx, Yy, Text$, Angle, Colr, TextSize#) STATIC

	SColor = GPDat%(14)          'get shadow color

	Size# = TextSize#            'use copies to preserve incoming vars
	X = Xx
	Y = Yy
	Expand = 0

	IF Size# < .001 THEN Size# = 1!
	'Prepare some variables that will be repeatedly used
	SAngle# = SIN((Angle / 180) * (22 / 7))
	CAngle# = COS((Angle / 180) * (22 / 7))

	IF Colr > 127 THEN          'if shadow then calculate size of shadow
	Ofsx = 1 + Size# * .6
	Ofsy = 1 + Size# * .3
	END IF                      'otherwise we don't care about the values
				'  of Ofsx and Ofsy
	IF Angle <> 0 OR GPDat%(24) <> 90 THEN
	IF GPDat%(24) <> 90 THEN
		SAngle# = 0
		CAngle# = -COS(((GPDat%(24)) / 180) * (22 / 7))
		FOR T = 1 TO LEN(Text$)
		  'Give a value 1-95 as an offset into the font set
		  Letter = ASC(MID$(Text$, T, 1)) - 31
		  IF Letter <= UBOUND(FontWidth%, 1) THEN
		'If shadowing then draw the shadow first
		IF Colr > 127 THEN CALL DrawCharA(X + Ofsx, Y + Ofsy, SAngle#, CAngle#, Letter, SColor, Size#, Expand)
		'Draw the character
		CALL DrawCharA(X, Y, SAngle#, CAngle#, Letter, (Colr AND 127), Size#, Expand)
		'Calculate position for next character to be drawn
		X = X + (FontWidth%(Letter, GPDat%(34)) + GPDat%(48) + GPDat%(59)) * Size#
		  END IF
		NEXT
	ELSE
	  FOR T = 1 TO LEN(Text$)
		'Give a value 1-95 as an offset into the font set
		Letter = ASC(MID$(Text$, T, 1)) - 31
		IF Letter <= UBOUND(FontWidth%, 1) THEN
		  'If shadowing then draw the shadow first
		  IF Colr > 127 THEN CALL DrawCharA(X + Ofsx, Y + Ofsy, SAngle#, CAngle#, Letter, SColor, Size#, Expand)
		  'Draw the character
		  CALL DrawCharA(X, Y, SAngle#, CAngle#, Letter, (Colr AND 127), Size#, Expand)
		  'Calculate position for next character to be drawn
		  X = X + CAngle# * (FontWidth%(Letter, GPDat%(34)) + GPDat%(48) + GPDat%(59)) * Size#
		  Y = Y - SAngle# * (FontWidth%(Letter, GPDat%(34)) + GPDat%(48) + GPDat%(59)) * Size#
		END IF
	  NEXT
	END IF
	ELSE
	FOR T = 1 TO LEN(Text$)
		'SEE ABOVE FOR COMMENTS
		Letter = ASC(MID$(Text$, T, 1)) - 31
		IF Letter <= UBOUND(FontWidth%, 1) THEN
		  IF Colr > 127 THEN CALL DrawChar(X + Ofsx, Y + Ofsy, Letter, SColor, Size#, Expand)
		  CALL DrawChar(X, Y, Letter, (Colr AND 127), Size#, Expand)
		  X = X + (FontWidth%(Letter, GPDat%(34)) + GPDat%(48) + GPDat%(59)) * Size#
		END IF
	NEXT
	END IF

END SUB

FUNCTION GetWidth% (Text$) STATIC

	FW = 0
	FOR T = 1 TO LEN(Text$)
	L = ASC(MID$(Text$, T, 1)) - 31
	FW = FW + FontWidth%(L, GPDat%(34)) + GPDat%(48)
	NEXT
	GetWidth% = FW

END FUNCTION

SUB LoadFont (FontFile$) STATIC

   LocalFile$ = FontFile$ + ".GFN"
   Filenum = FREEFILE
   OPEN LocalFile$ FOR INPUT AS #Filenum
   INPUT #Filenum, GPLen                    'the first record contains ASCII
   CLOSE #Filenum                           '  representation of record length

   OPEN LocalFile$ FOR RANDOM AS Filenum LEN = GPLen
   FIELD #Filenum, GPLen AS GPL$

   GET #Filenum                             'bypass the first record
   FOR GPCnt = 1 TO UBOUND(Font$, 1)
	   GET #Filenum                         'get next record from file
	   GPChar = ASC(LEFT$(GPL$, 1))         'first byte contains Length of $
	   Font$(GPCnt, GPDat%(34)) = MID$(GPL$, 2, GPChar) 'extract string
	   Max = ASC(MID$(GPL$, 2, 1)) MOD 16
	   FOR T = 3 TO GPChar + 1
	  Ma = ASC(MID$(GPL$, T, 1)) MOD 16
	  IF Ma > Max THEN Max = Ma
	   NEXT
	   IF GPCnt = 72 THEN  'Check for the height of the font by checking "g"
	  Max2 = ASC(MID$(GPL$, 2, 1)) \ 16
	  FOR T = 3 TO GPChar + 1
		 Ma2 = ASC(MID$(GPL$, T, 1)) \ 16
		 IF Ma2 > Max2 THEN Max2 = Ma2
	  NEXT
	  FontHeight%(GPDat%(34)) = Max2
	   END IF
	   FontWidth%(GPCnt, GPDat%(34)) = Max
	   IF EOF(Filenum) THEN EXIT FOR
   NEXT
   'Set the width of the space character here
   FontWidth%(1, GPDat%(34)) = GPDat%(48)

   CLOSE #Filenum

   CALL SetGPFont(GPDat%(34) + 1)

END SUB

'This Routine changes the current GraphPak font
'
SUB SetGPFont (FontNumber%) STATIC

	'Check for invalid FontNumber
	IF FontNumber% < 0 OR FontNumber% > GPDat%(33) THEN EXIT SUB

	GPDat%(34) = FontNumber% - 1     'Change the current font to FontNumber%
	GPDat%(36) = GPDat%(48) + FontHeight%(GPDat%(34))
	GPDat%(35) = FontWidth%(56, GPDat%(34))

END SUB

'This sub-program sets the character spacing for the GraphPak fonts
'
SUB SetGPSpacing (SpacingH%, SpacingV%) STATIC

	GPDat%(47) = SpacingH%
	GPDat%(48) = SpacingV%
	GPDat%(36) = GPDat%(48) + FontHeight%(GPDat%(34))

END SUB

'This subprogram draws text at angle while always keeping the letters at
'90 degree angles
'
SUB StepText (Xx, Yy, Text$, Angle, Colr, TextSize#) STATIC

	Size# = TextSize#               'use copies (see DrawText above)
	X = Xx
	Y = Yy
	Expand = -1

	IF Size# < .001 THEN Size# = 1!
	IF INT(Size# * 1000) <= 1000 THEN Expand = 0
	MSAngle = SIN((Angle / 180) * (22 / 7)) * GPDat%(35)
	MCangle = COS((Angle / 180) * (22 / 7)) * GPDat%(35)
	NewColr = Colr AND 255
	IF NewColr > 127 THEN       'if shadow then calculate size of shadow
	Ofsx = 1 + Size# * .6
	Ofsy = 1 + Size# * .3
	END IF                      'otherwise we don't care about the values
				'  of Ofsx and Ofsy
   
	FOR T = 1 TO LEN(Text$)
	Letter = ASC(MID$(Text$, T, 1)) - 31
	IF Letter <= UBOUND(FontWidth%, 1) THEN
	  Offset = (GPDat%(35) - FontWidth%(Letter, GPDat%(34))) \ 2
	  IF NewColr > 127 THEN CALL DrawChar(X + Offset + Ofsx, Y + Ofsy, Letter, SColor, Size#, Expand)
	  CALL DrawChar(X + Offset, Y, Letter, (NewColr MOD 128), Size#, Expand)
	  X = X + MCangle
	  Y = Y - MSAngle
	END IF
	NEXT

END SUB

