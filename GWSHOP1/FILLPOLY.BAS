'********** FillPoly.Bas

'Copyright (c) 1987,1990 Brian Giedt

DEFINT A-Z

DECLARE SUB LineVE (BYVAL x1, BYVAL y1, BYVAL x2, BYVAL y2, BYVAL LineClr)

'$INCLUDE: 'Common.GW'

SUB FillPoly (a, b, c, d, e, f, g, h, Colr) STATIC

'up until DoPoly: this code is that of the DOLINE procedure.  It has been
'doubled in size to accommodate two lines being drawn at the same time.
'Source code documentation is the same as in the DOLINE procedure.

GOTO DoPoly

'*************************************************************************

SETUP1:            
    Diag.y1.Inc = 0
    Diag.x1.Inc = 0
    Short.Distance1 = 0
    Straight.x1.Inc = 0
    Straight.y1.Inc = 0
    sc1 = 0
    dc1 = 0
    Cx1 = 1
    Dx1 = 1
    di1 = y2 - y1
    IF di1 >= 0 THEN GOTO keep.y1
    Dx1 = -1
    di1 = -1 * di1
keep.y1:
    Diag.y1.Inc = Dx1
    si1 = x2 - x1
    IF si1 >= 0 THEN GOTO keep.x1
    Cx1 = -1
    si1 = -1 * si1
keep.x1:
    Diag.x1.Inc = Cx1
    IF si1 > di1 THEN GOTO horz.seg1
    Cx1 = 0
    ss1 = di1
    di1 = si1
    si1 = ss1
    GOTO save.values1
horz.seg1:
    Dx1 = 0
save.values1:
    Short.Distance1 = di1
    Straight.x1.Inc = Cx1
    Straight.y1.Inc = Dx1
    ax1 = di1
    ax1 = ax1 * 2
    sc1 = ax1
    ax1 = ax1 - si1
    bx1 = ax1
    ax1 = ax1 - si1
    dc1 = ax1
    Cx1 = x1
    Dx1 = y1
    si1 = si1 + 1
    RETURN

'*************************************************************************


MainLoop1:
    PSET (Cx1, Dx1), Colr2
    IF Delta1 THEN RETURN                       'if change then return
    si1 = si1 - 1

skip.point1:
    IF si1 = 0 THEN RETURN
    IF bx1 >= 0 THEN GOTO diag.line1
    Cx1 = Cx1 + Straight.x1.Inc
    IF Straight.y1.Inc THEN Delta1 = -1         'change in x direction
    Dx1 = Dx1 + Straight.y1.Inc
    bx1 = bx1 + sc1
    GOTO MainLoop1

diag.line1:
    Cx1 = Cx1 + Diag.x1.Inc
    IF Diag.y1.Inc THEN Delta1 = -1             'change in x direction
    Dx1 = Dx1 + Diag.y1.Inc
    bx1 = bx1 + dc1
    GOTO MainLoop1

'*************************************************************************


SETUP2:
    Diag.y2.Inc = 0
    Diag.x2.Inc = 0
    Short.Distance2 = 0
    Straight.x2.Inc = 0
    Straight.y2.Inc = 0
    sc2 = 0
    dc2 = 0
    Cx2 = 1
    Dx2 = 1
    di2 = y2 - y1
    IF di2 >= 0 THEN GOTO keep.y2
    Dx2 = -1
    di2 = -1 * di2
keep.y2:
    Diag.y2.Inc = Dx2
    si2 = x2 - x1
    IF si2 >= 0 THEN GOTO keep.x2
    Cx2 = -1
    si2 = -1 * si2
keep.x2:
    Diag.x2.Inc = Cx2
    IF si2 > di2 THEN GOTO horz.seg2
    Cx2 = 0
    ss2 = di2
    di2 = si2
    si2 = ss2
    GOTO save.values2
horz.seg2:
    Dx2 = 0
save.values2:
    Short.Distance2 = di2
    Straight.x2.Inc = Cx2
    Straight.y2.Inc = Dx2
    ax2 = di2
    ax2 = ax2 * 2
    sc2 = ax2
    ax2 = ax2 - si2
    bx2 = ax2
    ax2 = ax2 - si2
    dc2 = ax2
    Cx2 = x1
    Dx2 = y1
    si2 = si2 + 1
    RETURN

'*************************************************************************


MainLoop2:
    PSET (Cx2, Dx2), Colr2
    IF Delta2 = -1 THEN RETURN                  'if change then return
    si2 = si2 - 1

skip.point2:
    IF si2 = 0 THEN RETURN
    IF bx2 >= 0 THEN GOTO diag.line2
    Cx2 = Cx2 + Straight.x2.Inc
    IF Straight.y2.Inc THEN Delta2 = -1         'change in x direction
    Dx2 = Dx2 + Straight.y2.Inc
    bx2 = bx2 + sc2
    GOTO MainLoop2

diag.line2:
    Cx2 = Cx2 + Diag.x2.Inc
    IF Diag.y2.Inc THEN Delta2 = -1             'change in x direction
    Dx2 = Dx2 + Diag.y2.Inc
    bx2 = bx2 + dc2
    GOTO MainLoop2

'*************************************************************************

DoPoly:
    Fini1 = 0                           'boolean variable tells when were done
    Fini2 = 0
    x1 = c                              'don't use passed variables
    y1 = d
    x2 = a
    y2 = b
    GOSUB SETUP1                        'setup first line from (x1,y1)-(x2,y2)
    x2 = g                              'line2 has same starting point
    y2 = h
    GOSUB SETUP2                        'setup second line from(x1,y1)-(x2,y2)
    PaintColor = Colr MOD 16
    Colr2 = 15
    IF GPDat%(26) THEN
	Colr2 = PaintColor
	IF GPDat%(31) = 2 OR GPDat%(31) = 6 THEN Colr2 = 15
    END IF
    IF GPDat%(31) = 2 OR GPDat%(31) = 6 THEN PaintColor = 0
      
DoLine1:
    Delta1 = 0                          'boolean tells if change in x direction
    GOSUB MainLoop1                     'figure some of line 1
    IF NOT Delta1 THEN                  'end of line occured
	IF Fini1 THEN GOTO DoLine2
	x1 = a                          'setup for the second line
	y1 = b                          'start at old end of line 1
	x2 = e                          'end at last position
	y2 = f
	Fini1 = -1
	GOSUB SETUP1                    'setup line 1 from (x1,y1)-(x2,y2)
	GOTO DoLine1                    'we need a change in x position
					'so do some more calculations
    END IF
DoLine2:
    Delta2 = 0                          'boolean tells if change in x direction
    GOSUB MainLoop2                     'figure some of line 2
    IF NOT Delta2 THEN                  'end of line occured
	IF Fini2 THEN EXIT SUB          'If we've been here, then leave
	x1 = g
	y1 = h
	x2 = e
	y2 = f
	Fini2 = -1                      'setup that we've been here
	GOSUB SETUP2                    'setup line from (x1,y1)-(x2,y2)
	GOTO DoLine2                    'do some more of calculations
    END IF

    'we have acheived a change in x-axis in both the upper and lower bound
    'so now we can draw a line between the two points
    CALL LineVE(Cx1, Dx1, Cx2, Dx2, PaintColor)
    GOTO DoLine1                        'draw some more lines

END SUB

