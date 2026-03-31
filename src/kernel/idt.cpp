// src/kernel/idt.cpp
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

extern "C" void isr0_handler();  // Divide by zero
extern "C" void isr13_handler(); // General protection fault
extern "C" void isr14_handler(); // Page fault

static void set_idt_gate(int n, uint32_t handler) {
    idt[n].offset_low  = handler & 0xFFFF;
    idt[n].selector    = 0x08;        // CODE_SEL = 0x08
    idt[n].zero        = 0;
    idt[n].type_attr   = 0x8E;        // present, ring0, 32bit interrupt gate
    idt[n].offset_high = (handler >> 16) & 0xFFFF;
}

extern "C" void idt_init() {
    idt_ptr.limit = sizeof(idt) - 1;
    idt_ptr.base  = (uint32_t)&idt;

    set_idt_gate(0,  (uint32_t)isr0_handler);
    set_idt_gate(13, (uint32_t)isr13_handler);
    set_idt_gate(14, (uint32_t)isr14_handler);

    idt_load((uint32_t)&idt_ptr);
}
