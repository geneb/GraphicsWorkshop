'**** Zoom.BAS

'Copyright 1990, Brian C. Giedt

DEFINT A-Z

'$INCLUDE: 'GWDECL.BAS'

'$INCLUDE: 'Common.GW'

SUB FullZoom (GWWindow AS Window1) STATIC

  PCOPY 0, 1
  XD! = GPDat%(43) / (GWWindow.X2 - GWWindow.X1 + 1)
  YD! = GPDat%(44) / (GWWindow.Y2 - GWWindow.Y1 + 1)
  
  FOR S = GWWindow.Y1 TO GWWindow.Y2
    FOR T = GWWindow.X1 TO GWWindow.X2
      SetDestPage 1
      V = GetCacheVE%(T, S)
      SetDestPage 0
      CALL LineBFVE((T - GWWindow.X1) * XD!, (S - GWWindow.Y1) * YD!, (T - GWWindow.X1 + 1) * XD!, (S - GWWindow.Y1 + 1) * YD!, V)
    NEXT
  NEXT

END SUB

SUB UnZoom (GWWindow AS Window1, DoTo) STATIC
 
  CALL SetGWPages(0, 1)
  XD! = GPDat%(43) / (GWWindow.X2 - GWWindow.X1 + 1)
  YD! = GPDat%(44) / (GWWindow.Y2 - GWWindow.Y1 + 1)
  AD = XD! * YD!

  B2 = 0
  FOR T = GWWindow.Y1 TO GWWindow.Y2
    A2 = 0
    FOR S = GWWindow.X1 TO GWWindow.X2
      DotCount = 0
      B1 = B2
      FOR N = 1 TO YD!
        A1 = A2
        FOR M = 1 TO XD!
          IF GetCacheVE%(A1, B1) <> 0 THEN DotCount = DotCount + 1
          A1 = A1 + 1
        NEXT
        B1 = B1 + 1
      NEXT
      A2 = A1
    
      'IF DotCount > MaxDot THEN MaxDot = DotCount
      IF DotCount < 3 THEN
        DotCount = 0
      ELSEIF DoTo AND DotCount < 10 THEN
        DotCount = 14
      ELSEIF DotCount < 4 THEN
        DotCount = 14
      ELSEIF DotCount < 6 THEN
        DotCount = 12
      ELSEIF DotCount < 9 THEN
        DotCount = 9
      ELSE
        DotCount = 15
      END IF
      PSET (S, T), DotCount
    NEXT
    B2 = B1
  NEXT

END SUB

