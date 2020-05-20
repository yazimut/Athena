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
    mov byte AL, [counter]
    cmp AL, 18
    jl .Return
        mov byte [counter], 0x00
        inc dword [time]
        
        ; Transform to hh:mm:ss
        push EDX
        push ECX
            mov EAX, dword [time]
            xor EDX, EDX
            mov ECX, 3600
            div ECX         ; Hours in EAX, remaining seconds in EDX

            mov byte [Hours], AL

            mov EAX, EDX    ; Remaining seconds in EAX
            xor EDX, EDX
            mov ECX, 60
            div ECX         ; Minutes in EAX, seconds in EDX

            mov byte [Minutes], AL
            mov byte [Seconds], DL
        pop ECX
        
        ; Save cursor position
        mov AH, 0x07
        int 0x30
        mov word [CursorPosition], DX

        ; Set cursor position.
        mov AH, 0x08
        mov DX, (0 << 8) + 36
        int 0x30

        ; Print Hours
        mov byte DL, [Hours]
        cmp DL, 10
        jge .PrintHours
            mov AX, 0x0330
            int 0x30
    .PrintHours:
        mov AX, 0xff1a
        int 0x30

        ; Print ':'
        mov AX, 0x033a
        int 0x30

        ; Print minutes
        mov byte DL, [Minutes]
        cmp DL, 10
        jge .PrintMinutes
            mov AX, 0x0330
            int 0x30
    .PrintMinutes:
        mov AX, 0xff1a
        int 0x30

        ; Print ':'
        mov AX, 0x033a
        int 0x30

        ; Print seconds
        mov byte DL, [Seconds]
        cmp DL, 10
        jge .PrintSeconds
            mov AX, 0x0330
            int 0x30
    .PrintSeconds:
        mov AX, 0xff1a
        int 0x30

        ; Restore cursor position
        mov AH, 0x08
        mov word DX, [CursorPosition]
        int 0x30
        
        pop EDX
.Return:
    __PIC_specific_EOI 0x00
pop EAX
iretd


section .data
    
    ; uint8_t counter
    counter db 0x00

    ; uint32_t time
    time dd 0x00000000

    CursorPosition dw 0x0000


section .bss

    Hours   resb 1
    Minutes resb 1
    Seconds resb 1


%endif ; __ISR_32_asm__
