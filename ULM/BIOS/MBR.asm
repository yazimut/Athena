%ifndef __MBR_asm__
%define __MBR_asm__

org 0x7e00
; BIOS will load this code to the 0x0000:0x7c00,
; but to use jump instructions in the copy of MBR
; we need to setup code origin to 0x7e00.

MBR_BOOTLOADER:
	; Some versions of BIOS loader MBR to 0x07c0:0x0000;
	; This instruction will fix this.
	jmp 0x0000:(Start - 0x0200)
Start:
	cli
		; Zeroing GP registers.
		xor EAX, EAX
		xor EBX, EBX
		xor ECX, ECX
		xor EDX, EDX
		xor ESI, ESI
		xor EDI, EDI
		xor EBP, EBP

		; Setting up segment registers.
		mov AX, CS
		mov DS, AX
		mov ES, AX
		mov FS, AX
		mov GS, AX

		; Setting up stack to 0x4000 segment = 64 KiB.
		; Stack grows DOWN!
		mov ESP, 0xffff
		mov EAX, 0x4000
		mov SS, AX
		xor EAX, EAX

		; Copying MBR to next sector.
		; To the 0x07c0:0x0000 will be loaded VBR.
		cld
			mov ESI, 0x7c00
			mov EDI, 0x7e00
			mov ECX, 0x0100
		rep movsw

		; Transfer control to the copy of MBR.
		jmp 0x0000:MBS_COPY

		; In case of exceptions
		jmp $

MBS_COPY:
	sti

	; Set videomode
	mov EAX, 0x0003			; Text 80x25 colored.
	int 0x10

	; Clear screen
	push 0xb800
	pop ES
	xor EDI, EDI
	mov EAX, 0x0720			; Light-gray spaces on black background.
	mov ECX, 80*25
clrscr:
		mov [ES:EDI], AX
		add EDI, 0x02
	loop clrscr
	push CS
	pop ES

	; Reading first sector of VBR from the disk
	mov EAX, 0x4200
	push CS
	pop DS
	xor EBX, EBX
	mov ESI, LBAAddressPacket
	mov EDX, 0x80
	int 0x13
	jc _printError

	; Jump to the VBR.
	;  Changing code segment!
	jmp 0x07c0:0x0000

	; In case of exceptions.
	jmp $

_printError:
	mov ESI, ErrorMessage
	mov ECX, 73
.print:
		push ECX
			mov EAX, 0x0a00
			mov AL, [DS:ESI]
			xor EBX, EBX
			mov ECX, 1
			int 0x10
		pop ECX
		inc ESI
		call _moveCursor
	loop .print
	jmp $

_moveCursor:
pusha
	mov EAX, 0x0300
	xor EBX, EBX
	int 0x10
	inc DL
	cmp DL, 80
	jl .move
		inc DH
		xor DL, DL
		cmp DH, 25
		jl .move
			xor DH, DH
.move:
	mov EAX, 0x0200
	xor EBX, EBX
	int 0x10
popa
ret

; Zeroing free space:
;  512 - size of MBR sector.
;  2   - MBR signature.
;  64  - Partition table. 4 records, 16 bytes each.
;  2   - Unused.
;  4   - Disk UID.
;  28  - Easter egg.
;  24  - LBA address packet.
;  73  - Error message.
times 512 - 2 - 64 - 2 - 4 - 28 - 24 - 73 - ($ - $$) nop

MBS_DATA:
	ErrorMessage db "Error 0x01! Unable to read sectors from disk. Please, reboot system . . ."

	LBAAddressPacket:
		db 0x10 				; Packet length
		db 0x00 				; Reserved
		db 0x01 				; How much sectors need - 1 sector
		db 0x00 				; Reserved
		dd 0x00007c00			; Buffer address - segment:offset
		dq 0x0000000000000040 	; LBA adrress of data on the disk - 64 sector
		dq 0x0000000000000000	; 64 bit buffer address

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

	; MBR signature.
	dw 0xaa55

MBS_END:

%endif ;  __MBR_asm__
