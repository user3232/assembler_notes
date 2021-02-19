
section .data

newline_char: db 10
codes: db '0123456789abcdef'



section .text
global _start

; function printing to stdout line feed (new line) character
; takes no arguments
print_newline:
    mov rax, 1            ; 'write' syscall identifier
    mov rdi, 1            ; stdout file descriptor
    mov rsi, newline_char ; where do we take data from
    mov rdx, 1            ; the amount of bytes to write
    syscall
    ret                   ; pop and jump to address in popped value

; function printing to stdout number in hex format
; takes number to print as first argument (in rdi)
print_hex:
    mov rax, rdi    ; rdi contains first function argument
                    ; print_hex does not take other args
    mov rdi, 1      ; prepare write syscall identifier
    mov rdx, 1      ; prepare write syscall filedescriptor
    mov rcx, 64     ; how far are we shifting rax?

    iterate:
        push rax              ; Save the initial rax value
        sub rcx, 4
        sar rax, cl           ; shift to 60, 56, 52, ... 4, 0
                              ; the cl register is the smallest part of rcx
        and rax, 0xf          ; clear all bits but the lowest four
        lea rsi, [codes + rax]; take a hexadecimal digit character code
        mov rax, 1            ; 
        push rcx              ; syscall will break rcx
        syscall               ; rax = 1 (31) -- the write identifier,
                              ; rdi = 1 for stdout,
                              ; rsi = the address of a character, see line 33
        pop rcx
        pop rax               ; ˆ see line 24 ˆ
        test rcx, rcx         ; rcx = 0 when all digits are shown
        jnz iterate
    ret     ; will pop stack and jump to popped value
            ; (rip before print_hex function call)

_start:
    mov rdi, 0x1122334455667788     ; specifying number to print
    call print_hex                  ; printing number in hex
    call print_newline              ; printing new line

exit:               ; all done, exit
    mov rax, 60     ; exit syscall number
    xor rdi, rdi    ; exit syscall argument (0 = OK)
    syscall         ; rax = 60 -- the exit identifier,
                    ; rdi = 0 for OK,

