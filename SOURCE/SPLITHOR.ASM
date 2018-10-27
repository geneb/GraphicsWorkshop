;SplitHor.ASM - routine which brings in a split screen on the horizontal
;               axis

;Copyright (c) 1991, Brian C. Giedt

;Syntax:
;
;  CALL SplitHorizontal(BYVAL Col1%, BYVAL Line1%, BYVAL Col2%, BYVAL Line2%, BYVAL DestCol%, BYVAL DestLine%)
;

.Model Medium, Basic
.Code

  EXTRN GMove3VE:Proc

Lines1st DW ?
Lines2nd DW ?

SplitHorizontal PROC Col1:word, Line1:word, Col2:word, Line2:word, DestCol:word, DestLine:word

Include BC7Start.GW

    ;Move the background screen in from both sides, using an interlace of 1.
    ;Note that unlike the other calls where 350 lines are moved, here only
    ;175 lines will be moved, so specify only 175 lines to be moved.

    Mov  DX,Line2       ;Let DX hold a variable called Lines that contains
    Sub  DX,Line1       ; the number of lines to move.
    Inc  DX

    Mov  BX,Col2        ;Let BX hold a variable called Cols that contains
    Sub  BX,Col1        ; the number of columns to move.
    Inc  BX

    Mov  AX,DX
    Shr  AX,1
    Mov  Lines1st,AX

    Mov  AX,DX
    Sub  AX,Lines1st
    Mov  Lines2nd,AX  ;This handles if an un-even number of lines was passed

    Mov  CX,BX          ;Make CX the LoopVariable equal to the number of
                        ; columns to move.

LocalLoop:
    Push CX             ;Save our Loop variable

    Push BX             ;Save the Cols variable

    Push Col1           ;Put the parameter Col1 on the stack
    Push Line1          ;Put the parameter Line1 on the stack.
    Sub  BX,CX          ;Put the parameter ColsToMove = (Cols-LoopVariable+1)
    Inc  BX             ; onto the stack.
    Push BX
    Push Lines1st       ;Put the Lines1st variable on the stack.
    Mov  AX,DestCol     ;Put the parameter DestCol = (DestCol+LoopVariable-1)
    Add  AX,CX          ; onto the stack.
    Dec  AX
    Push AX
    Push DestLine       ;Put the DestLine parameter on the stack.
    Mov  AX,1           ;Put 1 SkipLine on the stack.
    Push AX
    Call GMove3VE

    Pop  BX    ;Refresh BX and CX and re-save them
    Pop  CX
    Push CX
    Push BX

    Mov  AX,Col1        ;Put the parameter Column1 = (Col1+LoopVariable-1)
    Add  AX,CX          ; onto the stack.
    Dec  AX
    Push AX
    Mov  AX,Line1       ;Put the parameter Line1 + 1 on the stack.
    Inc  AX
    Push AX
    Sub  BX,CX          ;Put the parameter ColsToMove = (Cols-LoopVariable+1)
    Inc  BX             ; onto the stack.
    Push BX
    Push Lines2nd       ;Put the Lines2nd variable on the stack.
    Push DestCol        ;Put the parameter DestCol on the stack.
    Mov  AX,DestLine    ;Put the DestLine parameter on the stack.
    Inc  AX
    Push AX
    Mov  AX,1           ;Put 1 SkipLine on the stack.
    Push AX
    Call GMove3VE

    Pop  BX             ;Restore the Cols variable

    Pop  CX             ;Restore our LoopVariable
    Loop LocalLoop

Include BC7End.GW
    Ret
SplitHorizontal Endp

End
