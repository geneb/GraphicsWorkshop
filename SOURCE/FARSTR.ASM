;String Info  - returns length, segment and address of Far strings
;      saving all trashed registers
;Copyright (c) 1989 Crescent Software
;written by Jay Munro
;
;Usage -  Call StringInfo
;               Input
;               DS:SI = local address for string descriptor
;
;               Output
;               AX = offset of String Data
;               DX = Segment of String Data
;               CX = Length of String Data
;

.Model Medium,BASIC
.Data
        Public FarStrings
        FarStrings  DB ?      ;Local variable to tell whether far strings
                              ;are used or not.
                              ;mainly used for testing
        Public NullSpace
        NullSpace   DW  ?

.Code

Extrn  StringAddress:Proc     ;BC 7's routines to get Far Strings info
Extrn  StringLength:Proc      ;  supplied by Microsoft

StringInfo Proc

      Cmp  FarStrings,0       ;if not 0 then forget Far Strings
      Jnz  NotFar
      Push SI                 ;save these regs
      Push DI                 ;
      Push BX                 ;
      Push ES                 ;
      Pushf                   ; and flags too

      Push ES                 ;save ES again since we need it up ahead
      Push SI                 ;push incoming string descriptor address
      Call StringAddress      ;call to get address

      Pop  ES                 ;retrieve ES for next call to StringLength
      Push AX                 ;save offset returned from StringAddress
      Push DX                 ;  and segment returned from StringAddress

      Push SI                 ;push incoming string descriptor address
      Call StringLength       ;now go for the length
      Mov  CX,AX              ;LEN(string) is in AX, so put it into CX to return

      Pop  DX                 ;get back saved Segment
      Pop  AX                 ;and address

      Popf                    ;retrieve flags and saved registers
      Pop  ES
      Pop  BX
      Pop  DI
      Pop  SI
      Jmp Short Exit          ;and split

NotFar:                       ;for near strings do this for compatibility
      Mov  CX,[SI]            ;get length of near string
      Mov  DX,DS              ;and fake DS - into DX
      Mov  AX,[SI + 2]        ;get SADD into AX

Exit:
      Ret                     ;and return

StringInfo EndP


;MakeStrn.asm
;Makes a string descriptor for qbx

Comment / Expects :
 Incoming registers
    DX = Segment of Source Data
    AX = Offset of Source Data
    CX = Lenght of Source Data
    DS = Segment of Destination (string descriptor)
    DI = Offset of Destination
    BX = Length of Destination (0 for variable length string)

  Outgoing registers
    DS:[DI] is filled in with string descriptor
/


MakeString Proc Uses DS ES
     Cmp     FarStrings, 0
     Jnz     NearString

     Cmp     Word Ptr DS:[DI],0
     Jz      NotAssigned
     Push    AX
     Push    BX
     Push    CX
     Push    DX
     Push    ES
     Push    DI
     Push    DI
     Extrn   StringRelease:Proc
     Call    StringRelease
     Pop     DI
     Pop     ES
     Pop     DX
     Pop     CX
     Pop     BX
     Pop     AX

NotAssigned:
     Push    DX              ;Push Segment of source string
     Push    AX              ;Push Offset of source string
     Push    CX              ;Push length if fixed length
     Push    DS              ;Push segment of destination for descriptor
     Push    DI              ;push offset of destination for descriptor
     Push    BX              ;push length of destination

     Extrn   Stringassign:proc
     Call    Stringassign    ;go assign string
     Jmp Short Exit

NearString:
                             ;DS is assumed if this is a near string
    Mov     DS:[DI],CX       ;move length of string into descriptor
    Mov     DS:[DI+2],AX     ;move address of string into descriptor

Exit:
    Ret

MakeString  EndP
End
