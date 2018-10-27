;GetChar.ASM - Gets the charater value of a character printed to the screen
;              using the GPrint0VE routine or any of the other Row, Col
;              oriented print routines.

;Copyright(c) 1990, Brian C. Giedt

;Syntax:
;
;  CharValue% = GetCharacter(BYVAL Row%, BYVAL Col%)
;

.Model Medium, Basic

EXTRN ScreenArray:Byte ;The individual character values are stored in this
                       ;array

.Code

GetCharacter PROC Row:Word, Col:Word

include BC7Start.GW
         Mov  AX,Row    ;Calculate the offset into the Screen Array
         Dec  AX
         Mov  DX,80
         IMul DX
         Add  AX,Col
         Dec  AX

         Push DS
         Mov  DX,Seg ScreenArray
         Mov  DS,DX
         Mov  SI,Offset ScreenArray ;Make SI hold the address of the byte
         Add  SI,AX                 ; in the Screen Array we want to reference
         Mov  AL,[SI]               ;Get the character value and return it
         Xor  AH,AH                 ; in AX
         Pop  DS

include BC7End.GW
         Ret
GetCharacter Endp

End
