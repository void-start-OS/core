; src/boot/a20.asm
; Fast A20 Gate enable (port 0x92)

[BITS 16]

enable_a20_fast:
    in   al, 0x92
    or   al, 00000010b      ; A20 enable bit
    out  0x92, al
    ret
