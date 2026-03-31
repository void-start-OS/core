// src/kernel/exception.cpp
// CPU 例外発生時の簡易ハンドラ

#include <stdint.h>

static volatile uint16_t* vga = (uint16_t*)0xB8000;

extern "C" void exception_handler(uint32_t int_no, uint32_t err_code)
{
    const char* msg = "CPU Exception!";
    uint8_t color = 0x4F; // 赤背景・白文字

    // 1行目にメッセージ
    for (int i = 0; msg[i] != '\0'; ++i)
    {
        vga[i] = (uint16_t)msg[i] | ((uint16_t)color << 8);
    }

    // 2行目に例外番号とエラーコード（超簡易表示）
    const char* label = "INT=";
    int base = 80; // 2行目先頭
    for (int i = 0; label[i] != '\0'; ++i)
    {
        vga[base + i] = (uint16_t)label[i] | ((uint16_t)color << 8);
    }

    auto put_hex = [&](int pos, uint32_t val) {
        for (int i = 0; i < 8; ++i)
        {
            uint8_t nibble = (val >> ((7 - i) * 4)) & 0xF;
            char c = (nibble < 10) ? ('0' + nibble) : ('A' + (nibble - 10));
            vga[pos + i] = (uint16_t)c | ((uint16_t)color << 8);
        }
    };

    put_hex(base + 4, int_no);
    const char* label2 = " ERR=";
    int pos2 = base + 4 + 8;
    for (int i = 0; label2[i] != '\0'; ++i)
    {
        vga[pos2 + i] = (uint16_t)label2[i] | ((uint16_t)color << 8);
    }
    put_hex(pos2 + 5, err_code);

    while (1)
    {
        asm volatile ("hlt");
    }
}
