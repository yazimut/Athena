#-------------------------------------------------------------------------------
# Makefile for Athena operating system.

# Special instruction NOP - "Do nothing"
export nop=echo "ђ" > /dev/null
# Special instruction ERR - "Raise error"
export error=cat / 2>/dev/null

# Project vars
export PROJECT_DIR=$$(pwd)
export VM_DISK=$(PROJECT_DIR)/VirtualMachine/Athena.raw

.PHONY: build clean all re-make
.PHONY: rawdisk install


build:
	echo "\e[1;33mNothing to build \e[0m"

clean:
	echo "\e[1;33mNothing to clean \e[0m"

all: build install

re-make: clean build

rawdisk:
	rm -f $(VM_DISK)
	qemu-img create -f raw $(VM_DISK) 64M

install:
	echo "\e[1;33mNothing to install \e[0m"
