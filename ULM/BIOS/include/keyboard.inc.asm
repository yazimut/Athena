%ifndef __keyboard_inc_asm__
%define __keyboard_inc_asm__

%ifdef __keyboard_asm__
    %define declare(symbol, type) global symbol:type
%else
    %define declare(symbol, type) extern symbol
%endif ; __keyboard_asm__

; Constants
    ; Buffer.capacity in bytes
    Buffer.capacity     EQU 4096

    ; IO ports
    KBD_Data_Port       EQU 0x60
    KBD_Cmd_Port        EQU 0x64

    ; Keyboard flags
    ;  1st byte - main flags
    KBDFLAGS_Break      EQU (00000001b << 0)
    ;  2nd byte - control keys
    KBDFLAGS_LCtrl      EQU (00000001b << 8)
    KBDFLAGS_RCtrl      EQU (00000010b << 8)
    KBDFLAGS_LAlt       EQU (00000100b << 8)
    KBDFLAGS_RAlt       EQU (00001000b << 8)
    KBDFLAGS_LShift     EQU (00010000b << 8)
    KBDFLAGS_RShift     EQU (00100000b << 8)
    KBDFLAGS_LSuper     EQU (01000000b << 8)
    KBDFLAGS_RSuper     EQU (10000000b << 8)
    ;  3rd byte - LEDs and key states
    KBDFLAGS_ScrollLock EQU (00000001b << 16)
    KBDFLAGS_NumLock    EQU (00000010b << 16)
    KBDFLAGS_CapsLock   EQU (00000100b << 16)

    ; Special scan-codes from SCS #2
    SCS2_Break              EQU 0xf0
    SCS2_Special            EQU 0xe0
    SCS2_Pause_make         EQU 0xe1
    SCS2_PrtScn_make        EQU 0x12
    SCS2_PrtScn_break       EQU 0x7c
    SCS2_ScrollLock_make    EQU 0x7e
    SCS2_NumLock_make       EQU 0x77
    SCS2_CapsLock_make      EQU 0x58

; Data


; Functions
    ; Initialize  keyboard and controller
    ;   Output:
    ;       * Carry-flag is set, if error
    ;       * EAX - error code, if error
    declare(_KBD_init, function)

    ; Toggle ScrollLock LED and flag
    declare(_KBD_ScrollLock_toggle, function)

    ; Enable ScrollLock LED and set flag
    declare(_KBD_ScrollLock_enable, function)

    ; Disable ScrollLock LED and clear flag
    declare(_KBD_ScrollLock_disable, function)

    ; Toggle NumLock LED and flag
    declare(_KBD_NumLock_toggle, function)

    ; Enable NumLock LED and set flag
    declare(_KBD_NumLock_enable, function)

    ; Disable NumLock LED and clear flag
    declare(_KBD_NumLock_disable, function)

    ; Toggle CapsLock LED and flag
    declare(_KBD_CapsLock_toggle, function)

    ; Enable CapsLock LED and set flag
    declare(_KBD_CapsLock_enable, function)

    ; Disable CapsLock LED and clear flag
    declare(_KBD_CapsLock_disable, function)

    ; Read scan-code from driver buffer
    ;   Input:
    ;       * ES:EBX - 9-byte null-terminated buffer
    ;         with scan-code
    ;   Output:
    ;       * Carry-flag is set, if error
    ;       * EAX - error code, if error
    declare(_KBD_readScancode, function)

    ; Write scan-code to driver buffer
    ;   Input:
    ;       * ES:EBX - 9-byte null-terminated buffer
    ;         with scan-code
    ;   Output:
    ;       * Carry-flag is set, if error
    ;       * EAX - error code, if error
    declare(_KBD_writeScancode, function)

    ; Analise buffer and modify flags
    declare(_KBD_analiseBuffer, function)


%endif ; __keyboard_inc_asm__
