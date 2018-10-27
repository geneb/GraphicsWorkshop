'**** DEMOFADE.BAS -

'Copyright 1990, Brian C. Giedt

'This demostrates the routines:
'   FadeEGA     - An assembler routine which randomly and on almost a pixel
'                 by pixel basis transfers a screen image forward from the
'                 background screen.
'   DisplayPCXFile - A complete basic subroutine which loads the specified
'                    PCX file.  Screen Mode must be previously set.
'   RandomFade  - A basic subroutine which uses the FadeEGA routine.
'   NightFall   - A basic subroutine which uses the FadeEGA routine.
'
'The FadeEGA routine works best as effect when it is changing between to
'screen images which are for the most part exactly the same.  In that case
'the user sees very little of the overhead in transforming the screen.

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

DECLARE SUB RandomFade ()
DECLARE SUB NightFall ()

'$INCLUDE: 'GetVideo.BAS'

GPDat%(31) = 5     'FadeEGA is an EGA only routine
CALL SetVideo

CALL DisplayPCXFile("SALES2", 1)
CALL DisplayPCXFile("SALES1", 0)

CALL NightFall

CALL DisplayPCXFile("SALES1", 1)

CALL RandomFade

