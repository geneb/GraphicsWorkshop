;*** GWFileSz.Asm - retrieves the size of a file

;Copyright (c) 1988 Ethan Winer
;Modified 1990 Brian C. Giedt

;Syntax - FileName$ = "\Path\Filename.Ext"
;         Size = GWFileSize&(FileName$)
;         IF Size = -1 THEN PRINT "File doesn't exist."

.Model Medium, Basic
.Data

    File_Name DB 65 Dup (?)    ;holds a file name to add CHR$(0) locally
    DTA       DB 44 Dup (?)    ;holds a DOS Disk Transfer Area

.Code

ifdef bc7
  EXTRN StringInfo:Proc
endif

GWFileSize PROC FName:Ptr

Include BC7Start.GW

    Push DS
    Pop  ES                  ;insure that ES holds Data Segment
    Lea  DX,DTA              ;put DTA address into DS:DX for set DTA service

    Mov  AH,1Ah              ;set DTA service - creates space for file info
    Int  21h                 ;call DOS

    Mov  SI,FName            ;SI holds address of FileName$ descriptor
    Push DS
    Pop  ES
ifdef bc7
    Call StringInfo          ;Get the string address
    Mov  DS,DX               ;Place the address into DS:SI
    Mov  SI,AX
else
    Mov  CX,[SI]             ;Place String Length in CX
    Mov  SI,[SI+2]           ;Place the address of the string in SI
endif
    Mov  AX,-1               ;set AX and DX to -1 in case FileName$ is null
    Mov  DX,AX
    Jcxz Exit                ;it IS null, get out

    Lea  DI,File_Name        ;point DI to local storage
    Cld                      ;move bytes in the forward direction
    Rep  Movsb               ;move CX bytes
    Mov  Byte Ptr ES:[DI],0  ;make an ASCIIZ string by adding CHR$(0) to end
    Lea  DX,File_Name        ;Find First needs search string address in DS:DX

    Push ES                  ;Return our Data segement to what it used to be
    Pop  DS

    Mov  CL,00100111b        ;have search include normal files, hidden files,
                             ;  system files, and archive files
    Mov  AH,4Eh              ;find first matching file service
    Int  21h                 ;call DOS
    Mov  AX,-1               ;set AX and DX to -1 in case DOS reports an error
    Mov  DX,AX
    Jc   Exit                ;if Carry is set it wasn't there

    Lea  DI,DTA              ;point DI to DTA for getting file size
    Mov  AX,[DI+26]          ;put low word of file size into AX
    Mov  DX,[DI+28]          ;put high word of file size into DX

Exit:
Include BC7End.GW
    Ret

GWFileSize Endp

End
