;**** QBinLoad.Asm - Binary Load routine for files not created with BLOAD

;Copyright (c) 1990 Brian C. Giedt

;Syntax
;
;  Success% = QBinaryLoad%(FileName$, SEG Array%(0))
;
;  FileName$ is the file to load
;  Array%(0) is an integer array to load the file into
;  Success% will be TRUE if load is completed
;


.Model Medium, Basic
.Data

File_Name   DB  65 Dup (?)    ;holds a file name to add CHR$(0) locally
DTA         DB  44 Dup (?)    ;holds a DOS Disk Transfer Area

.Code

ifdef bc7
  EXTRN StringInfo:Proc
endif

QBinaryLoad PROC File:Ptr, AAdr:DWord

Include BC7Start.GW

    Push DS               ;save DS

    Mov  SI,File          ;SI holds address of FileName$ descriptor
ifdef bc7
    Call StringInfo       ;Get the string address
    Mov  ES,DX            ;Place the address into ES:SI
    Mov  SI,AX
else
    Mov  CX,[SI]          ;Place String Length in CX
    Mov  SI,[SI+2]        ;Place the address of the string in SI
    Push DS               ;Make the ES register point to our
    Pop  ES               ; data segment
endif
    Xor  AX,AX            ;in case there's an error
    Jcxz Exit             ;LEN(FileName$) = 0, someone messed up

    Lea  DI,File_Name     ;point Destination Index to start of local storage
    Mov  DX,DI            ;ditto for DX for DOS service below
MovesbFake:
    Mov  AL,ES:[SI]
    Mov  [DI],AL
    Inc  DI
    Inc  SI
    Loop MovesbFake
    Mov  Byte Ptr [DI],0  ;make an ASCIIZ string by adding CHR$(0) to end

Openit:
    Mov  AH,3Dh           ;open file service
    Mov  AL,0             ;open for reading only
    Int  21h              ;call DOS
    Jnc  Okay             ;no error, skip ahead

    Xor  AX,AX            ;error (the file probably wasn't found)
    Jmp  Short Exit       ;exit with AX set to show the error

Okay:
    Mov  BX,AX            ;save handle in BX
    Mov  AX,4200h         ;move file pointer to start of file
    Xor  CX,CX            ;file offset = 0
    Mov  DX,0             ;  plus 0 bytes
    Int  21h              ;do it

Read_File:
    Lds  DX,AAdr          ;set DS:DX to Array%(0) address

    Mov  CX,07FFFh        ;request 32K bytes read
    Mov  AH,3Fh           ;read file service #
    Int  21h              ;do it

    Mov  CX,DS            ;Increase the segment address by the size of the read
    Add  CX,07FFh
    Mov  DS,CX
    Add  DX,000Fh         ;Increase the offset by the offset change

    Mov  CX,07FFFh        ;request another 32K bytes read
    Mov  AH,3Fh           ;read file service #
    Int  21h              ;do it

    Mov  CX,DS            ;Increase the segment address by the size of the read
    Add  CX,07FFh
    Mov  DS,CX
    Add  DX,000Fh         ;Increase the offset by the offset change

    Mov  CX,07FFFh        ;request another 32K bytes read
    Mov  AH,3Fh           ;read file service #
    Int  21h              ;do it

    Mov  CX,DS            ;Increase the segment address by the size of the read
    Add  CX,07FFh
    Mov  DS,CX
    Add  DX,000Fh         ;Increase the offset by the offset change

    Mov  CX,07FFFh        ;request another 32K bytes read
    Mov  AH,3Fh           ;read file service #
    Int  21h              ;do it

    Mov  AH,3Eh           ;close file service
    Int  21h              ;do it
    Mov  AX,-1            ;we probably didn't have an error, or any error was
                          ; probably a read past the end of the file

Exit:
    Pop  DS

Include BC7End.GW
    Ret
QBinaryLoad Endp

End
