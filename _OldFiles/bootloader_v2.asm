; Process:
;   - Screen Clears
;   - Message Prints
;   - It waits

bits 16     ; Specify this asm is based on 16bit
org 0x7c00  ; offset address (where the BIOS loads the boot sector)

start:
    cld     ; clear direction flag so lodsb increments SI

    ; Clear the screen (set video mode 3)
    mov ax, 0x0003  ; AH: 0x00 (set video mode), AL: 0x03 (80x25)
    int 0x10        ; BIOS clears screen automatically

    ; Print Message
    mov si, msg_normal      ; SI: 16-Bit register pointing to string
    call print_normal

    ; Print New Line
    mov ah, 0x0E
    mov al, 0x0D        ; Put cursor on column 0 (CR)
    int 0x10
    mov al, 0x0A        ; Move cursor down one line, but keep column (0 in this case)
    int 0x10

    ; Print Color Message
    mov si, msg_color
    mov bl, 0xF3    ; Colors
    call print_color
    
    jmp $           ; Keep the bootloader running

loop:
    mov al, 0x0D    ; cursor pos 0
    int 0x10

;---------------------------
print_normal:
    mov ah, 0x0e    ; BIOS tty (teletypewriter) mode

.print_normal_loop:
    lodsb   ; Load next character into AL
            ;   --> mov al, si 
            ;       inc si

    ; Compare the value in AL to 0
    ;   if value is equal, finish the execution (goto done)
    cmp al, 0   ; AL: 8-bit register holding a character to print
    je .done_normal
    
    ; Print AL on screen and continue the loop ((if the print isn't done, lol))
    int 0x10
    jmp .print_normal_loop

.done_normal:
    ret

;----------------------------
; Differences from print_normal:
;   AH=09h does NOT move the cursor after printing a character
;   It writes the character+attribute ONLY at the cursor position
;
;   INT 10h only writes using the set attributes of the BIOS at startup
;   (Black background / White text in this case, since I don't modify anything)
;
;   Steps used:
;       - Manually position the cursor before each character (AH=02h)
;       - Write the character+attribute at that position (AH=09h)
;       - Advance our own column counter (color_x)
print_color:
.print_color_loop:
    lodsb             ; AL = next char
    cmp al, 0
    je .done_color

    ; Set cursor to row 1, column = color_x
    mov ah, 0x02        ; Set cursor position
    mov bh, 0           ; Video page
    mov dh, 1           ; Row 1 (0-based: second line on screen)
    mov dl, [color_x]   ; Current column into dl
    int 0x10

    ; Draw AL at the position with attributes BL
    mov ah, 0x09    ; write char+attribute
    mov bh, 0       ; Video page
    mov cx, 1       ; Print 1 time
    int 0x10        ; Print with color

    ; Increment to next column
    inc byte [color_x]

    jmp .print_color_loop

.done_color:
    ret
;----------------------------

msg_normal db "LAOS Bootloader started.", 0  ; null-terminated string (so it can end)
msg_color db "Peak, isn't it?", 0

color_x db 0    ; Track the column number in print_color to move it

; Placing 510 zeros, minus the size of the code above
;   then boot signature / magic number (16-bit / 2 bytes)
times 510 - ($-$$) db 0
dw 0xaa55