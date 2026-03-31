// src/kernel/idt.cpp
// IDT 初期化と CPU 例外ハンドラ登録

#include <stdint.h>

struct IDTEntry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t  zero;
    uint8_t  type_attr;
    uint16_t offset_high;
} __attribute__((packed));

struct IDTPointer {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

static IDTEntry idt[256];
static IDTPointer idt_ptr;

extern "C" void idt_load(uint32_t);

// ISR ハンドラ（アセンブリ側で定義）
extern "C" void isr0_handler();   // Divide by zero
extern "C" void isr13_handler();  // General protection fault
extern "C" void isr14_handler();  // Page fault

static void set_idt_gate(int n, uint32_t handler) {
    idt[n].offset_low  = handler & 0xFFFF;
    idt[n].selector    = 0x08;        // CODE_SEL = 0x08 (GDT の 2番目エントリ)
    idt[n].zero        = 0;
    idt[n].type_attr   = 0x8E;        // present=1, DPL=0, 32bit interrupt gate
    idt[n].offset_high = (handler >> 16) & 0xFFFF;
}

extern "C" void idt_init() {
    // IDT ポインタ設定
    idt_ptr.limit = sizeof(idt) - 1;
    idt_ptr.base  = (uint32_t)&idt;

    // いくつかの CPU 例外を登録
    set_idt_gate(0,  (uint32_t)isr0_handler);
    set_idt_gate(13, (uint32_t)isr13_handler);
    set_idt_gate(14, (uint32_t)isr14_handler);

    // lidt
    idt_load((uint32_t)&idt_ptr);
}
