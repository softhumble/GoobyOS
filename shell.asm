bits 16
org 0x8000

start:

    mov si, banner
    call puts

main_loop:

    mov si, prompt
    call puts

    xor di, di

read_loop:

    xor ah, ah
    int 0x16

    cmp al, 13
    je command_enter

    cmp al, 8
    je backspace

    cmp di, 62
    jae read_loop

    mov [buffer + di], al
    inc di

    mov ah, 0x0E
    int 0x10

    jmp read_loop


backspace:

    cmp di, 0
    je read_loop

    dec di

    mov ah, 0x0E

    mov al, 8
    int 0x10

    mov al, ' '
    int 0x10

    mov al, 8
    int 0x10

    jmp read_loop


command_enter:

    mov byte [buffer + di], 0

    mov si, buffer
    cmp byte [si], 0
    je command_done

    call command_help
    jc command_done

    call command_about
    jc command_done

    call command_ver
    jc command_done

    call command_clear
    jc command_done

    call command_reboot
    jc command_done

    call command_verity
    jc command_done

    call command_echo
    jc command_done

    call command_credits
    jc command_done

    mov si, unknown
    call puts


command_done:

    xor di, di

    mov si, crlf
    call puts

    jmp main_loop


; =====================================
; HELP
; =====================================

command_help:

    mov si, buffer
    mov di, cmd_help

    call strcmp

    jnc .no

    mov si, help_text
    call puts

    stc
    ret

.no:
    clc
    ret


; =====================================
; CREDITS
; =====================================

command_credits:
    mov si, buffer
    mov di, cmd_credits
    call strcmp
    jnc .no
    mov si, credits_text
    call puts
    stc
    ret
.no:
    clc
    ret
; =====================================
; ABOUT
; =====================================

command_about:

    mov si, buffer
    mov di, cmd_about

    call strcmp

    jnc .no

    mov si, about_text
    call puts

    stc
    ret

.no:
    clc
    ret


; =====================================
; VERSION
; =====================================

command_ver:

    mov si, buffer
    mov di, cmd_ver

    call strcmp

    jnc .no

    mov si, version_text
    call puts

    stc
    ret

.no:
    clc
    ret


; =====================================
; CLEAR
; =====================================

command_clear:

    mov si, buffer
    mov di, cmd_clear

    call strcmp

    jnc .no

    mov ax, 0x0003
    int 0x10

    stc
    ret

.no:
    clc
    ret


; =====================================
; REBOOT
; =====================================

command_reboot:

    mov si, buffer
    mov di, cmd_reboot

    call strcmp

    jnc .no

    int 0x19

    stc
    ret

.no:
    clc
    ret


; =====================================
; VERITY
; =====================================

command_verity:

    mov si, buffer

    mov di, cmd_verity
    call strcmp

    jc .main_verity

    mov si, buffer
    mov di, verity_france

    call starts_with

    jc .france

    mov si, buffer
    mov di, verity_cow

    call starts_with

    jc .cow

    mov si, buffer
    mov di, verity_friend

    call starts_with

    jc .friend

    clc
    ret


.main_verity:

    mov si, verity_intro
    call puts

    stc
    ret


.france:

    mov si, verity_france_text
    call puts

    stc
    ret


.cow:

    mov si, verity_cow_text
    call puts

    stc
    ret


.friend:

    mov si, verity_friend_text
    call puts

    stc
    ret


; =====================================
; ECHO
; =====================================

command_echo:

    mov si, buffer
    mov di, cmd_echo

    call starts_with

    jnc .no

    cmp byte [si], ' '
    jne .check_exact

    inc si

.print:

    push si
    mov si, crlf
    call puts
    pop si

.loop:

    lodsb

    test al, al
    jz .yes

    mov ah, 0x0E
    int 0x10

    jmp .loop

.check_exact:

    cmp byte [si], 0
    jne .no

    push si
    mov si, crlf
    call puts
    pop si

.yes:

    stc
    ret

.no:

    clc
    ret


; =====================================
; STRING COMPARE
;
; SI = string 1
; DI = string 2
;
; CF = 1 if equal
; =====================================

strcmp:

.loop:

    mov al, [si]
    mov ah, [di]

    cmp al, ah
    jne .no

    cmp al, 0
    je .yes

    inc si
    inc di

    jmp .loop


.yes:

    stc
    ret


.no:

    clc
    ret


; =====================================
; PREFIX COMPARE
;
; SI = input
; DI = prefix
;
; CF = 1 if prefix matches
; SI points after prefix
; =====================================

starts_with:

.loop:

    mov al, [di]

    cmp al, 0
    je .yes

    cmp al, [si]
    jne .no

    inc si
    inc di

    jmp .loop


.yes:

    stc
    ret


.no:

    clc
    ret


; =====================================
; PRINT STRING
; =====================================

puts:

.next:

    lodsb

    test al, al
    jz .done

    mov ah, 0x0E
    int 0x10

    jmp .next


.done:

    ret


; =====================================
; COMMAND NAMES
; =====================================

cmd_help:
    db "help",0

cmd_about:
    db "about",0

cmd_ver:
    db "ver",0

cmd_clear:
    db "clear",0

cmd_reboot:
    db "reboot",0

cmd_verity:
    db "verity",0

cmd_echo:
    db "echo",0

cmd_credits:
    db "credits",0
; =====================================
; VERITY COMMANDS
; =====================================

verity_france:
    db "verity france",0

verity_cow:
    db "verity cow",0


verity_friend:
    db "verity friend",0


; =====================================
; TEXT
; =====================================

banner:

    db 13,10
    db "================================",13,10
    db "          gubgubOS 0.3",13,10
    db "       Tiny x86 operating system",13,10
    db "================================",13,10
    db "Type 'help' for commands.",13,10
    db 13,10,0


prompt:

    db "gubgub> ",0


help_text:

    db 13,10
    db "gubgubOS commands:",13,10
    db " help             - show commands",13,10
    db " about            - about gubgubOS",13,10
    db " ver              - show version",13,10
    db " echo TEXT        - print text",13,10
    db " clear            - clear screen",13,10
    db " reboot           - restart",13,10
    db " verity           - talk to Verity",13,10
    db " verity france    - ask about France",13,10
    db " verity cow       - ask about cows",13,10
    db " verity friend    - ask about friendship",13,10
    db " credits          - credits of this operating system",13,10
    db 0

credits_text:
    db 13,10
    db "Owner Of GubGub: getcub3d on discord AND tiktok, softhumble on github",13,10
    db "Contributer: alithealiosowner on discord, hisswx9 on tiktok, justlinuxyourself on github",13,10
    db 0

about_text:

    db 13,10
    db "gubgubOS is a tiny hobby operating system.",13,10
    db "Built for learning, experimentation and fun.",13,10
    db "Non-commercial hobby project.",13,10
    db 0


version_text:

    db 13,10
    db "gubgubOS version 0.3",13,10
    db 0


verity_intro:

    db 13,10
    db "Hey, it's me, Verity.",13,10
    db "Ask me something.",13,10
    db "I've got answers ready.",13,10
    db "I'm here to help.",13,10
    db 0


verity_france_text:

    db 13,10
    db "Verity: Paris! Easy one.",13,10
    db 0


verity_cow_text:

    db 13,10
    db "Verity: Moo! I know that one too.",13,10
    db 0


verity_friend_text:

    db 13,10
    db "Verity: Of course. I'm here with you.",13,10
    db 0


unknown:

    db 13,10
    db "Unknown command. Type help.",13,10
    db 0


crlf:

    db 13,10,0


buffer:

    times 64 db 0
