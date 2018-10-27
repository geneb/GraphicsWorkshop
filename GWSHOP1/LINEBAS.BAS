'********** LineBAS.BAS

'Copyright (c) 1987,1990 Brian Giedt
'Copyright (c) 1987 Crescent Software

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

'$INCLUDE: 'COMMON.GW'

'This sub-program draws a line from (x1,y1) to (x2,y2)
'
'To change this routine to work with the Hercules, search for "****" and
'replace the call to DrawPointVE with a call to DrawPointH
'
SUB LineBAS (x1, y1, x2, y2, Colr) STATIC

    DrawnOnce = 0
    SkipOnce = 0
    Diag.y.Inc = 0                      'clear some variables
    Diag.x.Inc = 0
    Short.Distance = 0
    Straight.x.Inc = 0
    Straight.y.Inc = 0
    Straight.Count = 0
    Diag.Count = 0
    CX = 1                              'initial increments for x-axis
    DX = 1                              'initial increments for y-axis
    DI = y2 - y1                        'DI holds distance on y-axis
    IF DI >= 0 THEN GOTO keep.y         'go ahead if positive slope
    DX = -1                             'y-axis increment is -1
    DI = ABS(DI)                        'make DI positive

keep.y:
    Diag.y.Inc = DX                     'save Diagonal Y Increment
    SI = x2 - x1                        'SI holds distance on x-axis
    IF SI >= 0 THEN GOTO keep.x         'go ahead if positive slope
    CX = -1                             'x-axis increment is -1
    SI = ABS(SI)                        'make SI positive

keep.x:
    Diag.x.Inc = CX                     'save Diagonal X Increment

    'determine if straight segments of line are horizontal or vertical
    IF SI > DI THEN GOTO horz.seg       'is x-distance greater than y-distance
                                        'if not the we have vertical segments
    CX = 0                              'no x-axis change during segments
    SS = DI                             'swap SI and DI
    DI = SI
    SI = SS
    GOTO save.values                    'save these values

horz.seg:
    DX = 0                              'no y-axis change during segments

save.values:
    Short.Distance = DI                 'DI contains short distance
    Straight.x.Inc = CX                 'save Straight X Increment
    Straight.y.Inc = DX                 'save Straight Y Increment
    AX = DI                             'put short distance into AX
    AX = AX * 2                         'double short distance
    Straight.Count = AX                 'save for straight loop
    AX = AX - SI                        'AX = 2 * DI - SI
    BX = AX                             'save for loop counter
    AX = AX - SI                        'AX = 2 * DI - 2 * SI
    Diag.Count = AX                     'save if for loop
    CX = x1                             'starting x coordinate
    DX = y1                             'starting y coordinate
    SI = SI + 1                         'increase long axis by 1 for endpoint

mainloop:
    SI = SI - 1                         'decrement counter for long distance
    '****
    CALL DrawPointH(CX, DX, Colr)      'draw if nothing already exists
    IF SI = 0 THEN EXIT SUB             'are we done with long axis yet
    '****

skip.point:
    IF SI = 0 THEN EXIT SUB             'are we done with long axis yet
    IF BX >= 0 THEN GOTO diag.line      'draw straight segment when BX < 0
    CX = CX + Straight.x.Inc            'add increments for straight segment
    DX = DX + Straight.y.Inc
    BX = BX + Straight.Count            'add to adjustment factor
    GOTO mainloop

diag.line:
    CX = CX + Diag.x.Inc                'add increments for diagonal segments
    DX = DX + Diag.y.Inc
    BX = BX + Diag.Count                'subtract from adjustment factor
    GOTO mainloop

END SUB

