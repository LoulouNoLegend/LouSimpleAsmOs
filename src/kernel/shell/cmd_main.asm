shell_loop:
    mov si, cmd_prompt
    call print_tty

    call read_line      ; full the buffer

    ; if empty, return to base
    mov si, cmd_buffer
    mov al, [si]
    cmp al, 0
    je shell_loop

    ; clear
    mov si, cmd_buffer
    mov di, cmd_clear
    call cmp_str
    cmp al, 1
    je .do_clear

    ; help
    mov si, cmd_buffer
    mov di, cmd_help
    call cmp_str
    cmp al, 1
    je .do_help

    ; halt
    mov si, cmd_buffer
    mov di, cmd_halt
    call cmp_str
    cmp al, 1
    je .do_halt

    ; meow
    mov si, cmd_buffer
    mov di, cmd_meow
    call cmp_str
    cmp al, 1
    je .run_meow

    ; else: incognito commando
    mov si, msg_cmd_unknown
    call print_tty
    call newline_tty
    call newline_tty
    jmp shell_loop

; commands
.do_clear:
    ;call clear_screen
    ;jmp shell_loop
    jmp kernel_start    ; only for now, because it's not optimal at all (but the title stays)

.do_help:
    mov si, msg_cmd_help
    call print_tty
    call newline_tty
    call newline_tty
    jmp shell_loop

.do_halt:
    mov si, msg_cmd_halt
    call print_tty
    call newline_tty
    jmp .halt_loop

.halt_loop:
    jmp .halt_loop

; ---------------------
; COMMANDS RUN
.run_meow:
    call shell_cc_meow
    call newline_tty
    jmp shell_loop
;-------------------

read_line:
    ; Save used registers (push)
    push ax
    push si
    push cx

    mov si, cmd_buffer  ; SI = start cmd_buffer
    xor cx, cx  ; reset counter

.read_loop:
    call read_key   ; call read_key (returns AL)
    cmp al, 0x0D    ; if AL == 0x0D (Enter) -> jump to .done
    je .done

    cmp al, 0x08    ; if AL == 0x08 (Backspace) -> jump to .backspace
    je .backspace

    ; if counter >= 31 -> don't save just re-loop
    cmp cx, 31
    jge .read_loop

    mov [si], al
    inc si
    inc cx  ; CX++

    mov ah, 0x0E
    int 0x10

    jmp .read_loop  ; Return to the start of the loop

.done:
    ; put 0 in [SI] to end chain
    mov byte [si], 0

    call newline_tty

    pop cx
    pop si
    pop ax

    ret

.backspace:
    cmp cx, 0
    je .read_loop

    dec si
    dec cx
    mov ah, 0x0E

    mov al, 0x08
    int 0x10 

    mov al, ' '
    int 0x10 

    mov al, 0x08
    int 0x10
    
    jmp .read_loop

%include "src/kernel/shell/commands/_include.asm"

;---------------------
; Values
cmd_buffer times 32 db 0    ; 32o for CMD

cmd_mem db "mem", 0 ; TODO: Command to show memory
cmd_clear db "clear", 0
cmd_help db "help", 0
cmd_halt db "halt", 0
cmd_meow db "meow", 0

cmd_prompt db "LAOS> ", 0
msg_cmd_unknown db "Unknown command.", 0
msg_cmd_help db "Commands: mem, clear, help, halt", 0
msg_cmd_halt db "Kernel halted. You can reset the machine.", 0