%ifndef __APIC_inc_asm__
%define __APIC_inc_asm__

%ifdef __APIC_asm__
    %define declare(symbol, type) global symbol:type
%else
    %define declare(symbol, type) extern symbol
%endif ; __APIC_asm__


; Functions
    ; Disable Advanced Programmable Interrupt Controller.
    ; After this, Intel 8259 Master-Slave PIC will wait for initialization.
    declare(_APIC_disable, function)


%endif ; __APIC_inc_asm__
