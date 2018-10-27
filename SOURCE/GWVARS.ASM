;***  GWVARS.ASM  -  Graphics Workshop Variables

;Copyright 1990, Brian C. Giedt

.Model Medium, Basic
.Data

   PUBLIC VideoSeg, VideoOffset, YSave, StringOffset, StringSegment, MoreString
   PUBLIC LastWasGet, GWScrnMode
   PUBLIC EGAVideoSeg, EGAVideoSeg2, EGABytesPerLine, FirstEGAOffset
   PUBLIC V256BytesPerLine
   PUBLIC CGAVideoSeg, CGAVideoSeg2, CGABytesPerLine, FirstCGAOffset
   PUBLIC HERCVideoSeg, HERCVideoSeg2, HERCBytesPerLine, FirstHERCOffset
   PUBLIC EGABaseVideoSeg, CGABaseVideoSeg, HERCBaseVideoSeg
   PUBLIC ScreenOffset, ScreenArrayEnd, ScrnBytesPerLine
   Public  LastLineX, LastLineY


   GWScrnMode       DB  0

   VideoSeg          DW  0
   VideoOffset       DW  0

   YSave             DW  0
   StringOffset      DW  0
   StringSegment     DW  0
   MoreString        DW  0

   LastWasGet        DB  0

   EGABaseVideoSeg   DW  0A000h
   EGAVideoSeg       DW  0A000h
   EGAVideoSeg2      DW  0A800h
   EGABytesPerLine   DW  80           ;Physical number of bytes per scan line
   V256BytesPerLine  DW  320
   FirstEGAOffset    DW  0

   CGABaseVideoSeg   DW  0B800h
   CGAVideoSeg       DW  0B800h
   CGAVideoSeg2      DW  0BC00h
   CGABytesPerLine   DW  80
   FirstCGAOffset    DW  0

   HERCBaseVideoSeg  DW  0B000h
   HERCVideoSeg      DW  0B000h
   HERCVideoSeg2     DW  0B800h
   HERCBytesPerLine  DW  90
   FirstHERCOffset   DW  0

   ScreenOffset      DW  0
   ScreenArrayEnd    DW  0

   ScrnBytesPerLine  DW  80

   LastLineX      DW   0
   LastLineY      DW   0


.Code

   Public ScreenArray

   ScreenArray       DB  2400 DUP(0)  ;Holds Character's ASCII value at each
                                      ; position on the screen
END
