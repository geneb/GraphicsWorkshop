'**** PCXHeadr.BAS - Routines to interpret the header of .PCX files

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'
'$INCLUDE: 'COMMON.GW'

SUB HandlePCXPalette (Array$, WhichScreen) STATIC

  PCXVersion = ASC(MID$(Array$, 2, 1))
  IF PCXVersion <> 2 AND PCXVersion <> 5 THEN EXIT SUB

  I = 17
  IF WhichScreen = 9 THEN I = 69

  IF WhichScreen = 8 THEN
	IF GPDat%(31) = 5 THEN
	  FOR T = 0 TO 15
	N = 0
	a = ASC(MID$(Array$, I, 1)) \ 64
	IF (a AND 1) = 1 THEN N = N + 32
	IF (a AND 2) = 2 THEN N = N + 4
	I = I + 1
	b = ASC(MID$(Array$, I, 1)) \ 64
	IF (b AND 1) = 1 THEN N = N + 16
	IF (b AND 2) = 2 THEN N = N + 2
	I = I + 1
	c = ASC(MID$(Array$, I, 1)) \ 64
	IF (c AND 1) = 1 THEN N = N + 8
	IF (c AND 2) = 2 THEN N = N + 1
	I = I + 1
	CALL SetPaletteEGA(T, N)
	  NEXT
	ELSE
	  FOR T = 0 TO 15
	CALL SetPaletteEGA(T, T)
	  NEXT
	  FOR T = 0 TO 15
	a = ASC(MID$(Array$, I, 1)) \ 4
	I = I + 1
	b = ASC(MID$(Array$, I, 1)) \ 4
	I = I + 1
	c = ASC(MID$(Array$, I, 1)) \ 4
	I = I + 1
	CALL SetPalTripleVGA(T, a, b, c)
	  NEXT
	END IF
  ELSEIF WhichScreen = 5 THEN
	FOR T = 0 TO 15
	  N = 0
	  a = ASC(MID$(Array$, I, 1)) \ 64
	  IF (a AND 1) = 1 THEN N = N + 32
	  IF (a AND 2) = 2 THEN N = N + 4
	  I = I + 1
	  b = ASC(MID$(Array$, I, 1)) \ 64
	  IF (b AND 1) = 1 THEN N = N + 16
	  IF (b AND 2) = 2 THEN N = N + 2
	  I = I + 1
	  c = ASC(MID$(Array$, I, 1)) \ 64
	  IF (c AND 1) = 1 THEN N = N + 8
	  IF (c AND 2) = 2 THEN N = N + 1
	  I = I + 1
	  CALL SetPaletteEGA(T, N)
	NEXT
  ELSEIF WhichScreen = 9 THEN
	FOR T = 0 TO 255
	  a = ASC(MID$(Array$, I, 1)) \ 4
	  I = I + 1
	  b = ASC(MID$(Array$, I, 1)) \ 4
	  I = I + 1
	  c = ASC(MID$(Array$, I, 1)) \ 4
	  I = I + 1
	  CALL SetPalTripleVGA(T, a, b, c)
	NEXT
  END IF
 
END SUB

SUB WhichPCXScreen (Array$, WhichScreen) STATIC

  Manufacturer = ASC(MID$(Array$, 1, 1))
  PCXVersion = ASC(MID$(Array$, 2, 1))

  Compression = ASC(MID$(Array$, 3, 1))
  BitsPerPixel = ASC(MID$(Array$, 4, 1))

  XMin = CVI(MID$(Array$, 5, 2))          'Image locations
  YMin = CVI(MID$(Array$, 7, 2))
  XMax = CVI(MID$(Array$, 9, 2))
  YMax = CVI(MID$(Array$, 11, 2))

  XSize = CVI(MID$(Array$, 13, 2))        'Monitor Display Size
  YSize = CVI(MID$(Array$, 15, 2))
 
  NumPlanes = ASC(MID$(Array$, 66, 1))    'Number of video planes
  BytesPerLine = CVI(MID$(Array$, 67, 2)) 'Bytes Per Line

  'Determine Monitor Needed
  IF (XMax - XMin + 1) = 320 OR XSize = 320 THEN
	IF BitsPerPixel = 8 THEN
	  WhichScreen = 9
	ELSE
	  WhichScreen = 4
	END IF
  ELSEIF (XSize = 720) OR (XMax - XMin + 1) = 720 THEN
	WhichScreen = 2
  ELSEIF (XSize = 640) OR (XMax - XMin + 1) = 640 THEN
	IF (YSize = 200) OR (YMax - YMin + 1) = 200 THEN
	  WhichScreen = 6
	ELSEIF (YSize = 350) OR (YMax - YMin + 1) <= 350 THEN
	  WhichScreen = 5
	ELSEIF (YSize = 480) OR (YMax - YMin + 1) <= 480 THEN
	  WhichScreen = 8
	END IF
  END IF

  IF WhichScreen = 0 THEN
	IF NumPlanes > 1 THEN WhichScreen = 8 ELSE WhichScreen = 6
	IF BitsPerPixel = 2 THEN WhichScreen = 4
	IF BitsPerPixel = 8 THEN WhichScreen = 9
  END IF

END SUB

