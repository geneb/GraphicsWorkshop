;**** VGAStuff.ASM - Basic VGA handling routines

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;   CALL Screen11(KeepData%)  'Set the VGA 640x480 2-color mode
;
;   CALL Screen12(KeepData%)  'Set the VGA 640x480 16-color mode
;
;   CALL Screen13(KeepData%)  'Set the VGA 320x200 256-color mode
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

EXTRN ClearScreenArray:Proc

Screen11 PROC KeepData:Ptr       ;Set VGA 640x480 2 color mode

Include BC7Start.GW

        Mov     AX,11h           ;Function 0 - Screen Mode 11h
        MOV     GWScrnMode,AL    ;Store the Screen Mode in local memory
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep11         ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
        Jmp     Short Keep11
NoKeep11:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep11:
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen11 EndP

Screen12 PROC KeepData:Ptr       ;Set VGA 640x480 16 color mode

Include BC7Start.GW

        Mov     AX,12h           ;Function 0 - Screen Mode 12h
        MOV     GWScrnMode,AL    ;Store the Screen Mode in local memory
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep12         ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
        Jmp     Short Keep12
NoKeep12:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep12:
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen12 ENDP

Screen13 PROC KeepData:Ptr       ;Set VGA 320x200 256 color mode

Include BC7Start.GW

        Mov     AX,13h           ;Function 0 - Screen Mode 13h
        MOV     GWScrnMode,AL    ;Store the Screen Mode in local memory
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep13         ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
        Jmp     Short Keep13
NoKeep13:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep13:
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen13 ENDP

END
