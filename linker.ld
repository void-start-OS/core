/* Void-Start-OS kernel linker script */

ENTRY(kernel_main)

SECTIONS
{
    /* カーネルのリンクアドレス = 物理アドレス 0x00010000 */
    . = 0x00010000;

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
