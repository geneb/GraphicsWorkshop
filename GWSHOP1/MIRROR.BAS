'Mirror.BAS - routine to create a mirror image of a region

DEFINT A-Z

'Copyright 1990, Brian C. Giedt

'$INCLUDE: 'GWDecl.BAS'

SUB MirrorImage (Col1, Line1, Col2, Line2, DestCol, DestLine) STATIC

    Lines = Line2 - Line1 + 1
    Cols = Col2 - Col1 + 1

    S = DestLine + Lines
    FOR T = 0 TO Lines - 1
        CALL GMove1VE(Col1, Line1 + T, Cols, 1, DestCol, S - T)
    NEXT

END SUB

