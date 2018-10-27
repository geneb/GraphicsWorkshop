;GetSMode.ASM - Get the current screen mode and place it in the GWScrnMode
;               variable.

;Copyright (c) 1991, Brian C. Giedt

;Syntax:
;
;   V% = GetScreenMode%
;

.Model Medium, Basic
.Data

Include External.GW

.Code

GetScreenMode Proc

Include BC7Start.GW

    Mov  AH,0Fh             ;get the video mode through BIOS
    Push BP
    Int  10h                ;returns mode in AL
    Pop  BP

    Xor  Ah,Ah
    Mov  GWScrnMode,AL      ;Set the GWScrnMode variable for future use.

Include BC7End.GW
    Ret                     ;return to BASIC
GetScreenMode Endp

End

