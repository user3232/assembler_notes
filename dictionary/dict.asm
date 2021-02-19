global find_record_with_key ; this way function 
                            ; can be used by other module
extern string_equals        ; this way function from other
                            ; module can be used here
extern print_string         ; function from lib                        


section .rodata
msg_noword:
    db `Disctionary have not this key!\n\0`
msg_key_found:
    db `Key has been found!\n\0`
msg_hellow:
    db `Hellow from find_record_with_key\n\0`


section .text

; finds first key string in dictionary entries, or not,
; dictionary is empty if dictionary address is 0 !!!!!
; arguments:
;   rdi - address of string to find
;   rsi - address of head of list and first element
;           of entry - pointer to next element
; returns rax with:
;   address of dictionary record if found
;   0 otherwise
find_record_with_key:
    push rdi
    push rsi
    mov rdi, msg_hellow
    call print_string
    pop rsi
    pop rdi
    xor rax, rax            ; initially not found

    .record_exists:
        test rsi, rsi       ; check if record exists
        jz .no_more_records ; no records to check
    .match_key:
        push rdi            ; save
        push rsi            ; save
        add rsi, 8          ; byte offset to record (8 bytes)
                            ; key string fild
        call string_equals  ; external function, compares
                            ; strings, returns in rax:
                            ; address of string if match
                            ; 0 otherwise
        pop rsi             ; resotre
        pop rdi             ; restore
        test rax, rax       ; if found ZF not set
        jnz .found          ; 
    .move_to_next_record:
        mov rsi, [rsi]      ; first fild of record
                            ; is address of next record 
        jmp .record_exists  
    
    .no_more_records:
        mov rdi, msg_noword ; we may inform of failure
        call print_string   ;
        xor rax, rax        ; return 0
ret 
    .found:
        push rsi
        mov rdi, msg_key_found
        call print_string
        pop rax             ; rax <- rsi
                            ; rsi contains address of record
ret