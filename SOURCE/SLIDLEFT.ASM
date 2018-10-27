;SlidLeft.ASM - Slides a region of the screen to the left

;Copyright (c) 1991, Brian C. Giedt

;Syntax:
;
;  CALL SlideLeft(BYVAL Col1%, BYVAL Line1%, BYVAL Col2%, BYVAL Line2%, BYVAL DestCol%, BYVAL DestLine%)
;

.Model Medium, Basic
.Code

  EXTRN GMove1VE:Proc

SlideLeft PROC Col1:Word, Line1:Word, Col2:Word, Line2:Word, DestCol:Word, DestLine:Word

Include BC7Start.GW

    Mov  DX,Line2       ;Let DX hold a variable called Lines that contains
    Sub  DX,Line1       ; the number of lines to move.
    Inc  DX

    Mov  BX,Col2        ;Let BX hold a variable called Cols that contains
    Sub  BX,Col1        ; the number of columns to move.
    Inc  BX

    Mov  CX,BX          ;Make CX the LoopVariable equal to the number of
                        ; columns to move.

LocalLoop:
    Push CX             ;Save our Loop variable

    Push BX             ;Save the Cols variable
    Push DX             ;Save the Lines variable

    Push Col1           ;Put the parameter Col1 on the stack
    Push Line1          ;Put the parameter Line1 on the stack.
    Sub  BX,CX          ;Put the parameter ColsToMove = (Cols-LoopVariable+1)
    Inc  BX             ; onto the stack.
    Push BX
    Push DX             ;Put the Lines variable on the stack.
    Mov  AX,DestCol     ;Put the parameter DestCol = (DestCol+LoopVariable-1)
    Add  AX,CX          ; onto the stack.
    Dec  AX
    Push AX
    Push DestLine       ;Put the DestLine parameter on the stack.
    Call GMove1VE

    Pop  DX             ;Restore the Lines variable
    Pop  BX             ;Restore the Cols variable

    Pop  CX             ;Restore our LoopVariable
    Loop LocalLoop

Include BC7End.GW
    Ret
SlideLeft Endp

End

