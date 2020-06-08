%ifndef __ISR_48_asm__
%define __ISR_48_asm__
%define __interrupt_asm__

%include "interrupt.inc.asm"

[Bits 32]

section .text

; ISR 48 - Video service
;   Input: AH - subfunction
;     0x02 - Clear screen
;     0x03 - Write symbol at cursor position
;     0x04 - Read symbol/attribue at cursor position
;     0x05 - Write symbol/attribute at cursor position
;     0x06 - Write ASCII-Z string at cursor position
;     0x07 - Get cursor position
;     0x08 - Set cursor position
;     0x09 - Move cursor forward
;     0x0a - Move cursor backward
;     0x0b - Scroll down
;     0x0c - Scroll up
;     0xff - Print EDX
_ISR_48:
    push EAX
    .Check_0x02:
        cmp AH, 0x02
        jne .Check_0x03
            call _ISR_48_0x02
            jmp .Return
    .Check_0x03:
        cmp AH, 0x03
        jne .Check_0x04
            call _ISR_48_0x03
            jmp .Return
    .Check_0x04:
        cmp AH, 0x04
        jne .Check_0x05
            call _ISR_48_0x04
            jmp .Return
    .Check_0x05:
        cmp AH, 0x05
        jne .Check_0x06
            call _ISR_48_0x05
            jmp .Return
    .Check_0x06:
        cmp AH, 0x06
        jne .Check_0x07
            call _ISR_48_0x06
            jmp .Return
    .Check_0x07:
        cmp AH, 0x07
        jne .Check_0x08
            call _ISR_48_0x07
            jmp .Return
    .Check_0x08:
        cmp AH, 0x08
        jne .Check_0x09
            call _ISR_48_0x08
            jmp .Return
    .Check_0x09:
        cmp AH, 0x09
        jne .Check_0x0a
            call _ISR_48_0x09
            jmp .Return
    .Check_0x0a:
        cmp AH, 0x0a
        jne .Check_0x0b
            call _ISR_48_0x0a
            jmp .Return
    .Check_0x0b:
        cmp AH, 0x0b
        jne .Check_0x0c
            call _ISR_48_0x0b
            jmp .Return
    .Check_0x0c:
        cmp AH, 0x0c
        jne .Check_0xff
            call _ISR_48_0x0c
            jmp .Return
    .Check_0xff:
        cmp AH, 0xff
        jne .Return
            call _ISR_48_0xff
            jmp .Return
    .Return:
    pop EAX
iretd

; Clear screen
;   Input:
;    * AL - attribute
_ISR_48_0x02:
    push ECX
    push EDI
        ; Remember background color
        mov byte [Background], AL

        shl AX, 8           ; AH = attribute
        mov AL, 0x20        ; Spaces as symbol
        mov EDI, 80 * 160   ; From the row #1
        mov ECX, 80 * 203   ; To the row #203
        .clrscr:
            mov word [GS:EDI], AX
            inc EDI
            inc EDI
        loop .clrscr

        mov EDI, buffer
        mov ECX, 80
        .clrbuf:
            mov word [EDI], AX
            inc EDI
            inc EDI
        loop .clrbuf
    pop EDI
    pop ECX
ret

; Write symbol at cursor position
;   Input:
;    * AL - symbol
_ISR_48_0x03:
    push BX
    push DX
    push SI
        mov BL, AL
        mov word DX, [Cursor.Position]
        xor AX, AX
        mov AL, DH
        mov DH, 80
        mul DH
        xor DH, DH
        add AX, DX      ; Cursor offset
        shl AX, 1       ; Symbol position in video memory
        mov SI, AX
        mov [GS:SI], BL
        call _ISR_48_0x09
    pop SI
    pop DX
    pop BX
ret

; Read symbol/attribute at cursor position
;   Output:
;    * DL - symbol
;    * DH - attribute
_ISR_48_0x04:
    push BX
        mov word DX, [Cursor.Position]
        xor AX, AX
        mov AL, DH
        mov DH, 80
        mul DH
        xor DH, DH
        add AX, DX  ; Cursor offset
        shl AX, 1   ; Symbol position in video memory
        mov BX, AX
        mov word DX, [GS:BX]
    pop BX
ret

; Write symbol/attribute at cursor position
;   Input:
;    * DL - symbol
;    * DH - attribute
_ISR_48_0x05:
    push BX
    push DX
        mov word DX, [Cursor.Position]
        xor AX, AX
        mov AL, DH
        mov DH, 80
        mul DH
        xor DH, DH
        add AX, DX  ; Cursor offset
        shl AX, 1   ; Symbol position in video memory
        mov BX, AX
    pop DX
        mov word [GS:BX], DX
        call _ISR_48_0x09
    pop BX
ret

; Write ASCII-Z string at cursor position
;   Input:
;    * DS:EBX - string buffer
_ISR_48_0x06:
    push EBX
        .start:
        mov byte AL, [EBX]
        .Check_0x00:
            cmp AL, 0
            jne .Check_0x08
                jmp .Return
        .Check_0x08:
            cmp AL, 0x08
            jne .Check_0x09
                ; Backspace
                push BX
                push DX
                    call _ISR_48_0x0a
                    mov byte DH, [Background]
                    mov DL, 0x20
                    call _ISR_48_0x05
                    call _ISR_48_0x0a
                pop DX
                pop BX
                inc EBX
                jmp .start
        .Check_0x09:
            cmp AL, 0x09
            jne .Check_0x0a
                ; Tab
                    mov AL, 0x20
                    call _ISR_48_0x03
                    mov AL, 0x20
                    call _ISR_48_0x03
                    mov AL, 0x20
                    call _ISR_48_0x03
                    mov AL, 0x20
                    call _ISR_48_0x03
                inc EBX
                jmp .start
        .Check_0x0a:
            cmp AL, 0x0a
            jne .Check_0x0d
                ; New line
                push DX
                    mov word DX, [Cursor.Position]
                    mov DL, 79
                    mov word [Cursor.Position], DX
                    call _ISR_48_0x09
                    ; Clear new string
                    push EDI
                    push ECX
                        mov byte AH, [Background]
                        mov AL, 0x20
                        mov EDI, 24 * 160
                        mov ECX, 80
                        .clsstr:
                            mov [GS:EDI], AX
                            inc EDI
                            inc EDI
                        loop .clsstr
                    pop ECX
                    pop EDI
                    inc EBX
                pop DX
                jmp .start
        .Check_0x0d:
            cmp AL, 0x0d
            jne .PrintSymbol
                ; Carriage return
                push DX
                    mov word DX, [Cursor.Position]
                    xor DL, DL
                    call _ISR_48_0x08
                pop DX
                inc EBX
                jmp .start
        .PrintSymbol:
            call _ISR_48_0x03
            inc EBX
            jmp .start
    .Return:
    pop EBX
ret

; Get cursor position
;   Output:
;    * DH - row
;    * DL - column
_ISR_48_0x07:
    mov word DX, [Cursor.Position]
ret

; Set cursor position
;   Input:
;    * DH - row
;    * DL - column
_ISR_48_0x08:
    push BX
    push DX

    ; Remember position
    mov word [Cursor.Position], DX

    ; Move cursor
    mov AX, 80
    mul DH
    xor DH, DH
    add DX, AX
    mov BX, DX        ; Cursor offset

    mov DX, 0x03d4
    mov AL, 0x0f
    out DX, AL
    inc DL
    mov AL, BL
    out DX, AL

    dec DL
    mov AL, 0x0e
    out DX, AL
    inc DL
    mov AL, BH
    out DX, AL

    pop DX
    pop BX
ret

; Move cursor forward
_ISR_48_0x09:
    push DX
        mov word DX, [Cursor.Position]
        inc DL
        cmp DL, 80
        jl .CheckDH
            xor DL, DL
            inc DH
    .CheckDH:
        cmp DH, 25
        jl .Move
            mov DH, 24
            call _ISR_48_0x0b
    .Move:
        call _ISR_48_0x08
    pop DX
ret

; Move cursor backward
_ISR_48_0x0a:
    push DX
        mov word DX, [Cursor.Position]
        cmp DL, 0
        jg .ThisRow
            ; To the previous row
            mov DL, 79
            dec DH
            cmp DH, 0
            jg .Move
                ; Scroll up
                inc DH
                call _ISR_48_0x0c
                jmp .Move
    .ThisRow:
        dec DL
        jmp .Move
    .Move:
        call _ISR_48_0x08
    pop DX
ret

; Scroll down
_ISR_48_0x0b:
    push ECX
    push ESI
    push EDI

    ; 25 -> buffer
    push DS
    push ES
    mov AX, DS
    mov ES, AX  ; ES to .data
    mov AX, GS
    mov DS, AX  ; DS to video memory
    cld
        mov ESI, 25 * 160   ; linear address of row #25
        mov EDI, buffer
        mov ECX, 80
    rep movsw
    pop ES
    pop DS

    push DS
    push ES
        mov AX, GS
        mov DS, AX  ; DS to video memory
        mov ES, AX  ; ES to video memory
        ; 26 -> 25, ..., 203 -> 202
        mov ESI, 26 * 160       ; linear address of row #26
        mov EDI, 25 * 160       ; linear address of row #25
        mov ECX, 178
        .loop_26_203:
            push ECX
            cld
            mov ECX, 80
            rep movsw
            pop ECX
        loop .loop_26_203

        ; 1 -> 203
        cld
            mov ESI, 1 * 160    ; linear address of row #1
            mov EDI, 203 * 160  ; linear address of row #203
            mov ECX, 80
        rep movsw

        ; 2 -> 1, ..., 24 -> 23
        mov ESI, 2 * 160       ; linear address of row #2
        mov EDI, 1 * 160       ; linear address of row #2
        mov ECX, 23
        .loop_2_24:
            push ECX
            cld
            mov ECX, 80
            rep movsw
            pop ECX
        loop .loop_2_24
    pop ES
    pop DS

    push ES
    mov AX, GS
    mov ES, AX  ; ES to video memory
    ; buffer -> 24
    cld
        mov ESI, buffer
        mov EDI, 24 * 160   ; linear address of row #24
        mov ECX, 80
    rep movsw
    pop ES

    pop EDI
    pop ESI
    pop ECX
ret

; Scroll up
_ISR_48_0x0c:
    push ECX
    push ESI
    push EDI

    ; 24 -> buffer
    push DS
    push ES
    mov AX, DS
    mov ES, AX  ; ES to .data
    mov AX, GS
    mov DS, AX  ; DS to video memory
    std
        mov ESI, 24 * 160 + 160 - 2   ; linear address of end of row #24
        mov EDI, buffer + 160 - 2
        mov ECX, 80
    rep movsw
    pop ES
    pop DS

    push DS
    push ES
        mov AX, GS
        mov DS, AX  ; DS to video memory
        mov ES, AX  ; ES to video memory
        ; 23 -> 24, ..., 1 -> 2
        mov ESI, 23 * 160 + 160 - 2       ; linear address of end of row #23
        mov EDI, 24 * 160 + 160 - 2       ; linear address of end of row #24
        mov ECX, 23
        .loop_23_1:
            push ECX
            std
            mov ECX, 80
            rep movsw
            pop ECX
        loop .loop_23_1

        ; 203 -> 201
        std
            mov ESI, 203 * 160 + 160 - 2    ; linear address of end of row #203
            mov EDI, 1 * 160 + 160 - 2      ; linear address of end of row #1
            mov ECX, 80
        rep movsw

        ; 202 -> 203, ..., 25 -> 26
        mov ESI, 202 * 160 + 160 - 2        ; linear address of end of row #202
        mov EDI, 203 * 160 + 160 - 2        ; linear address of end of row #203
        mov ECX, 23
        .loop_202_25:
            push ECX
            std
            mov ECX, 80
            rep movsw
            pop ECX
        loop .loop_202_25
    pop ES
    pop DS

    push ES
    mov AX, GS
    mov ES, AX  ; ES to video memory
    ; buffer -> 25
    std
        mov ESI, buffer + 160 - 2
        mov EDI, 25 * 160 + 160 - 2   ; linear address of end of row #25
        mov ECX, 80
    rep movsw
    pop ES

    pop EDI
    pop ESI
    pop ECX
ret

; Print EDX
;   Input:
;    * AL: (OperandSize << 4) + OutputType
;       OperandSize in bytes. "0" = full register
;       OutputType:
;           0x0a    - decimal
;           0x0f    - hexadecimal
;    * DX - value to print
_ISR_48_0xff:
    push AX
    and AL, 00001111b
    .Check_0x0a:
        cmp AL, 0x0a
        jne .Check_0x0f
            ; Get operand size
            pop AX
                shr AL, 4       ; AL = Number of bytes
                shl AL, 3       ; AL = Number of bits
                mov CL, 32
                sub CL, AL      ; CL = Number of bits to shift right
                mov EAX, 0xffffffff
                shr EAX, CL
            and EDX, EAX
            ; Print dec
            mov EAX, EDX
            mov EBX, 10
            cmp EAX, 0
            jne .PrintDec.printEAX
                mov AL, '0'
                call _ISR_48_0x03
                jmp .Return
        .PrintDec.printEAX:
            push EAX
            push EDX
            cmp EAX, 0
            je .PrintDec.pdone
                xor EDX, EDX
                div EBX
                call .PrintDec.printEAX
                mov EAX, EDX
                add AL, 0x30
                call _ISR_48_0x03
        .PrintDec.pdone:
            pop EDX
            pop EAX
            ret
    .Check_0x0f:
        cmp AL, 0x0f
        jne .Return
            ; Get operand size
            pop AX
                shr AL, 4       ; AL = Number of bytes
                shl AL, 3       ; AL = Number of bits
                shr AL, 2       ; AL = Number of repeats
            xor ECX, ECX
            mov CL, AL
            ; Print hex
            mov AL, '0'
            call _ISR_48_0x03
            mov AL, 'x'
            call _ISR_48_0x03
            cmp CL, 0
            jne .PrintHex
                mov CL, 8
        .PrintHex:
                push CX
                push EDX
                    dec CL
                    shl CL, 2       ; Number of bits, to shift right
                    shr EDX, CL
                    and DL, 00001111b
                    add DL, 0x30
                    cmp DL, 0x3a
                    jl .PrintHex.print
                        add DL, 0x27        ; Low case
                .PrintHex.print:
                    mov AL, DL
                    call _ISR_48_0x03
                pop EDX
                pop CX
            loop .PrintHex
    .Return:
ret


section .data
    
    ; Cursor config
    Cursor:
        .Position:
            .x db 0x00
            .y db 0x00

    Background db 0x0f


section .bss
    
    ; Buffer for scrolling
    buffer resw 80


%endif ; __ISR_48_asm__
