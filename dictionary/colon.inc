
%ifndef DICT_MACROS
%define DICT_MACROS

; macros for creating static linked list
; to add ifdef ifndef to include only onece
; it is not neccessary now as redefinition
; would not do anything bad...

; define key label of last (first added) element
; last element (first added) should point to address 0
%define lw 0   

; define generator of list elements, 
; named colon taking 2 arguments:
;   %1: key desctiption - string
;   %2: key - label
%macro colon 2
%%lw:           ; define macro local label
                ; (unique to macro invocation)
    dq lw       ; address of next element (as label)
    db %1, 0    ; key description (%1) (string), null term
    xt_ %+ %2:  ; xt_ concatenced (%+) with key label (%2)

; redefine key label to last used key local label:
; lw will contain last added element (list head)
%define lw %%lw
%endmacro

%endif