; src/kernel/idt_load.asm
; lidt ラッパ

[BITS 32]

global idt_load

idt_load:
    ; 引数: [esp+4] = &IDTPointer
    lidt [esp + 4]
    ret
