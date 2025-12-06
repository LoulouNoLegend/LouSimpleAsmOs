bits 16     ; Specify this asm is based on 16bit
org 0x7c00  ; offset address (where the BIOS loads the boot sector)

start:
    ; Clear the screen (set video mode 3)
    mov ax, 0x0003  ; AH: 0x00 (set video mode), AL: 0x03 (80x25)
    int 0x10        ; BIOS clears screen automatically

    mov si, msg     ; SI: 16-Bit register pointing to current position in the string
    call print
    
    jmp $           ; Keep the bootloader running

print:
    mov ah, 0x0e    ; BIOS tty (teletypewriter) mode

.print_loop:
    lodsb   ; Load next character into AL

    ; Compare the value in AL to 0
    ;   if value is equal, finish the execution (goto done)
    cmp al, 0   ; AL: 8-bit register holding a character to print
    je .done
    
    ; Print AL on screen and continue the loop ((if the print isn't done, lol))
    int 0x10
    jmp .print_loop

.done:
    ret

msg db "LAOS Bootloader started.", 0  ; null-terminated string (so it can end)

; Placing 510 zeros, minus the size of the code above
;   then boot signature / magic number (16-bit / 2 bytes)
times 510 - ($-$$) db 0
dw 0xaa55