; src/kernel/isr.asm
[BITS 32]

extern exception_handler

%macro ISR_NOERR 1
global isr%1_handler
isr%1_handler:
    push dword 0      ; ダミーのエラーコード
    push dword %1     ; 例外番号
    jmp isr_common
%endmacro

%macro ISR_ERR 1
global isr%1_handler
isr%1_handler:
    push dword %1     ; 例外番号
    jmp isr_common
%endmacro

isr_common:
    call exception_handler
    add esp, 8
    iret

ISR_NOERR 0   ; Divide by zero
ISR_ERR   13  ; General protection fault
ISR_ERR   14  ; Page fault
