#-------------------------------------------------------------------------------
# Makefile for Athena operating system.
#  Unified loading method. 
#  Loading from under the BIOS firmware.

# Directories
export SRC=./src
export BIN=./bin
export INC=./include

# Compilers
export ASM=nasm
export ASM_FLAGS=-i $(INC)/ -f elf
export DISASM=ndisasm
export LINK=ld
export LINK_ARGV=-m elf_i386

.PHONY: build clean all re-make


build: $(BIN)/MBS.bin $(BIN)/UEFI.elf

clean:
	rm -f *.disasm
	rm -f $(BIN)/*.bin
	rm -f $(BIN)/*.o
	rm -f $(BIN)/*.elf
	rm -f $(BIN)/*.slib

all: build MBS.disasm

re-make: clean build


# Master Boot Sector
$(BIN)/MBS.bin: $(SRC)/MBS.asm
	$(ASM) -f bin -o $(BIN)/MBS.bin $(SRC)/MBS.asm
	"./check MBS.bin.sh"

MBS.disasm: $(BIN)/MBS.bin
	$(DISASM) -o 0x7c00 $(BIN)/MBS.bin > MBS.disasm


# UEFI imitation
$(BIN)/UEFI.elf: $(BIN)/entry.o $(BIN)/pmode.entry.o $(BIN)/interrupt.slib
	$(LINK) $(LINK_ARGV) -T UEFI.ld -o $(BIN)/UEFI.elf $^
	"./check UEFI.elf.sh"

$(BIN)/entry.o: $(SRC)/entry.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/entry.o $(SRC)/entry.asm

$(BIN)/pmode.entry.o: $(SRC)/pmode.entry.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/pmode.entry.o $(SRC)/pmode.entry.asm


# interrupt.slib
$(BIN)/interrupt.slib: $(BIN)/interrupt.o $(BIN)/PIC.o $(BIN)/APIC.o "$(BIN)/ISR\ Stub.o" "$(BIN)/ISR\ 32.o"
	$(LINK) $(LINK_ARGV) -r -o $(BIN)/interrupt.slib $^

$(BIN)/interrupt.o: $(SRC)/interrupt.asm $(INC)/interrupt.inc.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/interrupt.o $(SRC)/interrupt.asm

$(BIN)/PIC.o: $(SRC)/PIC.asm $(INC)/PIC.inc.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/PIC.o $(SRC)/PIC.asm

$(BIN)/APIC.o: $(SRC)/APIC.asm $(INC)/APIC.inc.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/APIC.o $(SRC)/APIC.asm

"$(BIN)/ISR\ Stub.o": $(SRC)/Interrupts/ISR\ Stub.asm $(INC)/interrupt.inc.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/ISR\ Stub.o $(SRC)/Interrupts/ISR\ Stub.asm

"$(BIN)/ISR\ 32.o": $(SRC)/Interrupts/ISR\ 32.asm $(INC)/interrupt.inc.asm
	$(ASM) $(ASM_FLAGS) -o $(BIN)/ISR\ 32.o $(SRC)/Interrupts/ISR\ 32.asm
