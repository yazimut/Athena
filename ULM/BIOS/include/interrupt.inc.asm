%ifndef __interrupt_inc_asm__
%define __interrupt_inc_asm__

%ifdef __interrupt_asm__
    %define declare(symbol, type) global symbol:type
%else
    %define declare(symbol, type) extern symbol
%endif ; __interrupt_asm__


; Functions
    ; ISR stub
    declare(_ISR_Stub, function)

    ; ISR #32 - IRQ #0 "System timer #0"
    declare(_ISR_32, function)

    ; Allocate Interrupt Descriptor Table
    ;   Input:
    ;    * AX           - IDT segment selector
    ;    * EBX          - IDT base linear address
    ;    * CX           - IDT limit
    ;    * DX           - Stub ISR segment selector
    ;    * ESI          - Stub ISR offset
    ;    * EDX[16-23]   - Access rights
    declare(_allocateIDT, function)

    ; Get interrupt gate descriptor from IDT
    ;   Input:
    ;    * BX   - ISR number
    ;   Output:
    ;    * AX   - ISR segment selector
    ;    * ECX  - ISR offset
    ;    * DL   - Access rights
    declare(_getIntGateDescriptor, function)

    ; Set interrupt gate descriptor in IDT
    ;   Input:
    ;    * BX   - ISR number
    ;    * AX   - ISR segment selector
    ;    * ECX  - ISR offset
    ;    * DL   - Access rights
    declare(_setIntGateDescriptor, function)

    ; Initialize interrupt controller
    declare(_initIC, function)

    ; Enable Non Maskable Interrupt
    declare(_NMI_enable, function)

    ; Disable Non Maskable Interrupt
    declare(_NMI_disable, function)


%endif ; __interrupt_inc_asm__
