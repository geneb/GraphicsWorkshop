;SlidDown.ASM - Slides a region of the screen towards the bottom of the screen

;Copyright(c) 1991, Brian C. Giedt

;Syntax:
;
;  CALL SlideDown(BYVAL Col1%, BYVAL Line1%, BYVAL Col2%, BYVAL Line2%, BYVAL DestCol%, BYVAL DestLine%)
;

.Model Medium, Basic
.Code

  EXTRN GMove1VE:Proc

Delta DW ?

SlideDown PROC Col1:word, Line1:word, Col2:word, Line2:word, DestCol:word, DestLine:word

Include BC7Start.GW

    Mov  DX,Line2       ;Let DX hold a variable called Lines that contains
    Sub  DX,Line1       ; the number of lines to move.
    Inc  DX

    Mov  BX,Col2        ;Let BX hold a variable called Cols that contains
    Sub  BX,Col1        ; the number of columns to move.
    Inc  BX

    Mov  Delta,10
    Cmp  DX,100
    Jge  AssignLoopVar
    Mov  Delta,5

AssignLoopVar:
    Mov  CX,DX          ;Make CX the LoopVariable equal to the number of
    Sub  CX,Delta       ; columns to move.

LocalLoop:
    Push CX             ;Save our Loop variable

    Push BX             ;Save the Cols variable
    Push DX             ;Save the Lines variable

    Push Col1           ;Put the parameter Col1 on the stack.
    Mov  AX,Line1       ;Put the parameter Line1 = (Line1 + LoopVariable)
    Add  AX,CX          ; onto the stack.
    Push AX
    Push BX             ;Put the Cols variable on the stack.
    Sub  DX,CX          ;Put the parameter LinesToMove = (Lines-LoopVariable)
    Push DX             ; onto the stack.
    Push DestCol        ;Put the DestCol parameter on the stack.
    Push DestLine       ;Put the DestLine parameter on the stack.
    CALL GMove1VE

    Pop  DX             ;Restore the Lines variable
    Pop  BX             ;Restore the Cols variable

    Pop  CX             ;Restore our LoopVariable
    Sub  CX,Delta
    Jg   LocalLoop

    ;Now that all the moving has been done, the image will be transfered one
    ;last time.  Since the Delta value above could possibly not divide evenly
    ;into the image size, this will put the image in the proper spot when we
    ;are finished moving it.
    Push Col1           ;Put the Col1 parameter on the stack
    Push Line1          ;Put the Line1 parameter on the stack
    Push BX             ;Put the Cols variable on the stack
    Push DX             ;Put the Lines variable on the stack
    Push DestCol        ;Put the Col1 parameter on the stack
    Push DestLine       ;Put the Col1 parameter on the stack
    CALL GMove1VE

Include BC7End.GW
    Ret
SlideDown Endp

End

