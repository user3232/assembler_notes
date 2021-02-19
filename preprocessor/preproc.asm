; To see preprocessing output 
;   nasm -E preproc.asm
; To see preprocessing output in file preproc_preproc.asm:
;   nasm -E preproc.asm -o preproc_preproc.asm
; To define symbol externaly (definitions inside 
; file will verride this):
;   nasm -E preproc.asm -D cat_count=42


section .data
;***************************
; Simple
;***************************
; Define named constant:

%define cat_count 42
%define foo(x)   1+x 
%define foo(x,y) 1+x*y

my_constant: 
    db cat_count, foo(1), foo(3,4)


simple_macro_arguments:
%define xyzzy(ex,str) ex, str 
    db xyzzy(3, 'yoyo'), `\0` 



;***************************
; Parameters
;***************************
; To define macro with arguments
; %macro <name> <nr_of_args>
; To instantiate macro
; <macro_name> <arg_1> <, arg_2> <, arg_3> ...

%macro test 3
dq %1
dq %2
dq %3
%endmacro
test_data: test 666, 555, 444


section .text



;***************************
; Conditionals
;***************************
%define test_value 5    ; define constant
%define flag            ; define flag

%if test_value == 10    ; test constant with constant
    mov rax, 100
%elif test_value == 15
    mov rax, 115
%else
    ; condition on single line macro
    %ifdef flag         ; do this if macro macro defined
        %define flag
        mov rax, rbx
    %else               ; do this if macro not defined
        mov rax, rcx
    %endif
%endif




%define i 1
%define d i * 3
%xdefine xd i * 3
%assign a i * 3
mov rax, d
mov rax, xd
mov rax, a
; let's redefine i
%define i 100
mov rax, d
mov rax, xd
mov rax, a