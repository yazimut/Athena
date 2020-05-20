%ifndef __ISR_Stub_asm__
%define __ISR_Stub_asm__
%define __interrupt_asm__

%include "interrupt.inc.asm"
%include "PIC.inc.asm"

[Bits 32]

section .text

; ISR stub
_ISR_Stub:
    
iretd


section .data

    ;


%endif ; __ISR_Stub_asm__
