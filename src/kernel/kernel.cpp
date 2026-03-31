// src/kernel/kernel.cpp
// Void-Start-OS: C++ kernel entry (freestanding)

#include <stdint.h>

extern "C" void idt_init();

extern "C" void kernel_main()
{
    // まず IDT を初期化して CPU 例外を捕捉できるようにする
    idt_init();

    volatile uint16_t* vga = (uint16_t*)0xB8000;
    const char* msg = "Void-Start-OS: kernel_main() + IDT ready";
    uint8_t color = 0x0F; // 白文字・黒背景

    for (int i = 0; msg[i] != '\0'; ++i)
    {
        vga[i] = (uint16_t)msg[i] | ((uint16_t)color << 8);
    }

    // テスト用：コメントアウトを外すと divide by zero 例外を発生させられる
    // int x = 1 / 0;

    while (true)
    {
        asm volatile ("hlt");
    }
}
