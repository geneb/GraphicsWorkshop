;********** FindLast.Asm - scans a string array to find the last valid element

;Copyright (c) 1988 Ethan Winer


;Syntax - Last = FindLast%(BYVAL VARPTR(Array$(Last)), Size%)
;
;   Where Array$(Last) is the last element in the array, and Size% is the
;   number of elements that precede it.  The function returns the last
;   non-blank element number.  If the entire array is null or Size% was
;   set to zero, the function returns a value of zero.
;
;   The equivalent BASIC algorithm is:
;
;      FOR X = Last TO Last - Size + 1
;          IF Array$(X) <> "" THEN
;             FindLast% = X
;             EXIT FOR
;          END IF
;      NEXT


.Model Medium
.Code

Include Mixed.Inc

HProc FindLast, Array:Ptr, Siz:Ptr

    Mov  SI,Siz           ;get the address for Size%
    Mov  CX,[SI]          ;put the number of elements into CX
    Jcxz BadExit          ;we can't search 0 elements, get out with AX = 0

    Mov  SI,Array         ;get the address for Array$(Last)
    Xor  BX,BX            ;we'll check the string lengths against BX

More:
    Cmp  [SI],BX          ;is this element null?
    Jne  Exit             ;no, so we found the last one
    Sub  SI,4             ;yes, consider the next lower string element
    Loop More             ;and keep searching until CX is exhausted

BadExit:
    Xor  CX,CX            ;show that the number of elements was invalid or
                          ;  the entire array is null
Exit:
    Mov  AX,CX            ;a function needs the outgoing value to be in AX
    HRet                  ;return to BASIC with AX holding the last element

HEndp
End
