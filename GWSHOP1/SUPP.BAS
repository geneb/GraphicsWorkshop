'**** Supp.Bas - Support Routines

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

'This sub-program converts a string of 0's and 1's into a binary number
'
FUNCTION MakeBinary% (Bin$) STATIC

    A = 0
    FOR T = 2 TO 16
        IF MID$(Bin$, T, 1) = "1" THEN A = A + 1
        IF T < 16 THEN A = A * 2
    NEXT
    IF MID$(Bin$, 1, 1) = "1" THEN
        A = A - 32768
    END IF
    MakeBinary% = A

END FUNCTION

