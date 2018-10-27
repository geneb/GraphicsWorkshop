;Palette4.ASM - Routines for accessing the palette registers using three values

;Copyright(c) 1990, Brian C. Giedt, Crescent Software

; Syntax:
;
;   DIM PalArray%(NumColors*3\2)
;   CALL CompletePalVGA(BYVAL NumColors%, PalArray%())
;
; or
;
;   CALL GetCompletePalVGA(BYVAL NumColors%, PalArray%())
;

.Model Medium, Basic
.Code

CompletePalVGA PROC NumColors:Word, PalArray:Ptr

     Mov  CX,NumColors
     Mov  SI,PalArray
     Mov  DX,SI
     Push DS
     Pop  ES

     Mov  CX,NumColors
     Xor  BX,BX
     Mov  AX,1012h
     Push BP
     Int  10h
     Pop  BP

     Ret
CompletePalVGA Endp

GetCompletePalVGA PROC NumColors:Word, PalArray:Ptr

Include BC7Start.GW

     Mov  CX,NumColors
     Mov  SI,PalArray
     Xor  BX,BX

GetNext:
     Push BX
     Push CX

     Mov  AX,1015h         ;Function 10h Sub-Function 15h gets the
                           ; three palette values
     Push BP
     Int  10h
     Pop  BP

     Mov  AL,[SI]
     Not  AL
     And  AL,DH            ;DH holds the Red Palette Value
     Mov  [SI],AL
     Inc  SI
     Mov  AL,[SI]
     Not  AL
     And  AL,CH            ;CH holds the Green Palette Value
     Mov  [SI],AL
     Inc  SI
     Mov  AL,[SI]
     Not  AL
     And  AL,CL            ;CL holds the Blue Palette Value
     Mov  [SI],AL
     Inc  SI

     Pop  CX
     Pop  BX
     Inc  BX
     Loop GetNext

Include BC7End.GW
     Ret
GetCompletePalVGA Endp

end
