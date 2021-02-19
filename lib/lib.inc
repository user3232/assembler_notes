
; functions in assembly

; exit function
; calls exit system code
; takes exit code as argument (in rdi)
exit:
    mov rax, 60     ; exit syscall number
    ; rdi           ; in rdi is exit code
                    ; and rdi is first param
                    ; of exit syscall
    syscall         ; exit syscall will terminate
                    ; process, so next instruction
                    ; will not be executed in
                    ; this case
ret 


; string_length function
; computes length of null terminated string
; takes address of string begining as arg (rdi)
; length returned in rax
string_length:
    xor rcx, rcx    ; store string length in counter
                    ; function can use any register, but register
                    ; may not initially be zero, so zero it
                    ; rcx = 0
    ; scan character
    ; seek next character
    ; loop or exit
    .loop:
        cmp byte [rdi + rcx], 0 ; compare current char with null
                                ; if no difference than
                                ; ZF is set (ZF = 1)
        je .end                 ; if null character, goto end
        inc rcx                 ; count not null character
        jmp .loop               ; loop
    .end:
        mov rax, rcx            ; store counted chars in rax
                                ; because of return functions
                                ; convention
ret

; Accepts a pointer to a null-terminated
; string and prints it to stdout.
print_string: 
    call string_length  ; compute string length, result in rax
    mov rdx, rax        ; write syscall arg length bytes
    mov rax, 1          ; write syscall number
    mov rsi, rdi        ; write syscall arg string start address
    mov rdi, 1          ; write syscall arg filedescriptor to stdout
    syscall
ret


; function print_char
; Accepts a character code address
; as its first argument (rdi)
; and prints char at this address to stdout.
print_char_at:
    mov rax, 1  ; write syscall number
    mov rsi, rdi; character to print address in rdi
    mov rdi, 1  ; stdout filedescriptor
    mov rdx, 1  ; print 1 char
    syscall
ret

print_char_at_2:
    push rdi
    mov rax, 1  ; write syscall number
    mov rdi, 1  ; stdout filedescriptor
    mov rsi, [rsp]; character to print address on stack top
    mov rdx, 1  ; print 1 char
    syscall
    pop rdi     ; leave stack in oryginal form
ret

; function print_char
; Accepts a character code directly
; as its first argument (rdi)
; and prints it to stdout. (syscall # 1)
print_char:
    push rdi
    mov rax, 1  ; write syscall number
    mov rdi, 1  ; stdout filedescriptor
    mov rsi, rsp; character to print address 
                ; is address of top of the stack
    mov rdx, 1  ; print 1 char
    syscall
    pop rdi     ; leave stack in oryginal form
ret ; jump to address at stack


; Prints a character with code 0xA
print_newline:
    mov rdi, 0xA
    call print_char
ret


; Outputs an unsigned 8-byte integer in decimal format.
; ascii code - char:
; ascii encoding for digits:
;
; |Ascii code: |48|49|50|51|52|53|54|55|56|57|
; |------------|--|--|--|--|--|--|--|--|--|--|
; |Display:    |0 |1 |2 |3 |4 |5 |6 |7 |8 |9 |
; 
digit_to_ascii:
    mov rax, 48
    add rax, rdi
ret

print_uint:
    ; push null terminator on the stack
    ; push digits mapped to ascii on the stack
    ;   but push needs 8 byte and char is 1 byte
    ;   so stack size must be allocated and accessed
    ;   by mov, otherwise string will contain nulls 
    ; print stack
    ; clean stack

    ; stack allocation: number is 8 byte
    ; 1 byte max number is 255 -> needs 3 chars
    ; so max 8 byte number needs at most 24 decimal chars
    ; and should be also room for null.

    .init:
    mov rax, rdi    ; copy number to print
    mov r8, 10      ; is base 10
    mov r9, rsp     ; save current stack pointer
                    ; syscall may change rcx, r11!!!
    mov r10, rsp    ; r10 will point to last char 
                    ; address on the stack, because
                    ; stack grows downwards on x86,
                    ; next byte decrements address
    sub rsp, 3*8    ; allocate stack, moving downwards 3B
    dec r10         ; byte will be pushed on stack so decrement
    mov byte[r10], `\0` ; bottom of the stack should 
                    ; be tarminated with null char
                    ; something like push_byte `\0`
    
    .loop:
    xor rdx, rdx    ; rdx = 0
    div r8          ; unsigned integer divides rax by r8
                    ; storing result in rax (quotient)
                    ; and remainder in rdx
    add dl, 48      ; add 48 to lowest 8 bits of rdx = dl
                    ; and store result in dl,
                    ; this is last digit in ascii encoding
    dec r10         ; byte will be pushed on stack so decrement
    mov byte[r10], dl   ; save digit on stack
    test rax, rax   ; check if rest of number is 0
    jnz .loop       ; if rax not equal 0 (flag ZF not set) 
                    ; than loop

    .print:
    mov rdi, r10    ; set string address
    call print_string ; print the stack until null terminator

    .clean:
    mov rsp, r9    ; leave stack in oryginal form
ret


print_uint_as_64B_chars:
    ; push null terminator on the stack
    ; push digits mapped to ascii on the stack
    ;   but push needs 8 byte and char is 1 byte
    ;   so stack size must be allocated and accessed
    ;   by mov, otherwise string will contain nulls 
    ; print stack
    ; clean stack

    .init:
    mov rax, rdi    ; copy number to print
    mov r8, 10      ; we will print in base 10
    mov r9, rsp     ; save current stack pointer
                    ; syscall may change rcx!!!
    push `\0`       ; bottom of the stack should 
                    ; be tarminated with null char
    xor r10, 0      ; r10 will count chars
    
    .loop:
    xor rdx, rdx    ; rdx = 0
    div r8          ; unsigned integer divides rax by r8
                    ; storing result in rax (quotient)
                    ; and remainder in rdx
    add rdx, 48      ; add 48 to lowest 8 bits of rdx = dl
                    ; and store result in dl,
                    ; this is last digit in ascii encoding
    push rdx        ; save digit on stack
    inc  r10        ; digit saved, so increment digit counter
    test rax, rax   ; check if rest of number is 0
    jnz .loop       ; if rax not equal 0 (flag ZF not set) 
                    ; than loop

    .print:
    sal r10, 3          ; multiply by 8 (2^3)
    mov rdx, r10        ; write syscall arg length bytes
    mov rax, 1          ; write syscall number
    mov rsi, rsp        ; write syscall arg string start address
    mov rdi, 1          ; write syscall arg filedescriptor to stdout
    syscall

    .clean:
    mov rsp, r9    ; leave stack in oryginal form
ret


; Output a signed 8-byte integer in decimal format.
print_int:
    ; check sign
    ; print unsigned and return
    ; print sign
    ; negate number
    ; print negated number and return
    test rdi, rdi   ; => tests rdi
                    ; if rdi = 0 => ZF (zero flag) set
                    ; if rdi >= 0 => SF (sign flag) set
                    ; parity ...
    jns print_uint ; jump to print unsigned and return
    push rdi        ; save rdi
    mov rdi, '-'    ; - character to print
    call print_char ; print -
    pop rdi         ; reload rdi
    neg rdi         ; aritmetic negation of rdi, result in rdi
    jmp print_uint  ; print number and return there


; Accepts a null-terminated string and tries to parse 
; an unsigned number from its start.
; Returns the number parsed in rax, 
; its characters count in rdx.
parse_uint:
    ; scan string
    ; if digit -> accumulate
    ; if other -> end

    xor rax, rax    ; current parsed uint = 0, 
                    ; rax is used by mul
    xor rdx, rdx    ; rdx is implicitly used by mul = 0
    xor rcx, rcx    ; current parsed chars count
                    ; chars before \0 or illegal
                    ; beware, syscalls can change rcx
    xor r9, r9      ; current char and char as number
    ; rdi           ; current char address
    push r12        ; save r12 (callee saved register)
    mov r12, 10     ; decimal base

    .read_digit:
        mov r9b, byte[rdi]  ; take digit (1B)

        .is_digit_proper:
            ; xor r9, r9    ; 
            test r9b, r9b   ; 
            jz .end         ; end if null char 
            cmp r9b, '0'    ; 
            jb .end         ; end if comparison below
            cmp r9b, '9'    ; 
            ja .end         ; end if comparison above

        .count_digit:
            inc rcx         ; increment valid char count

        .digit_to_number:
            sub r9b, '0'     ; have number in r9d

        .update_parsed:
            mul r12         ; rax = current * base 
                            ; shift 1 to left in base10
            add rax, r9     ; add digit


        .update_char_pointer:
            inc rdi         ; point to next char


    jmp .read_digit ; parse next char 

    .end:
        ; rax           ; function output in rax (parsed uint)
        mov rdx, rcx    ; function output in rdx (parsed digits #)
    
    pop r12        ; restore r12 (callee saved register)

ret


; Accepts a null-terminated string and tries 
; to parse a signed number from its start.
; Returns the number parsed in rax; 
; its characters count in rdx (including sign if any).
; No spaces between sign and digits are allowed.
parse_int:
    ; parse sign
    ; jump to parse_uint
    ; do sign
    ;mov al, byte [rdi]
    ;cmp al, '-'
    cmp byte[rdi], '-'  ; compare first char with -
    je .is_signed       ; if '-' jump to signed computation
    jmp parse_uint      ; not starting with '-' just parse uint

    .is_signed:
        inc rdi             ; skip sign
        call parse_uint     ; parse rest of string

    .check_if_valid:
        test rdx, rdx       ; check if parsed 0 chars
        jz .parsed_nothing  ; if so, return 0 parsed chars
        neg rax             ; negate uint
        inc rdx             ; else increment rdx
    ret  

    .parsed_nothing:
        ;xor rax, rax
ret


; Accepts two pointers to strings and compares them.
; Returns 1 if they are equal, otherwise 0.
; First string in rdi
; Second string in rsi
string_equals:
    mov al, byte[rdi]
    cmp al, byte[rsi]   ; are chars equals?
    jne .not_equal      ; not equal
    test al, al         ; are chars null terminator?
    je .terminator_equals
    inc rdi
    inc rsi
    jmp string_equals   ; check next chars

    .not_equal:
    mov rax, 0
    ret

    .terminator_equals:
    mov rax, 1
    ret


; Accepts a pointer to a string,
; a pointer to a buffer,
; and buffer’s length.
; Copies string to the destination. 
; The destination address is returned 
; if the string fits the buffer;
; otherwise zero is returned.
string_copy:
    ; rdi = source
    ; rsi = dest
    ; rdx = dest length 

    .buffer_is_enough:
        push rdi
        push rsi
        push rdx
        call string_length      ; what is length of source str?
        pop rdx
        pop rsi
        pop rdi
        cmp rax, rdx            ; rax = length of source
                                ; rdx = length of destination 
                                ; after rdx will be not neccessary
        ja .buffer_not_enough   ; length source > length destination
                                ; => buffer is too small

    mov r9, rsi                 ; save rsi

    .copy_char:
        mov dl, byte[rdi]       ; copy source byte to dl
        mov byte[rsi], dl       ; write destination byte from dl
        test dl, dl             ; is it null character?
        je .copying_finished    ; char is null terminator, finish it
        inc rdi                 ; seek to next source char
        inc rsi                 ; seek to next destination char
        jmp .copy_char          ; loop

    .buffer_not_enough:
        xor rax, rax            ; return 0, fail
ret
    
    .copying_finished
        mov rax, r9             ; reload rsi to rax
ret                             ; return rsi, success


; Read one character from stdin and return it. 
; If the end of input stream occurs, return 0.
read_char:
    xor rax, rax    ; read syscall number = 0
    xor rdi, rdi    ; filedescriptor => stdin = 0
    push 0          ; make room for char to read
    mov rsi, rsp    ; buffer address
    mov rdx, 1      ; buffer size/how many chars to read
    syscall
    pop rax
ret


; Accepts a buffer address and size as arguments. 
; Reads next word from stdin
; (skipping whitespaces 7 into buffer). 
; Stops and returns 0 if word is too big for the
; buffer specified; 
; otherwise returns a buffer address.
; This function should null-terminate the accepted string.
; We consider spaces, tabulation, and line breaks as whitespace characters. 
; Their codes are 0x20, 0x9, and 0x10, respectively.
read_word:
    ; rdi       ; buffer address
    ; rsi       ; current buffer size
    mov r9, rdi ; current char place address in buffer 

    .discard_white_space:
        push rdi
        push rsi
        push r9
        call read_char  ; char in rax (al)
        pop r9
        pop rsi
        pop rdi

        cmp al, ' '             ; is it space?
        je .discard_white_space ; it is, read next char
        cmp al, `\t`            ; is is tab?
        je .discard_white_space ; it is, read next char
        cmp al, `\r`            ; is is RF?
        je .discard_white_space ; it is, read next char
        cmp al, `\n`            ; is is LF?
        je .discard_white_space ; it is, read next char

    
    .buffer_space_is_enough:
        test rsi, rsi           ; is current size 0 ?
        jz .error


    .add_to_buffer:
        mov byte[r9], al        ; copy char to buffer
        inc r9                  ; point next char place in buffer
        dec rsi                 ; decrement available buffer size


    .finish_at_null_char:       ; if last char is null
                                ; than all is done
        test al, al             ; is it \0 ?
        jz .finish              ; it is, finish
    

    .finish_at_white_space:     ; if last char is space, than it
                                ; is end of the word, need to change
                                ; it to null
        cmp al, ' '             ; is it space?
        je .finish_at_word_end  ; it is, read next char
        cmp al, `\t`            ; is is tab?
        je .finish_at_word_end  ; it is, read next char
        cmp al, `\r`            ; is is RF?
        je .finish_at_word_end  ; it is, read next char
        cmp al, `\n`            ; is is LF?
        je .finish_at_word_end  ; it is, read next char


    .read_next_char:
        push rdi
        push rsi
        push r9
        call read_char  ; char in rax (al)
        pop r9
        pop rsi
        pop rdi
        
    jmp .buffer_space_is_enough


    .finish:            ; already null terminated, so
        mov rax, rdi    ; return address of oryginal
                        ; buffer
ret

    .finish_at_word_end:
        mov byte[r9], 0 ; override white char with \0
        mov rax, rdi    ; return address of oryginal
                        ; buffer
ret

    .error:
        xor rax, rax    ; return 0, failure
ret
