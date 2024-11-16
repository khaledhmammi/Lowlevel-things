BITS 16
ORG 0x7C00

start:
    ; Setup stack
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load kernel (sector 2 onwards)
    mov bx, 0x0000       ; Address to load kernel
    mov dh, 0            ; Head 0
    mov dl, 0            ; Drive 0 (floppy)
    mov ch, 0            ; Cylinder 0
    mov cl, 2            ; Sector 2
    mov ah, 0x02         ; BIOS function: read sectors
    mov al, 10           ; Number of sectors to read
    int 0x13             ; Call BIOS interrupt

    jc disk_error        ; Jump if there was a read error

    ; Jump to the kernel
    jmp 0x0000:0x0000

disk_error:
    hlt                  ; Halt on error

times 510-($-$$) db 0    ; Fill remaining bytes with zeros
dw 0xAA55                ; Boot signature
