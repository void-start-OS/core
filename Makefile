# Makefile - Void-Start-OS core

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

ASMFLAGS    := -f bin
CFLAGS      := -m32 -ffreestanding -fno-exceptions -fno-rtti -nostdlib -nostartfiles -Wall -Wextra -O2
LDFLAGS     := -m elf_i386 -T linker.ld -nostdlib

.PHONY: all run clean

all: $(IMAGE)

$(BUILD_DIR):
    mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(BOOT_DIR)/boot.asm | $(BUILD_DIR)
    $(ASM) $(ASMFLAGS) $< -o $@

$(KERNEL_ELF): $(KERNEL_DIR)/kernel.cpp linker.ld | $(BUILD_DIR)
    $(CC) $(CFLAGS) -c $(KERNEL_DIR)/kernel.cpp -o $(BUILD_DIR)/kernel.o
    $(LD) $(LDFLAGS) -o $@ $(BUILD_DIR)/kernel.o

$(KERNEL_BIN): $(KERNEL_ELF)
    $(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)

$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
    cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)

run: $(IMAGE)
    $(QEMU) -drive format=raw,file=$(IMAGE)

clean:
    rm -rf $(BUILD_DIR)
