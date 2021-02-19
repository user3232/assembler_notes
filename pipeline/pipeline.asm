
section .data
global somewhere

somewhere: dq 999
private: dq 666
datavar1: dq 1488
datavar2: dq 42
message: db `Yo yo\n\0`

section .bss
bssvar1: resq 4*1024*1024
bssvar2: resq 1

section .text
global _start
global func
extern something

func:
    mov rax, somewhere
    ret

_start:
    mov     rax, 1          ; system call number should be stored in rax
    mov     rdi, 1          ; argument #1 in rdi: where to write (descriptor)?
    mov     rsi, message    ; argument #2 in rsi: where does the string start?
    mov     rdx, 9          ; argument #3 in rdx: how many bytes to write?
    syscall                 ; this instruction invokes a system call

.the_end:                   ; mandatory because eof dont means end of 
                            ; instructions byte stream
    mov     rax, 60         ; 'exit' syscall number
    xor     rdi, rdi
    syscall

textlabel: dq 0