'CopyImag.BAS - routine to copy an image of a region to another region

DEFINT A-Z

'Copyright 1990, Brian C. Giedt

'$INCLUDE: 'GWDecl.BAS'

SUB CopyImage (Col1, Line1, Col2, Line2, DestCol, DestLine) STATIC

    Lines = Line2 - Line1 + 1
    Cols = Col2 - Col1 + 1

    CALL GMove1VE(Col1, Line1, Cols, Lines, DestCol, DestLine)

END SUB

