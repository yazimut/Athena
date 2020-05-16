%ifndef __interrupt_asm__
%define __interrupt_asm__

%include "interrupt.inc.asm"
%include "PIC.inc.asm"
%include "APIC.inc.asm"

[Bits 32]

section .text

; Allocate Interrupt Descriptor Table
;   Input:
;    * AX           - IDT segment selector
;    * EBX          - IDT base linear address
;    * CX           - IDT limit
;    * DX           - Stub ISR segment selector
;    * ESI          - Stub ISR offset
;    * EDX[16-23]   - Stub access rights
_allocateIDT:
    push EAX
    push EBX
    push ECX
    push EDX
    push ESI
    push EDI
    pushfd

    ; Save info
    mov [IDTR.Limit], CX
    mov [IDTR.Base], EBX
    mov [IDTR.Selector], AX

    ; Fill IDT by stubs for security
    push DS
    mov DS, AX
    ; Calculating number of movement operations
    push EDX
    mov EAX, ECX
    inc EAX
    xor EDX, EDX
    mov ECX, 8
    div ECX
    mov ECX, EAX    ; (Limit + 1) / 8 - number of movement operations
    pop EDX
    xor EDI, EDI
    .Fill:
        push ESI
        push EDX
        mov [EDI + 0x00], SI        ; Writing low word of offset
        shr ESI, 16
        mov [EDI + 0x06], SI        ; Writing high word of offset
        mov [EDI + 0x02], DX        ; Writing segment selector
        shr EDX, 16
        mov [EDI + 0x05], DL        ; Writing access rights
        mov [EDI + 0x04], byte 0x00 ; Writing empty byte
        add EDI, 0x08
        pop EDX
        pop ESI
    loop .Fill
    pop DS

    lidt [dword IDTR]

    popfd
    pop EDI
    pop ESI
    pop EDX
    pop ECX
    pop EBX
    pop EAX
ret

; Get interrupt gate descriptor from IDT
;   Input:
;    * BX   - ISR number
;   Output:
;    * AX   - ISR segment selector
;    * ECX  - ISR offset
;    * DL   - Access rights
_getIntGateDescriptor:
    push BX
    push DS
    pushfd

    ; Getting descriptor address
    mov AX, word [IDTR.Selector]
    mov DS, AX
    shl BX, 3

    mov CX, [BX + 0x06]    ; Getting high word of offset
    shl ECX, 16
    mov CX, [BX + 0x00]    ; Getting low word of offset
    mov AX, [BX + 0x02]    ; Getting ISR segment selector
    mov DL, [BX + 0x05]    ; Getting access rights

    popfd
    pop DS
    pop BX
ret

; Set interrupt gate descriptor in IDT
;   Input:
;    * BX   - ISR number
;    * AX   - ISR segment selector
;    * ECX  - ISR offset
;    * DL   - Access rights
_setIntGateDescriptor:
    push BX
    push DS
    pushfd

    ; Getting descriptor address
    push AX
    mov AX, word [IDTR.Selector]
    mov DS, AX
    pop AX
    shl BX, 3

    mov [BX + 0x00], CX         ; Writing low word of offset
    shr ECX, 16
    mov [BX + 0x06], CX         ; Writing high word of offset
    mov [BX + 0x02], AX         ; Writing ISR segment selector
    mov [BX + 0x05], DL         ; Writing access rights
    mov [BX + 0x04], byte 0x00  ; Writing empty byte

    popfd
    pop DS
    pop BX
ret

; Initialize interrupt controller
_initIC:
    call _APIC_disable

    push AX
    push DX
    mov DX, 0x2028
    call _PIC_init

    mov AH, 3
    mov DX, 0xffff
    call _PIC_set_IMR
    call _NMI_disable
    pop AX
    pop DX
ret

; Enable Non Maskable Interrupt
_NMI_enable:
    push AX
    in AL, 0x70
    and AL, 01111111b
    out 0x70, AL
    pop AX
ret

; Disable Non Maskable Interrupt
_NMI_disable:
    push AX
    in AL, 0x70
    or AL, 10000000b
    out 0x70, AL
    pop AX
ret


section .data align=1

    ; IDTR image
    ;  type - ptr32_t
    IDTR:
        ; IDT limit
        ;  type - uint16_t
        .Limit      dw 0x07ff

        ; IDT base linear address
        ;  type - ptr32_t
        .Base       dd 0x00000000

        ; IDT segment selector
        ;  type - uint16_t
        .Selector   dw (0x0002 << 3)    ; RPL=0, TI=GDT, Index=2


%endif ; __interrupt_asm__
