%ifndef __ISR_48_asm__
%define __ISR_48_asm__
%define __interrupt_asm__

%include "interrupt.inc.asm"

[Bits 32]

section .text

; ISR 48 - Video service
;   Input: AH - subfunction
;     0x02 - Set cursor position:
;       DH - row [0, 25]
;       DL - column [0, 79]
_ISR_48:
    pushfd
    push AX
        cmp AH, 0x02
            call _ISR_48_0x02
            jmp .Return
        jne .Return
    .Return:
    pop AX
    popfd
iretd

; Set cursor position
;   Input:
;    * AH = 0x02
;    * DH - row [0, 25]
;    * DL - column [0, 79]
_ISR_48_0x02:
    push BX
    push DX

    ; Remember position
    mov byte [Cursor.x], DL
    mov byte [Cursor.y], DH

    mov AX, 80
    mul DH
    xor DH, DH
    add DX, AX
    mov BX, DX        ; Cursor offset

    mov DX, 0x03d4
    mov AL, 0x0f    ; Move X
    out DX, AL
    inc DL
    mov AL, BL
    out DX, AL

    dec DL
    mov AL, 0x0e    ; Move Y
    out DX, AL
    inc DL
    mov AL, BH
    out DX, AL

    pop DX
    pop BX
ret


section .data
    
    ; Cursor config
    Cursor:
        ; Position
        .x db 0x00
        .y db 0x00


%endif ; __ISR_48_asm__
