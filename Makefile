#-------------------------------------------------------------------------------
# Makefile for Athena operating system.

# Special instruction NOP - "Do nothing"
export nop=echo "ђ" > /dev/null
# Special instruction ERR - "Raise error"
export error=cat / 2>/dev/null

# Project vars
export PROJECT_DIR=$$(pwd)
export VM_DISK=$(PROJECT_DIR)/VirtualMachine/Athena.raw

# Compilers
export ASM=nasm
export DISASM=ndisasm

.PHONY: build clean all re-make
.PHONY: rawdisk install
.PHONY: ULM


build: ULM

clean:
	cd ./ULM && $(MAKE) clean

all:
	cd ./ULM && $(MAKE) all
	$(MAKE) install

re-make: clean build

rawdisk:
	rm -f $(VM_DISK)
	qemu-img create -f raw $(VM_DISK) 64M

install:
	dd if=./ULM/BIOS/bin/MBS.bin of=$(VM_DISK) bs=512 count=1 conv=notrunc
	dd if=./ULM/BIOS/bin/UEFI.elf of=$(VM_DISK) bs=512 count=128 seek=66 conv=notrunc

ULM:
	cd ./ULM && $(MAKE)
