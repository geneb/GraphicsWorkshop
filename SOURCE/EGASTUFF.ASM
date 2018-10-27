;EGAStuff - Basic EGA handling routines

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;   CALL Screen0(KeepData%)   'Set Text Mode Screen
;
;   CALL Screen9(KeepData%)   'Set 640x350 16-color EGA mode
;
;   CALL Screen7(KeepData%)   'Set 640x350 2-color EGA mode
;
;   'MakeAddressVE% creates a video memory offset for the specified pixel
;   Address% = MakeAddressVE%(BYVAL X%, BYVAL Y%, BitPosition%)
;
;   CALL ClearVE              'Restores all VGA and EGA registers
;
;   CALL ClsVE                'Clears the VGA and EGA video screen
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

EXTRN ClearScreenArray : Proc
EXTRN GetScreenMode : Proc

Screen0 PROC KeepData:Ptr        ;Set to Text mode
Include BC7Start.GW

        XOR     AX,AX
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        Jz      NoKeep0          ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
NoKeep0:
        ADD     AL,02h           ;Function 0 - Screen Mode 2h
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

        XOR     AX,AX
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep0b         ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
NoKeep0b:
        ADD     AL,03h           ;Function 0 - Screen Mode 3h
        MOV     GWScrnMode,03h   ;Store the Screen Mode in local memory
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen0 ENDP


Screen9 PROC KeepData:Ptr        ;Set EGA 640x350 16 color screen mode

Include BC7Start.GW

        MOV     AX,10h           ;Function 0 - Screen Mode 10h
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep9          ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
        Jmp     Short Keep9
NoKeep9:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep9:
        MOV     GWScrnMode,10h   ;Store the Screen Mode in local memory
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen9 EndP


Screen7 PROC KeepData:Ptr        ;Set EGA 640x350 2 color mode

Include BC7Start.GW

        Mov     AX,0Fh           ;Function 0 - Screen Mode 0Fh
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep7          ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
        Jmp     Short Keep7
NoKeep7:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep7:
        MOV     GWScrnMode,0Fh   ;Store the Screen Mode in local memory
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen7 ENDP


MakeAddressVE PROC XPosition:Ptr, YPosition:Ptr, BitPosition:Ptr

Include BC7Start.GW

        Mov  BX,XPosition        ;Get the XPosition variable
        Mov  AX,YPosition        ;Get the YPosition variable

        Mov  CL,BL               ;Store the Lower X bits in CL for later

        Mov  DX,EGABytesPerLine  ;Multiply Y by the number of bytes per line
        Mul  DX

        Shr  BX,1                ;Get the X byte offset by dividing by 8
        Shr  BX,1
        Shr  BX,1
        Add  AX,BX               ;Add the X byte offset to the y offset
        Add  AX,FirstEGAOffset   ;Add the First EGA Offset

        And  CL,07h              ;Only keep the low 3 bits
        Mov  BL,128              ;Move one bit
        Shr  BL,CL               ; CL times to the right
        Xor  BH,BH               ;Clear the high byte
        Mov  SI,BitPosition      ;Store the bit position mask in Basic data
        Mov  [SI],BX             ; variable

Include BC7End.GW
        RET
MakeAddressVE ENDP


ClearVE PROC

Include BC7Start.GW

     Push AX                     ;Save the registers we use
     Push DX

     Mov  DX, 03C4h              ;Address of EGA port
     Mov  AX, 0F02h              ;Access register 2 (and set all bits on)
     Out  DX, AX

     Mov  DX, 03CEh              ;Address of EGA port
     Mov  AX, 0001h              ;Access register 1
     Out  DX, AX
     Mov  AX, 0002h              ;Access register 2
     Out  DX, AX
     Mov  AX, 0003h              ;Access register 3
     Out  DX, AX
     Mov  AX, 0FF08h             ;Access register 8
     Out  DX, AX
     Mov  AX, 0F07h              ;Access register 7
     Out  DX, AX
     Mov  AX, 0005h              ;Access register 5 (set write mode to 0)
     Out  DX, AX

     Pop  DX                     ;Restore the registers we used
     Pop  AX

Include BC7End.GW
     Ret
ClearVE ENDP


ClsVE Proc

Include BC7Start.GW

     Mov  AX,EGAVideoSeg   ;Get our video segment for our current page
     Mov  ES,AX
     Xor  DI,DI            ;Start with the beginning of the page
     Mov  CX,80*350        ;Assume an EGA mode and a size of 80 cols by 350

RetestScreenMode:
     Mov  AL,GWScrnMode    ;Check the actual screen mode.
     Cmp  AL,0             ;Has the screen mode been set
     Jne  WeHaveAMode
     CALL GetScreenMode    ;Ask our routine to tell us what video mode is
                           ; being used. GetScreenMode places it in GWScrnMode.
     Cmp  AL,0             ;Is it text mode, or an unknown mode?
     Je   AllDoneCls       ;If so then exit.
WeHaveAMode:
     Cmp  AL,10h           ;Was it an EGA?(color or mono)
     Jle  ReadyToClear     ;Yes, so keep the designated size.
     Mov  CX,80*480        ;Now, assume a VGA mode and a size of 80 cols by 480
     Cmp  AL,12h           ;Was it a VGA High-Resolution mode?(color or mono)
     Jle  ReadyToClear     ;Yes, so keep the modified size.
     Mov  CX,320*200       ;Now, it must be a VGA 256 color mode.

ReadyToClear:
     Xor  AL,AL            ;Send a value of 0 to all points on the screen
     Cld                   ;Make sure were moving in the right direction
Rep  Stosb                 ;Clear the screen physically

AllDoneCls:
Include BC7End.GW
     Ret
ClsVE Endp

END
