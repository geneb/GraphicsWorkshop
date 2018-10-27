'********** SetVideo.Bas - Initializes the appropriate Screen mode based
'                          on the type of display adapter

'Copyright (c) 1990 Brian Giedt

DEFINT A-Z

'$INCLUDE: 'Common.GW'

'This subprogram sets the proper screen mode
'
SUB SetVideo STATIC

    IF GPDat%(31) = 1 THEN                     'EGA (or VGA) w/mono monitor
       SCREEN 10                               'set Screen 10
       GPDat%(31) = 5                          'treat as a color EGA later
    ELSEIF GPDat%(31) = 2 THEN                 'Hercules monitor
       'SCREEN 3, 0                             'REM out if not using QB 4.0
       GPDat%(43) = 720
       GPDat%(44) = 350
       GPDat%(50) = 2
       GPDat%(56) = 1
       GPDat%(71) = 14   'Character size is 9x14 pixels
    ELSEIF GPDat%(31) = 3 THEN                 'plain monochrome
       CLS
       PRINT "Graphics adapter required."
       END
    ELSEIF GPDat%(31) = 4 THEN                 'CGA or EGA w/CGA emulation
       'SCREEN 1, 0
       GPDat%(43) = 320
       GPDat%(44) = 200
       GPDat%(50) = 4
       GPDat%(56) = 3
       GPDat%(71) = 8    'Character size is 8x8 pixels
    ELSEIF GPDat%(31) = 5 THEN                 'EGA (or VGA) w/color monitor
       SCREEN 9
    ELSEIF GPDat%(31) = 6 THEN                 'CGA hi-res, no color
       SCREEN 2, 0
       GPDat%(43) = 640
       GPDat%(44) = 200
       GPDat%(50) = 2
       GPDat%(56) = 1
       GPDat%(71) = 8    'Character size is 8x8 pixels
    ELSEIF GPDat%(31) = 7 THEN
       SCREEN 11
       GPDat%(31) = 8
    ELSEIF GPDat%(31) = 8 THEN
       SCREEN 12
    ELSEIF GPDat%(31) = 9 THEN
       'SCREEN 13
       GPDat%(43) = 320
       GPDat%(44) = 200
       GPDat%(50) = 255
       GPDat%(71) = 8    'Character size is 8x8 pixels
    END IF
   
    IF GPDat%(31) = 5 THEN
       GPDat%(43) = 640
       GPDat%(44) = 350
       GPDat%(50) = 16
       GPDat%(71) = 14   'Character size is 8x14 pixels
       GPDat(72) = &HA800
    ELSEIF GPDat%(31) = 8 THEN
       GPDat%(43) = 640
       GPDat%(44) = 480
       GPDat%(50) = 16
       GPDat%(71) = 16   'Character size is 8x16 pixels
       GPDat(72) = &HAA00
    END IF

    GPDat%(49) = INT((4 * (GPDat%(44) / GPDat%(43)) / 3) * 1000)

    'Reset the mouse for our new screen mode
    IF GPDat%(73) THEN CALL InitMouse(GPDat%(73))

END SUB

