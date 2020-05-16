%ifndef __ISR_32_asm__
%define __ISR_32_asm__
%define __interrupt_asm__

%include "interrupt.inc.asm"
%include "PIC.inc.asm"

[Bits 32]

section .text

; ISR #32 - IRQ #0 "System timer #0"
_ISR_32:
push EAX
    inc byte [counter]
    mov AL, byte [counter]
    cmp AL, 18
    jl .Return
        mov [counter], byte 0x00
        inc dword [time]
        
        ; Transform to mm:ss
        push BX
        push ECX
        push EDX
        mov EAX, dword [time]
        xor EDX, EDX
        mov ECX, 60
        div ECX     ; Minutes in EAX, Seconds in EDX
        
        xor BX, BX
        call printAX
        mov EAX, EDX
        mov BX, 6
        call printAX
        
        pop EDX
        pop ECX
        pop BX
.Return:
    __PIC_specific_EOI 0x00
pop EAX
iretd

; Print decimal AX.
; BX - position
printAX:
    push AX
    push CX
    
    ; Transform hex to dec
    mov CL, 10
    div CL          ; AH - AX%10, AL - AX/10
    add AH, 0x30
    add AL, 0x30
    mov [GS:BX], AL
    mov [GS:BX + 2], AH

    pop CX
    pop AX
ret


section .data
    
    ; uint8_t counter
    counter db 0x00

    ; uint32_t time
    time dd 0x00000000


%endif ; __ISR_32_asm__
