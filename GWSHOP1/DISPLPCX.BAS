DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB WhichPCXScreen (Array$, WhichScreen%)
DECLARE SUB HandlePCXPalette (Array$, WhichScreen%)

'$INCLUDE: 'Common.GW'


SUB DisplayPCXFile (FileName$, VideoPage%) STATIC

   L = INSTR(FileName$, ".")   'Append the .PCX extension if it isn't already there
   IF L = 0 THEN FileName$ = FileName$ + ".PCX"

   Array$ = SPACE$(68 + 768)   'Set up an array for the header and VGA 256 palette
   IF NOT OpenPCXFile(FileName$, Array$) THEN EXIT SUB

   CALL WhichPCXScreen(Array$, WhichScreen%)

   CALL HandlePCXPalette(Array$, WhichScreen%)

   'Each of the if statements before the CALL's to Screen statements
   'could be removed if you want the screen mode to be set by this routine
   'and not by calling SetVideo prior to calling this routine.  What the
   'if statements do is attempt not to set the screen mode if it the computer
   'is already in that screen mode.
   IF WhichScreen = 4 OR WhichScreen = 6 THEN
      IF WhichScreen = 4 THEN CALL Screen1(0) ELSE CALL Screen2(0)
      CALL DispPCXC(VideoPage%)
   ELSEIF WhichScreen = 2 THEN
      IF GPDat%(31) <> 3 THEN CALL Screen3(0)
      CALL DispPCXH(VideoPage%)
   ELSEIF WhichScreen = 9 AND GPDat%(31) = 8 THEN
      CALL Screen13(0)
      CALL DispPCXV256(VideoPage%)
   ELSEIF WhichScreen = 5 THEN
      IF GPDat%(31) = 8 THEN CALL Screen9(0)
      CALL DispPCXVE(VideoPage%)
   ELSE 'WhichScreen = 8
      'Un-REM this next line if you want the routine to set its own screen
      'mode.  Otherwise if the image is VGA, then the machine is likely to
      'be set in either VGA or EGA mode already.
      'IF GPDat%(31) = 5 THEN CALL Screen9(0) ELSE CALL Screen12(0)
      CALL DispPCXVE(VideoPage%)
   END IF
  
   Array$ = ""     'Empty the Array$.  We're done working with it.

END SUB

