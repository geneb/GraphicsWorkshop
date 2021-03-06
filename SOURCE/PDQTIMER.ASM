;********* PDQTIMER.ASM - PDQ replacement for BASIC's TIMER routine

;Copyright (c) 1989 Ethan Winer


;syntax - LongInt& = PDQTimer&


.Model Medium, Basic
.Code

PDQTimer Proc

Include BC7Start.GW

    Xor  AX,AX            ;look at low memory
    Mov  ES,AX            ;through ES
    Les  AX,ES:[046Ch]    ;get both words at once
    Mov  DX,ES            ;transfer the high word to DX

Include BC7End.GW
    Ret                   ;return to BASIC with the function output in DX:AX

PDQTimer Endp
End
