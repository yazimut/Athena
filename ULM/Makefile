#-------------------------------------------------------------------------------
# Makefile for Athena operating system.
#  Unified loading method.

.PHONY: build clean all re-make
.PHONY: BIOS


build: BIOS

clean:
	cd ./BIOS && $(MAKE) clean

all:
	cd ./BIOS && $(MAKE) all

re-make: clean build

BIOS:
	cd ./BIOS && $(MAKE)
