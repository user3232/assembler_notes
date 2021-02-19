

section .data
codes:
    db      '0123456789ABCDEF'  ; dictionary of hex encoding chars
linefeed:
    db      10                  ; '\n' or "\n" form does not work :-(
linefeed2:
    db      `\n`, 0             ; this works in nasm

section .text
global _start
_start:
    ; number 1122... in hexadecimal format
    mov rax, 0x1122334455667788 ; accumulator register, number to print
                                ; in hex format
    mov rdi, 1                  ; destination register, where to write
    mov rdx, 1                  ; data register, for write syscall, number
                                ; of chars to print
    mov rcx, 64                 ; counter register,
                                ; how many bits have number 
                                ; to transform?
   
   ; Each 4 bits should be output as one hexadecimal digit
   ; Use shift and bitwise AND to isolate them
   ; the result is the offset in 'codes' array
   ; print that iteratively
.printChar:
    push rax                    ; save current number
    sub rcx, 4                  ; decrement 4 bits (hex digit)
    sar rax, cl                 ; shift right rax by rcx 
                                ; cl = 7-0 LSB bits of rcx
    and rax, 0xf                ; rax & mask of first 4 bits 
    lea rsi, [codes + rax]      ; lea = load effective address 
                                ; now rsi = char code from codes array
                                ; indexed by offset in rax
    mov rax, 1                  ; syscall number must be in rax (-> write)
    push rcx                    ; syscall will leave rcx and r11 
                                ; changed, so save rcx on stack
                                ; error code in rcx after syscall?
    syscall                     ; (rax = 1 -> write, 
                                ; rdi = 1 -> stdout,
                                ; rsi = char code address -> codes + offset,
                                ; rdx = number of characters to write)
    pop rcx                     ; take back oryginal rcx from stack
    pop rax                     ; take back oryginal rax from stack
    test rcx, rcx               ; test assigns result of AND of its
                                ; operands to flags:
                                ; res ← rcx & rcx =>
                                ; ZF ← res == 0
                                ; SF ← MSB(res)
                                ; PF ← BitwiseXNOR(TEMP[0:7])
                                ; test assigns result of 
                                ; AND of its operands to flags:
                                ; ZF as result equated to zero
                                ; SF as MSB of result
                                ; PF as BitwiseXNOR(res[0:7])
    jnz .printChar              ; jump to .printChar if ZF flag
                                ; not equal zero

.endline:
    mov     rax, 1              ; 'write' syscall code
    mov     rdi, 1              ; to stdout
    mov     rsi, linefeed2       ; starting at linefeed address
    mov     rdx, 1              ; one character
    syscall                     ; do it now
.andexit:    
    mov     rax, 60             ; 'exit' syscall code
    xor     rdi, rdi            ; output to stderr, no other args
    syscall                     ; do it now

