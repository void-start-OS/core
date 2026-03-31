# Void-Start-OS - Core Makefile

TARGET      := void-start-os
BUILD_DIR   := build
SRC_DIR     := src
BOOT_DIR    := $(SRC_DIR)/boot
KERNEL_DIR  := $(SRC_DIR)/kernel

BOOT_BIN    := $(BUILD_DIR)/boot.bin
KERNEL_ELF  := $(BUILD_DIR)/kernel.elf
KERNEL_BIN  := $(BUILD_DIR)/kernel.bin
IMAGE       := $(BUILD_DIR)/$(TARGET).img

ASM         := nasm
CC          := g++
LD          := ld
OBJCOPY     := objcopy
QEMU        := qemu-system-i386

ASMFLAGS_BOOT  := -f bin
ASMFLAGS_ELF32 := -f elf32
CFLAGS      := -m32 -ffreestanding -fno-exceptions -fno-rtti -nostdlib -nostartfiles -Wall -Wextra -O2
LDFLAGS     := -m elf_i386 -T linker.ld -nostdlib

KERNEL_OBJS := \
    $(BUILD_DIR)/kernel.o \
    $(BUILD_DIR)/idt.o \
    $(BUILD_DIR)/exception.o \
    $(BUILD_DIR)/isr.o \
    $(BUILD_DIR)/idt_load.o

.PHONY: all run clean

all: $(IMAGE)

$(BUILD_DIR):
    mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(BOOT_DIR)/boot.asm $(BOOT_DIR)/a20.asm | $(BUILD_DIR)
    $(ASM) $(ASMFLAGS_BOOT) $< -o $@

$(BUILD_DIR)/kernel.o: $(KERNEL_DIR)/kernel.cpp | $(BUILD_DIR)
    $(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/idt.o: $(KERNEL_DIR)/idt.cpp | $(BUILD_DIR)
    $(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/exception.o: $(KERNEL_DIR)/exception.cpp | $(BUILD_DIR)
    $(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/isr.o: $(KERNEL_DIR)/isr.asm | $(BUILD_DIR)
    $(ASM) $(ASMFLAGS_ELF32) $< -o $@

$(BUILD_DIR)/idt_load.o: $(KERNEL_DIR)/idt_load.asm | $(BUILD_DIR)
    $(ASM) $(ASMFLAGS_ELF32) $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJS) linker.ld | $(BUILD_DIR)
    $(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)

$(KERNEL_BIN): $(KERNEL_ELF)
    $(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)

$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
    cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)

run: $(IMAGE)
    $(QEMU) -drive format=raw,file=$(IMAGE)

clean:
    rm -rf $(BUILD_DIR)
