; src/kernel/isr.asm
; CPU 例外 ISR スタブ
; C の exception_handler(uint32_t int_no, uint32_t err_code) を呼び出す

[BITS 32]

extern exception_handler

; 例外番号 n、エラーコードなし
%macro ISR_NOERR 1
global isr%1_handler
isr%1_handler:
    push dword 0          ; err_code = 0
    push dword %1         ; int_no
    call exception_handler
    add esp, 8            ; int_no, err_code を片付ける
    iret
%endmacro

; 例外番号 n、エラーコードあり（CPU が err_code をすでに push 済み）
%macro ISR_ERR 1
global isr%1_handler
isr%1_handler:
    push dword %1         ; int_no
    call exception_handler
    add esp, 4            ; int_no だけ片付ける（err_code は CPU が push したもの）
    iret
%endmacro

ISR_NOERR 0    ; Divide by zero
ISR_ERR   13   ; General protection fault
ISR_ERR   14   ; Page fault
