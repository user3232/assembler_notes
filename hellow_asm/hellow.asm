; to run this example use
; ./build_hellow.sh


global _start               ; what address to export? 
                            ; it is defined by global directive

section .data               ; array of numbers can be put in named sections
                            ; .data section typically contains initialized data
message: 
    db 'hello, world!'      ; db 10,11,12 is asm instruction 
    db 10                   ; which puts values 10,11,12 as bytes
mymess:  
    db 65,66,67             ; as string = "ABC"
    db 68,69,10,0           ; as string = "DE\n\0"
mymess0: 
    db 65                   ; as string = A
    db 66
    db 67
mymess3: 
    db 68
    db 69                   
mymess5: 
    db 10                   ; new line LF "\n" = 10
                            ; carrige return CR "\r" = 13
mymess6: 
    db 0                    ; null terminator NULL "\0" = 0

section .text
_start:
    mov     rax, 1          ; system call number should be stored in rax
    mov     rdi, 1          ; argument #1 in rdi: where to write (descriptor)?
    mov     rsi, mymess0    ; argument #2 in rsi: where does the string start?
    mov     rdx, 9          ; argument #3 in rdx: how many bytes to write?
    syscall                 ; this instruction invokes a system call

_the_end:                   ; mandatory because eof dont means end of 
                            ; instructions byte stream
    mov     rax, 60         ; 'exit' syscall number
    xor     rdi, rdi
    syscall

_does_not_matter:           ; after exit syscall instructions will
                            ; not be performed

    mov     rax, 1          ; system call number should be stored in rax
    mov     rdi, 1          ; argument #1 in rdi: where to write (descriptor)?
    mov     rsi, mymess0    ; argument #2 in rsi: where does the string start?
    mov     rdx, 9          ; argument #3 in rdx: how many bytes to write?
    syscall                 ; this instruction invokes a system call
