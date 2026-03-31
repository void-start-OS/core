; src/kernel/idt_load.asm
[BITS 32]

global idt_load
idt_load:
    lidt [esp + 4]
    ret
