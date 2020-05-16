%ifndef __PIC_inc_asm__
%define __PIC_inc_asm__

%ifdef __PIC_asm__
	%define declare(symbol, type) global symbol:type
%else
	%define declare(symbol, type) extern symbol
%endif ; __PIC_asm__


; Constants
	PIC_Master_Cmd_Port		EQU 0x20
	PIC_Slave_Cmd_Port		EQU 0xa0

	PIC_Master_Status_Port	EQU 0x20
	PIC_Slave_Status_Port	EQU 0xa0

	PIC_Master_IMR_Port		EQU 0x21
	PIC_Slave_IMR_Port		EQU 0xa1

	PIC_Master_Data_Port	EQU 0x21
	PIC_Slave_Data_Port		EQU 0xa1

	PIC_OCW3_Read_IRR		EQU 0x0a
	PIC_OCW3_Read_ISR		EQU 0x0b


; Macros
	; Non-specific End Of Interrupt
	;  Input:
	;   * IRQ to be ended
	%macro __PIC_EOI 1
		mov AL, 0x20
		out PIC_Master_Cmd_Port, AL

		%if %1 >= 0x08
			out PIC_Slave_Cmd_Port, AL
		%endif
	%endmacro

	; Specific End Of Interrupt
	;  Input:
	;   * IRQ to be ended
	%macro __PIC_specific_EOI 1
		%if %1 < 0x08
			mov AL, 01100000b + %1
			out PIC_Master_Cmd_Port, AL
		%else
			mov AL, 01100000b + %1 - 0x08
			out PIC_Slave_Cmd_Port, AL
			mov AL, 01100000b + 0x02
			out PIC_Master_Cmd_Port, AL
		%endif
	%endmacro


; Functions
	; Initialize Intel 8259 Master-Slave PIC
	; Master and Slave IMRs will be cleared!
	;  Input:
	;   * DH - ISRs offset of IRQ #0-7
	;   * DL - ISRs offset of IRQ #8-15
	declare(_PIC_init, function)

	; Disable Intel 8259 Master-Slave PIC
	; All interrupts will be masked!
	;  Output:
	;   * DH - IMR of Master PIC
	;   * DL - IMR of Slave PIC
	declare(_PIC_disable, function)

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
	declare(_PIC_get_IRR, function)

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
	declare(_PIC_get_ISR, function)

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
	declare(_PIC_get_IMR, function)

	; Set Interrupt Mask Register in PIC
	;  Input:
	;   * AH:
	;      1 - Master
	;      2 - Slave
	;      3 - Both
	;   * DH - Master PIC ISR
	;   * DL - Slave PIC ISR
	declare(_PIC_set_IMR, function)

	; Mask IRQ
	;  Input:
	;   * CL - IRQ to be masked
	declare(_PIC_mask_IRQ, function)

	; Unmask IRQ
	;  Input:
	;   * CL - IRQ to be unmasked
	declare(_PIC_unmask_IRQ, function)

	; Non-specific End Of Interrupt
	;  Input:
	;   * AL - IRQ
	declare(_PIC_EOI, function)

	; Specific End Of Interrupt
	;  Input:
	;   * AL - IRQ
	declare(_PIC_specific_EOI, function)


%endif ; __PIC_inc_asm__
