/* linker.ld - Void-Start-OS kernel linker script */

ENTRY(kernel_main)

SECTIONS
{
    /* カーネルのリンクアドレス（物理アドレスと一致させる） */
    . = 0x00100000;

    .text :
    {
        *(.text*)
    }

    .rodata :
    {
        *(.rodata*)
    }

    .data :
    {
        *(.data*)
    }

    .bss :
    {
        *(.bss*)
        *(COMMON)
    }
}
