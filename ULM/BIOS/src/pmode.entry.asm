%ifndef __pmode_entry_asm__
%define __pmode_entry_asm__

[Bits 32]

global _pmode_entry

section .text

_pmode_entry:
	mov AX, 6 << 3		; RPL=0, TI=GDT, Index=6
	mov SS, AX			; UEFI stack

	mov AX, 7 << 3		; RPL=0, TI=GDT, Index=7
	mov DS, AX			; UEFI data

	mov AX, 4 << 3		; RPL=0, TI=GDT, Index=4
	mov GS, AX			; Video memory

	xor AX, AX			; RPL=0, TI=GDT, Index=0
	mov ES, AX			; Not initialized!
	mov FS, AX			; Not initialized!

	mov ESI, MSG
	xor EDI, EDI
	mov ECX, MSG_size
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
	
	MSG db "Hello, World, from PM32-bit :)"
	MSG_size EQU $ - MSG

%endif ; __pmode_entry_asm__
