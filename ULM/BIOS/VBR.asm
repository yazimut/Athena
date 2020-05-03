%ifndef __VBR_asm__
%define __VBR_asm__

org 0x0000
; MBR will load this code to the 0x07c0:0x0000,
; so we need to setup code origin to 0x0000.

VBR_BOOTLOADER:
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
	sti

	; Set videomode
	mov EAX, 0x0003			; Text 80x25 colored.
	int 0x10

	; Clear screen
	push 0xb800
	pop ES
	xor EDI, EDI
	mov EAX, 0x0f20			; Light-gray spaces on black background.
	mov ECX, 80*25
clrscr:
		mov [ES:EDI], AX
		add EDI, 0x02
	loop clrscr
	push CS
	pop ES

	; Reading next sectors of VBR from the disk
	mov EAX, 0x4200
	push CS
	pop DS
	xor EBX, EBX
	mov ESI, LBAAddressPacket
	mov EDX, 0x80
	int 0x13
	jc _printError

	; Transfer control to the next sectors of VBR
	jmp VBS_END
	
	; In case of exceptions
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
;  512 - size of VBR sector.
;  2   - MBR signature.
;  24  - LBA address packet.
;  73  - Error message size.
times 512 - 2 - 24 - 73 - ($ - $$) nop

VBS_DATA:
	ErrorMessage:
		db "Error 0x02! Unable to read sectors from disk. Please, reboot system . . ."

	LBAAddressPacket:
		db 0x10 				; Packet length
		db 0x00 				; Reserved
		db 0x7f 				; How much sectors need - 127 sectors
		db 0x00 				; Reserved
		dd 0x00007e00			; Buffer address - segment:offset
		dq 0x0000000000000041 	; LBA adrress of data on the disk - 65 sector
		dq 0x0000000000000000	; 64 bit buffer address
	
	; VBR signature.
	dw 0xaa55

VBS_END:
; This part of loader have to enter the CPU into 
; the 32-bit Protected Mode, then into 64-bit Long Mode 
; and then transfer control to the C++ code.
	jmp $

%endif ; __VBR_asm__
