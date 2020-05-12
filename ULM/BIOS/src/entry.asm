%ifndef __entry_asm__
%define __entry_asm__

section .text
global _entry

[Bits 16]

_entry:
	; Init GP registers
	xor EAX, EAX
	xor EBX, EBX
	xor ECX, ECX
	xor EDX, EDX
	xor ESI, ESI
	xor EDI, EDI
	xor EBP, EBP

	; Init segment registers
	mov ES, AX			; Not initialized!
	mov FS, AX			; Not initialized!
	mov AX, 0x2080		; UEFI stack
	mov SS, AX
	mov AX, 0x3080		; UEFI data
	mov DS, AX
	mov AX, 0xb800		; Video memory
	mov GS, AX

	; Init stack
	mov ESP, 0xffff		; Stack size = 64 KiB (65536 Bytes)

	; Save BDA to .bss section
	push DS
	push ES
	cld
		xor AX, AX
		mov DS, AX
		mov ESI, 0x400				; Source - 0x0000:0x0400

		mov AX, 0x3080
		mov ES, AX
		mov EDI, BIOSDataArea 		; Destination - 0x3080:BIOSDataArea

		mov ECX, 256 / 4			; Size = 256 / 4 double words.
	rep movsd
	pop ES
	pop DS


; Right now we can use all memory in our purposes,
; excluding 0x80000-0xfffff - EBDA, Video memory and BIOS.

	mov ESI, string_HelloWorld
	xor EDI, EDI
	mov ECX, uint8_HelloWorld_size
	.print:
		mov AL, [ESI]
		mov [GS:EDI], AL
		inc ESI
		inc EDI
		inc EDI
	loop .print
	
	hlt
	jmp $


section .data

	string_HelloWorld db "Hello, World! :)"
	uint8_HelloWorld_size EQU $ - string_HelloWorld


section .bss
global BIOSDataArea

	BIOSDataArea resb 256

%endif ; __entry_asm__
