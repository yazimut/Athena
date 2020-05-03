#-------------------------------------------------------------------------------
# Makefile for Athena operating system.
#  Unified loading method for loading OS from under BIOS firmware.

# Compilers
export ASM=nasm
export DISASM=ndisasm

.PHONY: build clean all re-make


build: MBR.bin VBR.bin

clean:
	rm -f *.bin
	rm -f *.disasm

all: build MBR.disasm VBR.disasm

re-make: clean build

MBR.bin: MBR.asm
	$(ASM) MBR.asm -o MBR.bin -f bin

MBR.disasm: MBR.bin
	$(DISASM) MBR.bin -o 0x7e00 > MBR.disasm

VBR.bin: VBR.asm
	$(ASM) VBR.asm -o VBR.bin -f bin

VBR.disasm: VBR.bin
	$(DISASM) VBR.bin -o 0x0000 > VBR.disasm
