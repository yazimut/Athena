%ifndef __MBS_asm__
%define __MBS_asm__

[Bits 16]

; BIOS will load our MBS to the linear address 0x7c00.
[org 0x7c00]

; Some BIOS versions are loading MBS to 0x07c0:0x0000.
; This instruction fix this difference.
jmp 0x0000:MBS_bootloader
MBS_bootloader:

; Disable interrupts.
cli					; Disable all maskable interrupts
in AL, 0x70
or AL, 10000000b	; Disable NMI
out 0x70, AL

; Zeroing GP registers.
xor EAX, EAX
xor EBX, EBX
xor ECX, ECX
xor EDX, EDX
xor ESI, ESI
xor EDI, EDI
xor EBP, EBP

; Segment registers initialization.
mov SS, AX		; Stack
mov FS, AX		; Not initialized
mov GS, AX		; Not initialized
mov AX, CS
mov DS, AX		; Data in the same segment
mov AX, 0xb800
mov ES, AX		; Video memory

; Stack initialization.
;  Linear address 0x0500-0x7bff
;  Size = 29.75 KiB (30,464 Bytes)
mov ESP, 0x7bff

; Set videomode
mov AX, 0x0003			; Text 80x25 colored.
int 0x10

; Clear screen
mov AX, 0x0f20			; Light-gray spaces on black background.
mov ECX, 80*25
clrscr:
	mov [ES:DI], AX
	inc DI				; Double "inc DI" has less op-code length 
	inc DI				; than "add DI, 2".
loop clrscr

; Reading first 64 sectors of UEFI.elf from the disk
mov AH, 0x42
mov SI, LBAAddressPacket
mov DL, 0x80
int 0x13
mov ESI, LBAReadError
mov ECX, LBAReadError_size
jc _printError

; Reading last 64 sectors of UEFI.elf from the disk
mov byte [LBAAddressPacket + 0x07], 0x78
mov byte [LBAAddressPacket + 0x08], 0x82
mov AH, 0x42
mov SI, LBAAddressPacket
int 0x13
mov ESI, LBAReadError
mov ECX, LBAReadError_size
jc _printError

; Parsing UEFI.elf
mov AX, 0x7000		; UEFI.elf address
mov DS, AX

; Check ELF signature
mov EAX, [0x00]				; Read 4 bytes - signature
cmp EAX, 0x464c457f			; db 7f, "ELF"
mov ESI, UEFIBrokenError
mov ECX, UEFIBrokenError_size
jne _printError

; Loading program to the memory
xor EAX, EAX
mov EBP, [0x1c]				; dd e_phoff 		- Offset of Programs Headers
add EBP, EAX				; Program "LOAD" Header offset
mov ESI, [DS:EBP + 0x04]	; Program "LOAD" offset
mov ECX, [DS:EBP + 0x0f]	; Program "LOAD" size
push 0x3080					; Segment ".text"
pop ES						;
xor EDI, EDI				; destination address
cld
rep movsb

mov EAX, [0x18]				; dd e_entry		- Entry point
; Jump to UEFI.elf
mov [CS:offs], AX
jump: db 0xea
offs: dw 0x0000
segm: dw 0x3080

; In case of exceptions.
hlt
jmp $

; Printing error, move cursor and halt the CPU
;  ESI - Message pointer
;  ECX - Message size
_printError:
push ECX
; Printing message
xor EDI, EDI
.print:
	mov AL, [ESI]
	mov [ES:EDI], AL
	inc ESI
	inc EDI					; Double "inc DI" has less op-code length 
	inc EDI					; than "add DI, 2".
loop .print

pop EAX							; Message size
xor DX, DX
mov BX, 0x80
div BX							; AX - row, DX - column
push DX
push AX
; Moving cursor
mov DX, 0x03d4
mov AL, 0x0e					; Moving Y-coordinate - row
out DX, AL
inc DL
pop AX							; Y = AL
out DX, AL

dec DL
mov AL, 0x0f					; Moving X-coordinate - column
out DX, AL
inc DL
pop AX							; X = AL
out DX, AL

; Halting...
hlt
jmp $

LBAReadError db "Error 0x01! Unable to read UEFI.elf from disk."
LBAReadError_size EQU $ - LBAReadError

LBAAddressPacket:
	db 0x10					; Packet length
	db 0x00					; Reserved
	db 0x40					; How much sectors need - 64 sectors
	db 0x00					; Reserved
	dd 0x70000000			; Buffer address - segment:offset = 0x7000:0x0000
	;  0x78000000												0x7800:0x0000
	dq 0x0000000000000042	; LBA adrress of data on the disk - 66 sector
	;  0x0000000000000082										130 sector

UEFIBrokenError db "Error 0x02! UEFI.elf is broken."
UEFIBrokenError_size EQU $ - UEFIBrokenError

; Filling free space:
;  512 - size of MBS sector.
;  2   - MBS signature.
;  64  - Partition table. 4 records, 16 bytes each.
;  2   - Unused.
;  4   - Disk UID.
;  28  - Easter egg.
times 512 - 2 - 64 - 2 - 4 - 28 - ($ - $$) hlt

; Easter egg.
EasterEgg db 0x00, "god help © Queen Anastasia", 0x00

; Disk UID (4 bytes) and unused (2 bytes).
Athena db 0x41, 0x74, 0x68, 0x65, 0x6e, 0x61

; Here should be partition table.
; EFI Disk
db 0x80 				; Active partition
db 0xfe, 0xff, 0xff 	; CHS start coordinates
db 0xee 				; Type - EFI disk
db 0xfe, 0xff, 0xff 	; CHS end coordinates
dd 0x00000001			; Start LBA sector of partition
dd 0xffffffff			; LBA partition size

times 16 db 0x00		; 2nd partition
times 16 db 0x00		; 3rd partition
times 16 db 0x00		; 4th partition

; MBS signature.
MBS_signature dw 0xaa55

%endif ;  __MBS_asm__
