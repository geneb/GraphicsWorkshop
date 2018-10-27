;SlidRght.ASM - Slides a region of the screen to the right

;Copyright(c) 1991, Brian C. Giedt

;Syntax:
;
;  CALL SlideRight(BYVAL Col1%, BYVAL Line1%, BYVAL Col2%, BYVAL Line2%, BYVAL DestCol%, BYVAL DestLine%)
;

.Model Medium,Basic

.Code

  EXTRN GMove1VE:Proc

SlideRight PROC Col1:word, Line1:word, Col2:word, Line2:word, DestCol:word, DestLine:word

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

    Mov  AX,Col1        ;Put the parameter Column1 = (Col1 + LoopVariable - 1)
    Add  AX,CX          ; onto the stack.
    Dec  AX
    Push AX
    Push Line1          ;Put the parameter Line1 on the stack.
    Sub  BX,CX          ;Put the parameter ColsToMove = (Cols-LoopVariable+1)
    Inc  BX             ; onto the stack.
    Push BX
    Push DX             ;Put the Lines variable on the stack.
    Push DestCol        ;Put the DestCol parameter on the stack.
    Push DestLine       ;Put the DestLine parameter on the stack.
    Call GMove1VE

    Pop  DX             ;Restore the Lines variable
    Pop  BX             ;Restore the Cols variable

    Pop  CX             ;Restore our LoopVariable
    Loop LocalLoop

Include BC7End.GW
    Ret
SlideRight Endp

End

