[org 0x7c00] ; offset address (where the BIOS loads the boot sector)

mov si, msg     ; SI = pointer to string
mov ah, 0x0e    ; Enter tty mode (BIOS)

.print_loop:
    lodsb       ; AL = [SI], SI++ - Load one character in AL, then increment SI

    ; Compare the value in AL to 0
    ; If the value is the same, then finish the execution through done
    cmp al, 0
    je done
    
    ; Write AL and continue the loop (if the print isn't done)
    int 0x10
    jmp .print_loop

done:
    jmp $       ; Loop

msg db "OS LOADED!", 0  ; null-terminated string (so it can end)

; Placing 510 zeros minus the size of the code above
; Then boot signature / magic number (16-bit / 2 bytes)
times 510 - ($-$$) db 0
dw 0xaa55