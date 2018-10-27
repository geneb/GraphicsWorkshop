'DRWTXTNP.BAS - non-proportional version of DRAWTEXT.BAS

DEFINT A-Z

'$INCLUDE: 'GWDecl.BAS'

DECLARE SUB DrawChar (X, Y, Letter, Colr, Size#, Expand)
DECLARE SUB DrawCharA (X, Y, SAngle#, CAngle#, Letter, Colr, Size#, Expand)
DECLARE SUB DrawTextNonProp (Xx, Yy, Text$, Angle, Colr, TextSize#)

'$INCLUDE: 'Common.GW'

SUB DrawTextNonProp (Xx, Yy, Text$, Angle, Colr, TextSize#) STATIC

'You could modify the value of the wLetterWidth variable and reduce it by
'some abitrary number of pixels, perhaps the value returned by:
'
'  FontWidth%(ASC("o") - 31, GPDat%(34))
'
'if you want the letters to be closer and don't use a lot of capital W's
'(the widest character, which is why it's used below as the default).


  SColor = GPDat%(14)          'get shadow color
  Size# = TextSize#            'use copies to preserve incoming vars
  X = Xx
  Y = Yy
  Expand = 0
  
  IF Size# < .001 THEN Size# = 1! 'Prepare some variables that will be repeatedly used
  SAngle# = SIN((Angle / 180) * (22 / 7))
  CAngle# = COS((Angle / 180) * (22 / 7))

  IF Colr > 127 THEN              'if shadow then calculate size of shadow
    Ofsx = 1 + Size# * .6
    Ofsy = 1 + Size# * .3
  END IF                          'otherwise we don't care about the values
                                  '  of Ofsx and Ofsy
  wLetterWidth = FontWidth%(ASC("W") - 31, GPDat%(34))
  IF Angle <> 0 OR GPDat%(24) <> 90 THEN
    IF GPDat%(24) <> 90 THEN
      SAngle# = 0
      CAngle# = -COS(((GPDat%(24)) / 180) * (22 / 7))
      FOR T = 1 TO LEN(Text$)      'Give a value 1-95 as an offset into the font set
        Letter = ASC(MID$(Text$, T, 1)) - 31
        IF Letter <= UBOUND(FontWidth%, 1) THEN 'If shadowing then draw the shadow first
          'Draw the character
          IF Colr > 127 THEN CALL DrawCharA(X + Ofsx, Y + Ofsy, SAngle#, CAngle#, Letter, SColor, Size#, Expand)
          'Calculate position for next character to be drawn
          CALL DrawCharA(X + (wLetterWidth - FontWidth%(Letter, GPDat%(34))) \ 2, Y, SAngle#, CAngle#, Letter, (Colr AND 127), Size#, Expand)
          X = X + (wLetterWidth + GPDat%(48) + GPDat%(59)) * Size#
        END IF
      NEXT
    ELSE
      FOR T = 1 TO LEN(Text$) 'Give a value 1-95 as an offset into the font set
        Letter = ASC(MID$(Text$, T, 1)) - 31
        IF Letter <= UBOUND(FontWidth%, 1) THEN 'If shadowing then draw the shadow first
          'Draw the character
          IF Colr > 127 THEN CALL DrawCharA(X + Ofsx, Y + Ofsy, SAngle#, CAngle#, Letter, SColor, Size#, Expand)
          x1 = X + (CAngle# * (wLetterWidth - FontWidth%(Letter, GPDat%(34)))) \ 2
          y1 = Y - (SAngle# * (wLetterWidth - FontWidth%(Letter, GPDat%(34)))) \ 2
          'Calculate position for next character to be drawn
          CALL DrawCharA(x1, y1, SAngle#, CAngle#, Letter, (Colr AND 127), Size#, Expand)
          X = X + CAngle# * (wLetterWidth + GPDat%(48) + GPDat%(59)) * Size#
          Y = Y - SAngle# * (wLetterWidth + GPDat%(48) + GPDat%(59)) * Size#
        END IF
      NEXT
    END IF
  ELSE
    FOR T = 1 TO LEN(Text$)   'SEE ABOVE FOR COMMENTS
      Letter = ASC(MID$(Text$, T, 1)) - 31
      IF Letter <= UBOUND(FontWidth%, 1) THEN
        IF Colr > 127 THEN CALL DrawChar(X + Ofsx, Y + Ofsy, Letter, SColor, Size#, Expand)
        CALL DrawChar(X + (wLetterWidth - FontWidth%(Letter, GPDat%(34))) \ 2, Y, Letter, (Colr AND 127), Size#, Expand)
        X = X + (wLetterWidth + GPDat%(48) + GPDat%(59)) * Size#
      END IF
    NEXT
  END IF
END SUB

