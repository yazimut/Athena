%ifndef __pmode_entry_asm__
%define __pmode_entry_asm__

%include "interrupt.inc.asm"
%include "PIC.inc.asm"

[Bits 32]

global _pmode_entry
extern GDTR

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

	mov AL, '0'
	mov [GS:0 << 1], AL
	mov [GS:1 << 1], AL
	mov [GS:3 << 1], AL
	mov [GS:4 << 1], AL
	mov AL, ':'
	mov [GS:4], AL

	; Initialization of interrupts mechanism
	mov AX, 0x02 << 3	; RPL=0, TI=GDT, Index=2
	xor EBX, EBX
	mov CX, 0x7ff
	mov DX, 1_00_0_1110b	; Type=32-bit Int Gate, S=0, DPL=0, P=1
	shl EDX, 16
	mov DX, CS
	mov ESI, _ISR_Stub
	call _allocateIDT
	call _initIC

	; Setup ISR #32 - IRQ #0 "System timer #0"
	mov BX, 32
	mov AX, CS
	mov ECX, _ISR_32
	mov DL, 1_00_0_1110b	; Type=32-bit Int Gate, S=0, DPL=0, P=1
	call _setIntGateDescriptor
	xor CL, CL
	call _PIC_unmask_IRQ

	sti

	hlt
	jmp $


section .data
	
	;

%endif ; __pmode_entry_asm__
