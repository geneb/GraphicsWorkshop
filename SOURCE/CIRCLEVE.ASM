;Circle.ASM - Routine to draw a circle to the EGA/VGA screen mode.

;Copyright(c) 1990, Brian C. Giedt

;Syntax:
;
;  CALL CircleVE (BYVAL XCenter%, BYVAL YCenter%, BYVAL Radius%, BYVAL CircleColor%, BYVAL XAspect%, BYVAL YAspect%)
;
;Requires:
;
;   DrawPointVE

.Model Medium,Basic
.Data

Include External.GW

X           DW ?
Y           DW ?
Sum         DW ?

SaveDX      DW ?
SaveCX      DW ?

.Code

EXTRN DrawPointVE:Proc

CircleVE PROC XCenter:Word, YCenter:Word, Radius:Word, CircleColor:Word, XAspect:Word, YAspect:Word

Include BC7Start.GW

    Mov  AX,XCenter    ;Store the X and Y position of the center of the circle
    Mov  LastLineX,AX
    Mov  AX,YCenter
    Mov  LastLineY,AX

    Mov  DX,03CEh
    Mov  AX,CircleColor
    Mov  AL,03h     ;Specify the VGA/EGA rotate and logical operation register
    Out  DX,AX      ;Use the logical operation if specified

    Xor  AX,AX
    Mov  X,AX       ;Start with our X = 0, and our Y = Radius * 2
    Mov  BX,Radius
    Cmp  BX,0
    Jz   ZeroCircle
    Shl  BX,1
    Mov  Y,BX
    Mov  Sum,AX     ;The Sum which tells us when to change will start at 0

    Xor  AX,AX
    Cmp  XAspect,AX ;Are we doing a true radius along the X-axis?
    Jz   NextTest
    Jmp  XIsNot     ;No, the X-axis is not true, therefore do an ellipse on Y
NextTest:
    Cmp  YAspect,AX ;Are we doing a true radius along the Y-axis?
    Jz   NextPhaseNorm ;Yes, do a true circle
    Jmp  YIsNot     ;No, the Y-axis is not true, therefore do an ellipse on X

NextPhaseNorm:
    Mov  DX,X       ;Use the registers AX and BX to hold X and Y respectively
    Mov  CX,Y
    Cmp  DX,CX      ;If X is greater than Y then we are done
    Jg   DoneCircleNorm ;Yes, were done.
    Call Plot8PointsNorm ;No, it is even, so it is time to plot 8 points at a time

BypassNorm:
    Call NextPoint

    Jmp  Short NextPhaseNorm   ;Go back up and do it again

DoneCircleNorm:
    CALL Plot8PointsNorm
    Jmp  AllDone

ZeroCircle:           ;Draw a zero sized circle
    Push XCenter
    Push YCenter
    Push CircleColor
    Call DrawPointVE
    Jmp  AllDone

Plot8PointsNorm:
    ;Adjust our X and Y values by dividing them by 2.  We initially multiplied
    ; our radius by 2 to produce a better looking circle.
    Shr  DX,1       ;Let DX = X \ 2
    Inc  CX         ;Let CX = (Y + 1) \ 2
    Shr  CX,1
    Mov  SaveDX,DX
    Mov  SaveCX,CX

    Push CX
    Add  DX,XCenter
    Add  CX,YCenter ;Start with (X, Y)
    Push DX
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Pop  DX
    Pop  CX
    Push CX
    Neg  CX         ;Negate the Y coordinate to get (X, -Y)
    Add  CX,YCenter
    Push CX
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Pop  CX
    Mov  DX,SaveDX
    Neg  DX         ;This time negate the X coordinate.  Now have (-X, -Y)
    Add  DX,XCenter
    Push DX
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Pop  DX
    Pop  CX         ;Get back the original Y coordinate.  Now have (-X, Y)
    Add  CX,YCenter
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Mov  CX,SaveDX
    Push CX
    Mov  DX,SaveCX
    Add  DX,XCenter
    Add  CX,YCenter ;Swap the X and the Y coordinates.  Now have (Y, X)
    Push DX
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Pop  DX
    Pop  CX
    Push CX
    Neg  CX         ;Negate the X coordinate.  Now have (Y, -X)
    Add  CX,YCenter
    Push CX
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Pop  CX
    Mov  DX,SaveCX
    Neg  DX         ;Negate the Y coordinate.  Now have (-Y, -X)
    Add  DX,XCenter
    Push DX
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    Pop  DX
    Pop  CX         ;Get back the original X coordinate.  Now have (-Y, X)
    Add  CX,YCenter
      Push DX
      Push CX
      Push Word Ptr CircleColor
      Call DrawPointVE   ;Draw the individual point using this routine
    RetN

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
XIsNot:
NextPhaseXNot:
    Mov  DX,X       ;Use the registers AX and BX to hold X and Y respectively
    Mov  CX,Y
    Cmp  DX,CX      ;If X is greater than Y then we are done
    Jg   DoneCircleXNot ;Yes, were done.
    Call Plot8PointsXNot ;No, it is even, so it is time to plot 8 points at a time

BypassXNot:
    Call NextPoint
    Jmp  Short NextPhaseXNot   ;Go back up and do it again

DoneCircleXNot:
    CALL Plot8PointsXNot
    Jmp  AllDone


Plot8PointsXNot:
    ;Adjust our X and Y values by dividing them by 2.  We initially multiplied
    ; our radius by 2 to produce a better looking circle.
    Shr  DX,1       ;Let DX = X \ 2
    Inc  CX         ;Let CX = (Y + 1) \ 2
    Shr  CX,1
    Mov  SaveDX,DX
    Mov  SaveCX,CX

    Push CX
    Add  CX,YCenter ;Start with (X, Y)
    Push DX
      Call PlotPointXNot
    Pop  DX
    Pop  CX
    Push CX
    Neg  CX         ;Negate the Y coordinate to get (X, -Y)
    Add  CX,YCenter
    Push CX
      Call PlotPointXNot
    Pop  CX
    Mov  DX,SaveDX
    Neg  DX         ;This time negate the X coordinate.  Now have (-X, -Y)
    Push DX
      Call PlotPointXNot
    Pop  DX
    Pop  CX         ;Get back the original Y coordinate.  Now have (-X, Y)
    Add  CX,YCenter
      Call PlotPointXNot
    Mov  CX,SaveDX
    Push CX
    Mov  DX,SaveCX
    Add  CX,YCenter ;Swap the X and the Y coordinates.  Now have (Y, X)
    Push DX
      Call PlotPointXNot
    Pop  DX
    Pop  CX
    Push CX
    Neg  CX         ;Negate the X coordinate.  Now have (Y, -X)
    Add  CX,YCenter
    Push CX
      Call PlotPointXNot
    Pop  CX
    Mov  DX,SaveCX
    Neg  DX         ;Negate the Y coordinate.  Now have (-Y, -X)
    Push DX
      Call PlotPointXNot
    Pop  DX
    Pop  CX         ;Get back the original X coordinate.  Now have (-Y, X)
    Add  CX,YCenter
      Call PlotPointXNot
    RetN

PlotPointXNot:
;    PSET (XCenter + (a * XAspect&) \ 65536, YCenter + b), Colr
    Mov  AX,DX
    Shl  AX,1
    IMul XAspect
    Add  DX,XCenter
    Push DX
    Push CX
    Push Word Ptr CircleColor
    Call DrawPointVE
    RetN


;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
YIsNot:
NextPhaseYNot:
    Mov  DX,X       ;Use the registers AX and BX to hold X and Y respectively
    Mov  CX,Y
    Cmp  DX,CX      ;If X is greater than Y then we are done
    Jg   DoneCircleYNot  ;Yes, were done.
    Call Plot8PointsYNot ;No, it is even, so it is time to plot 8 points at a time

BypassYNot:
    Call NextPoint
    Jmp  Short NextPhaseYNot   ;Go back up and do it again

DoneCircleYNot:
    CALL Plot8PointsYNot
    Jmp  AllDone


Plot8PointsYNot:
    ;Adjust our X and Y values by dividing them by 2.  We initially multiplied
    ; our radius by 2 to produce a better looking circle.
    Shr  DX,1       ;Let DX = X \ 2
    Inc  CX         ;Let CX = (Y + 1) \ 2
    Shr  CX,1
    Mov  SaveDX,DX
    Mov  SaveCX,CX

    Push CX
    Add  DX,XCenter ;Start with (X, Y)
    Push DX
      Call PlotPointYNot
    Pop  DX
    Pop  CX
    Push CX
    Neg  CX         ;Negate the Y coordinate to get (X, -Y)
    Push CX
      Call PlotPointYNot
    Pop  CX
    Mov  DX,SaveDX
    Neg  DX         ;This time negate the X coordinate.  Now have (-X, -Y)
    Add  DX,XCenter
    Push DX
      Call PlotPointYNot
    Pop  DX
    Pop  CX         ;Get back the original Y coordinate.  Now have (-X, Y)
      Call PlotPointYNot
    Mov  CX,SaveDX
    Push CX
    Mov  DX,SaveCX
    Add  DX,XCenter ;Swap the X and the Y coordinates.  Now have (Y, X)
    Push DX
      Call PlotPointYNot
    Pop  DX
    Pop  CX
    Push CX
    Neg  CX         ;Negate the X coordinate.  Now have (Y, -X)
    Push CX
      Call PlotPointYNot
    Pop  CX
    Mov  DX,SaveCX
    Neg  DX         ;Negate the Y coordinate.  Now have (-Y, -X)
    Add  DX,XCenter
    Push DX
      Call PlotPointYNot
    Pop  DX
    Pop  CX         ;Get back the original X coordinate.  Now have (-Y, X)
      Call PlotPointYNot
    RetN

PlotPointYNot:
;      PSET (XCenter + a, YCenter + (b * YAspect&) \ 65536), Colr
    Push DX
    Mov  AX,CX
    Shl  AX,1
    IMul YAspect
    Add  DX,YCenter
    Push DX
    Push Word Ptr CircleColor
    Call DrawPointVE
    RetN

NextPoint:
    Mov  BX,X       ;Calculate the new Sum to be  Sum = Sum + X * 2 + 1
    Shl  BX,1
    Inc  BX
    Inc  BX
    Shl  BX,1
    Mov  DX,Sum
    Add  DX,BX      ;DX now holds the new value for Sum
    Inc  X          ;We're going to move on to the next X position
    Inc  X

    Cmp  DX,0       ;If the new sum is non-positive then we won't be changing
    Jle  SkipThisNorm   ; the Y position this time around
    Mov  BX,Y       ;The sum was positive so calculate the new value for the
    Shl  BX,1       ; sum to be  Sum = Sum - Y * 2 - 1
    Inc  BX
    Sub  DX,BX      ;Once again DX holds our new value for Sum
    Dec  Y          ;And we're going to move to the next Y position
    Cmp  DX,0       ;If the new sum is non-positive then we won't be changing
    Jle  SkipThisNorm   ; the Y position this time around
    Mov  BX,Y       ;The sum was positive so calculate the new value for the
    Shl  BX,1       ; sum to be  Sum = Sum - Y * 2 - 1
    Inc  BX
    Sub  DX,BX      ;Once again DX holds our new value for Sum
    Dec  Y          ;And we're going to move to the next Y position
SkipThisNorm:
    Mov  Sum,DX     ;Now we can store the Sum in its local variable
    RetN


AllDone:
    Mov  DX,03CEh
    Mov  AX,0003h   ;Specify the VGA/EGA rotate and logical operation register
    Out  DX,AX      ;Tell the VGA/EGA to stop using a different logical operation

Include BC7End.GW
    Ret


CircleVE Endp

End
