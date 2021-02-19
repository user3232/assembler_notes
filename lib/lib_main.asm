
section .data

LF: 
    db `\n`
a:  
    db  'a'
a_num:
    db 65
nullTermStr:
    db 'Yo yo man, ye ye ye \n \\0 '
    db 'continue here ', 0
shouldntBeHere:
    db 'should not be here unless not terminated'
decDisplay:
    db 'The number is: '
bannerParsingUInt:
    db `Parsing uint 123457:\n`, 0
uintToParse:
    db '123457', 0
bannerParsingInt:
    db `Parsing int -123k457:\n`, 0
intToParse:
    db '-123k457', 0

string1:
    db 'lalal al', 0
string2:
    db 'lalal al', 0
string3:
    db 'lalal', 0
banner_string_equals_1:
    db `Strings:\n\tlalal al\n\tlalal al\nare equal: `, 0
banner_string_equals_2:
    db `Strings:\n\tlalal al\n\tlalal\nare equal: `, 0

banner_string_copy_1:
    db `String:\n\tlalal\nCopied to address: `, 0
banner_string_copy_2:
    db `At this address there is string:\n`, 0

banner_enter_char:
    db `Please enter some char: `, 0
banner_enetred_char:
    db `\nYou entered: `, 0

section .text
global _start

%include "lib.inc"

_start:
    mov rdi, a
    call print_char_at

    mov rdi, LF
    call print_char_at_2

    mov rdi, [a]
    call print_char

    mov rdi, 65
    call print_char

    mov rdi, `\n`
    call print_char

    mov rdi, nullTermStr
    call print_string

    call print_newline

    mov rdi, decDisplay
    call print_string

    mov rdi, 31415 ;220; 31415
    call print_uint_as_64B_chars

    call print_newline

    mov rdi, decDisplay
    call print_string

    mov rdi, 31415 ;220; 31415
    call print_uint

    call print_newline

    mov rdi, bannerParsingUInt
    call print_string
    mov rdi, uintToParse
    call parse_uint
    mov rdi, rax
    call print_uint
    call print_newline


    mov rdi, bannerParsingInt
    call print_string
    mov rdi, intToParse
    call parse_int
    mov rdi, rax
    call print_int
    call print_newline

    mov rdi, -15
    call print_int
    call print_newline

    mov rdi, banner_string_equals_1
    call print_string
    mov rdi, string1
    mov rsi, string2
    call string_equals
    mov rdi, rax
    call print_uint
    call print_newline

    mov rdi, banner_string_equals_2
    call print_string
    mov rdi, string1
    mov rsi, string3
    call string_equals
    mov rdi, rax
    call print_uint
    call print_newline


    mov rdi, banner_string_copy_1
    call print_string
    mov rdi, string3
    mov rsi, string2
    mov rdx, 7
    call string_copy
    mov rdi, rax
    call print_uint
    call print_newline
    mov rdi, banner_string_copy_2
    call print_string
    mov rdi, string2
    call print_string
    call print_newline

    mov rdi, banner_enter_char
    call print_string
    call read_char
    push rax
    mov rdi, banner_enetred_char
    call print_string
    pop rax
    mov rdi, rax
    call print_char
    call print_newline

    

    xor rdi, rdi
    call exit