%ifndef DICT_INSTANCE
%define DICT_INSTANCE

; static linked list instantiation
; this file should be included only
; once, because repeating laybels
; will cause errors!!!

colon "hey", hey
        db "hoho",0

colon "test", test
        db "hihi", 0

colon "tost", tost
        db "haha", 0


; Preprocessed file results in a list.
; Added element makes list head!!! -> head moves ;-)
;
;; ..@1.lw: 
;;     dq 0                ; 64bit pointer to next element
;;                         ; last element points 0
;;     db "hey", 0         ; key = null terminated string
;;     xt_hey:             ; key leybel
;;         db "hoho",0     ; data = null terminated string
;; 
;; ..@2.lw: 
;;     dq ..@1.lw          
;;     db "test", 0      
;;     xt_test:            
;;         db "hihi", 0 
;; 
;; ..@3.lw:                ; list head !!!!
;;     dq ..@2.lw          ; 64bit pointer to next element (8b)
;;     db "tost", 0        ; key = null terminated string
;;     xt_tost:            ; key leybel
;;         db "haha", 0    ; data = null terminated string

%endif