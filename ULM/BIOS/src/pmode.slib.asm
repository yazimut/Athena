%ifndef __pmode_slib_asm__
%define __pmode_slib_asm__

%include "pmode.inc.asm"

[Bits 32]

section .text

; Filling current descriptor in GDT or LDT
;  * ES  - Table segment
;  * EBP - Segment index
;  * EAX - Base address
;  * EBX - Limit
;  * CL  - Access rights
;  * CH  - Attributes
_setDescriptor:
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

; Filling current gate descriptor in IDT.
;  * ES  - Table segment
;  * EBP - Gate index
;  * AX  - Code segment selector
;  * EBX - Code offset
;  * CL  - Flags
;  * CH  - Access rights
SetGateDescriptor:
push AX
push EBX
push CX
push EBP
pushfd
	; Calculating address
	; Address = EBP * 8.
	shl EBP, 3

	mov [ES:EBP + 0], BX		; Writing low word of offset
	mov [ES:EBP + 2], AX		; Writing code segment selector

	mov [ES:EBP + 4], CL		; Writing flags
	mov [ES:EBP + 5], CH		; Writing access rights

	shr EBX, 16
	mov [ES:EBP + 6], BX		; Writing high word of offset
popfd
pop EBP
pop CX
pop EBX
pop AX
ret

%endif ; __pmode_slib_asm__
