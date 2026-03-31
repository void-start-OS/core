// src/kernel/exception.cpp
#include <stdint.h>

static volatile unsigned short* vga = (unsigned short*)0xB8000;

extern "C" void exception_handler(uint32_t int_no, uint32_t err_code)
{
    const char* msg = "CPU Exception!";
    for (int i = 0; msg[i]; i++)
        vga[i] = msg[i] | (0x4F << 8); // 赤背景・白文字

    vga[80] = 'I' | (0x4F << 8);
    vga[81] = 'D' | (0x4F << 8);
    vga[82] = ':' | (0x4F << 8);
    vga[83] = '0' + (int_no / 10) | (0x4F << 8);
    vga[84] = '0' + (int_no % 10) | (0x4F << 8);

    while (1) asm volatile("hlt");
}
