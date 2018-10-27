'AboutPCX.Bas - this program looks at the header of a pcx file and displays
'               the pertinent information to the user

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'This program is set up to be used as an EXE.  The variable COMMAND$ tells
'the program what parameters where specified on the command line when the
'EXE is executed.  The COMMAND$ can be set using the Run Menu in QuickBASIC.
  
   PRINT "AboutPCX.EXE     Version 1.0     Copyright 1990, Brian C. Giedt"
   PRINT
   IF COMMAND$ = "" THEN
       PRINT "Format:  ABOUTPCX [path]filename[.pcx]"
       END
   END IF

   Filename$ = COMMAND$
   L = INSTR(Filename$, ".")
   IF L = 0 THEN Filename$ = Filename$ + ".PCX"

   PRINT "File: "; Filename$

   'Find the size of the file to determine the size of the array
   OPEN Filename$ FOR RANDOM AS #1 LEN = 128
   FIELD #1, 128 AS N$
   GET #1, 1
   Array$ = N$
   CLOSE #1

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
   IF XSize = 320 THEN
     IF BitsPerPixel = 8 THEN
       WhichScreen = 9
     ELSE
       WhichScreen = 4
     END IF
   ELSEIF XSize = 720 THEN
     WhichScreen = 2
   ELSEIF XSize = 640 THEN
     IF YSize = 200 THEN
       WhichScreen = 6
     ELSEIF YSize = 350 THEN
       WhichScreen = 5
     ELSEIF YSize = 480 THEN
       WhichScreen = 8
     END IF
   END IF

   IF WhichScreen = 0 THEN
     IF NumPlanes > 1 THEN WhichScreen = 8 ELSE WhichScreen = 6
     IF BitsPerPixel = 2 THEN WhichScreen = 4
     IF BitsPerPixel = 8 THEN WhichScreen = 9
   END IF

   A$ = ""
   IF Manufacturer = 10 THEN A$ = "(ZSoft)"
   PRINT "Manufacturer:"; Manufacturer; A$
   PRINT "File Version:"; PCXVersion; TAB(40); "PC PaintBrush Version: ";

   IF PCXVersion = 0 THEN
     PRINT "2.5"
   ELSEIF PCXVersion = 2 OR PCXVersion = 3 THEN
     PRINT "2.8"
   ELSEIF PCXVersion = 5 THEN
     PRINT "3.0"
   END IF
   IF PCXVersion = 2 OR PCXVersion = 5 THEN
     PRINT TAB(40); "(Contains Palette information)"
   END IF
   PRINT "Compression Scheme is Run Length Encoding"
   PRINT
   PRINT "Image Window: ("; XMin; ","; YMin; ") - ("; XMax; ","; YMax; ")"
   PRINT "Created on ";
   IF WhichScreen = 2 THEN PRINT "HERC (720x350) 2 color"
   IF WhichScreen = 4 THEN PRINT "CGA (320x200) 4 color"
   IF WhichScreen = 5 THEN PRINT "EGA (640x350) 16 color"
   IF WhichScreen = 6 THEN PRINT "CGA (640x200) 2 color"
   IF WhichScreen = 8 THEN PRINT "VGA (640x480) 16 color"
   IF WhichScreen = 9 THEN PRINT "VGA (320x200) 256 color"
   IF WhichScreen = 0 THEN PRINT "UnKnown ("; XSize; "x"; YSize; ")"; BitsPerPixel * (2 ^ NumPlanes); "color"
  
   IF WhichScreen = 0 THEN
     IF BitsPerPixel * (2 ^ NumPlanes) = 16 THEN WhichScreen = 8
     IF BitsPerPixel = 2 THEN WhichScreen = 4
     IF BitsPerPixel * (2 ^ NumPlanes) = 2 THEN WhichScreen = 6
     PRINT "Graphics Workshop will use ";
     IF WhichScreen = 8 THEN PRINT "EGA or VGA"
     IF WhichScreen = 4 OR WhichScreen = 6 THEN PRINT "CGA"
   END IF

   PRINT
   PRINT "Number of Planes:"; NumPlanes; "(Applies to EGA and VGA only)"
   PRINT "Bits Per Pixel:"; BitsPerPixel
   PRINT "Bytes Per Line:"; BytesPerLine

