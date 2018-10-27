;********* InStat.Asm - reports if keypresses are pending, and how many

;Copyright (c) 1988 Ethan Winer


;calling syntax -
;
;   Count = InStat%
;
;where Count returns the number of characters pending
;
;to simply tell if there's a key -
;
;   IF InStat% THEN . . .  ' a key is waiting


.Model Medium, Basic
.Code

InStat Proc

Include BC7Start.GW

    Xor  AX,AX          ;address the keyboard buffer in low memory
    Mov  ES,AX          ;ES = 0
    Mov  AX,ES:[41Ch]   ;AX holds the buffer tail address
    Sub  AX,ES:[41Ah]   ;calculate the difference from the head address
    Jns  More           ;the head was indeed lower, skip ahead
    Add  AX,32          ;adjust because the head was before the tail

More:
    Shr  AX,1           ;divide because each character takes two bytes
Include BC7End.GW
    Ret                 ;return to BASIC

InStat Endp

End
