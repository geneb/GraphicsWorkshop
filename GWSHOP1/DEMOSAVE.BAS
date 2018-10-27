'**** DEMOSAVE.BAS - Saves a PCX file

'Copyright 1990 Brian C. Giedt

'This demonstrates the routine SavePCXFileEGA, an assembler routine which
'saves the current EGA or VGA high resolution image in the PCX file format.

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'*******************************************************
'$INCLUDE: 'GetVideo.Bas'

GPDat%(31) = 5                 'Example file is an EGA file
CALL SetVideo

   Filename$ = "DEMOSHAD.PCX"
   CALL DisplayPCXFile(Filename$, 0)

   WHILE INKEY$ = "": WEND          'Pause until someone hits a key

   'Save the PCX file.
   CALL SavePCXVE("DEMOSAVE.PCX")
  
   CLS

   'Reload the newly saved PCX file.
   CALL DisplayPCXFile("DEMOSAVE.PCX", 0)

