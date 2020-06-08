%ifndef __keyboard_asm__
%define __keyboard_asm__

%include "keyboard.inc.asm"

; Private constants
    ; Controller command set
    CTRL_COMMAND_SELF_TEST          EQU 0xaa
    CTRL_COMMAND_READ_COMMAND_BYTE  EQU 0x20
    CTRL_COMMAND_WRITE_COMMAND_BYTE EQU 0x60

    ; Controller answers set
    CTRL_ANS_SELF_TEST_OK           EQU 0x55

    ; Keyboard command set
    KBD_COMMAND_RESET               EQU 0xff
    KBD_COMMAND_ECHO                EQU 0xee
    KBD_COMMAND_SET_LEDS            EQU 0xed
    KBD_COMMAND_ENABLE              EQU 0xf4
    KBD_COMMAND_SET_TYPEMATIC_RD    EQU 0xf3
    KBD_COMMAND_SET_ALL_KEYS_TMB    EQU 0xfa

    ; Keyboard answers set
    KBD_ANS_ACKNOWLEDGE             EQU 0xfa
    KBD_ANS_RESEND                  EQU 0xfe
    KBD_ANS_ERROR                   EQU 0xfc
    KBD_ANS_BAT_SUCCESSFUL          EQU 0xaa
    KBD_ANS_ECHO                    EQU 0xee

    ; Error codes
    INIT_ERROR_CTRL_INIT            EQU 0x01
    INIT_ERROR_KBD_INIT             EQU 0x02

    ; Controller status register
    CTRL_STATUS_OBF                 EQU 00000001b
    CTRL_STATUS_IBF                 EQU 00000010b
    CTRL_STATUS_SYS                 EQU 00000100b
    CTRL_STATUS_A2                  EQU 00001000b
    CTRL_STATUS_INH                 EQU 00010000b
    CTRL_STATUS_TxTO_MOBF           EQU 00100000b
    CTRL_STATUS_RxTO_TO             EQU 01000000b
    CTRL_STATUS_PERR                EQU 10000000b

    ; Controller command byte
    CTRL_CB_INT                     EQU 00000001b
    CTRL_CB_INT2                    EQU 00000010b
    CTRL_CB_SYS                     EQU 00000100b
    CTRL_CB_OVR                     EQU 00001000b
    CTRL_CB_EN                      EQU 00010000b
    CTRL_CB_PC_EN2                  EQU 00100000b
    CTRL_CB_XLAT                    EQU 01000000b

    ; Typematic rate/delay
    KBD_TYPEMATIC_RATE_30_0         EQU 0x00
    KBD_TYPEMATIC_RATE_26_7         EQU 0x01
    KBD_TYPEMATIC_RATE_24_0         EQU 0x02
    KBD_TYPEMATIC_RATE_21_8         EQU 0x03
    KBD_TYPEMATIC_RATE_20_7         EQU 0x04
    KBD_TYPEMATIC_RATE_18_5         EQU 0x05
    KBD_TYPEMATIC_RATE_17_1         EQU 0x06
    KBD_TYPEMATIC_RATE_16_0         EQU 0x07
    KBD_TYPEMATIC_RATE_15_0         EQU 0x08
    KBD_TYPEMATIC_RATE_13_3         EQU 0x09
    KBD_TYPEMATIC_RATE_12_0         EQU 0x0a
    KBD_TYPEMATIC_RATE_10_9         EQU 0x0b
    KBD_TYPEMATIC_RATE_10_0         EQU 0x0c
    KBD_TYPEMATIC_RATE_09_2         EQU 0x0d
    KBD_TYPEMATIC_RATE_08_6         EQU 0x0e
    KBD_TYPEMATIC_RATE_08_0         EQU 0x0f
    KBD_TYPEMATIC_RATE_07_5         EQU 0x10
    KBD_TYPEMATIC_RATE_06_7         EQU 0x11
    KBD_TYPEMATIC_RATE_06_0         EQU 0x12
    KBD_TYPEMATIC_RATE_05_5         EQU 0x13
    KBD_TYPEMATIC_RATE_05_0         EQU 0x14
    KBD_TYPEMATIC_RATE_04_6         EQU 0x15
    KBD_TYPEMATIC_RATE_04_3         EQU 0x16
    KBD_TYPEMATIC_RATE_04_0         EQU 0x17
    KBD_TYPEMATIC_RATE_03_7         EQU 0x18
    KBD_TYPEMATIC_RATE_03_3         EQU 0x19
    KBD_TYPEMATIC_RATE_03_0         EQU 0x1a
    KBD_TYPEMATIC_RATE_02_7         EQU 0x1b
    KBD_TYPEMATIC_RATE_02_5         EQU 0x1c
    KBD_TYPEMATIC_RATE_02_3         EQU 0x1d
    KBD_TYPEMATIC_RATE_02_1         EQU 0x1e
    KBD_TYPEMATIC_RATE_02_0         EQU 0x1f
    KBD_TYPEMATIC_DELAY_0_25        EQU (00b << 5)
    KBD_TYPEMATIC_DELAY_0_50        EQU (01b << 5)
    KBD_TYPEMATIC_DELAY_0_75        EQU (10b << 5)
    KBD_TYPEMATIC_DELAY_1_00        EQU (11b << 5)


[Bits 32]


section .text

; Read output buffer of controller
;   Output:
;       * AL - Value
_KBD_ctrl_readOutputBuffer:
    pushfd
        cli
    .CheckStatReg:
        in AL, KBD_Cmd_Port         ; Read status register
        test AL, CTRL_STATUS_OBF
        jz .CheckStatReg            ; Wait until OBF=1
        in AL, KBD_Data_Port
    popfd
ret

; Write input buffer of controller
;   Input:
;       * AL - Value
_KBD_ctrl_writeInputBuffer:
    pushfd
        cli
        push AX
    .CheckStatReg:
        in AL, KBD_Cmd_Port         ; Read status register
        test AL, CTRL_STATUS_IBF
        jnz .CheckStatReg           ; Wait until IBF=0
        pop AX
        out KBD_Data_Port, AL
    popfd
ret

; Send command to controller
;   Input:
;       * AL - command
_KBD_ctrl_sendCommand:
    pushfd
        cli
        push AX
    .CheckStatReg:
        in AL, KBD_Cmd_Port         ; Read status register
        test AL, CTRL_STATUS_IBF
        jnz .CheckStatReg           ; Wait until IBF=0
        pop AX
        out KBD_Cmd_Port, AL
    popfd
ret

; Send byte to the keyboard
;   Input:
;       * AL - byte
_KBD_kbd_sendByte:
    pushfd
        call _KBD_ctrl_writeInputBuffer
        call _KBD_ctrl_readOutputBuffer
    popfd
ret


; Initialize keyboard and controller.
_KBD_init:
    push AX
    pushfd
        cli
        
    .ControllerSelfTest:
        ; Controller self-test
        mov AL, CTRL_COMMAND_SELF_TEST
        call _KBD_ctrl_sendCommand
        call _KBD_ctrl_readOutputBuffer
        cmp AL, CTRL_ANS_SELF_TEST_OK
        je .KeyboardSelfTest
            ; Self-test failed
            popfd
            stc
            pop AX
            mov EAX, INIT_ERROR_CTRL_INIT
            ret

    .KeyboardSelfTest:
        ; Keyboard self-test
        mov AL, KBD_COMMAND_RESET
        call _KBD_kbd_sendByte
        call _KBD_ctrl_readOutputBuffer
        cmp AL, KBD_ANS_BAT_SUCCESSFUL
        je .EnableKeyboard
            ; BAT failed
            popfd
            stc
            pop AX
            mov EAX, INIT_ERROR_KBD_INIT
            ret

    .EnableKeyboard:
        mov AL, KBD_COMMAND_ENABLE
        call _KBD_kbd_sendByte

        mov AL, CTRL_COMMAND_READ_COMMAND_BYTE
        call _KBD_ctrl_sendCommand
        call _KBD_ctrl_readOutputBuffer
        and AL, ~(CTRL_CB_EN) & ~(CTRL_CB_XLAT)
        or AL, CTRL_CB_INT
        shl AX, 8
        mov AL, CTRL_COMMAND_WRITE_COMMAND_BYTE
        call _KBD_ctrl_sendCommand
        shr AX, 8
        call _KBD_ctrl_writeInputBuffer

        ; Set typematic rate/delay to 10cps/500ms
        mov AL, KBD_COMMAND_SET_TYPEMATIC_RD
        call _KBD_kbd_sendByte
        mov AL, KBD_TYPEMATIC_RATE_10_9 | KBD_TYPEMATIC_DELAY_0_50
        call _KBD_kbd_sendByte
    .Return:
    popfd
    pop AX
ret

; Toggle ScrollLock LED and flag
_KBD_ScrollLock_toggle:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        xor dword EAX, KBDFLAGS_ScrollLock
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Enable ScrollLock LED and set flag
_KBD_ScrollLock_enable:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        or dword EAX, KBDFLAGS_ScrollLock
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Disable ScrollLock LED and clear flag
_KBD_ScrollLock_disable:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        and dword EAX, ~(KBDFLAGS_ScrollLock)
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Toggle NumLock LED and flag
_KBD_NumLock_toggle:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        xor dword EAX, KBDFLAGS_NumLock
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Enable NumLock LED and set flag
_KBD_NumLock_enable:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        or dword EAX, KBDFLAGS_NumLock
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Disable NumLock LED and clear flag
_KBD_NumLock_disable:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        and dword EAX, ~(KBDFLAGS_NumLock)
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Toggle CapsLock LED and flag
_KBD_CapsLock_toggle:
    push EAX
    pushfd
        cli
        mov dword EAX, [KBDFlags]
        xor dword EAX, KBDFLAGS_CapsLock
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    popfd
    pop EAX
ret

; Enable CapsLock LED and set flag
_KBD_CapsLock_enable:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        or dword EAX, KBDFLAGS_CapsLock
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Disable CapsLock LED and clear flag
_KBD_CapsLock_disable:
    push EAX
        cli
        mov dword EAX, [KBDFlags]
        and dword EAX, ~(KBDFLAGS_CapsLock)
        mov dword [KBDFlags], EAX

        mov AL, KBD_COMMAND_SET_LEDS
        call _KBD_kbd_sendByte
        shr EAX, 16
        call _KBD_kbd_sendByte
    pop EAX
ret

; Read scan-code from driver buffer
;   Input:
;       * ES:EBX - 9-byte buffer
;         for scan-code
;   Output:
;       * Carry-flag is set, if error
;       * EAX - error code, if error
_KBD_readScancode:
    push EAX
    push EBX
    push EDX
    pushfd
        mov dword EAX, [Buffer.size]
        cmp EAX, 0
        jne .Read
            ; Buffer is empty
            popfd
            pop EDX
            pop EBX
            pop EAX
            stc
            mov EAX, 1
            ret
    .Read:
        call readFromBuffer
        mov byte [ES:EBX], AL
        inc EBX
    .Check_Pause_make:
        cmp AL, SCS2_Pause_make
        jne .Check_Special
            ; Scan-code "Pause make"
            push ECX
            mov ECX, 7
            .Read_Pause_make:
                call readFromBuffer
                mov byte [ES:EBX], AL
                inc EBX
            loop .Read_Pause_make
            pop ECX
            mov byte [ES:EBX], 0x00
            jmp .Return
    .Check_Special:
        cmp AL, SCS2_Special
        jne .Check_Break
            ; Scan-code "Special"
            or byte [ReadFlags], 00000001b
            jmp .Read
    .Check_Break:
        cmp AL, SCS2_Break
        jne .Check_PrtScn_make
            ; Scan-code "Break"
            or byte [ReadFlags], 00000010b
            jmp .Read
    .Check_PrtScn_make:
        cmp AL, SCS2_PrtScn_make
        jne .Check_PrtScn_break
            ; Probably scan-code "PrtScn make"
            test dword [ReadFlags], 00000001b
            jz .Not_PrtScn_make
                ; Scan-code "PrtScn make"
                push ECX
                mov ECX, 2
                .Read_PrtScn_make:
                    call readFromBuffer
                    mov byte [ES:EBX], AL
                    inc EBX
                loop .Read_PrtScn_make
                pop ECX
        .Not_PrtScn_make:
            ; Just general scan-code
            and dword [ReadFlags], 11111100b
            jmp .General
    .Check_PrtScn_break:
        cmp AL, SCS2_PrtScn_break
        jne .General
            ; Probably scan-code "PrtScn break"
            test dword [ReadFlags], 00000011b
            jz .Not_PrtScn_break
                ; Scan-code "PrtScn make"
                push ECX
                mov ECX, 3
                .Read_PrtScn_break:
                    call readFromBuffer
                    mov byte [ES:EBX], AL
                    inc EBX
                loop .Read_PrtScn_break
                pop ECX
        .Not_PrtScn_break:
            ; Just general scan-code
            and dword [ReadFlags], 11111100b
            jmp .General
    .General:
        and dword [ReadFlags], 11111100b
        mov byte [ES:EBX], 0x00
    .Return:
    popfd
    pop EDX
    pop EBX
    pop EAX
ret

readFromBuffer:
    push EBX
    push EDX
        mov dword EDX, [Buffer.head]
        add EDX, Buffer
        mov byte AL, [EDX]
        push AX
            mov dword EAX, [Buffer.head]
            inc EAX
            xor EDX, EDX
            mov EBX, Buffer.capacity
            div EBX
            mov dword [Buffer.head], EDX
            dec dword [Buffer.size]
        pop AX
    pop EDX
    pop EBX
ret

; Write scan-code to driver buffer
;   Input:
;       * ES:EBX - 9-byte null-terminated buffer
;         with scan-code
;   Output:
;       * Carry-flag is set, if error
;       * EAX - error code, if error
_KBD_writeScancode:
    push EAX
    push EBX
    push ECX
    pushfd
        ; Get scan-code length
        push EBX
            xor ECX, ECX
            .Count:
            mov byte AL, [ES:EBX]
            inc EBX
            inc ECX
            cmp AL, 0x00
            jne .Count
            dec ECX

            ; Check buffer size
            mov EBX, ECX
            add dword EBX, [Buffer.size]
            add EBX, 2
            cmp EBX, Buffer.capacity
            jle .Write
                ; Not enough space in buffer
                pop EBX
                popfd
                pop ECX
                pop EBX
                pop EAX
                stc
                mov EAX, 1
                ret
        pop EBX

    .Write:
        pop EBX
        .WL:
            mov byte AL, [ES:EBX]
            call writeToBuffer
            inc EBX
        loop .WL

    .Return:
    popfd
    pop ECX
    pop EBX
    pop EAX
ret

writeToBuffer:
    push EBX
    push EDX
        mov dword EDX, [Buffer.tail]
        add EDX, Buffer
        mov byte [EDX], AL
        mov dword EAX, [Buffer.tail]
        inc EAX
        xor EDX, EDX
        mov EBX, Buffer.capacity
        div EBX
        mov dword [Buffer.tail], EDX
        inc dword [Buffer.size]
    pop EDX
    pop EBX
ret


section .data

    ; uint32_t KBDFlags;
    ; Keyboard flags
    KBDFlags dd 0x00000000

    ; ptr32_t Buffer.head;
    ; ptr32_t Buffer.tail;
    ; Head and Tail of ring buffer
    Buffer.head dd 0x00000000
    Buffer.tail dd 0x00000000

    ; uint32_t Buffer.size;
    ; Size of ring buffer
    Buffer.size dd 0x00000000

    ; Flags for reading function
    ReadFlags db 0x00


section .bss

    ; ptr32_t Buffer;
    ; Buffer for scan-codes
    Buffer resb Buffer.capacity


%endif ; __keyboard_asm__
