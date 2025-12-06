[org 0x7c00] ; offset address (where the BIOS loads the boot sector)

mov si, msg     ; SI: 16-Bit register pointing to current position in the string
mov ah, 0x0e    ; Enter BIOS tty (teletypewriter) mode

.print_loop:
    lodsb       ; AL = [SI], SI++ - Load one character in AL, then increment SI

    ; Compare the value in AL to 0
    ;   if value is equal, finish the execution (goto done)
    cmp al, 0   ; AL: 8-bit register holding a character to print
    je done
    
    ; Print AL on screen and continue the loop ((if the print isn't done, lol))
    int 0x10
    jmp .print_loop

done:
    jmp $       ; Loop

msg db "LAOS Bootloader started.", 0  ; null-terminated string (so it can end)

; Placing 510 zeros, minus the size of the code above
;   then boot signature / magic number (16-bit / 2 bytes)
times 510 - ($-$$) db 0
dw 0xaa55