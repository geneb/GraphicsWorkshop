;CGAStuff - Basic CGA handling routines

;Copyright 1990, Brian C. Giedt

;Syntax:
;
;   CALL Screen1(KeepData)    'Set the CGA 320x200 4-color mode
;
;   CALL Screen2(KeepData)    'Set the CGA 640x200 2-color mode
;

.Model Medium, Basic
.Data

Include EXTERNAL.GW

.Code

EXTRN ClearScreenArray:Proc

Screen1 PROC KeepData:Ptr        ;Set CGA 320x200 4 color screen mode
Include BC7Start.GW

        MOV     AX,04h           ;Function 0 - Screen Mode 4h
        MOV     GWScrnMode,AL    ;Store the Screen Mode in local memory
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep1          ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
        Jmp     Short Keep1
NoKeep1:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep1:
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen1 ENDP

Screen2 PROC KeepData:Ptr        ;Set EGA 640x200 2 color screen mode

Include BC7Start.GW

        MOV     AX,06h           ;Function 0 - Screen Mode 6h
        MOV     GWScrnMode,AL    ;Store the Screen Mode in local memory
        MOV     SI,KeepData      ;Get the address of the Basic variable
        CMP     Byte Ptr [SI],0  ;Do we want to keep the data
        JZ      NoKeep2          ;No so go on to setting the screen mode
        ADD     AL,80h           ;Set bit 7 to tell BIOS to keep the data
NoKeep2:
        Push    AX
        CALL    ClearScreenArray ;Clear the character array
        Pop     AX
Keep2:
        PUSH    BP               ;Save BP - Some machines trash it
        INT     10h              ;Tell Video BIOS to set the screen mode
        POP     BP               ;Restore BP

Include BC7End.GW
        RET
Screen2 EndP

        END
