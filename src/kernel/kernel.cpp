// src/kernel/kernel.cpp
// freestanding C++ カーネルエントリ
// 32bit保護モード、フラットアドレス空間、ページングOFF前提

extern "C" void kernel_main()
{
    // VGAテキストモードのVRAMは物理アドレス 0xB8000
    // 1文字 = [文字][属性] の2バイト
    volatile unsigned short* vga = (unsigned short*)0xB8000;

    const char* msg = "Void-Start-OS: kernel_main() reached (C++ freestanding)";
    unsigned char color = 0x0F; // 白文字・黒背景

    for (int i = 0; msg[i] != '\0'; ++i)
    {
        vga[i] = (unsigned short)msg[i] | ((unsigned short)color << 8);
    }

    // ここで無限ループしておく（まだ割り込みやスケジューラはない）
    while (true)
    {
        asm volatile ("hlt");
    }
}
