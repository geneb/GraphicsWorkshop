;SetPages.ASM - Routines to set the video pages

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;   CALL SetGWPages(BYVAL SourcePage%, BYVAL DestPage%)
;
;   CALL SetSourcePage(BYVAL SourcePage%)
;
;   CALL SetDestPage(BYVAL DestPage%)
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

SetSourcePage PROC SourcePage:Word

     MOV  AX,SourcePage
     MOV  DX,800h
     MUL  DX
     ADD  AX,EGABaseVideoSeg
     MOV  EGAVideoSeg2,AX

     Ret
SetSourcePage Endp

SetDestPage PROC DestPage:Word

     MOV  AX,DestPage
     MOV  DX,800h
     MUL  DX
     ADD  AX,EGABaseVideoSeg
     MOV  EGAVideoSeg,AX

     Ret
SetDestPage Endp

SetGWPages PROC SourcePage:Word, DestPage:Word

     Push SourcePage
     Call SetSourcePage

     Push DestPage
     Call SetDestPage

     Ret
SetGWPages ENDP

End
