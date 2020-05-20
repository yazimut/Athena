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

	; Setup ISR #48 - Video service
	mov BX, 48
	mov AX, CS
	mov ECX, _ISR_48
	mov DL, 1_00_0_1110b	; Type=32-bit Int Gate, S=0, DPL=0, P=1
	call _setIntGateDescriptor

	sti

	; Set cursor position on the
	; row #1, column #0
	mov AH, 0x08
	mov DX, (1 << 8) + 0
	int 0x30

	; Print ASCII-Z string
	mov AH, 0x06
	mov EBX, Message
	int 0x30

	hlt
	jmp $


section .data
	
	Message db "Hello, Int 0x30! :)", 0x0a, 0x00


%endif ; __pmode_entry_asm__
