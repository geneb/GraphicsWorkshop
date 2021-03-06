;********** AltKey.Asm - returns whether or not the Alt key is depressed

;Copyright (c) 1988 Ethan Winer

;Syntax - IF AltKey% THEN . . .      'the Alt key is depressed


.Model Medium,Basic
.Code

AltKey Proc Uses ES

Include BC7Start.GW

    Xor  AX,AX                 ;look at the Alt key status in low memory
    Mov  ES,AX
    Test Byte Ptr ES:[417h],00001000b   ;test the Alt Key bit
    Jz   Exit                  ;it's not active, exit with AX still holding 0
    Dec  AX                    ;we were wrong, set AX to -1

Exit:
Include BC7End.GW
    Ret                        ;return to BASIC

AltKey Endp
       End
