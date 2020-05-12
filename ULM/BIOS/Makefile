#-------------------------------------------------------------------------------
# Makefile for Athena operating system.
#  Unified loading method. 
#  Loading from under the BIOS firmware.

# Directories
export SRC=./src
export BIN=./bin
export INCLUDE=./include

# Compilers
export ASM=nasm
export ASM_FLAGS=-i $(INCLUDE)/
export DISASM=ndisasm
export LINK=ld
export LINK_ARGV=-m elf_i386 -T UEFI.ld

.PHONY: build clean all re-make


build: $(BIN)/MBS.bin $(BIN)/UEFI.elf

clean:
	rm -f *.disasm
	rm -f $(BIN)/*.bin
	rm -f $(BIN)/*.o
	rm -f $(BIN)/*.elf

all: build MBS.disasm

re-make: clean build


# Master Boot Sector
$(BIN)/MBS.bin: $(SRC)/MBS.asm
	$(ASM) -f bin -o $(BIN)/MBS.bin $(SRC)/MBS.asm
	"./check MBS.bin.sh"

MBS.disasm: $(BIN)/MBS.bin
	$(DISASM) -o 0x7c00 $(BIN)/MBS.bin > MBS.disasm


# UEFI imitation
$(BIN)/UEFI.elf: $(BIN)/entry.o
	$(LINK) $(LINK_ARGV) -o $(BIN)/UEFI.elf $+
	"./check UEFI.elf.sh"

$(BIN)/entry.o: $(SRC)/entry.asm
	$(ASM) $(ASM_FLAGS) -f elf -o $(BIN)/entry.o $(SRC)/entry.asm
