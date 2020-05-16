%ifndef __PIC_asm__
%define __PIC_asm__

%include "PIC.inc.asm"

[Bits 32]

section .text

; Initialize Intel 8259 Master-Slave PIC
; Master and Slave IMRs will be cleared!
;  Input:
;   * DH - ISRs offset of IRQ #0-7
;   * DL - ISRs offset of IRQ #8-15
_PIC_init:
push AX
	; ICW #1
	mov AL, 00010001b				; Starting initialization - 4 ICWs.
	out PIC_Master_Cmd_Port, AL
	out PIC_Slave_Cmd_Port, AL
	nop
	nop

	; ICW #2
	mov AL, DH						; Master PIC will generate ISR=DH for IRQ #0
	out PIC_Master_Data_Port, AL
	mov AL, DL						; Slave PIC will generate ISR=DL for IRQ #8
	out PIC_Slave_Data_Port, AL
	nop
	nop

	; ICW #3
	mov AL, 00000100b 				; Slave PIC connected to IRQ #2 of Master PIC
	out PIC_Master_Data_Port, AL
	mov AL, 2						; Master PIC connected to IRQ #2 of Slave PIC
	out PIC_Slave_Data_Port, AL
	nop
	nop

	; ICW #4
	mov AL, 00000001b	 			; 80x86 mode
	out PIC_Master_Data_Port, AL
	out PIC_Slave_Data_Port, AL
pop AX
ret

; Disable Intel 8259 Master-Slave PIC
; All interrupts will be masked!
;  Output:
;   * DH - IMR of Master PIC
;   * DL - IMR of Slave PIC
_PIC_disable:
push AX
	in AL, PIC_Master_IMR_Port		; Save IMR of Master PIC
	mov DH, AL
	in AL, PIC_Slave_IMR_Port		; Save IMR of Slave PIC
	mov DL, AL
	mov AL, 11111111b				; Mask all interrupts
	out PIC_Master_IMR_Port, AL
	out PIC_Slave_IMR_Port, AL
pop AX
ret

; Get Interrupt Request Register from PIC
;  Input:
;   * AH:
;      1 - Master
;      2 - Slave
;      3 - Both
;  Output:
;   * DH - Master PIC ISR
;   * DL - Slave PIC ISR
;   * Carry flag, if wrong input parameter
_PIC_get_IRR:
clc
pushfd
	xor DX, DX
	push AX
	and AH, 00000001b
	dec AH
	jnz .CheckSlave
		; Get IRR from Master PIC
		mov AL, PIC_OCW3_Read_IRR
		out PIC_Master_Cmd_Port, AL
		nop
		nop
		in AL, PIC_Master_Status_Port
		mov DH, AL
.CheckSlave:
	pop AX
	and AH, 00000010b
	dec AH
	dec AH
	jnz .CheckIfError
		; Get IRR from Slave PIC
		mov AL, PIC_OCW3_Read_IRR
		out PIC_Slave_Cmd_Port, AL
		nop
		nop
		in AL, PIC_Slave_Status_Port
		mov DL, AL
		jmp .Return
.CheckIfError:
	cmp DH, 0
	jne .Return
		; Error! Wrong input parameter.
		popfd
		stc
		ret
.Return:
popfd
ret

; Get In-Service Register from PIC
;  Input:
;   * AH:
;      1 - Master
;      2 - Slave
;      3 - Both
;  Output:
;   * DH - Master PIC ISR
;   * DL - Slave PIC ISR
;   * Carry flag, if wrong input parameter
_PIC_get_ISR:
clc
pushfd
	xor DX, DX
	push AX
	and AH, 00000001b
	dec AH
	jnz .CheckSlave
		; Get ISR from Master PIC
		mov AL, PIC_OCW3_Read_ISR
		out PIC_Master_Cmd_Port, AL
		nop
		nop
		in AL, PIC_Master_Status_Port
		mov DH, AL
.CheckSlave:
	pop AX
	and AH, 00000010b
	dec AH
	dec AH
	jnz .CheckIfError
		; Get ISR from Slave PIC
		mov AL, PIC_OCW3_Read_ISR
		out PIC_Slave_Cmd_Port, AL
		nop
		nop
		in AL, PIC_Slave_Status_Port
		mov DL, AL
		jmp .Return
.CheckIfError:
	cmp DH, 0
	jne .Return
		; Error! Wrong input parameter.
		popfd
		stc
		ret
.Return:
popfd
ret

; Get Interrupt Mask Register from PIC
;  Input:
;   * AH:
;      1 - Master
;      2 - Slave
;      3 - Both
;  Output:
;   * DH - Master PIC ISR
;   * DL - Slave PIC ISR
;   * Carry flag, if wrong input parameter
_PIC_get_IMR:
clc
pushfd
	xor DX, DX
	push AX
	and AH, 00000001b
	dec AH
	jnz .CheckSlave
		; Get IMR from Master PIC
		in AL, PIC_Master_IMR_Port
		mov DH, AL
.CheckSlave:
	pop AX
	and AH, 00000010b
	dec AH
	dec AH
	jnz .CheckIfError
		; Get IMR from Slave PIC
		in AL, PIC_Slave_IMR_Port
		mov DL, AL
		jmp .Return
.CheckIfError:
	cmp DH, 0
	jne .Return
		; Error! Wrong input parameter.
		popfd
		stc
		ret
.Return:
popfd
ret

; Set Interrupt Mask Register in PIC
;  Input:
;   * AH:
;      1 - Master
;      2 - Slave
;      3 - Both
;   * DH - IMR value for Master PIC
;   * DL - IMR value for Slave PIC
_PIC_set_IMR:
pushfd
	push AX
	and AH, 00000001b
	dec AH
	jnz .CheckSlave
		; Set IMR in Master PIC
		mov AL, DH
		out PIC_Master_IMR_Port, AL
.CheckSlave:
	pop AX
	and AH, 00000010b
	dec AH
	dec AH
	jnz .Return
		; Set IMR in Slave PIC
		mov AL, DL
		out PIC_Slave_IMR_Port, AL
.Return:
popfd
ret

; Mask IRQ
;  Input:
;   * CL - IRQ to be masked
_PIC_mask_IRQ:
push AX
push CX
push DX
pushfd
	xor CH, CH
	mov DX, PIC_Master_IMR_Port
	cmp CL, 0x8
	jl .Mask
		mov DX, PIC_Slave_IMR_Port
		sub CL, 8
.Mask:
	in AL, DX
	bts AX, CX
	out DX, AL
popfd
pop DX
pop CX
pop AX
ret

; Unmask IRQ
;  Input:
;   * CL - IRQ to be masked
_PIC_unmask_IRQ:
push AX
push CX
push DX
pushfd
	xor CH, CH
	mov DX, PIC_Master_IMR_Port
	cmp CL, 0x8
	jl .Unmask
		mov DX, PIC_Slave_IMR_Port
		sub CL, 8
.Unmask:
	in AL, DX
	btr AX, CX
	out DX, AL
popfd
pop DX
pop CX
pop AX
ret

; Non-specific End Of Interrupt
;  Input:
;   * AL - IRQ
_PIC_EOI:
push AX
pushfd
	cmp AL, 0x08
	jl .Master
		mov AL, 0x20
		out PIC_Slave_Cmd_Port, AL
.Master:
	mov AL, 0x20
	out PIC_Master_Cmd_Port, AL
popfd
pop AX
ret

; Specific End Of Interrupt
;  Input:
;   * AL - IRQ
_PIC_specific_EOI:
push AX
pushfd
	cmp AL, 0x08
	jl .Master
		; Specific EOI for both PICs
		sub AL, 0x08
		add AL, 01100000b
		out PIC_Slave_Cmd_Port, AL

		mov AL, 0x02
		add AL, 01100000b
		out PIC_Master_Cmd_Port, AL
		jmp .Return
.Master:
	; Specific EOI only for Master PIC
	mov AL, AH
	add AL, 01100000b
	out PIC_Master_Cmd_Port, AL
.Return:
popfd
pop AX
ret
	

%endif ; __PIC_asm__
