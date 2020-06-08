%ifndef __ISR_33_asm__
%define __ISR_33_asm__
%define __interrupt_asm__

%include "interrupt.inc.asm"
%include "PIC.inc.asm"
%include "keyboard.inc.asm"

[Bits 32]

section .text

; ISR #33 - IRQ #1 "AT or PS/2 Keyboard"
_ISR_33:
    push EAX
    push EBX
    push ECX
    push EDX
        ; Get scan-code
        in AL, KBD_Cmd_Port         ; Read status register
        test AL, 00000001b
        jz .Return                  ; Wait until OBF=1
        in AL, KBD_Data_Port        ; Scan-code in AL
        push AX

        ; Print scan-code
        mov DL, AL
        mov AX, 0xff1f
        int 0x30

        ; Print a space
        mov AX, 0x0320
        int 0x30

        ; Handle *Lock keys
        pop AX
        cmp byte [Prev], SCS2_Break
        je .Return
            ; Handling
            cmp AL, SCS2_ScrollLock_make
            jne .CheckNumLock
                ; Toggle ScrollLock LED
                call _KBD_ScrollLock_toggle
                mov byte [Prev], AL
                jmp .Return
        .CheckNumLock:
            cmp AL, SCS2_NumLock_make
            jne .CheckCapsLock
                ; Toggle NumLock LED
                call _KBD_NumLock_toggle
                mov byte [Prev], AL
                jmp .Return
        .CheckCapsLock:
            cmp AL, SCS2_CapsLock_make
            jne .Return
                ; Toggle CapsLock LED
                call _KBD_CapsLock_toggle
                mov byte [Prev], AL
                jmp .Return

    .Return:
    mov byte [Prev], AL
    pop EDX
    pop ECX
    pop EBX
    pop EAX
        __PIC_specific_EOI 0x01
iretd


section .data

    ; Previous scan-code
    Prev db 0x00

    ; Scan-codes set #2
    ScanCodesSet2 db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x7e, 0x00, 0x00, \
                     0x00, 0x00, 0x00, 0x00,  'Q',  '1', 0x00, 0x00, \
                     0x00,  'Z',  'S',  'A',  'W',  '2', 0x00, 0x00, \
                      'C',  'X',  'D',  'E',  '4',  '3', 0x00, 0x00, \
                      ' ',  'V',  'F',  'T',  'R',  '5', 0x00, 0x00, \
                      'N',  'B',  'H',  'G',  'Y',  '6', 0x00,  'J', \
                     0x00,  'M', 0x00,  'U',  '7',  '8', 0x00, 0x00, \
                     0x2c,  'K',  'I',  'O',  '0',  '9', 0x00, 0x00, \
                      '.',  '/',  'L', 0x3b,  'P',  '-', 0x00, 0x00, \
                     0x00, 0x27, 0x00,  '[',  '=', 0x00, 0x00, 0x00, \
                     0x00, 0x00,  ']', 0x00, 0x5c, 0x00, 0x00, 0x00, \
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \
                      '1', 0x00,  '4',  '7', 0x00, 0x00, 0x00,  '0', \
                      '.',  '2',  '5',  '6',  '8', 0x00, 0x00,  '0', \
                      '+',  '3',  '-',  '*',  '9', 0x00, 0x00, 0x00, \
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


section .bss
    
    ;


%endif ; __ISR_33_asm__
