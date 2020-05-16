%ifndef __entry_asm__
%define __entry_asm__

[Bits 16]

global _entry
global BIOSDataArea:data
global GDTR:data
extern _pmode_entry

section .text

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


	; Preparing for switch CPU to the 32-bit Protected mode
	; Activating A20 line
	in AL, 0x92
	or AL, 00000010b
	out 0x92, AL

	call allocateGDT	; Allocating Global Descriptors Table

	mov EAX, CR0
	or AL, 00000001b
	mov CR0, EAX

	; The CPU in the Protected Mode!
	jmp (5 << 3):_pmode_entry
	
	; In case of exceptions
	hlt
	jmp $

allocateGDT:
push AX
	; GDT will be located at linear address - 0x800-0x107ff
	push ES
	mov AX, 0x80
	mov ES, AX

	xor EBP, EBP			; Null-segment
	xor EAX, EAX			; Base address
	xor EBX, EBX			; Limit
	xor CX, CX				; CL - Access rights; CH - Attributes
	call setDescriptor

	mov EBP, 1				; 1 - Global Descriptor Table
	mov EAX, 0x800			; Bounds: 0x800 - 0x107ff
	mov EBX, 0xffff			; Size: 64 KiB (65,536 Bytes)
	mov CL, 1_00_1_001_0b	; A=0, Type=Writable data, S=1, DPL=0, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	mov EBP, 2				; 2 - Interrupt Descriptor Table
	xor EAX, EAX			; Bounds: 0x00 - 0x7ff
	mov EBX, 0x7ff			; Size: 2 KiB (2,048 Bytes)
	mov CL, 1_00_1_001_0b	; A=0, Type=Writable data, S=1, DPL=0, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	mov EBP, 3				; 3 - Local Descriptor Table
	mov EAX, 0x10800		; Bounds: 0x00 - 0x7ff
	mov EBX, 0xffff			; Size: 64 KiB (65,536 Bytes)
	mov CL, 1_00_0_0010b	; Type=LDT, S=0, DPL=0, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	mov EBP, 4				; 4 - Video memory
	mov EAX, 0xb8000		; Bounds: 0xb8000 - 0xbffff
	mov EBX, 0x7fff			; Size: 32 KiB (32,768 Bytes)
	mov CL, 1_01_1_001_0b	; A=0, Type=Writable data, S=1, DPL=1, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	mov EBP, 5				; 5 - UEFI code
	mov EAX, 0x30800		; Bounds: 0x30800 - 0x407ff
	mov EBX, 0xffff			; Size: 64 KiB (65,536 Bytes)
	mov CL, 1_00_1_100_0b	; A=0, Type=Unreadable code, S=1, DPL=0, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	mov EBP, 6				; 6 - UEFI stack
	mov EAX, 0x20800		; Bounds: 0x20800 - 0x307ff
	mov EBX, 0xffff			; Size: 64 KiB (65,536 Bytes)
	mov CL, 1_00_1_001_0b	; A=0, Type=Writable data, S=1, DPL=0, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	mov EBP, 7				; 7 - UEFI data
	mov EAX, 0x30800		; Bounds: 0x30800 - 0x307ff
	mov EBX, 0xffff			; Size: 64 KiB (65,536 Bytes)
	mov CL, 1_00_1_001_0b	; A=0, Type=Writable data, S=1, DPL=0, P=1
	mov CH, 0_1_0_0_0000b	; AVL=0, L=0, OSz=1, G=0
	call setDescriptor

	pop ES
	lgdt [dword GDTR]
pop AX
ret

; Filling current descriptor in GDT or LDT
;  * ES  - Table segment
;  * EBP - Segment index
;  * EAX - Base address
;  * EBX - Limit
;  * CL  - Access rights
;  * CH  - Attributes
setDescriptor:
push EBP
push EAX
push EBX
push CX
	; Calculating address
	; Address = EBP * 8
	shl EBP, 3

	mov [ES:EBP + 0], BX	; Writing low word of limit
	mov [ES:EBP + 2], AX	; Writing low word of base address

	shr EAX, 16
	mov [ES:EBP + 4], AL	; Writing 3rd byte of base address
	mov [ES:EBP + 5], CL	; Writing access rights

	shr EBX, 16
	or CH, BL
	mov [ES:EBP + 6], CH	; Writing high 4 bits of limit and attributes
	mov [ES:EBP + 7], AH	; Writing 4th byte of base address
pop CX
pop EBX
pop EAX
pop EBP
ret


section .data

	; Pointer to Global Descriptors Table
	;  GDTR image
	GDTR:
		.GDT_Limit   dw 0xffff
		.GDT_Address dd 0x00000800


section .bss

	BIOSDataArea resb 256


%endif ; __entry_asm__
