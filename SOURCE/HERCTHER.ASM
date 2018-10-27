;********** HercTher.Asm

;Copyright (c) 1988 Chris May

;Syntax: IF NOT HercThere% THEN PRINT "Run QBHERC.COM"
;or      IF HercThere% THEN PRINT "QBHERC is installed"


.Model Medium, BASIC
.Code

HercThere Proc

Include BC7Start.GW

    Mov  DL,0FFh           ;set up for the QBHerc BIOS call
    Mov  AH,0EFh
    Int  10h               ;call Interrupt 10h
    Cmp  DL,0FFh           ;is QBHerc installed?
    Mov  AX,0              ;assume it is not
    Jz   Exit              ;we were right
    Dec  AX
Exit:
Include BC7End.GW
    Ret
HercThere Endp

End
