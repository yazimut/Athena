%ifndef __APIC_asm__
%define __APIC_asm__

%include "APIC.inc.asm"

[Bits 32]

section .text

; Disable Advanced Programmable Interrupt Controller.
; After this, Intel 8259A Master-Slave PIC will wait for initialization.
_APIC_disable:
push AX
push ECX
    mov ECX, 0x1b
    rdmsr
    and AH, 11110111b
    wrmsr
pop ECX
pop AX
ret


%endif ; __APIC_asm__
