section .text
global _start
; macros for linked list
%include "colon.inc"
; protected by preprocessor %ifndef
%include "colon.inc"

extern read_word
extern find_record_with_key
extern print_newline
extern print_string
extern print_uint
;extern print_error
extern string_length
extern exit


section .data

; static linked list:
%include "words.inc"
; protected by preprocessor %ifndef
%include "words.inc"

message_banner:
    db `Pleas type key of record\n: \0`
message_key_not_found:
    db `Key not found\0`
message_read_error:
    db `Read error\0`
message_key_found:
    db `Key found, its value is: \0`
message_search_success:
    db `Record address is:\0`
message_list_head_address:
    db `Head of lisht have address: \0`


section .bss

; buffer for user program input
%define buffer_size 255
buffer: 
    resb buffer_size + 1 ; reserve buffer for 255 chars + 1 for \0


section .text



_start:
    .show_banner:
        mov rdi, message_banner
        call print_string
    .read_program_input:
        mov rdi, buffer
        mov rsi, buffer_size
        call read_word  ; strips starting white spaces
                        ; returns null terminated string
                        ; address (= buffer), 
                        ; if error returns 0
        test rax, rax   ; check if reading errors
        jz .read_error  ; inform about error and exit
    
    .search_for_key:
        push rax
        mov rdi, message_list_head_address
        call print_string
        mov rdi, lw
        call print_uint
        call print_newline
        pop rax

        mov rdi, rax    ; ok, we have input string address 
                        ; from program (user)
        mov rsi, lw     ; and address of list head record
        call find_record_with_key  ; 
        
        push rax
        mov rdi, message_search_success
        call print_string
        pop rax

        push rax
        mov rdi, rax
        call print_uint
        call print_newline
        pop rax

        test rax, rax   ; if found rax is not 0
        jz .exit        ; jump if zero 
    
    .print_key_value:
        push rax            ; save record address
        mov rdi, message_key_found 
        call print_string   ; print banner
        pop rax             ; restore found record address
        mov rdi, rax        ; rdi = address of found record
        add rdi, 8          ; rdi = key string address (offset 8B)
        push rdi            ; save rdi key string address
        call string_length  ; rax = length of key string
        pop rdi             ; restore rdi key string address
        add rdi, rax        ; rdi = value string address (offset + length)
        add rdi, 1
        call print_string   ; print record value fild
        call print_newline
    
    .exit:
        call exit
    
    .read_error:
        mov rdi, message_read_error
        call print_string
        call print_newline
        call exit
    

