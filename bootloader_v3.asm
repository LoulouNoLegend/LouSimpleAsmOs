; LAOS Micro-OS v0
; One boot sector "OS"
;   - Screen Clears
;   - Tiny menu
;   - Waits for keys
;   - React to 1 & 2

bits 16
org 0x7c00

start:
    ; Basic Segment + stack setup (for safety)
    cli         ; Clear interrupt flag / Disable hardware interrupts
    xor ax, ax  ; ax = 0
    mov ds, ax  ; Set Data Segment to 0x0000 (interpret everything at physical address)
    mov es, ax  ; Set Extra Segment to 0x0000
    mov ss, ax  ; Set Stack Segment to 0x0000
    mov sp, 0x7C00  ; Set Stack Pointer to 0x7C00
    sti         ; Enable hardware interrupts again

    call clear_scren    ; Push address on stack, so don't put before the stack setup

main_menu:    
    call clear_scren

    ; Reset cursor to top-left
    mov ah, 0x02
    mov bh, 0       ; Page 0
    mov dh, 0       ; Row 0
    mov dl, 0       ; Col 0
    int 0x10

    mov si, msg_title
    mov bl, 0x09
    call print_color
    
    call newline_tty
    mov si, msg_opt1
    call print_normal
    
    call newline_tty
    mov si, msg_opt2
    call print_normal
    
    call newline_tty
    call newline_tty
    mov si, msg_prompt
    call print_normal

    call read_key

    cmp al, '1'
    je show_about

    cmp al, '2'
    je show_halt
    
    jmp main_menu

;---------------------------
show_about:
    call clear_scren

    mov si, msg_about
    call print_normal

    call newline_tty
    call newline_tty
    mov si, msg_anykey
    call print_normal

    ; wait and then go back to menu
    call read_key
    jmp main_menu

show_halt:
    call clear_scren

    mov si, msg_halt
    mov bl, 0x0A
    call print_color

    jmp $   ; freeze forever aaaa

;---------------------------
newline_tty:
    mov ah, 0x0E     ; teletype mode / reset AH
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

; Read one key from keyboard (blocking)
; Return: AL = ASCII code
read_key:
    mov ah, 0x00    ; BIOS: wait for key
    int 0x16        ; AH=scan code, AL=ASCII
    ret

clear_scren:
    ; Text mode 80x25, clear screen
    mov ax, 0x0003  ; 00: VideoMode / 03: 80x25
    int 0x10
    ret
;---------------------------
print_normal:
    mov ah, 0x0E

.print_normal_loop:
    lodsb
    cmp al, 0
    je .done_normal
    int 0x10
    jmp .print_normal_loop

.done_normal:
    ret

;----------------------------
print_color:
    mov byte [color_x], 0
.print_color_loop:
    lodsb
    cmp al, 0
    je .done_color

    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, [color_x]
    int 0x10

    mov ah, 0x09
    mov bh, 0
    mov cx, 1
    int 0x10

    inc byte [color_x]

    jmp .print_color_loop

.done_color:
    ret
;----------------------------

msg_title  db "LAOS Micro-OS v0", 0
msg_opt1   db "[1] About", 0
msg_opt2   db "[2] Halt system", 0
msg_prompt db "Select option: ", 0

msg_about  db "LAOS is a tiny bootloader OS experiment.", 0
msg_anykey db "Press any key to return to menu.", 0

msg_halt   db "System halted. You can turn off the machine now.", 0

color_x db 0

; Placing 510 zeros, minus the size of the code above
;   then boot signature / magic number (16-bit / 2 bytes)
times 510 - ($-$$) db 0
dw 0xaa55